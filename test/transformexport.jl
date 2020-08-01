using Codex
using Codex.TransformExport
using DataFrames
using Test

@testset "TransformExport" begin
    dir = joinpath(project_root(), "test", "data", "2020-08")
    @test typeof(responses(dir)) == Dict{String,DataFrame}
end
