using DataFrames
using Dates

export 
    Output,
    apply,
    categorical2simple,
    dirparent,
    has_duplicates,
    map_by_df,
    nofalse,
    project_root,
    rmextension,
    today

struct Output
    exitcode::Int
    stdout::String
    stderr::String
end

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
    categorical2simple(A::CategoricalArray)

Returns simple Julia collection for the CategoricalArray `a`.
"""
categorical2simple(A) = map(x -> x === missing ? missing : get(x), A)

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

today() = Dates.format(Dates.now(), DateFormat("yyyy-mm-dd"))

"""
    rescale(a, a_l, a_u, b_l, b_u)::Number

Apply feature scaling to `a` from the range `[a_l, a_u]` to the range `[b_l, b_u]`.
"""
rescale(a, a_l, a_u, b_l, b_u) = b_l + ( ((a - a_l)*(b_u - b_l)) / (a_u - a_l) )

"""
    nrow_per_group(df::DataFrame, group::Symbol; col1="group", col2="nrow")::DataFrame

Return the group name and the number of rows per group in `df`.
"""
function nrow_per_group(df, group::Symbol; col1="group", col2="nrow")::DataFrame 
	grouped = groupby(df, group)
	out = DataFrame([(col1 = first(k), col2 = nrow(g)) for (k, g) in zip(keys(grouped), grouped)])
    select(out, :col1 => col1, :col2 => col2)
end


"""
    stdout_stderr(f::Function) -> Output
    stdout_stderr(cmd::Cmd) -> Output

Evaluates `f` of type `f(out::String, err::String)::CmdRedirect` or `cmd::Cmd`.
"""
function stdout_stderr(f::Function)::Output
    # Don't need fancy live scrolling log because it runs in CI anyway.
    out = IOBuffer()
    err = IOBuffer()
    take_str!(io) = String(take!(io))
    exitcode = 99
    try 
        process = run(f(out, err))
        exitcode = process.exitcode
    catch
        @error "Error while running $cmd. Printing stdout and stderr:"
        out_s = take_str!(out)
        err_s = take_str!(err)
        return Output(-1, out_s, err_s)
    end

    out_s = take_str!(out)
    err_s = take_str!(err)
    Output(exitcode, out_s, err_s)
end

stdout_stderr(cmd::Cmd)::Output = 
    stdout_stderr((out, err) -> pipeline(cmd, stdout=out, stderr=err))
