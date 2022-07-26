module Questionnaires

using Codex
using CSV
using DataFrames
using Dates

struct Items
    normal::Array{Int,1}
    reversed::Array{Int,1}
end

const NATO_NAMES = [
    "alfa",
    "bravo",
    "charlie",
    "delta",
    "echo",
    "foxtrot",
    "golf",
    "hotel",
    "india",
    "julliet",
    "kilo",
    "lima",
    "mike"
]

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

include("demographics.jl")
include("resilience.jl")
include("commitment.jl")
include("self-efficacy.jl")
include("personality.jl")
include("intelligence.jl")
include("toughness.jl")
include("optimism.jl")
include("coping.jl")
include("inspire.jl")
include("hotel.jl")

"""
    get_hnd(path::AbstractString)::DataFrame

Get HowNutsAreTheDutch data and select big five, age and more.
"""
function get_hnd(path::AbstractString)::DataFrame
    path = string(path)::String
    # Don't need the added complexity of weakrefstrings here.
    df = try
        CSV.read(path, DataFrame; stringtype=String)
    catch
        # CSV version 0.8.
        CSV.read(path, DataFrame)
    end
    # Assumes that all neo scores are missing if neo_neurot is 999.
    filter!(:neo_neurot => !=(999), df)
    df[!, :group] .= "civilians"
    domains = (:neo_neurot => :N, :neo_extraversion => :E, :neo_openness => :O,
        :neo_agreeable => :A, :neo_conscient => :C)
    select!(df, :id, :age, :start_educ => :education, domains...)
    @assert nrow(df) == 4_984
    df
end

transformation_map = Dict{String,Function}(
    "bravo" => unify_demographics,
    "charlie" => resilience2scores,
    "delta" => Commitment.delta2scores,
    "echo" => self_efficacy2scores,
    "foxtrot" => Intelligence.foxtrot2scores,
    "golf" => Intelligence.golf2scores,
    "hotel" => hotel2scores,
    "india" => Toughness.india2scores,
    "julliet" => Coping.julliet2scores,
    "kilo" => Optimism.kilo2scores,
    "lima" => personality2scores,
    "mike" => Inspire.mike2scores
)

"""
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

    # Fix data.
    if nato_name != "mike" || !contains(data_dir, "2018")
        select!(people_data, :person_id => :backend_id, :first_name => :id)
        rename!(responses_data, Dict(:filled_out_by_id => "backend_id"))
        # If people_data is free from missings, then matchmissing equal should not introduce
        # missings, I think.
        dropmissing!(people_data)
        joined = innerjoin(people_data, responses_data, on=:backend_id, matchmissing=:equal)
        select!(joined, Not(:backend_id))
    else
        joined = responses_data
    end

    if "locale" in names(joined)
        select!(joined, Not(:locale))
    end

    if nato_name in keys(transformation_map)
        transformer = transformation_map[nato_name]
        joined = transformer(joined)
    end
    return joined
end

remove_auth_prefix(s) = ismissing(s) ? missing : s[7:end]

"""
    replace_usernames(df::DataFrame, id_col::Symbol, id_username::DataFrame)

For every username in `df[!, id_col]`, replace the name by the long identifier.
The long identifier is necessary, because usernames where not anonymized in 2018.
"""
function replace_usernames(df::DataFrame, id_col::Symbol, id_username::DataFrame)
    matchmissing = :notequal
    on = id_col => :username
    makeunique = true
    df = leftjoin(df, id_username; on, matchmissing, makeunique)
    new_col = Symbol("$(id_col)_1")
    df[!, new_col] = remove_auth_prefix.(df[!, new_col])
    df[!, :id] = [ismissing(new_id) ? id : new_id for (id, new_id) in zip(df[!, :id], df[!, new_col])]
    select!(df, Not(new_col))
    df
end

"""
    dropouts(raw_dir::String)

Returns dropout data where all IDs are in the long identifier format.
On 2021-07-19, returned a 197x7 dataset.
"""
function dropouts(raw_dir::String)
    dropouts_file = joinpath(raw_dir, "dropouts.csv")
    dropouts = Codex.TransformExport.read_csv(dropouts_file; delim=';')

    id_username_file = joinpath(raw_dir, "id-username.csv")
    id_username = Codex.TransformExport.read_csv(id_username_file; delim=',')

    dropouts = replace_usernames(dropouts, :id, id_username)
    transform!(dropouts, :dropout => ByRow(Bool) => :dropout)
    msg = "Unable to convert all usernames. Got:\n$dropouts"
    @assert all([length(id) == 24 for id in dropouts.id]) msg
    dropouts
end

function clean_graduates_dropouts(responses::DataFrame, dropouts::DataFrame, group, cohort)
    @assert group != "operators"

    responses = transform(responses, :id => ByRow(remove_auth_prefix) => :id)
    df = leftjoin(responses, dropouts; on=:id)

    function filter_group(dropout::Bool, dropout_reason::Union{Missing,String})
        if group == "graduates"
            !dropout
        else
            # Read as: if the query asks for "dropouts-medical", then get data with:
            medical_reason_match() = group == "dropouts-medical" ?
                dropout_reason == "B" || dropout_reason == "medisch" :
                dropout_reason == "A" || dropout_reason == "C" || dropout_reason == "ontheffing"
            dropout && medical_reason_match()
        end
    end
    function filter_group(dropout::Missing, dropout_reason)
        false
    end

    df = subset!(df, [:dropout, :dropout_reason] => ByRow(filter_group))
    df[!, :group] .= group
    df = select!(df, :group, names(responses)...)
end

"""
    validate_dropouts(df::DataFrame)

Validate "dropouts.csv".
"""
function validate_dropouts(df::DataFrame)
    disallowmissing!(df, :dropout)
    # Test whether a dropout reason is given when dropout=true.
    valid(dropout_reason::Missing, dropout::Bool) = !dropout
    valid(dropout_reason::String, dropout::Bool) = dropout
    invs = subset(df, [:dropout_reason, :dropout] => ByRow(!valid))
    @assert nrow(invs) == 0 "Found invalid rows:\n$invs"
end

"""
    responses(data_dir::String, nato_name::String, group::String; measurement=999)::DataFrame

Responses for group `group` and measurement `measurement`, where `group` is one of `graduates`, `operators`, `dropouts-medical` or `dropouts-non-medical`.
`measurement` is only used to split the 2018 data, for the later datasets it is ignored.

## Example in 2021-07:

```
julia> dir = joinpath(ysf_raw, "2020-first");

julia> df = Codex.Questionnaires.responses(dir, "kilo", "dropouts");

julia> nrow(df)
25

julia> select(first(df, 5), Not([:id, :completed_at]))
5×3 DataFrame
 Row │ group     optimism  pessimism
     │ String    Int64     Int64
─────┼───────────────────────────────
   1 │ dropouts        10         10
   2 │ dropouts        13          6
   3 │ dropouts        10          9
   4 │ dropouts        12          6
   5 │ dropouts        12          5
```
"""
function responses(data_dir::String, nato_name::String, group::String; measurement=999)::DataFrame
    responses_data = responses(data_dir, nato_name)

    cohort = parse(Int, match(r"[0-9]{4}", data_dir).match)
    dropouts_data = dropouts(dirname(data_dir))
    validate_dropouts(dropouts_data)

    if group == "operators"
        df = responses_data
        df[:, :group] .= "operators"
    else # Graduates and dropouts.
        df = clean_graduates_dropouts(responses_data, dropouts_data, group, cohort)
    end

    if cohort == 2018
        if !(measurement in [1, 2])
            throw(AssertionError("Measurement has to be specified for the 2018 data"))
        end
        threshold = Date("2019-01-01")
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
        (raw_dir, "2018-first", "graduates"),
        (raw_dir, "2018-first", "dropouts-medical"),
        (raw_dir, "2018-first", "dropouts-non-medical"),
        (raw_dir, "2019-first", "graduates"),
        (raw_dir, "2019-first", "dropouts-medical"),
        (raw_dir, "2019-first", "dropouts-non-medical"),
        (raw_dir, "2020-operators", "operators"),
        (raw_dir, "2020-first", "graduates"),
        (raw_dir, "2020-first", "dropouts-medical"),
        (raw_dir, "2020-first", "dropouts-non-medical"),
        (raw_dir, "2021-03", "graduates"),
        (raw_dir, "2021-03", "dropouts-medical"),
        (raw_dir, "2021-03", "dropouts-non-medical"),
        (raw_dir, "2021-08", "graduates"),
        (raw_dir, "2021-08", "dropouts-medical"),
        (raw_dir, "2021-08", "dropouts-non-medical"),
        (raw_dir, "2022-03", "graduates")
        # TODO: Dropouts nog even een categorie geven of deze code eindelijk omschrijven.
        # (raw_dir, "2022-03", "dropouts-medical"),
        # (raw_dir, "2021-03", "dropouts-non-medical"),
    ]
    # Responses are missing for this year.
    if nato_name == "hotel"
        filter!(p -> !contains(p[2], "2018"), parameters)
    end
    measurement = 1
    function helper(dir, cohort_dir, group)
        data_dir = joinpath(dir, cohort_dir)
        responses(data_dir, nato_name, group; measurement)
    end
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
    if nato_name == "mike"
        filter!(p -> p[2] != "2018-second", parameters)
    end
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
        rename!(s -> s == "id" ? s : "$(b)_$s", B)
        innerjoin(A, B, on = :id)
    end

    function ysf_join(a::String, b::String)
        A = prepare_responses(a)
        rename!(s -> s == "id" || s == "group" ? s : "$(a)_$s", A)
        ysf_join(A, b)
    end

    reduce(ysf_join, questionnaires)
end

"""
    join_vo_questionnaires(raw_dir::String)::DataFrame

Combine information from multiple questionnaires to allow model fitting.
"""
function join_vo_questionnaires(raw_dir::String)::DataFrame
    questionnaires = sort(collect(keys(transformation_map)))
    # Ignoring delta since only two operators participated in it.
    questionnaires = filter(!in(["bravo", "delta"]), questionnaires)
    df = Codex.Questionnaires.join_questionnaires(
        raw_dir,
        questionnaires,
        ["graduates", "operators", "dropouts-non-medical"]
    )
    df[:, :binary_group] = [x == "graduates" || x == "operators" ? 1 : 0 for x in df[:, :group]]
    df
end

function csv_files(dir::String)
    return filter(endswith(".csv"), readdir(dir))
end

"""
    unfinished_questionnaires(responses_dir::String, id::String)

Return questionnaire names in `responses_dir` for which `id` is not in `filled_out_by_id` column.
This assumes that unfinished questionnaires have a `missing` in the `filled_out_by_id` column.
"""
function unfinished_questionnaires(responses_dir::String, id::String)
    csvs = csv_files(responses_dir)
    unfinished_csv_files = filter(csvs) do csv_file
        csv_path = joinpath(responses_dir, csv_file)
        df = CSV.read(csv_path, DataFrame)
        if "filled_out_by_id" in names(df)
            return !(id in skipmissing(df.filled_out_by_id))
        else
            # We can ignore the dataset since it is not a valid u-can-act output.
            return true
        end
    end
    unfinished = first.(splitext.(unfinished_csv_files))
    return unfinished
end

"""
    all_ids(responses_dir)::Vector{String}

"""
function all_ids(responses_dir)::Vector{String}
    csvs = csv_files(responses_dir)
    ids = map(csvs) do csv_file
        csv_path = joinpath(responses_dir, csv_file)
        df = CSV.read(csv_path, DataFrame)
        if "filled_out_by_id" in names(df)
            return collect(skipmissing(df.filled_out_by_id))
        else
            return String[]
        end
    end
    return sort(unique(Iterators.flatten(ids)))
end

struct Unfinished
    id::String
    unfinished_questionnaires::Vector{String}
end

"""
    unfinished_info(responses_dir; required::Union{Nothing,Vector{String}}=missing)::Vector{Unfinished}

Return the ids for which not all questionnaires in `required` have been filled in.
When `ismissing(required)`, take all the questionnaires in `responses_dir`.

# Example
```
julia> responses_dir = joinpath(homedir(), "git", "ysf-raw", "2021-08", "responses");

julia> required = ["alfa", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "julliet", "kilo", "lima", "mike"];

julia> Codex.Questionnaires.unfinished_info(responses_dir; required)

"""
function unfinished_info(responses_dir; required::Union{Missing,Vector{String}}=missing)::Vector{Unfinished}
    if ismissing(required)
        required = first.(splitext.(csv_files(responses_dir)))
    end
    ids = all_ids(responses_dir)
    U = [unfinished_questionnaires(responses_dir, id) for id in ids]
    U = [filter(in(required), unfinished) for unfinished in U]
    Z = collect(zip(ids, U))
    Z = filter(t -> !isempty(last(t)), Z)
    return [Unfinished(id, unfinished) for (id, unfinished) in Z]
end

end # module
