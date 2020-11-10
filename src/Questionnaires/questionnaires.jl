module Questionnaires

using Codex
using CSV
using DataFrames
using DataValues
using Dates
using Query

include("personality.jl")

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
Returns a DataFrame { id, r...} where `id` is a long identifier and not the one from the backend.
"""
function responses(data_dir::String, nato_name::String)::DataFrame
    responses_dir = joinpath(data_dir, "responses")
    responses_file = joinpath(responses_dir, "$nato_name.csv")
    responses = Codex.TransformExport.read_csv(responses_file, delim=';')
    people_file = joinpath(data_dir, "people.csv")
    people = Codex.TransformExport.read_csv(people_file, delim=';')
    @from p in people begin
        # Every response should have a non-empty `filled_out_by_id`.
        @join r in responses on DataValue{String}(p.person_id) equals r.filled_out_by_id
        @let id = p.first_name
        @select { id, r... }
        @collect DataFrame
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
