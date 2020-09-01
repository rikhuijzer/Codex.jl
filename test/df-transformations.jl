using CategoricalArrays
using Codex
using DataFrames
using Test

@testset "DataFrame Transformations" begin
    unordered = DataFrame(x = [1, "2", missing], y = ["1", "2", "4"])
    ordering = Ordering(:x, ["2", 1, 3, missing])
    actual = order_with(unordered, [ordering])
    @test actual.y == ["2", "1", "4"]
    @test typeof(actual.x) == typeof(unordered.x)

    unordered = DataFrame(x = [1, 2, 1], y = ["c", "a", "b"])
    expected = DataFrame(x = [1, 1, 2], y = ["b", "c", "a"]) 
    @test order_with(unordered, [Ordering(:x, nothing), Ordering(:y, nothing)]) == expected

    incomplete = DataFrame(x = [1], y = ["1"])
    @test all(add_missing(incomplete, :x, [1, 2]).y .=== ["1", missing])

    incomplete = DataFrame(u = [1, 1], v = ["a", "b"])
    # Add missing is probably not necessary in Manager since all will be there from the backend.
    # @test all(add_missing(incomplete, :u, [1, 2], :v).v .=== ["a", missing, "b", missing])
end
