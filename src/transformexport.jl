module TransformExport

using CSV
using DataFrames

export responses

"""
    responses(dir::String)::Dict{String,DataFrame}

Return responses for an export folder such as "2020-08".
"""
function responses(dir::String)::Dict{String,DataFrame}
    path = joinpath(dir, "responses", "first.csv") 
    df = CSV.File(path, delim=';') |> DataFrame!
    Dict("A" => df, "B" => df)
end

end # module
