charlie_mapping = Dict{String,Int}(
    "Nooit" => 1,
    "Bijna nooit" => 2,
    "Soms" => 3,
    "Vaak" => 4,
    "Altijd" => 5
)

charlie2int(s::String)::Int = charlie_mapping[s]

"""
    charlie2int(q::Int, s::String)

Convert `s` to Int for question number `q`.
"""
function charlie2int(q::Int, s::String)::Int
    value = charlie2int(s)
    reversed_questions = [2, 4, 6]
    if q in reversed_questions
        value = 6 - value
    end
    value
end

"""
    resilience2scores(df::DataFrame)

Return the score for questionnaire charlie.
"""
function resilience2scores(df::DataFrame)
    df = dropmissing(df)
    nq = 6
    T = ["v$i" => x -> charlie2int.(i, x) for i in 1:nq]
    transform!(df, :, T...; renamecols=false)
    cols = ["v$i" for i in 1:nq]
    transform!(df, :, cols => ByRow(+) => :score)
    select!(df, :id, :completed_at, :score)
end
