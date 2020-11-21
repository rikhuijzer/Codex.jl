using Test

@testset "Backup" begin
    include("gitlab.jl")
    include("rclone.jl")
end
