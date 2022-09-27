using Test
using Bruno
using Distributions: Normal
using Statistics: mean
using HypothesisTests: ADFTest
using LinearAlgebra 

include("widgettests.jl")
include("datagentests.jl")
include("bootstraptests.jl")
include("factorytest.jl")
include("pricingmodeltests.jl")