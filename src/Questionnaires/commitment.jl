module Commitment

using Codex
using DataFrames

export delta2scores

reverse(ans::Number) = 8 - ans

"""
    is_2018(df::DataFrame)::Bool

Returns whether `df` contains responses to the 2018 version of the delta questionnaire.
"""
is_2018(df::DataFrame)::Bool = !("v7" in names(df))

ans_2018_mapping = Dict(
    "Helemaal mee oneens" => 1,
    "Gedeeltelijk mee oneens" => 2,
    "Niet oneens, niet eens" => 3,
    "Gedeeltelijk mee eens" => 4,
    "Helemaal mee eens" => 5
)

function is_reversed(question::Int, year::Int)::Bool
    year == 2018 ? question in [1, 2, 4] : question in [2, 3, 5]
end

"""
    ans2num(ans, question::Int, year::Int)

Note that the scale was from 1 to 5 in 2018 and 1 to 7 in later years.
"""
function ans2num(ans, question::Int, year::Int)
    ans = year == 2018 ?
        Codex.rescale(ans_2018_mapping[ans], 1, 5, 1, 7) :
        (typeof(ans) != Int ? get(ans, Int) : ans)
    return is_reversed(question, year) ? reverse(ans) : ans
end

score_2018(responses...) = sum(ans2num.(responses, 1:5, 2018))
score_2019(responses...) = sum(ans2num.(responses, 2:6, 2019))

"""
    delta2scores(df::DataFrame)

Score the commitment questionnaire (delta).

Achievable is based on only one question so can optionally be omitted.
"""
function delta2scores(df::DataFrame)
    if is_2018(df)
        transform!(df, [:v1, :v2, :v3, :v4, :v5] => ByRow(score_2018) => :score)
        df[!, :achievable] .= ""
    else
        transform!(df, [:v2, :v3, :v4, :v5, :v6] => ByRow(score_2019) => :score)
        select!(df, :, :v7 => :achievable)
    end
    select!(df, :id, :completed_at, :score, :achievable)
    disallowmissing!(df)
end

end # module
