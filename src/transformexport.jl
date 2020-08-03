module TransformExport

using Codex
using CSV
using DataFrames

export 
    read_csv,
    responses,
    simplify,
    process

"""
    read_csv(path; delim)::DataFrame

Copies CSV at `path` into memory.
"""
read_csv(path; delim=',')::DataFrame = CSV.File(path, delim=delim) |> DataFrame!

"""
    read_csv(;delim)::DataFrame

Create a function that reads a CSV with `delim`, that is,
a function equivalent to `read_csv(path) -> read_csv(path; delim)`.
For similar partial function declarations in `Base`, see issue #35052 or `endswith(suffix)`.
"""
read_csv(;delim) = path -> read_csv(path; delim)

"""
    responses(dir::String)::Dict{String,DataFrame}

Return responses for an export folder such as "2020-08".
"""
function responses(dir::String)::Dict{String,DataFrame}
    dir = joinpath(dir, "responses")
    files = filter(file -> endswith(file, ".csv"), readdir(dir))
    names = map(rmextension, files)
    paths = map(file -> joinpath(dir, file), files)
    dfs = map(read_csv(delim=';'), paths)
    Dict(zip(names, dfs))
end

rm_timing!(df::DataFrame) = select!(df, Not(r".+\_timing"))
rm_timestamps!(df::DataFrame) = select!(df, Not(r".+\_(from|at)"))
rm_boring_foreign_keys!(df::DataFrame) = select!(df, Not(r".+\_(?<!by_)id"))
rm_empty_rows!(df::DataFrame) = dropmissing!(df, :filled_out_by_id)
rename_id_col!(df::DataFrame) = rename!(df, Dict(:filled_out_by_id => :id))

"""
    simplify(df)

Renames id column after removing extraneous rows and columns, that is, removes empty rows and 
removes columns such as `protocol_subscription_id`, `open_from` and `v2_1_timing`.
"""
simplify(df::DataFrame) = DataFrame(
    apply([rm_timing!, rm_timestamps!, rm_boring_foreign_keys!, rm_empty_rows!, rename_id_col!], df)
)

"""
    process(in_dir, out_dir; functions)

Processes the responses from the export folder, applies the `functions` and places the files at `out_dir`.
"""
function process(in_dir, out_dir; fns=nothing)
    # mkpath(out_dir)
    out_dir
end

end # module
