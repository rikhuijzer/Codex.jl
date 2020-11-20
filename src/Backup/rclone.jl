using Codex

function capture_streams(f)
    _stdout, _stderr = STDOUT, STDERR
    stdout_rd, stdout_wr = redirect_stdout()
    stderr_rd, stderr_wr = redirect_stderr()

    # buf combines the stdout and stderr
    buf, buf_stdout, buf_stderr = IOBuffer(), IOBuffer(), IOBuffer()

    # the signature of the callback is cb(stream, n)
    function cb_stdout(s,n)
        bytes = read(s,n)
        write(buf_stdout, bytes)
        write(buf, bytes)
        false
    end
    Base.start_reading(stdout_rd, cb_stdout)

    function cb_stderr(s,n)
        bytes = read(s,n)
        write(buf_stderr, bytes)
        write(buf, bytes)
        false
    end
    Base.start_reading(stderr_rd, cb_stderr)

    ret = try
        f()
    catch e
        println("ERROR in capture_streams(): $e")
    finally
        # read and restore
        redirect_stdout(_stdout)
        redirect_stderr(_stderr)

        close(stdout_wr)
        close(stderr_wr)

        #stdout_buf = readstring(stdout_rd)
        #stderr_buf = readstring(stderr_rd)

        close(stdout_rd)
        close(stderr_rd)
    end
    ret, takebuf_string(buf), takebuf_string(buf_stdout), takebuf_string(buf_stderr)
end


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
    sync(a::AbstractString, b::AbstractString) -> Tuple

Make source and dest identical, modifying destination only.
"""
function sync(a::AbstractString, b::AbstractString)::Tuple
    cmd = `rclone sync $a $b --verbose`
    f(out, err) = pipeline(cmd, stdout=out, stderr=err)
    Codex.stdout_stderr(f)
end
