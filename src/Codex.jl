module Codex

include("gitlab.jl")
include("utils.jl")
include("stats.jl")
include("df-transformations.jl")
include(joinpath("Backup", "backup.jl"))
include(joinpath("TransformExport", "transformexport.jl"))
include(joinpath("Questionnaires", "questionnaires.jl"))
include("comparing-means-sds.jl")

end # module
