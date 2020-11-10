using CSV
using DataFrames
using Query

export personality2scores
    
ans_mapping = Dict("HO" => 1, "O" => 2, "N" => 3, "E" => 4, "HE" => 5)
reverse(ans::Number)::Number = 6 - ans
reversed_questions = [
		# Page 113
    1, 61, 121, 181, 
    36, 96, 156, 
    11, 71, 
    46, 106, 166,
    21, 81, 141, 231,
    56, 116, 176, 206, 236,
    # Page 114
    32, 92, 
    7, 67, 187, 
    42, 102, 162, 222,
    17, 77, 137, 
    52, 112, 
    # Page 115
    33, 93, 153, 183,
    8, 68, 128,
    43, 103, 163,
    18, 78, 138, 198, 228,
    53, 113, 173, 
    # Page 116
    4, 64, 124,
    39, 99, 159, 189, 219,
    14, 74, 134,
    49, 109, 169, 199, 229,
    24, 84, 144, 234,
    59, 119, 
    # Page 117
    95, 155,
    10, 70, 130, 190, 220,
    45, 105, 
    20, 80, 140, 
    55, 115, 205, 
    30, 90, 150,
]
is_reversed(question::Number)::Bool = question in reversed_questions

function ans2num(ans::String, question::Number)::Number
    ans = ans_mapping[ans]
    return is_reversed(question) ? reverse(ans) : ans
end

ans2num(ans::String, question::String) = ans2num(ans, parse(Int64, question[2:end]))
ans2num(ans::Missing, question::String) = ans2num("N", question)
ans2num(ans::String, question::Symbol) = ans2num(ans, string(question))

function personality2digits(lima::DataFrame)::DataFrame
	lima_digits = select(lima, [:id, :completed_at])

	for question in names(lima)[3:end]
			digits = map(ans -> ans2num(ans, question), lima[!, question])
			lima_digits = hcat(lima_digits, DataFrame(question => digits))
	end
	return lima_digits
end

facets = Dict(
    "N1" => [1, 31, 61, 91, 121, 151, 181, 211],
    "N2" => [6, 36, 66, 96, 126, 156, 186, 216],
    "N3" => [11, 41, 71, 101, 131, 161, 191, 221],
    "N4" => [16, 46, 76, 106, 136, 166, 196, 226],
    "N5" => [21, 51, 81, 111, 141, 171, 201, 231],
    "N6" => [26, 56, 86, 116, 146, 176, 206, 236],
    "E1" => [2, 32, 62, 92, 122, 152, 182, 212],
    "E2" => [7,37, 67, 97, 127, 157, 187, 217],
    "E3" => [12, 42, 72, 102, 132, 162, 192, 222],
    "E4" => [17, 47, 77, 107, 137, 167, 197, 227],
    "E5" => [22, 52, 82, 112, 142, 172, 202, 232],
    "E6" => [27, 57, 87, 117, 147, 177, 207, 237],
    "O1" => [3, 33, 63, 93, 123, 153, 183, 213],
    "O2" => [8, 38, 68, 98, 128, 158, 188, 218],
    "O3" => [13, 43, 73, 103, 133, 163, 193, 223],
    "O4" => [18, 48, 78, 108, 138, 168, 198, 228],
    "O5" => [23, 53, 83, 113, 143, 173, 203, 233],
    "O6" => [28, 58, 88, 118, 148, 178, 208, 238],
    "A1" => [4, 34, 64, 94, 124, 154, 184, 214],
    "A2" => [9, 39, 69, 99, 129, 159, 189, 219],
    "A3" => [14, 44, 74, 104, 134, 164, 194, 224],
    "A4" => [19, 49, 79, 109, 139, 169, 199, 229],
    "A5" => [24, 54, 84, 114, 144, 174, 204, 234],
    "A6" => [29, 59, 89, 119, 149, 179, 209, 239],
    "C1" => [5, 35, 65, 95, 125, 155, 185, 215],
    "C2" => [10, 40, 70, 100, 130, 160, 190, 220],
    "C3" => [15, 45, 75, 105, 135, 165, 195, 225],
    "C4" => [20, 50, 80, 110, 140, 170, 200, 230],
    "C5" => [25, 55, 85, 115, 145, 175, 205, 235],
    "C6" => [30, 60, 90, 120, 150, 180, 210, 240]
)

function facet(question::Number)::String
    for key in keys(facets)
        if question in facets[key]
            return string(key)
        end
    end
    return "question not listed in facets"
end

domain(question::Number)::Char = facet(question)[1]
answer(lima::DataFrame, row::Number, question::Symbol) = lima[row, question]
answer(lima::DataFrame, row::Number, question::Number) = answer(lima, row, Symbol("v" * string(question)))

function score_everyone(lima_digits::DataFrame, facet::String) 
	answers(row::Number) = map(question -> answer(lima_digits, row, question), facets[facet])
	map(row -> sum(answers(row)), 1:nrow(lima_digits))
end

function personality2facets(lima_digits::DataFrame)::DataFrame
	lima_facets = select(lima_digits, [:id, :completed_at])

	for facet in sort(collect(keys(facets)))
			df = DataFrame(Symbol(facet) => score_everyone(lima_digits, facet))
			lima_facets = hcat(lima_facets, df)
	end
	return lima_facets
end

function personality2scores(lima::DataFrame)::DataFrame
    lima_digits = personality2digits(lima)
	lima_facets = personality2facets(lima_digits)
	lima_scores = copy(lima_facets)

	answers(row::Number, facet::String) = map(question -> answer(lima_digits, row, question), facets[facet])
	score_everyone(facet::String) = map(row -> sum(answers(row, facet)), 1:nrow(lima_digits))

	domains = Set(map(key -> string(key)[1], collect(keys(facets))))
	get_facets(domain::Char)::Array{String,1} = filter(key -> string(key)[1] == domain, collect(keys(facets)))
	
	facet_scores(domain::Char) = map(score_everyone, get_facets(domain))
	score_everyone(domain::Char) = sum(facet_scores(domain))

	for domain in sort(collect(domains))
        df = DataFrame(Symbol(domain) => score_everyone(domain))
        lima_scores = hcat(lima_scores, df)
	end

	return lima_scores
end
