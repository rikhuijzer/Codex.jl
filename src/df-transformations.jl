using CategoricalArrays
using DataFrames: ColumnIndex

export 
    order_with,
    Ordering,
    enforce_ordering

struct Ordering
    col::T where {T<:ColumnIndex}
    newlevels::Union{Vector, Nothing}
end

"""
    order_with(df::DataFrame, orderings::Array{Ordering,1})::DataFrame

Sorts `df` by `cols` in the order given by `orderings`, see the documentation of `DataFrames.sort`.
Let `o` be an `ordering::Ordering`.
Enforces that the columns `o.col` of `df` are ordered according to `o.newlevels` if `o.newlevels` is not `missing`.
"""
function order_with(df::DataFrame, orderings::Array{Ordering,1})::DataFrame
    df = DataFrame(df)
    for o in orderings
        if o.newlevels != nothing
            df[!, o.col] = CategoricalArray(df[!, o.col])
            levels!(df[!, o.col], o.newlevels; allowmissing=true)
        end
    end
    sort!(df, map(o -> o.col, orderings))
    for o in orderings
        if o.newlevels != nothing
             df[!, o.col] = categorical2simple(df[!, o.col])
        end
    end
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
    # look at push!(df, (1, "M")) 
    df
end
