# This module generates data using a log-normal diffusion process of the form
#
#      P_{t+1} = P_t \cdot e^{drift + volatility \cdot v}
#
# where P_t is the value of the data at timestep t. The drift and 
# volatility represent the mean and standard deviation of a normal
# distribution. The equation given above expresses them as such by 
# letting v be a draw from a standard normal distribution which is
# then shifted and scaled by the drift and volatility terms

module LogDiffusion
import Dates.DateTime
import Dates.Second
import Random.rand
import Distributions.Normal

struct ParamLogDiff 
    nTimeStep::Integer # number of timesteps to simulate
    initialPrice::Real # in dollars
    dt::Real # change in time between timesteps in days
    volatility::Real # volatility as a standard deviation
    drift::Real # 
    ParamLogDiff(nTimeStep; initialPrice=100, dt=1, volatility=0.00930, drift=0.000538) = 
        new(nTimeStep, initialPrice, dt, volatility, drift)
    #ParamLogDiff(nTimeStep) = new(nTimeStep, 100.0, 1.0, 0.00930, 0.000538, )
    #ParamLogDiff(nTimeStep, initialPrice) = new(nTimeStep, initialPrice, 1.0, 0.00930, 0.000538)
    #ParamLogDiff(nTimeStep, initialPrice, dt, volatility, drift) = new(nTimeStep, initialPrice, dt, volatility, drift)
end
function getData(Param::ParamLogDiff, nSimulation=1)
    
    # compute array of random values
    nData = Param.nTimeStep + 1
    data = zeros((nData, nSimulation))
    data[2:nData,:] = rand(Normal(Param.drift,Param.volatility), (Param.nTimeStep,nSimulation))
    data = exp.(cumsum(data,dims=1) .+ log(Param.initialPrice))

    # export values
    return data

end
function getTime(Param::ParamLogDiff)
    secondPerDay = (3600*24)
    nSecondPerStepInt = floor(Param.dt*secondPerDay)
    nSecondPerStepSec = Second(nSecondPerStepInt)
    nSecondAll = Second(nSecondPerStepInt*Param.nTimeStep)

    tStart = DateTime(2000)
    tFinal = tStart + nSecondAll
    time = tStart:nSecondPerStepSec:tFinal
    return time
end
end