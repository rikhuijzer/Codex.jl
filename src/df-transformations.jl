using CategoricalArrays
using DataFrames: ColumnIndex

export 
    order_with,
    enforce_ordering

"""
    order_with(df::DataFrame, col::ColumnIndex, ordering::Array)::DataFrame

Enforces that the column `col` of `df` is ordered according to `newlevels`.
"""
function order_with(df::DataFrame, col::T, newlevels::Vector)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    df[!, col] = CategoricalArray(df[!, col])
    levels!(df[!, col], newlevels; allowmissing=true)
    sort!(df, [col])
    df[!, col] = categorical2simple(df[!, col])
    df
end

"""
    enforce_ordering(df::DataFrame, col::ColumnIndex, ordering::Array)::DataFrame

Enforces that the column `col` of `df` is ordered in the same way and contains the same elements as `ordering`.
"""
function enforce_ordering(df::DataFrame, col::T, ordering)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    if has_duplicates(df[!, col]) 
        @warn "enforce_ordering: DataFrame contains duplicates at column $col"
    end
    if length(df[!, col]) < length(ordering)
        @warn "enforce_ordering: DataFrame is missing elements at column $col"
    end
    df = order_with(df, col, ordering)
    df
end
