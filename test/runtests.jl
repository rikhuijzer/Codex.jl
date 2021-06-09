using Codex
using Test

@testset "Codex" begin
    include("gitlab.jl")
    include("utils.jl")
    include("stats.jl")
    include(joinpath("TransformExport", "transformexport.jl"))
    include(joinpath("Questionnaires", "questionnaires.jl"))
end
