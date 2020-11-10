using Documenter
using Codex

makedocs(
    sitename = "Codex.jl",
    pages = [
        "Index" => "index.md",
        "TransformExport" => "transformexport.md",
        "Questionnaires" => "questionnaires.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

deploydocs(repo = "github.com/rikhuijzer/Codex.jl.git")
