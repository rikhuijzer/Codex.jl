using DataFrames
using Test

import Codex

@testset "DataFrame Transformations" begin
    unordered = DataFrame(x = [1, 2], y = ["1", "2"])
    ordering = [2, 1, 3]
    expected = DataFrame(x = [2, 1], y = ["2", "1"])
    @test Codex.order_with(unordered, :x, ordering) == expected

    # Maybe add missing functionality later.
    # expected = DataFrame(x = ordering, y = ["2", "1", missing])
    # @test Codex.enforce_ordering(unordered, :x, ordering) == expected
end
