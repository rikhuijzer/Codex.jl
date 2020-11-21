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

    df = DataFrame(group = [4, 9, 9])
    @test Codex.nrow_per_group(df, :group; col1="group", col2="n") == DataFrame(group = [4, 9], n = [1, 2])

    cmd = `echo lorem`
    f(out, err) = pipeline(cmd, stdout=out, stderr=err)
    expected = Output(0, "lorem\n", "")
    @test Codex.output(f) == expected
    @test Codex.output(cmd) == expected
end
