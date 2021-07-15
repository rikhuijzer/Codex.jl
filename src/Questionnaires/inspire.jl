module Inspire

using Codex.Questionnaires: Items, get_scores
using DataFrames

export mike2scores

# The scoring is determined by guessing by me.
# I expect to have made a few mistakes, but overall the scoring was reasonably after knowing
# the number of items per predictor; thanks to
# https://repository.tudelft.nl/view/tno/uuid:98d97d5c-ff8e-4f26-9fba-f993bc585d39.
# For coping, the last 4 items seem to be reversed and added later by someone.
# Those are ignored.

coping_flexibility = Items(1:36, [])

emotional_stability = Items(
    [41, 44, 49, 50, 52, 54, 56],
    [42, 43, 45, 46, 47, 48, 51, 53, 55]
)

optimism = Items(
    [61, 63, 69],
    [58, 59, 67]
)

social_competence = Items(
    [57, 60, 62, 64, 65, 66, 68, 70],
    []
)

self_efficacy = Items(71:83, [])

self_reflection = Items(
    [88, 90, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103],
    [84, 85, 86, 87, 91, 92, 89]
)

function mike2scores(df::DataFrame)
    new_df = DataFrame(df)
    # Not using Query since precompilation would be slow on all these cols.
    if !("completed_at" in names(new_df))
        # Cleaning up the 2018 data.
        new_df[:, :completed_at] = repeat([""], nrow(new_df))
        select!(new_df, :id, :completed_at, Not([:id, :completed_at]))
        new_df = filter(:id => x -> !contains(x, "unknown"), new_df)
    end

    new_df[:, :coping_flexibility] = get_scores(new_df, coping_flexibility)
    new_df[:, :emotional_stability] = get_scores(new_df, emotional_stability)
    new_df[:, :optimism] = get_scores(new_df, optimism)
    new_df[:, :social_competence] = get_scores(new_df, optimism)
    new_df[:, :self_efficacy] = get_scores(new_df, self_efficacy)
    new_df[:, :self_reflection] = get_scores(new_df, self_reflection)

    scored = select(new_df, :id, :completed_at,
        :coping_flexibility, :emotional_stability, :optimism,
        :social_competence, :self_efficacy, :self_reflection
    )
    # This could have been done above, but I mistakenly used `disallowmissing`
    # instead and went from there.
    dropmissing!(scored)
    scored
end

end # module
