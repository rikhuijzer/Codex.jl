using Codex.Backup.GitLab
using Dates
using Test

GitLab = Codex.Backup.GitLab

@testset "GitLab" begin
    # Allow tests to pass locally when GITLAB_TOKEN is not set.
    if "CI" in keys(ENV) || "GITLAB_TOKEN" in keys(ENV)
        config = GitLab.Config(ENV["GITLAB_TOKEN"], "https://gitlab.com")
        project_id = 22670750

        # Without this, we cannot be sure that `delete_schedule` works.
        @test GitLab.create_schedule(config, project_id, 
            (description = "Test", ref = "master", cron = "0 1 * * *")
        ).description == "Test"

        for s in GitLab.list_schedules(config, project_id)
            GitLab.delete_schedule(config, project_id, s.id)
        end

        @test length(GitLab.list_schedules(config, project_id)) == 0

        @test GitLab.create_schedule(config, project_id, 
            (description = string(Dates.now()), ref = "master", 
                cron = "0 1 * * *", active = "false")
        ).active == false

        @test length(GitLab.list_schedules(config, project_id)) == 1
    end
end
