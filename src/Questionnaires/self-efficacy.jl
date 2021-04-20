"""
    self_efficacy2scores(echo::DataFrame)::DataFrame

Return the scores for the echo questionnaire, which is about self-efficacy.
None of the items appear to be reversed, so this method just returns the sum.

This function assumes questions [1, 14] which holds for all questionnaires in from 2018 to the time of writing (2021).
"""
function self_efficacy2scores(echo::DataFrame)::DataFrame
    df = disallowmissing(echo)
    questions = [Symbol("v$i") for i in 1:14]
    cols = [df[:, col] for col in questions]
    df.score = [sum(t) for t in zip(cols...)]
    select!(df, Not(questions))
end
