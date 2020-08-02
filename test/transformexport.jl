using Codex
using Codex.TransformExport
using DataFrames
using Test

@testset "TransformExport" begin
    dfs = responses(joinpath(project_root(), "test", "data", "2020-08"))
    @test typeof(dfs) == Dict{String,DataFrame}
    @test "first" in keys(dfs)
    @test "second" in keys(dfs)
end
