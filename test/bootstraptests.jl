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
    
    # check stationarity of bootstrap
    @test bsADF.stat < bsADF.cv[1] 
end

@testset "Optimal Block Length test" begin
    # using this AR(1) data set
    ar = [1.0, 1.513150483642114, 1.4372622307759826, 1.4479754825782691, 
    0.6450704760464047, 0.6211199968073472, -0.004385905016206504, -1.569601823910172, 
    -2.918695454755963, -3.867425723655376, -4.1867970913294235, -3.7669832349089956, 
    -3.5309573063690705, -2.838271585578148, -1.7422324553622037, 0.18606991603291845, 
    1.0900879942964972, 1.4026347037927855, 2.3923805204653528, 3.174516523504543]
    
    # test for minimum block lenght value (this should require using b_max in the function, 
    # not b_length) These minimum parameters are from Andrew Patton's matlab code as well
    # as the python arch package by Kevin Sheppard
    @test opt_block_length(ar, Stationary()) == 7.0
    @test opt_block_length(ar, CircularBlock())  == 7.0

    # AR(1) dataset to be used in the larger series 
    ar = [1.0, 1.513150483642114, 1.4372622307759826, 1.4479754825782691, 0.6450704760464047, 
    0.6211199968073472, -0.004385905016206504, -1.569601823910172, -2.918695454755963, 
    -3.867425723655376, -4.1867970913294235, -3.7669832349089956, -3.5309573063690705, 
    -2.838271585578148, -1.7422324553622037, 0.18606991603291845, 1.0900879942964972, 
    1.4026347037927855, 2.3923805204653528, 3.174516523504543, 3.62438594356655, 
    4.178401558064353, 2.53617220094934, 2.249880439619924, 2.312098030773388, 
    5.051734238630761, 3.8075242053576894, 4.282825070031542, 4.39383656673906, 
    3.7583614105928707, 3.3164572742911753, 3.5950158987366376, 3.443655301194908, 
    1.0611963589441706, 0.6423352307071624, -0.32320929219003847, 0.04357299076863691, 
    -0.3718239254293272, -0.7643697529169282, 0.5096708387105471, 0.3916877734814425, 
    -0.7260910943279493, -0.717294103432776, -1.6044089426812829, -1.8949065084995287, 
    -1.8799579310870467, -0.15545753877938973, -1.0170615325360886, -1.9874095797147562, 
    -1.129495292911531]

    # testing out the block size using the data above against computed values using the 
    # Politis and White paper defining the algorithm.
    @test isapprox(opt_block_length(ar, Stationary()), 6.3085; atol=.001)
    @test isapprox(opt_block_length(ar, CircularBlock()), 7.2214; atol = .001)
end
