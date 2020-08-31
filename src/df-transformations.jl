using CategoricalArrays
using DataFrames: ColumnIndex

export 
    order_with

"""
    order_with(df::DataFrame, col::ColumnIndex, ordering::Array)::DataFrame

Enforces that the column `col` of `df` is ordered in the same way as `ordering`.
"""
function order_with(df::DataFrame, col::T, ordering::Array)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    df[!, col] = CategoricalArray(df[!, col], ordered=true)
    levels!(df[!, col], ordering)
    sort!(df, [col])
    df
end

"""
    enforce_ordering(df::DataFrame, col::ColumnIndex, ordering::Array)::DataFrame

Enforces that the column `col` of `df` is ordered in the same way and contains the same elements as `ordering`.
"""
function enforce_ordering(df::DataFrame, col::T, ordering::Array)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    df
end
