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

@testset verbose = true "to Congruence" begin
    @testset "scaffolding" begin
        # Check both public conversion signatures.
        @test hasmethod(
            Semigroups.to,
            Tuple{Type{Congruence},congruence_kind,FroidurePin,Any},
        )
        @test hasmethod(Semigroups.to, Tuple{Type{Congruence},congruence_kind,WordGraph})
    end

    @testset "from FroidurePin" begin
        # Convert the right Cayley graph of a completed Froidure-Pin.
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        run!(fp)
        c = Semigroups.to(Congruence, twosided, fp, right_cayley_graph(fp))

        @test c isa Congruence
        @test c isa CongruenceCommon
        @test number_of_classes(c) == 6
        @test kind(c) == twosided
        @test alphabet(presentation(c)) == [1, 2]
    end

    @testset "from WordGraph" begin
        # Convert a graph directly without a Froidure-Pin wrapper.
        wg = WordGraph(2, 1)
        target!(wg, 1, 1, 2)
        target!(wg, 2, 1, 2)

        c = Semigroups.to(Congruence, twosided, wg)

        @test c isa Congruence
        @test c isa CongruenceCommon
        @test number_of_classes(c) == 1
        @test kind(c) == twosided
        @test alphabet(presentation(c)) == [1]
    end

    @testset "errors are translated" begin
        fp = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test_throws LibsemigroupsError Semigroups.to(
            Congruence,
            twosided,
            fp,
            WordGraph(2, 1),
        )
    end
end

@testset verbose = true "to InversePresentation" begin
    @testset "scaffolding" begin
        # Check conversion from Presentation and copying an inverse presentation.
        @test hasmethod(Semigroups.to, Tuple{Type{InversePresentation},Presentation})
        @test hasmethod(Semigroups.to, Tuple{Type{InversePresentation},InversePresentation})
    end

    @testset "from Presentation" begin
        # Conversion adds inverse generators and preserves the original rules.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 2], [2, 1])

        ip = Semigroups.to(InversePresentation, p)

        @test ip isa InversePresentation
        @test alphabet(ip) == [1, 2, 3, 4]
        @test rules(ip) == rules(p)
        @test inverses(ip) == [3, 4, 1, 2]
        throw_if_bad_alphabet_rules_or_inverses(ip)
    end

    @testset "copy" begin
        # Copy conversion must produce an equal but distinct wrapper.
        p = Presentation()
        set_alphabet!(p, 1)
        ip = InversePresentation(p)
        set_inverses!(ip, [1])

        copy = Semigroups.to(InversePresentation, ip)

        @test copy isa InversePresentation
        @test copy !== ip
        @test copy == ip
        @test inverses(copy) == [1]
    end
end

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
