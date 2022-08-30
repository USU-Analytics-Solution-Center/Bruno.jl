# testing for statistical consistency. TEST IS NOT DETERMINISTIC. 
# MAY PASS EVEN IF CODE IS BROKEN 
@testset "Statistical consistency check for $v" for v in (MovingBlock, 
                                                CircularBlock, Stationary)
    # create AR(1) data set
    ar1 = [1.0]
    for _ in 1:999
        push!(ar1, 0.5 * ar1[end] + rand(Normal()))
    end
    # estimate the Beta parameter with OLS
    top = dot(ar1[1:end-1], ar1[2:end])
    bottom = dot(ar1[1:end-1], ar1[1:end-1])
    beta = top / bottom 

    # check a set of bootstraps to see if we can recover beta
    input = BootstrapInput{v}(ar1, 1000, 50, 1)
    results = zeros(1000)
    for i in 1:1000
        bootstrap = getData(input)
        top = dot(bootstrap[1:end-1], bootstrap[2:end])
        bottom = dot(bootstrap[1:end-1], bootstrap[1:end-1])
        results[i] = top / bottom
    end
    @test isapprox(mean(results), beta; atol = .05)
end

@testset "Stationarity test for Stationary Bootstrap" begin
    # create AR(1) data set
    ar1 = [1.0]
    for _ in 1:999
        push!(ar1, 0.5 * ar1[end] + rand(Normal()))
    end

    # check stationarity for AR(1) data set
    ar1ADF = ADFTest(ar1, :none, 0)
    @test ar1ADF.stat < ar1ADF.cv[1]

    # bootstrap AR(1) series 
    input = BootstrapInput{Stationary}(ar1, 1000, 50, 1)
    bs_data = getData(input)
    bootstrap = [bs_data[i] for i in 1:length(bs_data)]
    bsADF = ADFTest(bootstrap, :none, 0)
    
    # check stationarit of bootstrap
    @test bsADF.stat < bsADF.cv[1] 
end