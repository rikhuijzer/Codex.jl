using Codex
using Statistics
using Test

@testset "Stats" begin
    A = [1, 2, 3]
    B = [3, 4, 5]
    # Checked with effsize package in R.
    @test cohens_d(A, B) == -2
    @test cohens_d(length(A), mean(A), std(A), length(B), mean(B), std(B)) == -2
end
