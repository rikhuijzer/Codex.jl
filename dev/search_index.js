var documenterSearchIndex = {"docs":
[{"location":"transformexport/#TransformExport","page":"TransformExport","title":"TransformExport","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Module to transform the data exported from the backend.","category":"page"},{"location":"transformexport/#Public","page":"TransformExport","title":"Public","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Modules = [Codex.TransformExport]\nPrivate = false","category":"page"},{"location":"transformexport/#Codex.TransformExport.process-Tuple{Any,Any}","page":"TransformExport","title":"Codex.TransformExport.process","text":"process(in_dir, out_dir; fns)\n\nProcesses the responses from the export folder, applies the functions fns and places the files at out_dir.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.read_csv-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.read_csv","text":"read_csv(path; delim)::DataFrame\n\nCopies CSV at path into memory.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.responses-Tuple{String}","page":"TransformExport","title":"Codex.TransformExport.responses","text":"responses(dir::String)::Dict{String,DataFrame}\n\nReturn responses for an export folder such as \"2020-08\".\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.rm_descriptions-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.rm_descriptions","text":"rm_descriptions(df)::DataFrame\n\nFind responses containing a description, for example 6 (heel erg), and remove the description.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.simplify-Tuple{DataFrames.DataFrame}","page":"TransformExport","title":"Codex.TransformExport.simplify","text":"simplify(df)::DataFrame\n\nRenames id column after removing extraneous rows and columns, that is, removes empty rows and  removes columns such as protocol_subscription_id, open_from and v2_1_timing.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.split_datetime-Union{Tuple{T}, Tuple{DataFrames.DataFrame,T}} where T<:Union{AbstractString, Signed, Symbol, Unsigned}","page":"TransformExport","title":"Codex.TransformExport.split_datetime","text":"split_datetime(df::DataFrame, datetime_col::ColumnIndex)::DataFrame\n\nSplit the datetime column datetime_col into two columns, namely one for date and one for time.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.substitute_names-Tuple{Any,DataFrames.DataFrame}","page":"TransformExport","title":"Codex.TransformExport.substitute_names","text":"substitute_names(df, with::DataFrame)::DataFrame\nsubstitute_names(with)::Function\n\nReplaces person_ids by the first name as listed in with.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Private","page":"TransformExport","title":"Private","text":"","category":"section"},{"location":"transformexport/","page":"TransformExport","title":"TransformExport","text":"Modules = [Codex.TransformExport]\nPublic = false","category":"page"},{"location":"transformexport/#Codex.TransformExport._contains_description-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._contains_description","text":"_contains_description(col)::Bool\n\nReturn whether the column col contains descriptions.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._description_regex-Tuple{}","page":"TransformExport","title":"Codex.TransformExport._description_regex","text":"_description_regex()\n\nReturn regex for matching a description such as 1 (lorem) or 2 <br /> (ipsum).\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._rm_description-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._rm_description","text":"_rm_description(e::String)::String\n\nApply regex replace on element e.\n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport._rm_descriptions-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport._rm_descriptions","text":"_rm_descriptions(col)::Array{Int,1}\n\nApply a regex replace and type conversion to all elements of the column col. \n\n\n\n\n\n","category":"method"},{"location":"transformexport/#Codex.TransformExport.parsedatetime-Tuple{Any}","page":"TransformExport","title":"Codex.TransformExport.parsedatetime","text":"parsedatetime(str)::DateTime\n\nParse a date and time string from the export to a Julia DateTime object.\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Questionnaires","page":"Questionnaires","title":"Questionnaires","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Module for analysing the questionnaires.","category":"page"},{"location":"questionnaires/#Public","page":"Questionnaires","title":"Public","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Modules = [Codex.Questionnaires]\nPrivate = false","category":"page"},{"location":"questionnaires/#Private","page":"Questionnaires","title":"Private","text":"","category":"section"},{"location":"questionnaires/","page":"Questionnaires","title":"Questionnaires","text":"Modules = [Codex.Questionnaires]\nPublic = false","category":"page"},{"location":"questionnaires/#Codex.Questionnaires.first_personality_measurement-Tuple{String,Int64}","page":"Questionnaires","title":"Codex.Questionnaires.first_personality_measurement","text":"first_personality_measurement(raw_dir::String, cohort::Int; group=\"dropouts\", dropout_medical=true)::DataFrame\n\n\n\n\n\n","category":"method"},{"location":"questionnaires/#Codex.Questionnaires.get_hnd-Tuple{AbstractString}","page":"Questionnaires","title":"Codex.Questionnaires.get_hnd","text":"get_hnd(path::AbstractString)::DataFrame\n\nGet HowNutsAreTheDutch data and select big five, age and more.\n\n\n\n\n\n","category":"method"},{"location":"#Codex","page":"Index","title":"Codex","text":"","category":"section"},{"location":"#Public","page":"Index","title":"Public","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Modules = [Codex]\nPublic = true","category":"page"},{"location":"#Codex.add_missing-Union{Tuple{T}, Tuple{DataFrames.DataFrame,T,AbstractArray,T}} where T<:Union{AbstractString, Signed, Symbol, Unsigned}","page":"Index","title":"Codex.add_missing","text":"add_missing(df::DataFrame, actual::ColumnIndex, expected::Array, by::ColumnIndex)::DataFrame\n\nAdd rows to ensure that for all elements in expected, the same element exists in actual for each unique element of by.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.add_missing-Union{Tuple{T}, Tuple{DataFrames.DataFrame,T,AbstractArray}} where T<:Union{AbstractString, Signed, Symbol, Unsigned}","page":"Index","title":"Codex.add_missing","text":"add_missing(df::DataFrame, actual::ColumnIndex, expected::Array)::DataFrame\n\nAdd rows to ensure that for all elements in expected, the same element exists in actual.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.apply-Tuple{Any,Any}","page":"Index","title":"Codex.apply","text":"apply(fns, obj)\napply(fns)::Function\n\nApply functions fns to object obj. The functions are applied in order, unlike the behaviour of function composition. Also defines partial function. (For partial declarations in Base, see issue #35052 or endswith(suffix).)\n\n\n\n\n\n","category":"method"},{"location":"#Codex.categorical2simple-Tuple{Any}","page":"Index","title":"Codex.categorical2simple","text":"categorical2simple(A::CategoricalArray)\n\nReturns simple Julia collection for the CategoricalArray a.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.dirparent-Tuple{Any}","page":"Index","title":"Codex.dirparent","text":"dirparent(path)::String\ndirparent(path, n)::String\n\nReturns the parent or n-th parent directory for path, where path can be a file or directory.\n\ndirparent(\"/a/b/c\")\n\n\n\n\n\n","category":"method"},{"location":"#Codex.has_duplicates-Tuple{AbstractArray}","page":"Index","title":"Codex.has_duplicates","text":"has_duplicates(A::AbstractArray)::Bool\n\nReturns whether A contains duplicates.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.map_by_df-Tuple{Array,DataFrames.DataFrame,Symbol,Symbol}","page":"Index","title":"Codex.map_by_df","text":"map_by_df(a::Array, df::DataFrame, from::Symbol, to::Symbol; missing=nothing)::Array\n\nMap array a by using arrays from and to. Leaving all elements of a for which no match is found unchanged.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.order_with-Tuple{DataFrames.DataFrame,Array{Ordering,1}}","page":"Index","title":"Codex.order_with","text":"order_with(df::DataFrame, orderings::Array{Ordering,1})::DataFrame\n\nSorts df by cols in the order given by orderings, see the documentation of DataFrames.sort. Let o be an ordering::Ordering. Enforces that the columns o.col of df are ordered according to o.newlevels if o.newlevels is not missing.\n\n\n\n\n\n","category":"method"},{"location":"#Codex.project_root-Tuple{}","page":"Index","title":"Codex.project_root","text":"project_root()::String\n\nReturns root directory of the current Module. This is usually also the root of the Git repository.\n\n\n\n\n\n","category":"method"},{"location":"#Private","page":"Index","title":"Private","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Modules = [Codex]\nPrivate = true","category":"page"}]
}
