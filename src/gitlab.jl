module GitLab

import JSON2

using Codex
using HTTP
using HTTP: Response

struct Config
    token::AbstractString
    url::AbstractString
end

struct Project
    config::Config
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

struct Variable
    schedule::Schedule
    key::AbstractString
end
variable_url(v::Variable) = 
    "$(schedule_url(v.schedule))/variables/$(v.key)" 

auth_header(config::Config) = Dict("PRIVATE-TOKEN" => config.token)
auth_header(p::Project) = auth_header(p.config)
auth_header(s::Schedule) = auth_header(s.project)
auth_header(v::Variable) = auth_header(v.schedule)

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
    enforce_schedules(p::Project, params::Vector) -> Vector{NamedTuple}

Enforce schedules for `project_id` as defined by `params`.
For example, `params = [(description = "A", ...), (description = "B", ...)]`.
"""
function enforce_schedules(p::Project, params::Vector)::Vector{NamedTuple}
    list = list_schedules(p)
    [delete_schedule(Schedule(p, nt.id)) for nt in list]
    @assert n_schedules(p) == 0
    [create_schedule(p, param) for param in params]
end

"""
    edit_schedule_variable(v::Variable, param::NamedTuple) -> NamedTuple

"""
function edit_schedule_variable(v::Variable, param::NamedTuple)::NamedTuple
    r = HTTP.request("PUT", variable_url(v), auth_header(v), form(param))
    nt = json(r)
    @assert param[:value] == nt[:value]
    nt
end

end # module
