module Commitment

using Codex
using DataFrames
using Query

export 
    delta2scores

reverse(ans::Number)::Number = 8 - ans

"""
    is_2018(df)::Bool

Returns whether `df` contains responses to the 2018 version of the delta questionnaire.
"""
is_2018(df)::Bool = !("v7" in names(df))

ans_2018_mapping = Dict(
    "Helemaal mee oneens" => 1, 
    "Gedeeltelijk mee oneens" => 2, 
    "Niet oneens, niet eens" => 3, 
    "Gedeeltelijk mee eens" => 4, 
    "Helemaal mee eens" => 5
)

is_reversed(question::Int, year::Int)::Bool = 
    year == 2018 ? question in [1, 2, 4] : question in [2, 3, 5]

function ans2num(ans, question::Int, year::Int)::Number
    ans = year == 2018 ? 
        Codex.rescale(ans_2018_mapping[ans], 1, 5, 1, 7) : 
        (typeof(ans) != Int ? get(ans, Int) : ans)
    return is_reversed(question, year) ? reverse(ans) : ans
end

function delta2scores(df::DataFrame)
    result = @from i in df begin
        @let score = is_2018(df) ?
            sum([
                ans2num(i.v1, 1, 2018),
                ans2num(i.v2, 2, 2018),
                ans2num(i.v3, 3, 2018),
                ans2num(i.v4, 4, 2018),
                ans2num(i.v5, 5, 2018),
            ]) :
            sum([
                ans2num(i.v2, 2, 2019),
                ans2num(i.v3, 3, 2019),
                ans2num(i.v4, 4, 2019),
                ans2num(i.v5, 5, 2019),
                ans2num(i.v6, 6, 2019),
            ])
        @let achievable = is_2018(df) ? "" : 
            (typeof(i.v7) != String ? get(i.v7, String) : i.v7)
        @select { i.id, i.completed_at, score, achievable }
        @collect DataFrame
    end

    # Enforce types to allow `vcat`.
    DataFrame(
        id = string.(result[:, :id]),
        completed_at = string.(result[:, :completed_at]),
        score = float.(result[:, :score]),
        achievable = string.(result[:, :achievable])
    )
end

end # module
