using Codex.GitLab
using Dates
using Test

GitLab = Codex.GitLab

@testset "GitLab" begin
    # Allow tests to pass locally without GITLAB_TOKEN.
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
        @test GitLab.n_schedules(config, project_id) == 0

        params = (description = string(Dates.now()), ref = "master", 
            cron = "0 1 * * *", active = false)
        @test GitLab.create_schedule(config, project_id, params).active == false
        @test GitLab.n_schedules(config, project_id) == 1

        GitLab.enforce_schedules(config, project_id, [params, params]) 
        @test GitLab.n_schedules(config, project_id) == 2
    end
end
