# Loading DataFrames avoids `no default `Tables.rows` implementation for type: Gadfly.Plot`?
using DataFrames
using Gadfly

"""
    plot_domain_density(df::DataFrame, y::Symbol)

Density plot for age and domain `y` on DataFrame `df` containing `group`.
"""
function plot_domain_density(df::DataFrame, y::Symbol)
	xticks = y == :age ? range(0, 100, step=20) : range(0, 300, step=100) 
    xlabel = y == :N ? "neuroticisme" :
        y == :E ? "extraversie" :
        y == :O ? "openheid" :
        y == :A ? "aangenaamheid" :
        y == :C ? "consciëntieusheid" :
        string(y)
	p = plot(df,
		x = y, color = :group,
		Stat.density,
		Guide.xticks(ticks = xticks),
		Geom.polygon(fill = false, preserve_order = true),
        Guide.xlabel(xlabel),
		Guide.ylabel("dichtheid"),
		Theme(line_width = 0.5mm) 
	)
end
