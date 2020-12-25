import CSV
using Codex
using Compose
using DataFrames
using Distributions
using Gadfly
using Query

# Source: https://github.com/GiovineItalia/Gadfly.jl/issues/1169
function vstack2(plots::Vector{Plot}; spacing::Float64=0.0, heights::Vector{<:Real}=Float64[])
    n = length(plots)
    heights==Float64[] && (heights = fill(1/n, n))
    sumh = cumsum([0;heights])
    vpos = sumh + spacing.*[0; 1:n-1; n-1]
    M = [(context(0,v,1,h), render(p)) for (v,h,p) in zip(vpos[1:n], heights, plots)]
    return compose(context(units=UnitBox(0,0,1,vpos[n+1])), M...)
end

function study2df(name, means::Array, sds::Array, 
    l = (240 / 5) * 1,
    u = (240 / 5) * 5
  )
  l = trunc(Int, l)
  u = trunc(Int, u)
  DataFrame(
    name = repeat([name], 5), 
    domain = [:N, :E, :O, :A, :C],
    mean = means, 
    sd = sds,
    l = repeat([l], 5),
    u = repeat([u], 5)
  )	
end

studies = vcat(
# Maybe reverse N, because the paper talks about "Emotional Stability"?
  study2df("Fosse - Norwegian Military (BFI)",
    [5.27, 4.74, 4.48, 5.06, 4.98],
    [0.76, 0.90, 0.79, 0.69, 0.75],
    1, 7
  ),
  study2df("Jackson - German Military 1 (FFI/12)",  
    [2.11, 2.81, 2.63, 2.79, 2.90],
      [0.44, 0.39, 0.42, 0.36, 0.44],
    1, 5
  ), study2df("Jackson - Civilian 1 (FFI/12)",
    [2.17, 2.80, 2.70, 2.89, 2.84],
    [0.41, 0.40, 0.46, 0.35, 0.47],
    1, 5
  ), study2df("Jackson - German Military 2 (FFI/12)",
    [1.92, 2.84, 2.68, 2.87, 3.08],
    [0.47, 0.42, 0.44, 0.40, 0.40],
    1, 5
  ), study2df("Jackson - Civilian 2 (FFI/12)",
    [2.01, 2.83, 2.76, 3.00, 2.98],
    [0.47, 0.42, 0.46, 0.35, 0.48],
    1, 5
# It is almost impossible for these studies to have used 1 - 5,
# instead it must be 0 - 4, but the paper reports otherwise.
  ), study2df("Barto2011 - Male Pilots (PI-R)",
    [67.88, 127.68, 112.94, 114.78, 131.40],
    [18.39, 17.15, 18.10, 16.61, 17.55],
    (240 / 5) * 1, (240 / 5) * 5
  ), study2df("Barto2011 - Male Norm (PI-R)",
    [75.2, 108.5, 110.1, 120.1, 123.6],
    [19.9, 18.5, 17.5, 16.1, 17.4],
    (240 / 5) * 1, (240 / 5) * 5
  ), study2df("NEO - Age 23-35 (PI-R)",
    [132.9, 155.1, 153.3, 167.2, 165.0],
    [22.8, 18.8, 18.1, 15.6, 19.7],
    (240 / 5) * 1, (240 / 5) * 5
  ), study2df("NEO - Male (PI-R)",
    [125.0, 152.7, 149.5, 165.2, 165.1],
    [21.3, 17.8, 16.5, 17.0, 19.1],
    (240 / 5) * 1, (240 / 5) * 5
  ), study2df("NEO - Age 23-35 (FFI-3)",
    [34.8, 39.1, 39.1, 40.4, 42.6],
    [7.2, 5.8, 5.6, 5.7, 6.0],
    12, 48
  ), study2df("NEO - Male (FFI-3)",
    [32.2, 39.6, 38.1, 39.9, 43.5],
    [7.4, 5.7, 5.4, 5.3, 5.8],
    12, 48
  ), study2df("Sorlie - Military (PI-3)",
    [62.81, 130.36, 117.29, 125.33, 140.00],
    [19.84, 18.04, 18.11, 16.73, 17.86],
    (240 / 5) * 0, (240 / 5) * 4
  ), study2df("Rolland - French Military (PI-R)", 
    [56.8, 127.5, 107.6, 126.7, 131.7],
    [16.7, 12.9, 12.4, 12.8, 15.4],
    (240 / 5) * 0, (240 / 5) * 4
  ), study2df("Rolland - French Students (PI-R)",
    [106.9, 112.1, 126.9, 119.3, 107.2],
    [22.8, 18.5, 17.1, 19.1, 21.9]
  ), study2df("Rolland - French Military (FFI)",
    [9.92, 32.86, 25.31, 34.44, 38.13],
    [4.84, 4.17, 4.25, 4.09, 4.99],
    12, 48
  ), study2df("Rolland - French Students (FFI)",
    [27.21, 28.66, 31.09, 30.97, 29.07],
    [8.58, 6.69, 5.69, 5.86, 8.01],
    12, 48
  ), study2df("This study - Civilians (FFI)",
    [143.08, 156.17, 176.93, 174.0, 171.12],
    [36.37, 29.98, 25.79, 24.32, 27.01],
    # Note that this is first upscaled in personality.jl.
    (240 / 5) * 1, (240 / 5) * 5
  ), study2df("This study - Veterans (PI-3)",
    [113.01, 162.36, 148.87, 163.46, 178.13],
    [17.64, 10.99, 14.1, 13.96, 17.73]
  ), study2df("This study - Graduates (PI-3)",
    [110.55, 165.73, 148.18, 169.42, 181.7],
    [14.65, 7.73, 15.43, 12.73, 12.96]
  ), study2df("This study - Dropouts-medical (PI-3)",
    [114.86, 161.95, 147.18, 171.09, 181.59],
    [16.87, 12.93, 13.07, 14.45, 13.89]
  ), study2df("This study - Dropouts-non-medical (PI-3)",
    [115.97, 159.29, 148.93, 169.91, 179.48],
    [15.03, 14.13, 14.33, 13.93, 13.27]
  ), study2df("Linden - Dutch Military (PI-R)", 
    [108.97, 178.05, 155.11, 172.49, 178.77],
    [16.542, 15.273, 15.439, 13.517, 16.351]
  ), study2df("Linden - Dutch Military (FFI)",
    [26.69, 45.69, 34.46, 42.32, 46.34],
    [5.811, 4.411, 4.594, 4.195, 5.069],
    12, 48
  )
)

rescale_mean_to_ysf(m, l, u) = 48 + ( (m - l) / (u - l) ) * (240 - 48)  
rescale_sd_to_ysf(s, l, u) = ( s / (u - l) ) * (240 - 48)

function prepare_plot(studies::DataFrame, domain::Symbol)
  # Be very careful when ordering! Only order before the `where` to 
  # avoid a mismatch between labels and data.
  df = @from i in studies begin
    @where i.domain == domain
    @let m = rescale_mean_to_ysf(i.mean, i.l, i.u)
    @let s = rescale_sd_to_ysf(i.sd, i.l, i.u)
    @let dist = Normal(m, s)
    @let lower = quantile(dist, 0.025)
    @let upper = quantile(dist, 0.975)
    @select { name = string(i.name), i.domain, mean = m, sd = s, lower, upper }
    @collect DataFrame
  end
end

function plot_forest(studies::DataFrame, domain::Symbol; 
        hide_y = false, prepare_fn = prepare_plot, y_orientation = :horizontal,
        yticks = 48:48:240, ymin = 48, ymax = 240
    )
    ylabel = domain == :challenge ? "C1" :
        domain == :commitment ? "C2" :
        domain == :emotional_control ? "C3" :
        domain == :life_control ? "C4" :
        domain == :confidence_in_abilities ? "C4" :
        domain == :interpersonal_confidence ? "C5" :
        string(domain)

    prepared = prepare_fn(studies, domain)
    plot(prepared,
        x = :name, y = :mean, ymin = :lower, ymax = :upper,
        Guide.yticks(ticks = yticks),
        Guide.xticks(ticks = hide_y ? nothing : :auto),
        Coord.cartesian(ymin = ymin, ymax = ymax),
        Geom.point, Geom.errorbar,
        yintercept = [ymin], Geom.hline(color = "#cccccc"),
        Guide.xlabel(""), 
        Guide.ylabel(ylabel; orientation=y_orientation),
        Theme(; line_width = 0.6pt, point_size = 2.2pt, default_color = "#305080",
            highlight_width=0mm # Outline of points.
        )
    )
end

# `xmin` and `xmax` refer to the position of the labels.
# `ymin` and `ymax` refer to cartesian dimensions for the y-axes.
function plot_stacked_forest(df::DataFrame; 
        spacing=-0.26, heights=[1,1,1,1,1,1.58], 
        prepare_fn=prepare_plot, domains=[:N, :E, :O, :A, :C],
        y_orientation=:horizontal, yticks=48:48:240, 
        xmin = -2.6, xmax = 20, ymin = 48, ymax = 240
        )
    
    plot_forest_partial(domain) = plot_forest(df, domain; 
        hide_y = true, prepare_fn, y_orientation, 
        yticks, ymin, ymax
    )

    labels = plot(prepare_fn(df, first(domains)),
        x = :name, y = :mean,
        Guide.yticks(ticks = nothing),
        Coord.cartesian(; xmin, xmax, ymin = 0, ymax = 0),
        Theme(grid_line_width=0mm),
        Guide.ylabel(""), Guide.xlabel("")
    )

    vstack2([
        plot_forest_partial.(domains)...,
        labels
    ]; spacing, heights)
end

function prepare_sd_plot(studies::DataFrame, domain)
  df = @from i in studies begin
    @let m = rescale_mean_to_ysf(i.mean, i.l, i.u)
    @let s = rescale_sd_to_ysf(i.sd, i.l, i.u)
    @let dist = Normal(m, s)
    @let lower = quantile(dist, 0.025)
    @let upper = quantile(dist, 0.975)
    # WARNING: order before the where clause to avoid label mismatch!
    @orderby ascending(s)
    @where i.domain == domain
    @select { i.name, i.domain, mean = m, sd = s, lower, upper }
    @collect DataFrame
  end
  df
end

function write_prepare_sd_plot_csv()
    df = @from i in studies begin
        @let m = round(rescale_mean_to_ysf(i.mean, i.l, i.u), digits=2)
        @let s = round(rescale_sd_to_ysf(i.sd, i.l, i.u), digits=2)
        @let dist = Normal(m, s)
        @let lower = round(quantile(dist, 0.025), digits=2)
        @let upper = round(quantile(dist, 0.975), digits=2)
        @select { i.name, i.domain, mean = m, sd = s, lower, upper } 
        @collect DataFrame
    end
    # df = select!(prepared, Not([:lower, :upper]))
    write_csv("prepare-sd-plot", df)
end

# Converts `{ group, id, completed_at, domain_1, ..., domain_n }` to
# `{ name, domain, mean, sd, lower, upper}`.
function prepare_data_plot(data::DataFrame)
    groups = unique(data[:, :group])
    function per_group(group)
        out = filter([:group] => g -> g == group, data)
        select!(out, Not([:group, :id, Symbol("completed_at")]))
        dropmissing!(out)
        # mapcols(col -> mean(col), out)
        out = stack(out, names(out); variable_name = :domain)
        out = groupby(out, :domain)
        function per_subscale(data_group)
            m = round(mean(data_group[:, :value]), digits=2)
            s = round(std(data_group[:, :value]), digits=2)
            dist = Normal(m, s)
            DataFrame(
                name = "This study - $group",
                domain = first(data_group[:, :domain]),
                mean = m,
                sd = s,
                lower = round(quantile(dist, 0.025), digits=2),
                upper = round(quantile(dist, 0.975), digits=2)
            )
        end
        subscale_rows = vcat([per_subscale(group) for group in out]...)
    end
    vcat(per_group.(groups)...)
end

toughness_domains = Symbol.(["challenge", "commitment", "emotional_control",
    "life_control", "confidence_in_abilities", "interpersonal_confidence"])

function toughness2df(name, means::Array, sds::Array)
    dists = [Normal(t[1], t[2]) for t in zip(means, sds)]
    DataFrame(
        name = repeat([name], 6),
        mean = means,
        domain = toughness_domains,
        sd = sds,
        lower = round.(quantile.(dists, 0.025), digits=2),
        upper = round.(quantile.(dists, 0.975), digits=2)
    )
end

toughness_studies = vcat(
  toughness2df("Vaughan et al., 2018 - Niet-atleet",
    [24.13, 33.83, 20.22, 20.47, 24.34, 17.50],
    [6.53, 8.56, 5.06, 6.10, 7.45, 5.76]
  ),
  toughness2df("Vaughan et al., 2018 - Amateur",
    [31.12, 42.92, 24.90, 27.22, 32.01, 23.45],
    [5.15, 6.91, 4.38, 4.56, 7.35, 4.30]
  ),
  toughness2df("Vaughan et al., 2018 - Elite",
    [31.51, 44.32, 25.53, 27.09, 33.66, 23.84],
    [4.88, 6.46, 4.31, 4.50, 7.18, 5.56]
  ),
  toughness2df("Gerber et al., 2012 - Adolescenten", 
    [28.34, 37.24, 15.33, 23.29, 21.64, 30.94],
    [4.69, 6.31, 3.28, 3.95, 3.96, 5.71]
  ),
  toughness2df("Crust et al., 2010 - Atleten",
    [31.82, 40.97, 22.82, 25.64, 31.85, 23.22],
    [4.13, 4.76, 3.44, 3.60, 4.77, 2.46]
  ),
)

function prepare_toughness_plot(studies::DataFrame)::DataFrame
    india = Codex.Questionnaires.first_measurement(Dashboard.raw_dir(), "india")
    from_data = prepare_data_plot(india)
    df = vcat(from_data, studies)
    df[!, :domain] = string.(df[!, :domain])
    df = sort(df, [:domain, :mean])
    df[!, :domain] = Symbol.(df[!, :domain])
    df
end

function prepare_toughness_plot(studies::DataFrame, domain)::DataFrame
    # This is very inefficient, but ensures ordering.
    df = prepare_toughness_plot(studies)
    df[!, :domain] = Symbol.(df[!, :domain])
    filtered = filter(:domain => d -> d == Symbol(domain), df)
end
