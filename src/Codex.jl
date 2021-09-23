module Codex

using Requires: @require

using Reexport
@reexport using DataFrames
@reexport using Dates
@reexport using Statistics

const PROJECT_ROOT = string(pkgdir(Codex))::String

include("utils.jl")
export Output, apply, dirparent, has_duplicates, nt2dict
include("stats.jl")
include(joinpath("TransformExport", "transformexport.jl"))
include(joinpath("Questionnaires", "questionnaires.jl"))

function __init__()
    @require JSON2="2535ab7d-5cd8-5a07-80ac-9b1792aadce3" include("gitlab.jl")
end

end # module
