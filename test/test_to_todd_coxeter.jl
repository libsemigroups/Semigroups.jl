using Test
using Semigroups

@testset verbose = true "to ToddCoxeter" begin
    @testset "scaffolding" begin
        # Check conversions from Froidure-Pin and Knuth-Bendix.
        @test hasmethod(
            Semigroups.to,
            Tuple{Type{ToddCoxeter},congruence_kind,FroidurePin,Any},
        )
        @test hasmethod(Semigroups.to, Tuple{Type{ToddCoxeter},congruence_kind,KnuthBendix})
    end

    @testset "from FroidurePin" begin
        # Convert a completed Froidure-Pin graph.
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        tc = Semigroups.to(ToddCoxeter, twosided, fp, right_cayley_graph(fp))

        @test tc isa ToddCoxeter
        @test alphabet(presentation(tc)) == [1, 2]
    end

    @testset "errors are translated" begin
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test_throws LibsemigroupsError Semigroups.to(
            ToddCoxeter,
            twosided,
            fp,
            WordGraph(2, 1),
        )
    end

    @testset "from KnuthBendix" begin
        # Convert a Knuth-Bendix instance built from a presentation.
        p = Presentation()
        set_alphabet!(p, 1)
        add_rule_no_checks!(p, [1, 1], [1])
        kb = KnuthBendix(twosided, p)

        tc = Semigroups.to(ToddCoxeter, twosided, kb)

        @test tc isa ToddCoxeter
        @test alphabet(presentation(tc)) == [1]
        @test number_of_classes(tc) == 1
    end
end
