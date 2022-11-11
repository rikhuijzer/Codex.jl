module Toughness

using Codex.Questionnaires: Items, get_scores
using DataFrames

# This one is not tested since it uses the same method as inspire.jl.

export
    india2scores

# It seems that this questionnaire is the same for 2018, 2019 and 2020.

ans_mapping = Dict(
    "Zeer mee oneens" => 1,
    "Oneens" => 2,
    "Noch mee eens, noch mee oneens" => 3,
    "Mee eens" => 4,
    "Zeer mee eens" => 5
)

reverse(ans::Number)::Number = 6 - ans

reversed_questions = [6, 9, 10, 11, 14, 15, 18, 21, 22, 27, 28, 29, 32, 33, 34, 35, 36, 37, 41, 42, 46, 47]

challenge = Items(
    [4, 23, 30, 40, 44, 48],
    [6, 14]
)

commitment = Items(
    [1, 7, 19, 25, 39],
    [11, 22, 29, 35, 42, 47]
)

emotional_control = Items(
    [26, 31, 45],
    [21, 27, 34, 37]
)

life_control = Items(
    [2, 5, 9, 12],
    [15, 33, 41]
)

confidence_in_abilities = Items(
    [3, 8, 13, 16, 24],
    [10, 18, 32, 36]
)

interpersonal_confidence = Items(
    [17, 20, 38, 43],
    [28, 46]
)

"""
    india2scores(df::DataFrame)

Score mental toughness (india).
This thing is sold as 4 C's: Challenge, Commitment, Control, and Confidence.

Vaughan et al. (2018) caution against the use of this measure with elite athletes.
"""
function india2scores(df::DataFrame)
    v_names = filter(contains(r"v[0-9]+"), names(df))
    for name in v_names
        # Apply ans_mapping.
        df[:, "$(name)_new"] = [ans_mapping[x] for x in df[:, name]]
        select!(df, :, "$(name)_new" => name)
    end

    let
        scores(items::Items) = get_scores(df, items; average=false)

        df[:, :challenge] = scores(challenge) # Challenge.
        df[:, :commitment] = scores(commitment) # Commitment.
        df[:, :emotional_control] = scores(emotional_control) # Control.
        df[:, :life_control] = scores(life_control) # Control.
        df[:, :confidence_in_abilities] = scores(confidence_in_abilities) # Confidence.
        df[:, :interpersonal_confidence] = scores(interpersonal_confidence) # Confidence.
    end

    select!(df, :id, :completed_at,
        :challenge, :commitment, :emotional_control,
        :life_control, :confidence_in_abilities, :interpersonal_confidence
    )
    return df
end

end # module
