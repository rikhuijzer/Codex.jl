using Codex.Backup
using Test

Backup = Codex.Backup

@testset "rclone" begin
    tmp = mktempdir()
    
    source = mkpath(joinpath(tmp, "a"))
    open(joinpath(source, "tmp.txt"), "w") do io
        write(io, "lorem")
    end
    target = mkpath(joinpath(tmp, "b"))
    
    flags = ["--verbose", "--ignore-existing"]
    output = Backup.rsync(source, target; flags)
    @test output.exitcode == 0
    @test contains(output.stderr, "Copied (new)")
end
