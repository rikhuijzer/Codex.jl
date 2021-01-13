function fix_age(x)::Int
    value = tryparse(Int, string(x))
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
