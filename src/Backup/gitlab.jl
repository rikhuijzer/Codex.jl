module GitLab

using Codex

"""
    form_data(attrs::NamedTuple) -> String

Prepares attributes to be passed to as Form data via cURL.
For example, converts `(a = 3, b = 4)` into
```
--form a="3" \\
--form b="4" 
```
"""
function form_data(attrs::NamedTuple)::String
    form_items = ["--form $(t[1]):\"$(t[2])\"" for t in zip(keys(attrs), attrs)]
    join(form_items, " \\\n ")
end

"""
    set_schedule(url::String, project_id::Int, schedule_id::Int, attrs::NamedTuple) -> Output

See https://docs.gitlab.com/ee/api/pipeline_schedules.html.
Requires `ENV["GITLAB_PAT"]` to be set.
"""
function set_schedule(url::String, project_id::Int, schedule_id::Int, attrs::NamedTuple)::Output
    pat = ENV["GITLAB_PAT"]
    cmd = `curl \
        --request PUT \
        --header "PRIVATE-TOKEN: $pat" \
        $(unpack_attributes(attrs)) \
        $url/api/v4/projects/$project_id/pipeline_schedules/$schedule_id
    `
    output(cmd)
end

end # module
