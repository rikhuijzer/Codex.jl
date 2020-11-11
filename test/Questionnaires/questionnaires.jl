using Test
using Codex.TransformExport
using Codex.Questionnaires

@testset "Questionnaires" begin
    include("personality.jl")

    data_dir = joinpath(project_root(), "test", "data", "2020-08")

    df = Codex.Questionnaires.responses(data_dir, "second")
    @test size(df) == (3, 8)

    df = Codex.Questionnaires.responses(data_dir, "delta")
    @test df[:, [:id, :score]] == DataFrame(id = [0002], score = [26])

    df = Codex.Questionnaires.responses(data_dir, "foxtrot")
    @test df[:, [:correct, :incorrect, :dontknow]] == 
        DataFrame(correct = [8], incorrect = [3], dontknow = [0])


end
