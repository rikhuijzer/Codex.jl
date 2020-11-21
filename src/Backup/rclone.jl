using Codex

"""
    set_rclone_config(config::AbstractString)

Set the rclone configuration by writing `config` to the rclone config file.
"""
function set_rclone_config(config::AbstractString)
    file = last(split(read(`rclone config file`, String), ':'))
    
    open(file, "w") do io
        write(io, config)    
    end
end

"""
    rcopy(a::AbstractString, b::AbstractString; flags=[""]) -> Tuple

Wrapper around `rclone copy`.
"""
function rcopy(a::AbstractString, b::AbstractString; flags=[""])::Tuple
    cmd = `rclone copy $a $b $(join(flags, ' '))`
    Codex.stdout_stderr(cmd)
end

"""
    rsync(a::AbstractString, b::AbstractString; flags=[""]) -> Output

Wrapper around `rclone sync`.
"""
function rsync(a::AbstractString, b::AbstractString; flags=[""])::Output
    cmd = `rclone sync $a $b $(join(flags, ' '))`
    Codex.output(cmd)
end
