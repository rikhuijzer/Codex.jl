module Optimism

using Codex
using DataFrames

export kilo2scores

# TODO:
# - check with test

# Kilo is, basically, the same for 2018, 2019 and 2020 according to `diff`.

ans_mapping = Dict(
    "Absoluut niet<br> mee eens" => 1,
    "Niet<br>mee eens" => 2,
    "Deels<br>mee eens" => 3,
    "Mee<br>eens" => 4,
    "Absoluut<br>mee eens" => 5
)

ans2num(ans)::Int = return ans_mapping[ans]
score(responses...) = sum(ans2num.(responses))

# According to Glaesmer et al. (2012). The other questions are "filler items".
optimism_questions = [1, 4, 10]
pessimism_questions = [3, 7, 9]

"""
    kilo2scores(df::DataFrame)

Add optimism and pessimism columns.
In 2021-07, returns 290 rows.
"""
function kilo2scores(df::DataFrame)
    cols = [
        :id,
        :completed_at,
        [:v1, :v4, :v10] => ByRow(score) => :optimism,
        [:v3, :v7, :v9] => ByRow(score) => :pessimism
    ]
    select!(df, cols...)
    disallowmissing!(df)
end

end # module
