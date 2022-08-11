# import graphing utility
import Plots.plot
import Plots.plot!

# include Bruno library
include("../src/Bruno.jl")

# Initialize a Log-Diffusion Data-Gen utility
nTimeStep = 100
GenParam1 = Bruno.DataGeneration.LogDiffusion.ParamLogDiff(nTimeStep, volatility=0)

# Generate Data for a single simulation
data1 = Bruno.DataGeneration.LogDiffusion.getData(GenParam1)

# Generate Corresponding Time Axis
time1 = Bruno.DataGeneration.LogDiffusion.getTime(GenParam1)

# Initialize a second object with initial parameters
GenParam2 = Bruno.DataGeneration.LogDiffusion.ParamLogDiff(nTimeStep)

# Generate Data 100 simulations
nSimulation = 100
data2 = Bruno.DataGeneration.LogDiffusion.getData(GenParam2, nSimulation)

# Generate Time Axis
time2 = Bruno.DataGeneration.LogDiffusion.getTime(GenParam2)

# Display Plots
plt = plot(time2, data2, show=true, color="blue", legend=false)
plot!(plt, time1, data1,show=true, color="red", legend=false, linewidth=3)
print("Press Enter to Quit\n")
readline()