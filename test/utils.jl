using DataFrames
using Codex
using Test

import CategoricalArrays

@testset "Utils" begin
    A = ["1", 2, missing]
    @test all(categorical2simple(CategoricalArrays.CategoricalArray(A)) .=== A)
    @test dirparent("/a/b/c") == "/a/b"
    @test dirparent("/a/b/c/") == "/a/b"
    @test dirparent("/a/b/c", 2) == "/a"
    @test has_duplicates([1]) == false
    @test has_duplicates([1,1]) == true

    @test endswith(project_root(), "Codex.jl")

    fns = [
        df -> transform(df, :A => :A2),
        df -> select(df, :A2)
    ]
    @test apply(fns, DataFrame(:A => 1)) == DataFrame(:A2 => 1)
    @test map(apply([x -> x + 1]), [1]) == [2]

    df = DataFrame(from = [1], to = ["one"])
    @test map_by_df([1, 2], df, :from, :to) == ["one", 2]

    @test Codex.rescale(5, 1, 5, 0, 6) == 6
end
