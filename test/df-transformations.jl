using CategoricalArrays
using DataFrames
using Test

import Codex

@testset "DataFrame Transformations" begin
    unordered = DataFrame(x = [1, "2", missing], y = ["1", "2", "4"])
    ordering = ["2", 1, 3, missing]
    actual = Codex.order_with(unordered, :x, ordering)
    @test actual.y == ["2", "1", "4"]
    @test typeof(actual.x) == typeof(unordered.x)

    # Maybe add feature to add missing rows later.
    # expected = DataFrame(x = ordering, y = ["2", "1", missing])
    # @test Codex.enforce_ordering(unordered, :x, ordering) == expected
end
