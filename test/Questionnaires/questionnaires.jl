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

    responses_dir = joinpath(data_dir, "responses")
    id = "aaab"
    unfinished = Codex.Questionnaires.unfinished_questionnaires(responses_dir, id)
    @test unfinished == ["first", "personality", "third"]

    ids = Codex.Questionnaires.all_ids(responses_dir)
    @test ids == ["aaaa", "aaab", "aaac", "aaad"]

    U = Codex.Questionnaires.unfinished_info(responses_dir; required=["first"])
    @test getproperty.(U, :id) == ["aaab", "aaac", "aaad"]
    @test getproperty.(U, :unfinished_questionnaires) == fill(["first"], 3)
end
