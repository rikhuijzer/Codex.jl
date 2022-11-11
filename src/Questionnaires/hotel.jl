# Hotel is a combination of many questionnaires:
# Mindset [Dweck, 2013], fear of failure [Thrash & Elliot, 2003], basic motives [van Yperen et al., 2014], motivation type [Pelletier et al., 2013], and approach-avoidance temperament [Elliot & Thrash, 2010]
# Some of these questions are mostly theoretically interesting and can be omitted when only focusing on prediction.

"""
    add_mindsets!(df::DataFrame)

Add motivation columns and remove the items.
All items are 1 (helemaal mee oneens) to 6 (helemaal mee eens) and v4 and v6 are reversed.
Verified on 2019-first and 2020-first.
"""
function add_mindsets!(df::DataFrame)
    reverse(x::Int) = 7 - x
    df.v4 = reverse.(df.v4)
    df.v6 = reverse.(df.v6)
    Q = ["v$i" for i in 1:6]
    select!(df, Q => ByRow(+) => :mindset, Not(Q))
    return df
end

"""
    add_basic_motives!(df::DataFrame)

Add basale drijfveren columns and remove the items.
All items are 1 (helemaal niet) to 7 (in extreem sterke mate).

```
1-4 autonomie;
5-8 verbondenheid;
9-12 competentie;
13-16 structuur;
17-20 macht;
21-24 maatschappelijke verantwoordelijkheid;
25-28 status
```
So, all domains contain 4 items.

Note that autonomy, connectedness, and competence are very well known while the others are not.
"""
function add_basic_motives!(df::DataFrame)
    questions = Dict(
        :autonomie => 1:4,
        :verbondenheid => 5:8,
        :competentie => 9:12,
        :structuur => 13:16, # Less known.
        :macht => 17:20, # Less known.
        :maatschappelijke_verantwoordelijkheid => 21:24, # Less known.
        :status => 25:28 # Less known.
    )
    for key in keys(questions)
        Q = ["v$(6 + i)" for i in questions[key]]
        select!(df, Q => ByRow(+) => key, Not(Q))
    end
    return df
end

"""
    add_fear_of_failure(df::DataFrame)

Add fear of failure (faalangst) columns and remove the items.
9 items from 1 (helemaal mee oneens) to 5 (helemaal mee eens).
"""
function add_fear_of_failure!(df::DataFrame)
    Q = ["v$(34 + i)" for i in 1:9]
    name = :fear_of_failure
    select!(df, Q => ByRow(+) => name, Not(Q))
    return df
end

"""
    add_motivation_type!(df::DataFrame)::DataFrame

Add type motivatie columns and remove the items.

Scoring is based on Ruud his Word document:
```
Amotivation (3,11,16);
External regulation (4,8,13);
Introjected regulation (7,12,18);
Identified regulation (5,9,15);
Integrated regulation (1,6,17);
Intrinsic motivation (2,10,14)
```

The items start at 48 for all versions.

Also, 2019 to 2020 go from 1 to 7 so let's say all.

Nico has a book in which at Figure 12.1a the self-determination theory is displayed:

Amotivation     Controlled Motivation   Controlled Motivation   Autonomous Motivation   Autonomous Motivation   Autonomous Motivation
Amotivation     Extrinsic Motivation    Extrinsic Motivation    Extrinsic Motivation    Extrinsic Motivation    Intrinsic Motivation
Amotivation     External Regulation     Introjected Regulation  Identified Regulation   Integrated Regulation   Intrinsic Regulation
"""
function add_motivation_type!(df::DataFrame)::DataFrame
    questions = Dict(
        :amotivation => [3, 11, 16],
        :external_regulation => [4, 8, 13], # Controlled Motivation
        :introjected_regulation => [7, 12, 18], # Controlled Motivation
        :identified_regulation => [5, 9, 15], # Autonomous Motivation
        :integrated_regulation => [1, 6, 17], # Autonomous Motivation
        :intrinsic_motivation => [2, 10, 14] # Autonomous Motivation
    )
    for key in keys(questions)
        Q = ["v$(43 + i)" for i in questions[key]]
        select!(df, Q => ByRow(+) => key, Not(Q))
    end
    return df
end

"""
    add_temperaments!(df)

Add approach and avoidance temperament columns and remove the items.

Scoring is based on Ruud his Word document:
```
Approach temperament = item2+item4+item5+item8+item10+item11
Avoidance temperament = item1+item3+item6+item7+item9+item12
```

And according to 2019-first/questionnaires/hotel.csv the items start at 62.
Also for 2020 first.

These variables should not be combined according to Nico.
"""
function add_temperaments!(df)
    let
        Q = ["v$(61 + i)" for i in [2, 4, 5, 8, 10, 11]]
        select!(df, Q => ByRow(+) => :approach_temperament, Not(Q))
    end
    let
        Q = ["v$(61 + i)" for i in [1, 3, 6, 7, 9, 12]]
        select!(df, Q => ByRow(+) => :avoidance_temperament, Not(Q))
    end
    return df
end

function hotel2scores(hotel::DataFrame)::DataFrame
    df = copy(hotel)
    add_mindsets!(df)
    add_basic_motives!(df)
    add_fear_of_failure!(df)
    add_motivation_type!(df)
    add_temperaments!(df)
    return df
end
