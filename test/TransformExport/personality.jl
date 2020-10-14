import Codex
import Codex.TransformExport

using DataFrames
using Test

@testset "personality" begin
    path = joinpath(export_dir, "responses", "personality.csv")
    simple = Codex.TransformExport.read_csv(path, delim=';')
    scores = Codex.TransformExport.personality2scores(simple)
    @test typeof(first(scores)[:A1]) == Int
end
