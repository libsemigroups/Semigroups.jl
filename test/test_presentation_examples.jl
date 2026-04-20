using Test
using Semigroups

@testset verbose = true "presentation examples" begin
    @testset "scaffolding" begin
        p = symmetric_group(3)
        @test p isa Presentation
        @test length(alphabet(p)) == 2
        # Known from libsemigroups tests-presentation-examples-1.cpp:
        # symmetric_group(3) has 4 rules.
        @test number_of_rules(p) == 4
        throw_if_bad_alphabet_or_rules(p)
    end

    @testset "batch A (group/transformation)" begin
        # Smoke: every binding produces a valid presentation
        for (fn, n) in [
            (alternating_group, 5),
            (braid_group, 4),
            (not_symmetric_group, 4),
            (full_transformation_monoid, 4),
            (partial_transformation_monoid, 4),
            (symmetric_inverse_monoid, 4),
            (cyclic_inverse_monoid, 4),
            (order_preserving_monoid, 4),
            (order_preserving_cyclic_inverse_monoid, 4),
            (orientation_preserving_monoid, 4),
            (orientation_preserving_reversing_monoid, 4),
        ]
            p = fn(n)
            @test p isa Presentation
            throw_if_bad_alphabet_or_rules(p)
        end

        # Known-answer check: symmetric_group uses Car56 variant, which has n-1 generators
        p4 = symmetric_group(4)
        @test length(alphabet(p4)) == 3              # Car56: n-1 = 3 generators for n=4
    end

    @testset "batch B (diagram/partition)" begin
        for (fn, n) in [
            (partition_monoid, 4),
            (partial_brauer_monoid, 3),
            (brauer_monoid, 3),
            (singular_brauer_monoid, 3),
            (temperley_lieb_monoid, 4),
            (motzkin_monoid, 4),
            (partial_isometries_cycle_graph_monoid, 3),
            (uniform_block_bijection_monoid, 3),
            (dual_symmetric_inverse_monoid, 3),
            (stellar_monoid, 3),
            (zero_rook_monoid, 3),
        ]
            p = fn(n)
            @test p isa Presentation
            throw_if_bad_alphabet_or_rules(p)
        end

        # abacus_jones_monoid has two args
        ajm = abacus_jones_monoid(4, 3)
        @test ajm isa Presentation
        throw_if_bad_alphabet_or_rules(ajm)

        # Known-answer: temperley_lieb_monoid(4) — n-1 generators
        tlm = temperley_lieb_monoid(4)
        @test length(alphabet(tlm)) == 3             # n-1 = 3 generators for n=4
    end

    @testset "batch C (plactic/misc)" begin
        for (fn, n) in [
            (plactic_monoid, 4),
            (chinese_monoid, 4),
            (hypo_plactic_monoid, 4),
            (stylic_monoid, 4),
            (special_linear_group_2, 3),
        ]
            p = fn(n)
            @test p isa Presentation
            throw_if_bad_alphabet_or_rules(p)
        end

        # 2-arg variants
        for (fn, a, b) in [
            (fibonacci_semigroup, 2, 5),
            (monogenic_semigroup, 3, 2),
            (rectangular_band, 2, 3),
        ]
            p = fn(a, b)
            @test p isa Presentation
            throw_if_bad_alphabet_or_rules(p)
        end

        # sigma_plactic_monoid — vector input (0-based per libsemigroups)
        spm = sigma_plactic_monoid([2, 1])
        @test spm isa Presentation
        throw_if_bad_alphabet_or_rules(spm)

        # Renner-family (int q)
        for fn in (
            renner_type_B_monoid,
            renner_type_D_monoid,
            not_renner_type_B_monoid,
            not_renner_type_D_monoid,
        )
            p = fn(3, 1)
            @test p isa Presentation
            throw_if_bad_alphabet_or_rules(p)
        end

        # Known-answer: monogenic_semigroup(m=3, r=2) has a single generator
        ms = monogenic_semigroup(3, 2)
        @test length(alphabet(ms)) == 1
    end
end
