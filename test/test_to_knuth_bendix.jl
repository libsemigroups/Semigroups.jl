using Test
using Semigroups

@testset verbose = true "to KnuthBendix" begin
    @testset "scaffolding" begin
        # Check conversions from Froidure-Pin and Todd-Coxeter.
        @test hasmethod(Semigroups.to, Tuple{Type{KnuthBendix},congruence_kind,FroidurePin})
        @test hasmethod(Semigroups.to, Tuple{Type{KnuthBendix},congruence_kind,ToddCoxeter})
    end

    @testset "from FroidurePin" begin
        # Conversion from a completed Froidure-Pin creates active rules.
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        run!(fp)
        kb = Semigroups.to(KnuthBendix, twosided, fp)

        @test kb isa KnuthBendix
        @test alphabet(presentation(kb)) == [1, 2]
        @test number_of_rules(presentation(kb)) > 0
        throw_if_bad_alphabet_or_rules(presentation(kb))
    end

    @testset "from ToddCoxeter" begin
        # Conversion preserves the Todd-Coxeter presentation.
        p = Presentation()
        set_alphabet!(p, 1)
        add_rule_no_checks!(p, [1, 1], [1])
        tc = ToddCoxeter(twosided, p)

        kb = Semigroups.to(KnuthBendix, twosided, tc)

        @test kb isa KnuthBendix
        @test presentation(kb) == presentation(tc)
    end
end
