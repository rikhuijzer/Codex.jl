module GitLab

import JSON2

using Codex
using HTTP
using HTTP: Response

## TODO: Assert response.params == params. 

struct Config
    token::AbstractString
    url::AbstractString
end

auth_header(config::Config) = Dict("PRIVATE-TOKEN" => config.token)
form(params) = HTTP.Form(nt2dict(params))
json(r::Response) = JSON2.read(String(r.body))

"""
    list_schedules(config::Config, project_id::Int) -> Array{NamedTuple,1}

Returns an array of named tuples `(id = ..., description = ..., ...)`.
For `params`, see
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#get-all-pipeline-schedules>.
"""
function list_schedules(config::Config, project_id::Int)::Array{NamedTuple,1}
    r = HTTP.request("GET",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules",
        auth_header(config)
    )
    list = json(r)
end

"""
    create_schedule(config::Config, project_id::Int, params::NamedTuple) -> NamedTuple

For `params`, see 
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#create-a-new-pipeline-schedule>.
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
    delete_schedule(config::Config, project_id::Int, schedule_id::Int) -> NamedTuple

Deletes `schedule_id` for `project_id`.
"""
function delete_schedule(config::Config, project_id::Int, schedule_id::Int)::NamedTuple
    r = HTTP.request("DELETE",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules/$schedule_id",
        auth_header(config)
    )
    json(r)
end

end # module
