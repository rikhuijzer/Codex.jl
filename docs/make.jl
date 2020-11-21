using Documenter
using Codex

makedocs(
    sitename = "Codex.jl",
    pages = [
        "Codex" => "index.md",
        "Backup" => "backup.md",
        "Backup.GitLab" => "backup/gitlab.md",
        "TransformExport" => "transformexport.md",
        "Questionnaires" => "questionnaires.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

deploydocs(repo = "github.com/rikhuijzer/Codex.jl.git")
