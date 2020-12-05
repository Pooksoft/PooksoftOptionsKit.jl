using PyPlot

# assumption: seller blue #00A2FF, buyer orange #FF8C00 
# we have already run the simulation_at_exp script -
plot(data_array_at_exp[:,1], data_array_at_exp[:,2], lw=2, color="#FF8C00")
ax = gca()
fig = gcf()
ax.set_facecolor("black")
fig.set_facecolor("black")
grid(color="dimgray", linestyle="dashed")

ax.spines["bottom"].set_color("white")
ax.spines["top"].set_color("white") 
ax.spines["right"].set_color("white")
ax.spines["left"].set_color("white")
ax.tick_params(axis="x", colors="white")
ax.tick_params(axis="y", colors="white")

xlabel("Stock Price (USD)", fontsize=16,fontname="Arial",color="white")
ylabel("Profit or Loss (USD)", fontsize=16,fontname="Arial",color="white")