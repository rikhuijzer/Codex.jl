using Test
using Codex.TransformExport
using Codex.Questionnaires

@testset "Questionnaires" begin
    include("personality.jl")

    data_dir = joinpath(Codex.PROJECT_ROOT, "test", "data", "2020-08")

    df = Codex.Questionnaires.responses(data_dir, "second")
    @test size(df) == (3, 8)

    df = Codex.Questionnaires.responses(data_dir, "delta")
    @test df[1, :score] == 26.0

    df = Codex.Questionnaires.responses(data_dir, "foxtrot")
    @test df[:, [:correct, :incorrect, :dontknow]] == 
        DataFrame(correct = [8], incorrect = [3], dontknow = [0])

    df = Codex.Questionnaires.responses(data_dir, "kilo")
    @test df[:, [:optimism, :pessimism]] == DataFrame(optimism = [10], pessimism = [7])

    df = Codex.Questionnaires.responses(data_dir, "mike")
    @test df[1, :optimism] ≈ 19 / 6
end
