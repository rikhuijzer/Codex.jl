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
    
    output = Backup.rsync(source, target; flags = ["--verbose"])
    @test output.exitcode == 0
    @test contains(output.stderr, "Copied (new)")
end
