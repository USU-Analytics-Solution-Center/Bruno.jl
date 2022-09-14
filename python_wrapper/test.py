# Imports and downloads Julia if now already downloaded
# Need to figure out how to dynamucally do this...
# Maybe have an outer python function that the user calls
# and it handels the julia download/ seperate function calls
import julia
julia.install()

from time import process_time
from julia import Main
import pandas as pd

print("Loading Julia")
js_start = process_time()
Main.include("src/Instruments/widgets.jl")
js_loaded = process_time()
print("loaded Julia in ", js_loaded - js_start)