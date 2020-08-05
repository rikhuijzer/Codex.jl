module TransformExport

using Codex
using CSV
using DataFrames

export 
    read_csv,
    responses,
    simplify,
    substitute_names,
    process

"""
    read_csv(path; delim)::DataFrame

Copies CSV at `path` into memory.
"""
read_csv(path; delim=',')::DataFrame = CSV.File(path, delim=delim) |> DataFrame!

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
rm_timestamps!(df::DataFrame) = select!(df, Not(r".+\_(from|at)"))
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
    apply([rm_timing!, rm_timestamps!, rm_boring_foreign_keys!, rm_locale!, rm_empty_rows!, rename_id_col!], df)
)

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
    process(in_dir, out_dir; fns)

Processes the responses from the export folder, applies the functions `fns` and places the files at `out_dir`.
"""
function process(in_dir, out_dir; fns=nothing)
    # mkpath(out_dir)
    out_dir
end

end # module
