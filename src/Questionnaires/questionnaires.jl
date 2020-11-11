module Questionnaires

using Codex
using CSV
using DataFrames
using DataValues
using Dates
using Query

include("personality.jl")
include("intelligence.jl")
include("plot.jl")

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

    if nato_name == "foxtrot"
        joined = Intelligence.foxtrot2scores(joined)
    elseif nato_name == "golf"
        joined = Intelligence.golf2scores(joined)
    elseif nato_name == "lima"
        joined = personality2scores(joined)
    end
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
        df = responses_data
        df[:group] = "operators"
    else # Graduates and dropouts.
        # If this code takes too long (>5 seconds), then try to reduce the number of columns.
        df = @from r in responses_data begin
            @left_outer_join d in dropouts_data on r.id[7:end] equals d.id
            @where d.cohort == cohort
            @where group == "graduates" ? 
                d.dropout == 0 :
                #  Must be dropouts, by `group == operators` conditional above.
                (d.dropout == 1 && (group == "dropout-medical" ?
                    d.dropout_reason == "B" :
                    d.dropout_reason != "B"))
            @select { group = group, r... }
            @collect DataFrame
        end
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

function first_measurement(raw_dir::String, nato_name::String) 
    parameters = [
        (raw_dir, "2018-first", nato_name, "graduates", 1),
        (raw_dir, "2018-first", nato_name, "dropouts-medical", 1),
        (raw_dir, "2018-first", nato_name, "dropouts-non-medical", 1),
        (raw_dir, "2019-first", nato_name, "graduates", 1),
        (raw_dir, "2019-first", nato_name, "dropouts-medical", 1),
        (raw_dir, "2019-first", nato_name, "dropouts-non-medical", 1),
        (raw_dir, "2020-operators", nato_name, "operators", 1)
    ]
    helper(a, b, c, d, e::Int) = responses(joinpath(a, b), c, d; measurement=e)
    vcat([helper(t...) for t in parameters]...)
end

end # module
