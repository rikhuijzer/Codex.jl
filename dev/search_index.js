var documenterSearchIndex = {"docs":
[{"location":"transformexport/#TransformExport","page":"TransformExport","title":"TransformExport","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Module to transform the data exported from the backend.","category":"page"},{"location":"transformexport/#Public","page":"TransformExport","title":"Public","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Modules = [Codex.TransformExport]\nPrivate = false","category":"page"},{"location":"transformexport/#Codex.TransformExport.process-Tuple{Any, Any}","page":"TransformExport","title":"Codex.TransformExport.process","text":"process(in_dir, out_dir; fns)\n\nProcesses the responses from the export folder, applies the functions fns and places the files at out_dir.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.read_csv-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.read_csv","text":"read_csv(path; delim)::DataFrame\n\nCopies CSV at path into memory.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.responses-Tuple{String}","page":"TransformExport","title":"Codex.TransformExport.responses","text":"responses(dir::String)::Dict{String,DataFrame}\n\nReturn responses for an export folder such as \"2020-08\".\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.rm_descriptions-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.rm_descriptions","text":"rm_descriptions(df)::DataFrame\n\nFind responses containing a description, for example 6 (heel erg), and remove the description.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.simplify-Tuple{DataFrames.DataFrame}","page":"TransformExport","title":"Codex.TransformExport.simplify","text":"simplify(df)::DataFrame\n\nRenames id column after removing extraneous rows and columns, that is, removes empty rows and  removes columns such as protocol_subscription_id, open_from and v2_1_timing.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.split_datetime-Union{Tuple{T}, Tuple{DataFrames.DataFrame, T}} where T<:Union{AbstractString, Signed, Symbol, Unsigned}","page":"TransformExport","title":"Codex.TransformExport.split_datetime","text":"split_datetime(df::DataFrame, datetime_col::ColumnIndex)::DataFrame\n\nSplit the datetime column datetime_col into two columns, namely one for date and one for time.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.substitute_names-Tuple{Any, DataFrames.DataFrame}","page":"TransformExport","title":"Codex.TransformExport.substitute_names","text":"substitute_names(df, with::DataFrame)::DataFrame\nsubstitute_names(with)::Function\n\nReplaces person_ids by the first name as listed in with.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Private","page":"TransformExport","title":"Private","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Modules = [Codex.TransformExport]\nPublic = false","category":"page"},{"location":"transformexport/#Codex.TransformExport._contains_description-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._contains_description","text":"_contains_description(col)::Bool\n\nReturn whether the column col contains descriptions.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._description_regex-Tuple{}","page":"TransformExport","title":"Codex.TransformExport._description_regex","text":"_description_regex()\n\nReturn regex for matching a description such as 1 (lorem) or 2 <br /> (ipsum).\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._rm_description-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._rm_description","text":"_rm_description(e::String)::String\n\nApply regex replace on element e.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._rm_descriptions-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._rm_descriptions","text":"_rm_descriptions(col)::Array{Int,1}\n\nApply a regex replace and type conversion to all elements of the column col. \n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.parsedatetime-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.parsedatetime","text":"parsedatetime(str)::DateTime\n\nParse a date and time string from the export to a Julia DateTime object.\n\n\n\n\n\n","category":"method"},{"location":"backup/#Backup","page":"Backup","title":"Backup","text":"","category":"section"},{"location":"backup/","page":"Backup","title":"Backup","text":"Module for automating backups.","category":"page"},{"location":"backup/#Public","page":"Backup","title":"Public","text":"","category":"section"},{"location":"backup/","page":"Backup","title":"Backup","text":"Modules = [Codex.Backup]\nPrivate = false","category":"page"},{"location":"backup/#Private","page":"Backup","title":"Private","text":"","category":"section"},{"location":"backup/","page":"Backup","title":"Backup","text":"Modules = [Codex.Backup]\nPublic = false","category":"page"},{"location":"backup/#Codex.Backup.rcopy-Tuple{AbstractString, AbstractString}","page":"Backup","title":"Codex.Backup.rcopy","text":"rcopy(a::AbstractString, b::AbstractString; flags=[\"\"]) -> Output\n\nWrapper around rclone copy.\n\n\n\n\n\n","category":"method"},{"location":"backup/#Codex.Backup.rsync-Tuple{AbstractString, AbstractString}","page":"Backup","title":"Codex.Backup.rsync","text":"rsync(a::AbstractString, b::AbstractString; flags=[\"\"]) -> Output\n\nWrapper around rclone sync.\n\n\n\n\n\n","category":"method"},{"location":"backup/#Codex.Backup.set_rclone_config-Tuple{AbstractString}","page":"Backup","title":"Codex.Backup.set_rclone_config","text":"set_rclone_config(config::AbstractString)\n\nSet the rclone configuration by writing config to the rclone config file.\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#GitLab","page":"GitLab","title":"GitLab","text":"","category":"section"},{"location":"gitlab/","page":"GitLab","title":"GitLab","text":"Julia interface to some endpoints of the GitLab API v4.","category":"page"},{"location":"gitlab/#Public","page":"GitLab","title":"Public","text":"","category":"section"},{"location":"gitlab/","page":"GitLab","title":"GitLab","text":"Modules = [Codex.GitLab]\nPrivate = false","category":"page"},{"location":"gitlab/#Codex.GitLab.enforce_schedules-Tuple{Codex.GitLab.Project, Vector{T} where T}","page":"GitLab","title":"Codex.GitLab.enforce_schedules","text":"enforce_schedules(p::Project, params::Vector; variables=[]) -> Vector{NamedTuple}\n\nEnforce schedules for p as defined by params. Variables per schedule can be set via variables. For example,\n\nparams = [\n    (description = \"A\", ...),\n    (description = \"B\", ...)\n]\nvariables = [\n    [(key = \"key1\", value = \"value1\")], # for schedule A.\n    [(key = \"key1\", value = \"value2\")] # for schedule B.\n]\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Codex.GitLab.enforce_variables-Tuple{Codex.GitLab.Project, Vector{T} where T}","page":"GitLab","title":"Codex.GitLab.enforce_variables","text":"enforce_variables(p::Project, variables::Vector) -> Vector\n\nEnforces variables for project p. For example, \n\nvariables = [\n    (key = \"key1\", value = \"value1\", protected = true),\n    (key = \"key2\", value = \"value2\", protected = false)\n]\n\nThis method can fail with key exists. Possibly because the create request is too quick.\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Private","page":"GitLab","title":"Private","text":"","category":"section"},{"location":"gitlab/","page":"GitLab","title":"GitLab","text":"Modules = [Codex.GitLab]\nPublic = false","category":"page"},{"location":"gitlab/#Codex.GitLab.create_schedule-Tuple{Codex.GitLab.Project, NamedTuple}","page":"GitLab","title":"Codex.GitLab.create_schedule","text":"create_schedule(p::Project, param::NamedTuple) -> NamedTuple\n\nFor param, see  https://docs.gitlab.com/ee/api/pipeline_schedules.html#create-a-new-pipeline-schedule.\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Codex.GitLab.create_schedule_variable-Tuple{Codex.GitLab.Schedule, NamedTuple}","page":"GitLab","title":"Codex.GitLab.create_schedule_variable","text":"create_schedule_variable(v::Variable, param::NamedTuple) -> NamedTuple\n\nFor param, see  https://docs.gitlab.com/ee/api/pipeline_schedules.html#create-a-new-pipeline-schedule-variable. This codebase does not define edit or delete methods because the variables are deleted via enforce_schedules.\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Codex.GitLab.create_schedule_variable-Tuple{Codex.GitLab.Schedule, Vector{T} where T}","page":"GitLab","title":"Codex.GitLab.create_schedule_variable","text":"create_schedule_variable(s::Schedule, params::Vector) -> Vector\n\nSet multiple variables via params. For example,\n\nparams = [\n    (key = \"key1\", value = \"value1\"),\n    (key = \"key2\", value = \"value2\")\n]\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Codex.GitLab.delete_schedule-Tuple{Codex.GitLab.Schedule}","page":"GitLab","title":"Codex.GitLab.delete_schedule","text":"delete_schedule(s::Schedule) -> NamedTuple\n\nDeletes schedule_id for project_id.\n\n\n\n\n\n","category":"method"},{"location":"gitlab/#Codex.GitLab.list_schedules-Tuple{Codex.GitLab.Project}","page":"GitLab","title":"Codex.GitLab.list_schedules","text":"list_schedules(p::Project) -> Vector{NamedTuple}\n\nReturns an array of named tuples (id = ..., description = ..., ...). For details, see https://docs.gitlab.com/ee/api/pipeline_schedules.html#get-all-pipeline-schedules.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Questionnaires","page":"Questionnaires","title":"Questionnaires","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Module for analysing the questionnaires.","category":"page"},{"location":"questionnaires/#Public","page":"Questionnaires","title":"Public","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Modules = [Codex.Questionnaires]\nPrivate = false","category":"page"},{"location":"questionnaires/#Private","page":"Questionnaires","title":"Private","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Modules = [Codex.Questionnaires]\nPublic = false","category":"page"},{"location":"questionnaires/#Codex.Questionnaires.dropouts-Tuple{String}","page":"Questionnaires","title":"Codex.Questionnaires.dropouts","text":"dropouts(raw_dir::String)::DataFrame\n\nReturns dropout data where all IDs are in the long identifier format.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.fix_age-Tuple{AbstractString}","page":"Questionnaires","title":"Codex.Questionnaires.fix_age","text":"fix_age(x::AbstractString)::Int\n\nReturn age after parsing x.\n\njulia> fix_age = Codex.Questionnaires.fix_age;\n\njulia> fix_age(\"27-jun-93\")\n26\n\njulia> fix_age(\"1993\")\n26\n\njulia> fix_age(\"23 jaar\")\n23\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.get_hnd-Tuple{AbstractString}","page":"Questionnaires","title":"Codex.Questionnaires.get_hnd","text":"get_hnd(path::AbstractString)::DataFrame\n\nGet HowNutsAreTheDutch data and select big five, age and more.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.join_dropout_questionnaires-Tuple{String}","page":"Questionnaires","title":"Codex.Questionnaires.join_dropout_questionnaires","text":"join_dropout_questionnaires(raw_dir::String)::DataFrame\n\nCombine information from multiple questionnaires to allow model fitting.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.join_questionnaires-Tuple{String, Vector{String}, Vector{String}}","page":"Questionnaires","title":"Codex.Questionnaires.join_questionnaires","text":"join_questionnaires(raw_dir::String, questionnaires::Array{String,1}, groups::Array{String,1})::DataFrame\n\nJoines multiple questionnaires for the members of groups, where groups ensures that the joins do not remove rows which shouldn't be removed. For instance, given questionnaires \"A\" and \"B\" containing respectively columns :a1, :a2 and :b1, this method will return { group, id, A_a1, A_a2, B_b1 }.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.plot_domain_density-Tuple{DataFrames.DataFrame, Symbol}","page":"Questionnaires","title":"Codex.Questionnaires.plot_domain_density","text":"plot_domain_density(df::DataFrame, y::Symbol)\n\nDensity plot for age and domain y on DataFrame df containing group.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.responses-Tuple{String, String, String}","page":"Questionnaires","title":"Codex.Questionnaires.responses","text":"responses(data_dir::String, nato_name::String, group::String; measurement=999)::DataFrame\n\nResponses for group group and measurement measurement, where group is one of graduates, operators, dropouts-medical or dropouts-non-medical. measurement is only used to split the 2018 data, for the later datasets it is ignored.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.responses-Tuple{String, String}","page":"Questionnaires","title":"Codex.Questionnaires.responses","text":"responses(data_dir::String, nato_name::String)::DataFrame\n\nResponses for questionnaire nato_name as contained in directory data_dir. Returns a DataFrame with rows { id, r...} where id is a long identifier and not the one from the backend.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.self_efficacy2scores-Tuple{DataFrames.DataFrame}","page":"Questionnaires","title":"Codex.Questionnaires.self_efficacy2scores","text":"self_efficacy2scores(echo::DataFrame)::DataFrame\n\nReturn the scores for the echo questionnaire, which is about self-efficacy. None of the items appear to be reversed, so this method just returns the sum.\n\nThis function assumes questions [1, 14] which holds for all questionnaires in from 2018 to the time of writing (2021).\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.unify_demographics-Tuple{Any}","page":"Questionnaires","title":"Codex.Questionnaires.unify_demographics","text":"unify_demographics(df)\n\nReturns an simplified and unified DataFrame which is the same for 2018, 2019 and 2020. It may throw out some data which we don't need at the time of writing.\n\n\n\n\n\n","category":"method"},{"location":"#Codex","page":"Codex","title":"Codex","text":"","category":"section"},{"location":"#Public","page":"Codex","title":"Public","text":"","category":"section"},{"location":"","page":"Codex","title":"Codex","text":"Modules = [Codex]\nPublic = true","category":"page"},{"location":"#Codex.accuracy-Tuple{Any, Any}","page":"Codex","title":"Codex.accuracy","text":"accuracy(trues, preds)::Number\n\nThe number of correct predictions in pred (by comparing true to prediction) divided by the total number of predictions.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.apply-Tuple{Any, Any}","page":"Codex","title":"Codex.apply","text":"apply(fns, obj)\napply(fns) -> Function\napply(fn::Function, nt::NamedTuple) -> NamedTuple\n\nApply function fn or functions fns to object. The functions are applied in order, unlike the behaviour of function composition. Also defines partial function. (For partial declarations in Base, see issue #35052 or endswith(suffix).)\n\n\n\n\n\n","category":"method"},{"location":"#Codex.cohens_d-Tuple{Any, Any, Any}","page":"Codex","title":"Codex.cohens_d","text":"cohens_d(μ1, μ2, s) \ncohens_d(n1, μ1, s1, n2, μ2, s2)\ncohens_d(A::Array, B::Array)\n\nEffect size according to Cohen's d for means μ1 and μ2, number of samples n1 and n2, and standard deviations s1 and s2 for respectively group 1 and 2.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.dirparent-Tuple{Any}","page":"Codex","title":"Codex.dirparent","text":"dirparent(path)::String\ndirparent(path, n)::String\n\nReturns the parent or n-th parent directory for path, where path can be a file or directory.\n\ndirparent(\"/a/b/c\")\n\n\n\n\n\n","category":"method"},{"location":"#Codex.has_duplicates-Tuple{AbstractArray}","page":"Codex","title":"Codex.has_duplicates","text":"has_duplicates(A::AbstractArray)::Bool\n\nReturns whether A contains duplicates.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.map_by_df-Tuple{AbstractArray, DataFrames.DataFrame, Symbol, Symbol}","page":"Codex","title":"Codex.map_by_df","text":"map_by_df(a::Array, df::DataFrame, from::Symbol, to::Symbol; missing=nothing)::Array\n\nReturn array A where all elements are mapped from U to V. Leaving all elements of A for which no match is found unchanged.\n\n!! Note-to-self. This is dumb function. Use joins instead.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.nrow_per_group-Tuple{Any, Symbol}","page":"Codex","title":"Codex.nrow_per_group","text":"nrow_per_group(df::DataFrame, group::Symbol; col1=\"group\", col2=\"nrow\")::DataFrame\n\nReturn the group name and the number of rows per group in df.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.output-Tuple{Function}","page":"Codex","title":"Codex.output","text":"output(f::Function) -> Output\noutput(cmd::Cmd) -> Output\n\nEvaluates f of type f(out::String, err::String)::CmdRedirect or cmd::Cmd.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.project_root-Tuple{}","page":"Codex","title":"Codex.project_root","text":"project_root()::String\n\nReturns root directory of the current Module. This is usually also the root of the Git repository.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.rescale-NTuple{5, Any}","page":"Codex","title":"Codex.rescale","text":"rescale(a, a_l, a_u, b_l, b_u)::Number\n\nApply feature scaling to a from the range [a_l, a_u] to the range [b_l, b_u].\n\n\n\n\n\n","category":"method"},{"location":"#Private","page":"Codex","title":"Private","text":"","category":"section"},{"location":"","page":"Codex","title":"Codex","text":"Modules = [Codex]\nPrivate = true","category":"page"}]
}
