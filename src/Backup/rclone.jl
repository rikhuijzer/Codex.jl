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
    sync(a::AbstractString, b::AbstractString; flags=[""]) -> Tuple

Make source and dest identical, modifying destination only.
"""
function sync(a::AbstractString, b::AbstractString; flags=[""])::Tuple
    cmd = `rclone sync $a $b $(join(flags, ' '))`
    Codex.stdout_stderr(cmd)
end
