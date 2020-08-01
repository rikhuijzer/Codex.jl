export 
    dirparent,
    project_root

"""
    dirparent(path)::String
    dirparent(path, [n])::String

Returns the parent or `n`-th parent directory for `path`, where `path` can be a file or directory.
"""
dirparent(path)::String = splitdir(endswith(path, '/') ? path[1:end-1] : path)[1]
dirparent(path, n)::String = ∘(repeat([dirparent], n)...)(path)

"""
    project_root()::String

Returns root directory of the current Module.
This is usually also the root of the Git repository.
"""
project_root()::String = dirparent(pathof(Codex), 2)
