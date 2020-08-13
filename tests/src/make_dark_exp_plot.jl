using PyPlot

# assumption: #00A2FF
# we have already run the simulation_at_exp script -
plot(data_array_at_exp[:,1], data_array_at_exp[:,2], lw=2, color="darkorange")
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