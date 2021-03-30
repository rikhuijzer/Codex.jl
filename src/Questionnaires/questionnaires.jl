module Questionnaires

using Codex
using CSV
using DataFrames
using DataValues
using Dates
using Query

struct Items
    normal::Array{Int,1}
    reversed::Array{Int,1}
end

reverse(x::Int) = 6 - x
reverse(x::Missing) = missing

function get_scores(df::DataFrame, items::Items; average=true)::Array
    if length(items.normal) != 0
        v_normal = [Symbol("v$i") for i in items.normal]
        normal_scores = [sum(row[v_normal]) for row in eachrow(df[:, v_normal])]
    else
        normal_scores = repeat([0], nrow(df))
    end

    if length(items.reversed) != 0
        v_reversed = [Symbol("v$i") for i in items.reversed]
        reversed_scores = [sum(map(reverse, row)) for row in eachrow(df[:, v_reversed])]
    else
        reversed_scores = repeat([0], nrow(df))
    end

    totals = normal_scores .+ reversed_scores
    n_items = length(items.normal) + length(items.reversed)
    
    return average ? totals ./ n_items : totals
end

include("commitment.jl")
include("demographics.jl")
include("personality.jl")
include("intelligence.jl")
include("toughness.jl")
include("optimism.jl")
include("coping.jl")
include("inspire.jl")
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

    if nato_name != "mike" || !contains(data_dir, "2018")
        # Avoiding Query because precompilation takes ages (>1 minutes) for hundreds of columns.
        select!(people_data, :person_id => :backend_id, :first_name => :id)
        rename!(responses_data, Dict(:filled_out_by_id => "backend_id"))
        # If people_data is free from missings, then matchmissing equal should not introduce 
        # missings, I think.
        dropmissing!(people_data)
    joined = nothing
    try
        joined = innerjoin(people_data, responses_data, on=:backend_id, matchmissing=:equal)
    catch # DataFrames < 0.22
        joined = innerjoin(people_data, responses_data, on=:backend_id)
    end
        select!(joined, Not(:backend_id))
    else 
        joined = responses_data
    end

    if "locale" in names(joined)
        select!(joined, Not(:locale))
    end

    # When updating this part, also update `join_dropout_questionnaires` below.
    if nato_name == "bravo"
        joined = unify_demographics(joined)
    elseif nato_name == "delta"
        joined = Commitment.delta2scores(joined)
    elseif nato_name == "foxtrot"
        joined = Intelligence.foxtrot2scores(joined)
    elseif nato_name == "golf"
        joined = Intelligence.golf2scores(joined)
    elseif nato_name == "india"
        joined = Toughness.india2scores(joined)
    elseif nato_name == "julliet"
        joined = Coping.julliet2scores(joined)
    elseif nato_name == "kilo"
        joined = Optimism.kilo2scores(joined)
    elseif nato_name == "lima"
        joined = personality2scores(joined)
    elseif nato_name == "mike"
        joined = Inspire.mike2scores(joined)
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

Responses for group `group` and measurement `measurement`, where `group` is one of `graduates`, `operators`, `dropouts-medical` or `dropouts-non-medical`.
`measurement` is only used to split the 2018 data, for the later datasets it is ignored.
"""
function responses(data_dir::String, nato_name::String, group::String; measurement=999)
    responses_data = responses(data_dir, nato_name) 

    cohort = parse(Int, match(r"[0-9]{4}", data_dir).match)
    dropouts_data = dropouts(dirname(data_dir))
    
    if group == "operators"
        df = responses_data
        df[:, :group] = repeat(["operators"], nrow(df))
    else # Graduates and dropouts.
        # If this code takes too long (>5 seconds), then try to reduce the number of columns.
        df = @from r in responses_data begin
            @left_outer_join d in dropouts_data on r.id[7:end] equals d.id
            @where d.cohort == cohort
            @where group == "graduates" ? 
                d.dropout == 0 :
                #  Must be dropouts, by `group == operators` conditional above.
                (d.dropout == 1 && (group == "dropouts-medical" ?
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
        return nato_name != "mike" ? filter([:completed_at] => filter_date, df) : df
    else # After 2018, the datasets are already split on before and after selection.
        df
    end
end

function first_measurement(raw_dir::AbstractString, nato_name::AbstractString)
    parameters = [
        (raw_dir, "2018-first", "graduates", 1),
        (raw_dir, "2018-first", "dropouts-medical", 1),
        (raw_dir, "2018-first", "dropouts-non-medical", 1),
        (raw_dir, "2019-first", "graduates", 1),
        (raw_dir, "2019-first", "dropouts-medical", 1),
        (raw_dir, "2019-first", "dropouts-non-medical", 1),
        (raw_dir, "2020-operators", "operators", 1),
        (raw_dir, "2020-first", "graduates", 1),
#        (raw_dir, "2020-first", "dropouts-medical", 1),
#        (raw_dir, "2020-first", "dropouts-non-medical", 1),
    ]
    helper(dir, cohort_dir, group, measurement::Int) =
        responses(joinpath(dir, cohort_dir), nato_name, group; measurement)
    vcat([helper(p...) for p in parameters]...)
end

function second_measurement(raw_dir::AbstractString, nato_name::AbstractString)
    parameters = [
        (raw_dir, "2018-second", "graduates", 2),
        (raw_dir, "2018-second", "dropouts-medical", 2),
        (raw_dir, "2018-second", "dropouts-non-medical", 2),
        (raw_dir, "2019-second", "graduates", 2),
        (raw_dir, "2019-second", "dropouts-medical", 2),
        (raw_dir, "2019-second", "dropouts-non-medical", 2),

#        (raw_dir, "2020-first", "dropouts-medical", 1),
#        (raw_dir, "2020-first", "dropouts-non-medical", 1),
    ]
    helper(dir, cohort_dir, group, measurement::Int) =
        responses(joinpath(dir, cohort_dir), nato_name, group; measurement)
    vcat([helper(p...) for p in parameters]...)

end

"""
    join_questionnaires(raw_dir::String, questionnaires::Array{String,1}, groups::Array{String,1})::DataFrame

Joines multiple `questionnaires` for the members of `groups`, where `groups` ensures that the joins do not remove rows which shouldn't be removed.
For instance, given questionnaires `"A"` and `"B"` containing respectively columns `:a1`, `:a2` and `:b1`, this method will return `{ group, id, A_a1, A_a2, B_b1 }`.
"""
function join_questionnaires(raw_dir::String, questionnaires::Array{String,1}, groups::Array{String,1})::DataFrame
    function prepare_responses(q::String)::DataFrame
        df = first_measurement(raw_dir, q)
        filter!(:group => x -> x in groups, df)
        select!(df, Not(:completed_at))
    end

    function ysf_join(A::DataFrame, b::String)
        B = prepare_responses(b)
        # Group information is already provided by `A`.
        select!(B, Not(:group))
        rename!(s -> s == "id" ? s : "$(b[1])_$s", B)
        innerjoin(A, B, on = :id)
    end

    function ysf_join(a::String, b::String)
        A = prepare_responses(a)
        rename!(s -> s == "id" || s == "group" ? s : "$(a[1])_$s", A)
        ysf_join(A, b)
    end

    reduce(ysf_join, questionnaires)
end

"""
    join_dropout_questionnaires(raw_dir::String)::DataFrame

Combine information from multiple questionnaires to allow model fitting.
"""
function join_dropout_questionnaires(raw_dir::String)::DataFrame
    df = Codex.Questionnaires.join_questionnaires(
        raw_dir,
        # Ignoring delta since only two operators participated in delta.
        ["foxtrot", "golf", "india", "kilo", "lima", "mike"],
        ["graduates", "operators", "dropouts-non-medical"]
    )
    df[:, :binary_group] = [x == "graduates" || x == "operators" ? 1 : 0 for x in df[:, :group]]
    df
end

end # module
