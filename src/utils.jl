using DataFrames

export 
    apply,
    dirparent,
    has_duplicates,
    map_by_df,
    nofalse,
    project_root,
    rmextension

"""
    apply(fns, obj)
    apply(fns)::Function

Apply functions `fns` to object `obj`.
The functions are applied in order, unlike the behaviour of function composition.
Also defines partial function.
(For partial declarations in `Base`, see issue #35052 or `endswith(suffix)`.)
"""
apply(fns, obj) = ∘(reverse(fns)...)(obj)
apply(fns) = obj -> apply(fns, obj)

"""
    dirparent(path)::String
    dirparent(path, n)::String

Returns the parent or `n`-th parent directory for `path`, where `path` can be a file or directory.

```@example
dirparent("/a/b/c")
```
"""
dirparent(path)::String = splitdir(endswith(path, '/') ? path[1:end-1] : path)[1]
dirparent(path, n)::String = ∘(repeat([dirparent], n)...)(path)

"""
    has_duplicates(A::AbstractArray)::Bool

Returns whether `A` contains duplicates.
"""
has_duplicates(A::AbstractArray) = length(A) != length(unique(A))

"""
    project_root()::String

Returns root directory of the current Module.
This is usually also the root of the Git repository.
"""
project_root()::String = dirparent(pathof(Codex), 2)

rmextension(s::String)::String = s[1:findlast('.', s)-1]

"""
    map_by_df(a::Array, df::DataFrame, from::Symbol, to::Symbol; missing=nothing)::Array

Map array `a` by using arrays `from` and `to`.
Leaving all elements of `a` for which no match is found unchanged.
"""
function map_by_df(a::Array, df::DataFrame, from::Symbol, to::Symbol)::Array
    if typeof(a) != typeof(df[!, from])
        @warn TypeError(:map_by_df, "trying to map `a` with `from`", typeof(a), typeof(df[!, from]))
    end
    function map_element(e)
        filtered = filter(row -> row[from] == e, df)
        nrow(filtered) == 1 ? first(filtered)[to] : e
    end
    map(map_element, a)
end
