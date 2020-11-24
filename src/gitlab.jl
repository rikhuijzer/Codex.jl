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
# Make all values string
# All values are coverted to string to avoid errors when using `active = false`.
form(params) = HTTP.Form(nt2dict(apply(string, params)))
json(r::Response) = JSON2.read(String(r.body))

"""
    list_schedules(config::Config, project_id::Int) -> Vector{NamedTuple}

Returns an array of named tuples `(id = ..., description = ..., ...)`.
For `params`, see
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#get-all-pipeline-schedules>.
"""
function list_schedules(config::Config, project_id::Int)::Vector{NamedTuple}
    r = HTTP.request("GET",
        "$(config.url)/api/v4/projects/$project_id/pipeline_schedules",
        auth_header(config)
    )
    list = json(r)
end
n_schedules(config, project_id) = length(GitLab.list_schedules(config, project_id))

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
    nt = json(r)
    for key in keys(params)
        @assert params[key] == nt[key] "$key: $(params[key]) != $(nt[key])"
    end
    nt
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

"""
    enforce_schedules(config::Config, project_id::Int, params::Vector) -> Vector{NamedTuple}

Enforce schedules for `project_id` as defined by `params`.
For example, `params = [(description = "A", ...), (description = "B", ...)]`.
"""
function enforce_schedules(config::Config, project_id::Int, params::Vector)::Vector{NamedTuple}
    schedules = list_schedules(config, project_id)
    [delete_schedule(config, project_id, s.id) for s in schedules]
    @assert n_schedules(config, project_id) == 0
    [create_schedule(config, project_id, p) for p in params]
end

end # module
