using Test
using Semigroups

@testset verbose = true "to Presentation" begin
    @testset "scaffolding" begin
        # Check every public conversion to Presentation.
        @test isdefined(Semigroups, :to)
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},Presentation})
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},Congruence})
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},Kambites})
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},ToddCoxeter})
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},KnuthBendix})
        @test hasmethod(Semigroups.to, Tuple{Type{Presentation},FroidurePin})
    end

    @testset "Presentation conversion" begin
        # Copying preserves presentation data without aliasing the wrapper.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 1], [2])
        set_contains_empty_word!(p, true)

        q = Semigroups.to(Presentation, p)

        @test q isa Presentation
        @test q == p
        @test q !== p
        @test alphabet(q) == alphabet(p)
        @test rules(q) == rules(p)
        @test contains_empty_word(q) == contains_empty_word(p)
    end

    @testset "Congruence conversion" begin
        # A congruence converts back to its defining presentation.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 1], [2])
        c = Congruence(twosided, p)

        q = Semigroups.to(Presentation, c)

        @test q isa Presentation
        @test q == p
    end

    @testset "conversion with no rules" begin
        # Conversion also preserves an alphabet when there are no rules.
        p = Presentation()
        set_alphabet!(p, 3)
        k = Kambites(twosided, p)

        q = Semigroups.to(Presentation, k)

        @test q isa Presentation
        @test q == presentation(k)
        @test alphabet(q) == alphabet(p)
        @test rules(q) == rules(p)
    end

    @testset "conversion of alphabet + rules" begin
        # Conversion preserves both alphabet and rules.
        p = Presentation()
        set_alphabet!(p, 3)
        add_rule_no_checks!(p, [1, 2, 1], [2, 3])
        add_rule_no_checks!(p, [3, 3], [1])
        k = Kambites(twosided, p)

        q = Semigroups.to(Presentation, k)

        @test q == presentation(k)
        @test q == p
        @test alphabet(q) == alphabet(p)
        @test rules(q) == rules(p)
    end

    @testset "contains empty word" begin
        # The empty-word flag is retained by conversion.
        p = Presentation()
        set_alphabet!(p, 1)
        set_contains_empty_word!(p, true)
        k = Kambites(twosided, p)

        q = Semigroups.to(Presentation, k)

        @test q == presentation(k)
        @test contains_empty_word(q)
    end

    @testset "matches Kambites presentation" begin
        # The converted presentation matches Kambites exactly.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 1], [2])
        k = Kambites(twosided, p)

        q = Semigroups.to(Presentation, k)

        @test q == presentation(k)
        @test alphabet(q) == alphabet(presentation(k))
        @test rules(q) == rules(presentation(k))
    end

    @testset "ToddCoxeter conversion" begin
        # Conversion preserves the Todd-Coxeter presentation data.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 1], [2])
        tc = ToddCoxeter(twosided, p)

        q = Semigroups.to(Presentation, tc)

        @test q isa Presentation
        @test q == presentation(tc)
        @test alphabet(q) == alphabet(p)
        @test rules(q) == rules(p)
    end

    @testset "ToddCoxeter conversion contains empty word" begin
        # Check the empty-word flag for Todd-Coxeter conversion.
        p = Presentation()
        set_alphabet!(p, 1)
        set_contains_empty_word!(p, true)
        tc = ToddCoxeter(twosided, p)

        @test contains_empty_word(Semigroups.to(Presentation, tc))
    end

    @testset "KnuthBendix conversion" begin
        # Conversion exposes the active Knuth-Bendix rules.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 1], [1])
        kb = KnuthBendix(twosided, p)
        run!(kb)

        q = Semigroups.to(Presentation, kb)

        @test q isa Presentation
        @test alphabet(q) == alphabet(presentation(kb))
        @test rules(q) == active_rules(kb)
        @test number_of_rules(q) == length(active_rules(kb))
    end

    @testset "KnuthBendix conversion contains empty word" begin
        # Check the empty-word flag for Knuth-Bendix conversion.
        p = Presentation()
        set_alphabet!(p, 1)
        set_contains_empty_word!(p, true)
        kb = KnuthBendix(twosided, p)

        @test contains_empty_word(Semigroups.to(Presentation, kb))
    end

    @testset "FroidurePin conversion" begin
        # Conversion produces a valid presentation from Froidure-Pin.
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))

        @test !finished(fp)

        q = Semigroups.to(Presentation, fp)

        @test finished(fp)
        @test q isa Presentation
        @test alphabet(q) == [1, 2]
        @test number_of_rules(q) > 0
        throw_if_bad_alphabet_or_rules(q)
    end
end
