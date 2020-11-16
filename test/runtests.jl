using Codex
using Test

@testset "Codex" begin
    include("utils.jl")
    include("stats.jl")
    include("df-transformations.jl")
    include(joinpath("TransformExport", "transformexport.jl"))
    include(joinpath("Questionnaires", "questionnaires.jl"))
end
