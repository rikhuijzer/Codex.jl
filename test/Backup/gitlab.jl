using Codex.Backup.GitLab
using Test

GitLab = Codex.Backup.GitLab

@testset "GitLab" begin
    nt = (a = 3, b = 4)
    @test contains(GitLab.form_data(nt), raw"""--form a:"3" """)
end
