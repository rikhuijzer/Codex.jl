using Codex
using Test

@testset "Utils" begin
    @test dirparent("/a/b/c") == "/a/b"
    @test dirparent("/a/b/c/") == "/a/b"
    @test dirparent("/a/b/c", 2) == "/a"
    
    @test endswith(project_root(), "Codex.jl")
end
