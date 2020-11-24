module GitLab

import JSON2

using Codex
using HTTP
using HTTP: Response

## TODO: Remove **all** pipeline_schedules before adding a new one.

struct Config
    token::AbstractString # GitLab token.
    url::AbstractString # GitLab URL.
end

auth_header(config::Config) = Dict("PRIVATE-TOKEN" => config.token)
form(params) = HTTP.Form(nt2dict(params))
json(r::Response) = JSON2.read(String(r.body))

"""
    list_schedules(config::Config, project_id::Int) -> Array

Returns an array of named tuples `(id = ..., description = ..., ...)`.
"""
function list_schedules(config::Config, project_id::Int)::Array
    r = HTTP.request("GET",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules",
        auth_header(config)
    )
    list = json(r)
end

"""
    create_schedule(config::Config, project_id::Int, params::NamedTuple) -> NamedTuple

"""
function create_schedule(config::Config, project_id::Int, params::NamedTuple)::NamedTuple
    r = HTTP.request("POST",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules",
        auth_header(config),
        form(params)
    )
    json(r)
end

"""
    delete_schedule(config::Config, project_id::Int, schedule_id::Int)

"""
function delete_schedule(config::Config, project_id::Int, schedule_id::Int)
    r = HTTP.request("DELETE",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules/$schedule_id",
        auth_header(config)
    )
    json(r)
end

end # module
