using FractionalCalculus
using Test

@testset "Test Fractional Integral" begin
    @test isapprox(fracint(x->x^4, 0.5, 0, 1.23, 1e-8, RL())[1], 1.163931646862977; atol = 0.00001)
    @test isapprox(fracint(x->x^4, 0.25, 0, 1.23, 1e-8, RL())[1], 1.64294134724409; atol = 0.00001)
    @test isapprox(fracint(x->x^4, 0.15, 0, 1.23, 1e-8, RL())[1], 1.878978485456182; atol = 0.00001)
    @test isapprox(fracint(x->sin(x), 0.5, 0, 0.97, 1e-8, RL())[1], 0.6442601778843754; atol = 0.00001)
    @test isapprox(fracint(x->sin(x), 0.25, 0, 0.97, 1e-8, RL())[1], 0.7448298999485293; atol = 0.00001)
    @test isapprox(fracint(x->sin(x), 0.15, 0, 0.97, 1e-8, RL())[1], 0.7802555196986999; atol = 0.00001)
end