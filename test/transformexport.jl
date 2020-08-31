import Codex
import Codex.TransformExport
import CSV

using DataFrames
using Test

@testset "TransformExport" begin
    data_dir = joinpath(project_root(), "test", "data")
    export_dir = joinpath(data_dir, "2020-08")
    dfs = TransformExport.responses(export_dir)
    @test typeof(dfs) == Dict{String,DataFrame}
    @test "first" in keys(dfs)
    @test "second" in keys(dfs)

    @test TransformExport.rm_timing!(DataFrame(:v1_timing => 1)) == DataFrame()
    @test TransformExport.rm_boring_timestamps!(DataFrame(completed_at = 0, opened_at = 1, open_from = 2)) == DataFrame(completed_at = 0)
    @test TransformExport.rm_boring_foreign_keys!(DataFrame(t_for_id = 1, t_by_id = 2)) == DataFrame(t_by_id = 2)
    @test TransformExport.rm_empty_rows!(DataFrame(filled_out_by_id = [1, missing])) == DataFrame(filled_out_by_id = 1)
    @test TransformExport.rename_id_col!(DataFrame(filled_out_by_id = 1)) == DataFrame(id = 1)

    df = TransformExport.read_csv(joinpath(export_dir, "responses", "first.csv"); delim=';')
    without_descr = TransformExport.rm_descriptions(df)
    @test TransformExport.simplify(without_descr) == 
        DataFrame(id = "aaaa", completed_at = "22-08-2020 14:49:47", v2 = 2, v3 = 3)
    @test string(TransformExport.parsedatetime(df[1, :completed_at])) == "2020-08-22T14:49:47"

    @test size(df) == (3, 17)
    simple = TransformExport.simplify(df) 
    @test simple == DataFrame(id = "aaaa", completed_at = "22-08-2020 14:49:47", v2 = "2 <br/> (lorem)", v3 = "3 (heel erg)")

    @test TransformExport._rm_description("1") == 1
    @test TransformExport._rm_description("23 (lorem)") == 23
    @test TransformExport._rm_description("45 <br/> (lorem)") == 45
    @test TransformExport._rm_descriptions(["6"]) == [6]
    @test TransformExport._contains_description(["7 (ipsum)"]) == true
    @test TransformExport._contains_description(["2018"]) == false

    people = DataFrame(:person_id => ["aaaa", "aaab"], :first_name => ["0001", "0002"])
    with_names = DataFrame(id = "0001", completed_at = "22-08-2020 14:49:47", v2 = "2 <br/> (lorem)", v3 = "3 (heel erg)")
    @test TransformExport.substitute_names(simple, people) == with_names

    id_username = TransformExport.read_csv(joinpath(data_dir, "id-username.csv"))
    @test TransformExport.names2usernames(with_names, id_username)[!, :id] == ["jackson"]
end
