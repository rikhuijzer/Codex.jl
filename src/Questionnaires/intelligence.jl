module Intelligence

using CSV
using DataFrames

export foxtrot2scores, golf2scores

function str2int(letter::String)::Int
    @assert(occursin(r"[A-Z]+", letter), "r\"[A-Z]+\" does not occur in $letter")
    ch = letter[1]
    i = Int(ch) - 64
end

n_equal(a::Array, b::Array)::Number = count(map(t -> t[1] == t[2], zip(a, b)))
n_equal(a::Array, b::String)::Number = n_equal(a, map(i -> b, 1:length(a)))
n_weetniet(preds::Array{Int64,1})::Int64 = length(filter(v -> v == "Weet ik niet", preds))
get_answers(i::Number, df::DataFrame)::Vector = Vector(df[i, :][3:end])
get_numbers(i::Number, df::DataFrame)::Array{Int64,1} = map(str2int, get_answers(i, df))

function n_correct(df::DataFrame, solutions::Array)::Array{Int64,1}
    map(i -> n_equal(get_numbers(i, df), solutions), 1:nrow(df))
end

function n_incorrect(df::DataFrame, solutions::Array)::Array{Int64,1}
    map(n -> length(solutions) - n, n_correct(df, solutions))
end

function n_weetniet(df::DataFrame)::Array{Int64,1}
    map(i -> n_equal(get_answers(i, df), "Weet ik niet"), 1:nrow(df))
end

add_column(df::DataFrame, name::Symbol, data::Array)::DataFrame = hcat(df, DataFrame(name => data))

function foxtrot2scores(foxtrot::DataFrame)::DataFrame
    # Source: https://github.com/compsy/hoe_gek_is/blob/master/db/questionnaires/intelligentie.rb
    solutions = [4, 3, 5, 2, 2, 4, 5, 3, 1, 4, 5]

    scores = select(foxtrot, [:id, :completed_at])
    scores = add_column(scores, :correct, n_correct(foxtrot, solutions))
    scores = add_column(scores, :incorrect, n_incorrect(foxtrot, solutions))
    scores = add_column(scores, :dontknow, n_weetniet(foxtrot))

    return scores
end

function golf2scores(golf::DataFrame)::DataFrame
    solutions = [6, 5, 3, 2, 2, 6, 1, 7, 3, 7, 1, 5, 7, 1, 6, 5, 2, 3, 5, 6, 1, 2, 7, 3]

    scores = select(golf, [:id, :completed_at])
    scores = add_column(scores, :correct, n_correct(golf, solutions))
    scores = add_column(scores, :incorrect, n_incorrect(golf, solutions))
    scores = add_column(scores, :dontknow, n_weetniet(golf))

    return scores
end

end # module
