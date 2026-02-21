# test_errors.jl - Tests for error handling

@testset "Error handling" begin
    # Initially no errors
    @test !have_error()

    # Test error checking doesn't throw when no errors
    @test check_error!() === nothing
end
