module TransformExport

using Codex
using CSV
using DataFrames

export responses

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
    # print(dfs[1])
    Dict(zip(names, dfs))
end

end # module
