using Codex.GitLab
using Dates
using Test

GitLab = Codex.GitLab

@testset "GitLab" begin
    # Allow tests to pass locally without GITLAB_TOKEN.
    if "CI" in keys(ENV) || "GITLAB_TOKEN" in keys(ENV)
        config = GitLab.Config(ENV["GITLAB_TOKEN"], "https://gitlab.com")
        project_id = 22670750
        project = GitLab.Project(config, project_id)

        # Ensure that `enforce_schedule` also deletes.
        @test GitLab.create_schedule(project,
            (description = "Test", ref = "master", cron = "0 1 * * *")
        ).description == "Test"

        param = (description = string(Dates.now()), ref = "master", 
            cron = "0 2 * * *", active = false)
        params = [
            (description = string(Dates.now(), "-1"), ref = "master",
            cron = "0 1 * * *", active = false),
            (description = string(Dates.now(), "-2"), ref = "master",
            cron = "0 2 * * *", active = false)
        ]
        variables = [
            [(key = "key1", value = "value1")], 
            [(key = "key2", value = "value2")] 
        ]
        schedules = GitLab.enforce_schedules(project, params; variables) 
        @test GitLab.n_schedules(project) == 2
        @test schedules[1].active == false
    end
end
