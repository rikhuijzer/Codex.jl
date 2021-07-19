module Coping

using Codex
using DataFrames
using Query

export julliet2scores

ans_mapping = Dict(
    "Nooit" => 1,
    "Bijna nooit" => 2,
    "Soms" => 3,
    "Vaak" => 4,
    "Altijd" => 5
)

ans2num(ans)::Int = return ans_mapping[ans]

score(responses...) = sum(ans2num.(responses))

"""
    julliet2scores(df::DataFrame)

In 2021-07, returns 289×6 DataFrame.

For Julliet, 2018 and 2019 are the same.
2020 is a bit different, but it shouldn't matter for this code, see `diff`
For more information, see the e-mail with the subject `Julliet`.

This file is not tested in-depth, because the procedure is the same as delta.
"""
function julliet2scores(df::DataFrame)
    cols = [
        :id,
        :completed_at,
        [:v1, :v5, :v8, :v11, :v14] => ByRow(score) => :problem_focused,
        [:v3, :v7, :v10, :v13, :v4] => ByRow(score) => :emotion_focused,
        [:v2, :v6, :v9, :v15, :v12] => ByRow(score) => :seeking_support
    ]
    select!(df, cols...)
    disallowmissing!(df)
end

end # module
