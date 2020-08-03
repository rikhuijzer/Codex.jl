export 
    apply,
    dirparent,
    project_root,
    rmextension

"""
    apply(functions, object)
    apply(functions)::Function

Applies `functions` to `object`.
The functions are applied in order, unlike the behaviour of function composition.
For partial declarations in `Base`, see issue #35052 or `endswith(suffix)`.
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
    project_root()::String

Returns root directory of the current Module.
This is usually also the root of the Git repository.
"""
project_root()::String = dirparent(pathof(Codex), 2)

rmextension(s::String)::String = s[1:findlast('.', s)-1]
