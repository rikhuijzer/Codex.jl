module GitLab

import JSON2

using Codex
using HTTP
using HTTP: Response

export
    enforce_schedules

struct Config
    token::AbstractString
    url::AbstractString
end

struct Project
    config::Config
    # Not using urlencoded NAMESPACE/PROJECT_NAME for simplicity.
    project_id::Int
end
project_url(p::Project) = 
    "$(p.config.url)/api/v4/projects/$(p.project_id)"

struct Schedule
    project::Project
    schedule_id::Int
end
schedule_url(s::Schedule) = 
    "$(project_url(s.project))/pipeline_schedules/$(s.schedule_id)"

auth_header(config::Config) = Dict("PRIVATE-TOKEN" => config.token)
auth_header(p::Project) = auth_header(p.config)
auth_header(s::Schedule) = auth_header(s.project)

# All values are coverted to string to avoid errors when using `active = false`.
form(param::NamedTuple) = HTTP.Form(nt2dict(apply(string, param)))
json(r::Response) = JSON2.read(String(r.body))

"""
    list_schedules(p::Project) -> Vector{NamedTuple}

Returns an array of named tuples `(id = ..., description = ..., ...)`.
For details, see
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#get-all-pipeline-schedules>.
"""
function list_schedules(p::Project)::Vector{NamedTuple}
    endpoint = "$(project_url(p))/pipeline_schedules"
    r = HTTP.request("GET", endpoint, auth_header(p))
    list = json(r)
end
n_schedules(p::Project) = length(GitLab.list_schedules(p))

"""
    create_schedule(p::Project, param::NamedTuple) -> NamedTuple

For `param`, see 
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#create-a-new-pipeline-schedule>.
"""
function create_schedule(p::Project, param::NamedTuple)::NamedTuple
    endpoint = "$(project_url(p))/pipeline_schedules"
    r = HTTP.request("POST", endpoint, auth_header(p), form(param))
    nt = json(r)
    for key in keys(param)
        @assert param[key] == nt[key] "$key: $(param[key]) != $(nt[key])"
    end
    nt
end

"""
    delete_schedule(s::Schedule) -> NamedTuple

Deletes `schedule_id` for `project_id`.
"""
function delete_schedule(s::Schedule)::NamedTuple
    r = HTTP.request("DELETE", schedule_url(s), auth_header(s))
    json(r)
end

"""
    create_schedule_variable(v::Variable, param::NamedTuple) -> NamedTuple

For param, see 
<https://docs.gitlab.com/ee/api/pipeline_schedules.html#create-a-new-pipeline-schedule-variable>.
This codebase does not define edit or delete methods because the variables
are deleted via `enforce_schedules`.
"""
function create_schedule_variable(s::Schedule, param::NamedTuple)::NamedTuple
    endpoint = "$(schedule_url(s))/variables"
    r = HTTP.request("POST", endpoint, auth_header(s), form(param))
    nt = json(r)
    @assert param[:value] == nt[:value]
    nt
end

"""
    create_schedule_variable(s::Schedule, params::Vector) -> Vector

Set multiple variables via `params`.
For example,
```
params = [
    (key = "key1", value = "value1"),
    (key = "key2", value = "value2")
]
```
"""
function create_schedule_variable(s::Schedule, params::Vector)::Vector
    [create_schedule_variable(s::Schedule, param) for param in params]
end

"""
    enforce_schedules(p::Project, params::Vector; variables=[]) -> Vector{NamedTuple}

Enforce schedules for `p` as defined by `params`.
Variables per schedule can be set via `variables`.
For example,
```
params = [
    (description = "A", ...),
    (description = "B", ...)
]
variables = [
    [(key = "key1", value = "value1")], # for schedule A.
    [(key = "key1", value = "value2")] # for schedule B.
]
```
"""
function enforce_schedules(p::Project, params::Vector; variables=[])::Vector{NamedTuple}
    [delete_schedule(Schedule(p, nt.id)) for nt in list_schedules(p)]
    @assert n_schedules(p) == 0
    list = [create_schedule(p, param) for param in params]
    [create_schedule_variable(Schedule(p, t[2].id), variables[t[1]]) for t in enumerate(list)]
    list 
end

end # module
