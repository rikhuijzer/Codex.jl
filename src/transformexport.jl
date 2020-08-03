module TransformExport

using Codex
using CSV
using DataFrames

export 
    read_csv,
    responses,
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

remove_timing(df::DataFrame)::DataFrame = select(df, Not(r".+\_timing"))
remove_timestamps(df::DataFrame)::DataFrame = select(df, Not(r"

"""
    process(in_dir, out_dir; functions)

Processes the responses from the export folder, applies the `functions` and places the files at `out_dir`.
"""
function process(in_dir, out_dir; fns=nothing)
    # mkpath(out_dir)
    out_dir
end

end # module
