using Codex
using Codex.TransformExport
using DataFrames
using Test

@testset "TransformExport" begin
    export_dir = joinpath(project_root(), "test", "data", "2020-08")
    dfs = responses(export_dir)
    @test typeof(dfs) == Dict{String,DataFrame}
    @test "first" in keys(dfs)
    @test "second" in keys(dfs)

    @test TransformExport.rm_timing!(DataFrame(:v1_timing => 1)) == DataFrame()
    @test TransformExport.rm_timestamps!(DataFrame(:opened_at => 1, :open_from => 2)) == DataFrame()
    @test TransformExport.rm_boring_foreign_keys!(DataFrame(:t_for_id => 1, :t_by_id => 2)) == DataFrame(:t_by_id => 2)
    @test TransformExport.rm_empty_rows!(DataFrame(:filled_out_by_id => [1, missing])) == DataFrame(:filled_out_by_id => 1)
    @test TransformExport.rename_id_col!(DataFrame(:filled_out_by_id => 1)) == DataFrame(:id => 1)

    df = read_csv(joinpath(export_dir, "responses", "first.csv"), delim=';')
    @test size(df) == (3, 17)
    @test TransformExport.simplify(df) == DataFrame(:id => "aaaa", :v2 => 2, :v3 => 3)
end
