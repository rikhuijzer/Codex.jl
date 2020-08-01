using Codex
using Test

@testset "Codex" begin
    @test Codex.greet() == "Hello world"
end
