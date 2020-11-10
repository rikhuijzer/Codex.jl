using Test
using Codex.TransformExport
using Codex.Questionnaires

@testset "Questionnaires" begin
    include("personality.jl")

    data_dir = joinpath(project_root(), "test", "data", "2020-08")

    df = Codex.Questionnaires.responses(data_dir, "second")
    @test size(df) == (3, 61)
    
end
