using CategoricalArrays
using DataFrames: ColumnIndex

export 
    Ordering,
    add_missing,
    order_with

struct Ordering
    col::T where {T<:ColumnIndex}
    newlevels::Union{Vector, Nothing}
end

"""
    add_missing(df::DataFrame, actual::ColumnIndex, expected::Array)::DataFrame

Add rows to ensure that for all elements in `expected`, the same element exists in `actual`.
"""
function add_missing(df::DataFrame, actual::T, expected::AbstractArray)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    for e in expected
        if !(e in df[!, actual]) 
            allowmissing!(df)
            row = Tuple([[e]; repeat([missing], ncol(df) - 1)])
            push!(df, row)
        end
    end
    df
end

"""
    add_missing(df::DataFrame, actual::ColumnIndex, expected::Array, by::ColumnIndex)::DataFrame

Add rows to ensure that for all elements in `expected`, the same element exists in `actual` for each unique element of `by`.
"""
function add_missing(df::DataFrame, actual::T, expected::AbstractArray, by::T)::DataFrame where {T<:ColumnIndex}
    df = DataFrame(df)
    function process_by(u)::DataFrame
        subset = filter(by => v -> v == u, df)
        subset = select!(subset, Not(by))
        subset = add_missing(subset, actual, expected)
        subset[!, by] = repeat([u], nrow(subset))
        subset
    end
    uniques = unique(df[!, by])
    reduce(append!, map(process_by, uniques))
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
            df[!, o.col] = categorical(df[!, o.col])
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
