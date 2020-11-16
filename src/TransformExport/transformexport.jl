module TransformExport

using Codex
using CSV
using DataFrames
using DataFrames: ColumnIndex
using Dates

export 
    read_csv,
    responses,
    simplify,
    substitute_names,
    names2usernames,
    process,
    rm_descriptions,
    split_datetime

"""
    read_csv(path; delim)::DataFrame

Copies CSV at `path` into memory.
"""
read_csv(path; delim=',')::DataFrame = CSV.File(path, delim=delim) |> DataFrame

"""
    responses(dir::String)::Dict{String,DataFrame}

Return responses for an export folder such as "2020-08".
"""
function responses(dir::String)::Dict{String,DataFrame}
    dir = joinpath(dir, "responses")
    files = filter(file -> endswith(file, ".csv"), readdir(dir))
    names = map(rmextension, files)
    paths = map(file -> joinpath(dir, file), files)
    dfs = map(path -> read_csv(path, delim=';'), paths)
    Dict(zip(names, dfs))
end

rm_timing!(df::DataFrame) = select!(df, Not(r".+\_timing"))
rm_boring_timestamps!(df::DataFrame) = select!(df, Not(r".+\_(?<!completed_)(from|at)"))
rm_boring_foreign_keys!(df::DataFrame) = select!(df, Not(r".+\_(?<!by_)id"))
rm_locale!(df::DataFrame) = "locale" in names(df) ? select!(df, Not("locale")) : df
rm_empty_rows!(df::DataFrame) = dropmissing!(df, :filled_out_by_id)
rename_id_col!(df::DataFrame) = rename!(df, Dict(:filled_out_by_id => :id))

"""
    simplify(df)::DataFrame

Renames id column after removing extraneous rows and columns, that is, removes empty rows and 
removes columns such as `protocol_subscription_id`, `open_from` and `v2_1_timing`.
"""
simplify(df::DataFrame)::DataFrame = DataFrame(
    apply([rm_timing!, rm_boring_timestamps!, rm_boring_foreign_keys!, rm_locale!, rm_empty_rows!, rename_id_col!], df)
)

"""
    _description_regex()

Return regex for matching a description such as `1 (lorem)` or `2 <br /> (ipsum)`.
"""
_description_regex() = r"([0-9]+) (<br\w*\/> )?\([^\)]+\)"

"""
    _rm_description(e::String)::String

Apply regex replace on element `e`.
"""
_rm_description(e) = e === missing ? e : parse(Int, replace(e, _description_regex() => s"\1"))

"""
    _rm_descriptions(col)::Array{Int,1}

Apply a regex replace and type conversion to all elements of the column `col`. 
"""
_rm_descriptions(col) = map(_rm_description, col)

"""
    _contains_description(col)::Bool

Return whether the column `col` contains descriptions.
"""
function _contains_description(col)::Bool 
    function is_match(value)
        if value === missing
            false
        else  
            contains(value, _description_regex()) 
        end
    end
    any(is_match, col)
end

"""
    rm_descriptions(df)::DataFrame

Find responses containing a description, for example `6 (heel erg)`, and remove the description.
"""
function rm_descriptions(df)::DataFrame
    df = DataFrame(df)
    # Not using in-place replacement since the type has to change.
    function map_col(i::Number)::Array
        col = df[!, 1]
        _rm_descriptions(col)
    end
    for i in 1:ncol(df)
        col = df[!, i]
        if contains(string(typeof(col)), "String") && _contains_description(col)
            df[!, i] = _rm_descriptions(col)
        end
    end
    df
end

"""
    substitute_names(df, with::DataFrame)::DataFrame
    substitute_names(with)::Function

Replaces `person_id`s by the first name as listed in `with`.
"""
function substitute_names(df, with::DataFrame)::DataFrame
    mapping = Dict(zip(with.person_id, with.first_name))
    select!(df, :id => ByRow(id -> mapping[id]), Not(:id))
    rename!(df, Dict(:id_function => :id))
end
substitute_names(with) = df -> substitute_names(df, with)

"""
    parsedatetime(str)::DateTime

Parse a date and time string from the export to a Julia DateTime object.
"""
parsedatetime(s) = DateTime(s, "d-m-y H:M:S")

"""
    process(in_dir, out_dir; fns)

Processes the responses from the export folder, applies the functions `fns` and places the files at `out_dir`.
"""
function process(in_dir, out_dir; fns=nothing)
    # mkpath(out_dir)
    out_dir
end

function names2usernames(df, id_username)::DataFrame
    df.id = map_by_df(df.id, id_username, :id, :username)
    df
end

"""
    split_datetime(df::DataFrame, datetime_col::ColumnIndex)::DataFrame

Split the datetime column `datetime_col` into two columns, namely one for date and one for time.
"""
function split_datetime(df::DataFrame, datetime_col::T)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df) 
    df.date = map(x -> first(split(x, " ")), df[!, datetime_col])
    df.time = map(x -> split(x, " ")[2], df[!, datetime_col])
    select!(df, Not(datetime_col))
    df
end

end # module
