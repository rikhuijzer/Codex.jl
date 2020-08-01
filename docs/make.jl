using Documenter
using Codex

makedocs(sitename = "Codex.jl",
    pages = [
        "Index" => "index.md",
        "TransformExport" => "transformexport.md"
    ]
)

deploydocs(repo = "github.com/rikhuijzer/Codex.jl.git")
