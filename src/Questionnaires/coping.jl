module Coping

using Codex
using DataFrames
using Query

export 
    julliet2scores

# For Julliet, 2018 and 2019 are the same. 
# 2020 is a bit different, but it shouldn't matter for this code, see `diff`
# For more information, see the e-mail with the subject `Julliet`.

# This file is not tested in-depth, because the procedure is the same as delta.

ans_mapping = Dict(
    "Nooit" => 1, 
    "Bijna nooit" => 2, 
    "Soms" => 3, 
    "Vaak" => 4, 
    "Altijd" => 5
)
    
ans2num(ans)::Int = return ans_mapping[ans]

function julliet2scores(df::DataFrame)
    result = @from i in df begin
        # Problem focused coping.
        @let problem_focused = sum([
            ans2num(i.v1),
            ans2num(i.v5),
            ans2num(i.v8),
            ans2num(i.v11),
            ans2num(i.v14)
        ])
        # Emotion focused coping.
        @let emotion_focused = sum([
            ans2num(i.v3),
            ans2num(i.v7),
            ans2num(i.v10),
            ans2num(i.v13),
            ans2num(i.v4)
        ])
        # Seeking social support.
        @let seeking_support = sum([
            ans2num(i.v2),
            ans2num(i.v6),
            ans2num(i.v9),
            ans2num(i.v15),
            ans2num(i.v12)
        ])
        @select { i.id, i.completed_at, problem_focused, emotion_focused, seeking_support }
        @collect DataFrame
    end

    # Enforce types to allow `vcat`.
    DataFrame(
        id = string.(result[:, :id]),
        completed_at = string.(result[:, :completed_at]),
        problem_focused = Int.(result[:, :problem_focused]),
        emotion_focused = Int.(result[:, :emotion_focused]),
        seeking_support = Int.(result[:, :seeking_support])
    )
end

end # module
