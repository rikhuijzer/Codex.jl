using Statistics

export
    cohens_d

"""
    cohens_d(μ1, μ2, s) 
    cohens_d(n1, μ1, s1, n2, μ2, s2)
    cohens_d(A::Array, B::Array)

Effect size according to Cohen's d for means `μ1` and `μ2`, number of samples `n1` and `n2`, and standard deviations `s1` and `s2` for respectively group 1 and 2.
"""
cohens_d(μ1, μ2, s) = (μ1 - μ2) / s
s_pooled(n1, s1, n2, s2) = sqrt(
    ( (n1 - 1) * s1^2 + (n2 - 1) * s2^2 ) /
    ( n1 + n2 - 2)
)
s_pooled(A::Array, B::Array) = s_pooled(length(A), std(A), length(B), std(B))
cohens_d(A::Array, B::Array) = cohens_d(mean(A), mean(B), s_pooled(A, B))
cohens_d(n1, μ1, s1, n2, μ2, s2) = cohens_d(μ1, μ2, s_pooled(n1, s1, n2, s2))

"""
    accuracy(trues, preds)::Number

The number of correct predictions in `pred` (by comparing `true` to `prediction`) divided by the total number of predictions.
"""
accuracy(trues, preds)::Number = count(trues .== preds) / length(preds)
