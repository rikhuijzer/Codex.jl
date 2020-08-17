using DataFrames
using Codex
using Test

@testset "Utils" begin
    @test dirparent("/a/b/c") == "/a/b"
    @test dirparent("/a/b/c/") == "/a/b"
    @test dirparent("/a/b/c", 2) == "/a"
    
    @test endswith(project_root(), "Codex.jl")

    fns = [
        df -> transform(df, :A => :A2),
        df -> select(df, :A2)
    ]
    @test apply(fns, DataFrame(:A => 1)) == DataFrame(:A2 => 1)
    @test map(apply([x -> x + 1]), [1]) == [2]
end
