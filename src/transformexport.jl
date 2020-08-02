module TransformExport

using Codex
using CSV
using DataFrames

export 
    responses,
    transform

"""
    responses(dir::String)::Dict{String,DataFrame}

Return responses for an export folder such as "2020-08".
"""
function responses(dir::String)::Dict{String,DataFrame}
    dir = joinpath(dir, "responses")
    files = filter(file -> endswith(file, ".csv"), readdir(dir))
    names = map(rmextension, files)
    paths = map(file -> joinpath(dir, file), files)
    dfs = map(path -> CSV.File(path, delim=';') |> DataFrame!, paths)
    Dict(zip(names, dfs))
end

"""
    transform(in_dir, out_dir; transformations::Array)
    transform(in_dir, out_dir)

Transforms an export folder, such as "2020-08", and places the files at `out_dir`.
`transformations` is expected to be a collection of functions of type `DataFrame -> DataFrame`. 
"""
function transform(in_dir::String, out_dir::String; transformations)
    mkpath(out_dir)
end

end # module
