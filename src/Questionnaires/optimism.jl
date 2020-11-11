module Optimism

using Codex
using DataFrames
using Query

export 
    kilo2scores

# TODO: 
# - check in Pluto
# - check with test

# Kilo is, basically, the same for 2018, 2019 and 2020 according to `diff`.

ans_mapping = Dict(
    "Absoluut niet<br> mee eens" => 1,
    "Niet<br>mee eens" => 2,
    "Deels<br>mee eens" => 3, 
    "Mee<br>eens" => 4,
    "Absoluut<br>mee eens" => 5
)

# According to Glaesmer et al. (2012). The other questions are "filler items".
optimism_questions = [1, 4, 10]
pessimism_questions = [3, 7, 9]

function kilo2scores(df::DataFrame)
    result = @from i in df begin
        # 1, 4 and 10.
        @let optimism = sum([
                ans_mapping[i.v1],
                ans_mapping[i.v4],
                ans_mapping[i.v10]
            ])
        @let pessimism = sum([
                ans_mapping[i.v3],
                ans_mapping[i.v7],
                ans_mapping[i.v9]
            ])
        @select { i.id, i.completed_at, optimism, pessimism }
        @collect DataFrame
    end

    # Enforce types to allow `vcat`.
    DataFrame(
        id = string.(result[:, :id]),
        completed_at = string.(result[:, :completed_at]),
        optimism = Int.(result[:, :optimism]),
        pessimism = Int.(result[:, :pessimism]),
    )
end

end # module
