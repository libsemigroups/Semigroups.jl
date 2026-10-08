using Test
using Semigroups

@testset verbose = true "to FroidurePin" begin
    @testset "scaffolding" begin
        @test hasmethod(Semigroups.to, Tuple{Type{FroidurePin},WordGraph})
    end

    @testset "from WordGraph" begin
        wg = WordGraph(2, 1)
        target!(wg, 1, 1, 2)
        target!(wg, 2, 1, 2)

        fp = Semigroups.to(FroidurePin, wg)

        @test fp isa FroidurePin{Transf{UInt32}}
        @test number_of_generators(fp) == 1
        @test degree(fp) == 2
    end

    @testset "errors are translated" begin
        @test_throws LibsemigroupsError Semigroups.to(FroidurePin, WordGraph(2, 1))
    end
end
