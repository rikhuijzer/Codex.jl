using Documenter
using Codex

makedocs(
    sitename = "Codex.jl",
    pages = [
        "Codex" => "index.md",
        "Backup" => "backup.md",
        "GitLab" => "gitlab.md",
        "TransformExport" => "transformexport.md",
        "Questionnaires" => "questionnaires.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

repo = "github.com/rikhuijzer/Codex.jl.git"
devbranch = "main"
deploydocs(; repo, devbranch)
