using Codex
using Codex.TransformExport
using DataFrames
using Test

@testset "TransformExport" begin
    export_dir = joinpath(project_root(), "test", "data", "2020-08")
    dfs = responses(export_dir)
    @test typeof(dfs) == Dict{String,DataFrame}
    @test "first" in keys(dfs)
    @test "second" in keys(dfs)
end
