module Questionnaires

using Codex
using CSV
using DataFrames
using DataValues
using Dates
using Query

include("personality.jl")

dv_str(s) = DataValue{String}(s)
dv_any(x) = DataValue{Any}(x)

"""
    get_hnd(path::AbstractString)::DataFrame

Get HowNutsAreTheDutch data and select big five, age and more.
"""
function get_hnd(path::AbstractString)::DataFrame
	CSV.File(path, delim=';') |> 
		@query(i, begin
			# Assumes that all neo scores are missing if neo_neurot is 999.
			@where i.neo_neurot != 999
			@select {i.id, i.age, education=i.start_educ, group="civilians",
                N=i.neo_neurot,
				E=i.neo_extraversion, O=i.neo_openness,
				A=i.neo_agreeable, C=i.neo_conscient}
		end) |> DataFrame 
end

"""
    responses(data_dir::String, nato_name::String)::DataFrame

Responses for questionnaire `nato_name` as contained in directory `data_dir`.
Returns a DataFrame with rows `{ id, r...}` where `id` is a long identifier and not the one from the backend.
"""
function responses(data_dir::String, nato_name::String)::DataFrame
    responses_dir = joinpath(data_dir, "responses")
    responses_file = joinpath(responses_dir, "$nato_name.csv")
    responses_data = Codex.TransformExport.read_csv(responses_file, delim=';')
    # To speed up further processing.
    Codex.TransformExport.rm_timing!(responses_data)
    Codex.TransformExport.rm_boring_timestamps!(responses_data)
    Codex.TransformExport.rm_boring_foreign_keys!(responses_data)

    people_file = joinpath(data_dir, "people.csv")
    people_data = Codex.TransformExport.read_csv(people_file, delim=';')

    # Avoiding Query because precompilation takes ages (>1 minutes) for hundreds of rows.
    select!(people_data, :person_id => :backend_id, :first_name => :id)
    rename!(responses_data, Dict(:filled_out_by_id => "backend_id"))
    joined = innerjoin(people_data, responses_data, on = :backend_id)
    select!(joined, Not(:backend_id))
    return joined
end

"""
    dropouts(raw_dir::String)::DataFrame

Returns dropout data where all IDs are in the long identifier format.
"""
function dropouts(raw_dir::String)
    dropouts_file = joinpath(raw_dir, "dropouts.csv")
    dropouts_data = Codex.TransformExport.read_csv(dropouts_file; delim=';')

    id_username_file = joinpath(raw_dir, "id-username.csv")
    id_username_data = Codex.TransformExport.read_csv(id_username_file; delim=',')

    @from d in dropouts_data begin
        @left_outer_join i in id_username_data on dv_str(d.id) equals i.username
        @let fixed_id = get(i.id, String) == String ? d.id : string(get(i.id, String))[7:end]
        @select { id = fixed_id, d.cohort, d.dropout, d.dropout_date, 
            d.dropout_reason, d.dropout_code, d.note }
        @collect DataFrame
    end
end

"""
    responses(data_dir::String, nato_name::String, group::String; measurement=999)::DataFrame

Responses for group `group` and measurement `measurement`, where `group` is one of `graduates`, `operators`, `dropout-medical` or `dropout-non-medical`.
`measurement` is only used to split the 2018 data, for the later datasets it is ignored.
"""
function responses(data_dir::String, nato_name::String, group::String; measurement=999)
    responses_data = responses(data_dir, nato_name) 

    cohort = parse(Int, match(r"[0-9]{4}", data_dir).match)
    dropouts_data = dropouts(Codex.dirparent(data_dir))
    
    if group == "operators"
        df = @from r in responses_data begin
            @select { r... }
            @collect DataFrame
        end
    else # Graduates and dropouts.
        # Not using Query here, because it takes ages on lima.
        df
#        df = @from r in responses_data begin
#            @left_outer_join d in dropouts_data on r.id[7:end] equals d.id
#            @where d.cohort == cohort
#            @where group == "graduates" ? 
#                d.dropout == 0 :
#                #  Must be dropouts, by `group == operators` conditional above.
#                (d.dropout == 1 && (group == "dropout-medical" ?
#                    d.dropout_reason == "B" :
#                    d.dropout_reason != "B"))
#            @select { r..., group = group }
#            @collect DataFrame
#        end
    end

    if cohort == 2018
        if !(measurement in [1, 2])
            throw(AssertionError("Measurement has to be specified for the 2018 data"))
        end
        threshold = Date("2019-01-01")
        # Not using a query since it cannot handle `{ i... }` for some reason.
        function filter_date(x)::Bool
            date = Date(first(split(x, ' ')), DateFormat("dd-mm-yyyy"))
            measurement == 1 ? date < threshold : threshold < date
        end
        return filter([:completed_at] => filter_date, df)
    else # After 2018, the datasets are already split on before and after selection.
        df
    end
end

"""
    first_personality_measurement(raw_dir::String, cohort::Int; group="dropouts", dropout_medical=true)::DataFrame
"""
function first_personality_measurement(raw_dir::String, cohort::Int; group="dropouts", dropout_medical=true)::DataFrame
    # TODO: Move this to a function which returns a dataset after receiving a string.
	file = cohort == 2018 ?
		"$raw_dir/2018-02/responses_kct_bravo_2019-02-21.csv" :
		"$raw_dir/2019-09/responses_kct_bravo_2019-10-10.csv"
	bravo = CSV.File(file, delim=';') |> DataFrame
	file = cohort == 2018 ?
		"$raw_dir/2018-02/people_2019-02-21.csv" :
		"$raw_dir/2019-09/people_2019-10-01.csv"
	people = CSV.File(file, delim=';') |> DataFrame
	file = cohort == 2018 ?
        "$raw_dir/2018-02/responses_kct_lima_2019-02-21.csv" :
        "$raw_dir/2019-09/responses_kct_lima_2019-10-01.csv"
    lima_before = CSV.File(file, delim=';') |> DataFrame
    return lima_before
    lima_before_scores = Codex.Questionnaires.personality2scores(lima_before)
    file = "$raw_dir/dropouts.csv"
    dropouts = CSV.File(file, delim=';') |> DataFrame

	@from b in bravo begin
		@join p in people on b.filled_out_by_id equals DataValue(p.person_id)
		# Wrapping tryparse in DataValue(...) will throw an error.
		@let parse_attempt = typeof(b.v1) == DataValue{Int64} ?
			b.v1 :
			tryparse(Int, get(b.v1, String))
		@let age = typeof(b.v1) == DataValue{Int64} ? 
			b.v1 : 
			isnothing(parse_attempt) ? 
				9999 : 
				DataValue{Int}(parse_attempt)
		@select {id=p.first_name[7:end], age=age, education=b.v5} into a
		@where !isnothing(a.age) && a.age < 100 && a.id != ""
		@join l in lima_before_scores on DataValue{String}(a.id) equals DataValue{String}(l.id)
		@join d in dropouts on DataValue{String}(l.id) equals DataValue{String}(d.id)
		@where (group != "dropouts") ? 
			d.dropout == 0 :
			(d.dropout == 1 && (dropout_medical ? 
				d.dropout_reason == "B" :
				d.dropout_reason != "B"))
		@let detailed_group = (group != "dropouts") ? group : group * (dropout_medical ? "-medical" : "-non-medical")
		@select {a.id, a.age, a.education, group=detailed_group, l.N, l.E, l.O, l.A, l.C}
		@collect DataFrame
	end
end

end # module
