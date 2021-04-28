"""
    fix_age(x::AbstractString)::Int

Return age after parsing `x`.

```jldoctest
julia> fix_age = Codex.Questionnaires.fix_age;

julia> fix_age("27-jun-93")
26

julia> fix_age("1993")
26

julia> fix_age("23 jaar")
23
```
"""
function fix_age(x::AbstractString)::Int
    x = string(x)
    if endswith(x, "jaar")
        x = x[1:end-4]
    end
    value = tryparse(Int, x)
    if !isnothing(value) && 18 < value && value < 65
        return value
    elseif !isnothing(value) && 65 < value
        return 2019 - value
    elseif x == "27-jun-93"
        return 2019 - 1993
    else
        throw(MissingException("No known fix for the age $x"))
    end
end

fix_age(x::Int) = x

"""
    unify_demographics(df)

Returns an simplified and unified DataFrame which is the same for 2018, 2019 and 2020.
It may throw out some data which we don't need at the time of writing.
"""
function unify_demographics(df)
    df.age = fix_age.(df.v1)
    select!(df, :id, :completed_at, :age)
    df
end
