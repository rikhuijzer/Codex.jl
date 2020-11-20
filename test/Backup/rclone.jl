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
    
    exitcode, out, err = Backup.sync(source, target)
    @test exitcode == 0
    @test contains(err, "Copied (new)")
end
