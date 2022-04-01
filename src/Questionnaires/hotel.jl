# Hotel is a combination of many questionnaires:
# Mindset [Dweck, 2013], fear of failure [Thrash & Elliot, 2003], basic motives [van Yperen et al., 2014], motivation type [Pelletier et al., 2013], and approach-avoidance temperament [Elliot & Thrash, 2010]


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
"""
function add_temperaments!(df)
    let
        Q = ["v$(i + 61)" for i in [2, 4, 5, 8, 10, 11]]
        dropmissing!(df, Q)
        select!(df, Q => ByRow(+) => :approach_temperament, Not(Q))
    end
    let
        Q = ["v$(i + 61)" for i in [1, 3, 6, 7, 9, 12]]
        dropmissing!(df, Q)
        select!(df, Q => ByRow(+) => :avoidance_temperament, Not(Q))
    end
    return df
end

function hotel2scores(hotel::DataFrame)::DataFrame
    df = copy(hotel)
    add_temperaments!(df)
    return df
end
