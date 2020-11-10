import Codex
import Codex.TransformExport
import Codex.Questionnaires

using DataFrames
using Test

@testset "personality" begin
    path = joinpath(export_dir, "responses", "personality.csv")
    simple = Codex.TransformExport.read_csv(path, delim=';')
    scores = Codex.Questionnaires.personality2scores(simple)
    @test typeof(first(scores)[:A1]) == Int
end
