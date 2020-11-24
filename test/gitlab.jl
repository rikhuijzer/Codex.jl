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
        schedules = GitLab.enforce_schedules(project, [param, param]) 
        @test GitLab.n_schedules(project) == 2
        @test schedules[1].active == false

        schedule = GitLab.Schedule(project, schedules[1].id)
        param = (key = "test_key", value = "test_value")
        # Smoke test.
        GitLab.create_schedule_variable(schedule, param)
    end
end
