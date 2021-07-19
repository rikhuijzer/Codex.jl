struct Output
    exitcode::Int
    stdout::String
    stderr::String
end

"""
    apply(fns, obj)
    apply(fns) -> Function
    apply(fn::Function, nt::NamedTuple) -> NamedTuple

Apply function `fn` or functions `fns` to object.
The functions are applied in order, unlike the behaviour of function composition.
Also defines partial function.
(For partial declarations in `Base`, see issue #35052 or `endswith(suffix)`.)
"""
apply(fns, obj) = ∘(reverse(fns)...)(obj)
apply(fns) = obj -> apply(fns, obj)

apply(fn::Function, nt::NamedTuple)::NamedTuple = (; Dict([(t[1], string(t[2])) for t in zip(keys(nt), nt)])...)

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
    map_by_df(a::Array, df::DataFrame, from::Symbol, to::Symbol; missing=nothing)::Array

Return array `A` where all elements are mapped `from` `U` `to` `V`.
Leaving all elements of `A` for which no match is found unchanged.

!! Note-to-self. This is dumb function. Use joins instead.
"""
function map_by_df(A::AbstractArray, df::DataFrame, from::Symbol, to::Symbol)::Array
    U = df[:, from]

    if eltype(A) != eltype(U)
        @warn TypeError(:map_by_df, "trying to map `A` with `from`", typeof(A), typeof(U))
    end
    function map_element(e)
        if ismissing(e)
            return missing
        else
            filtered = filter(row -> row[from] == e, df)
            nrow(filtered) == 1 ? first(filtered)[to] : e
        end
    end
    map(map_element, A)
end

rmextension(path::AbstractString) = string(splitext(path)[1])::String

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
    output(f::Function) -> Output
    output(cmd::Cmd) -> Output

Evaluates `f` of type `f(out::String, err::String)::CmdRedirect` or `cmd::Cmd`.
"""
function output(f::Function)::Output
    # Don't need fancy live scrolling log because it runs in CI anyway.
    out = IOBuffer()
    err = IOBuffer()
    take_str!(io) = String(take!(io))
    exitcode = 99
    try 
        process = run(f(out, err))
        exitcode = process.exitcode
    catch
        @error "Error while running function. Printing stdout and stderr:"
        out_s = take_str!(out)
        println("stdout = ")
        println.(split(out_s, '\n'))
        err_s = take_str!(err)
        println("stderr = ")
        println.(split(err_s, '\n'))
        return Output(-1, out_s, err_s)
    end

    out_s = take_str!(out)
    err_s = take_str!(err)
    Output(exitcode, out_s, err_s)
end

output(cmd::Cmd)::Output = output((out, err) -> pipeline(cmd, stdout=out, stderr=err))

nt2dict(nt::NamedTuple)::Dict = Dict(zip(keys(nt), nt))

function graded()
    q = [:P1, :P2, :P3, :P4, :P5, :M1, :M2, :M3, :M4, :M5, :C1, :Penalty]
    s = [
        0.5, # P1 [0.5]
        0.75, # P2 [0.75]
        0.5, # P3 [0.5]
        1, # P4 [1.5]
        1, # P5 [1.0]
        0.5, # M1 [0.5]
        1, # M2 [1.5]
        1, # M3 [1.0]
        0.25, # M4 [0.25]
        1.5, # M5 [1.5]
        1, # C1 [1.0]
        0, # Penalty [-0.5]
    ]
    max = [0.5, 0.75, 0.5, 1.5, 1.0, 0.5, 1.5, 1.0, 0.25, 1.5, 1.0, -0.5]

    df = DataFrame(; q, s, max)
    @show df
    println()
    @show sum(df.s)
    nothing
end
