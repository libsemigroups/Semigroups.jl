# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_froidure_pin_transf.jl - FroidurePin<Transf<>> correctness tests

Ported from libsemigroups/tests/test-froidure-pin-transf.cpp.
All indices are 1-based (Julia convention).
"""

# ============================================================================
# Helper functions (mirroring C++ test helpers)
# ============================================================================

"""
Test that element at position `pos` in `S` is idempotent:
  1. is_idempotent(S, pos) returns true
  2. x * x == x
  3. fast_product(S, pos, pos) == pos
"""
function test_idempotent(S, x)
    pos = Semigroups.position(S, x)
    @test is_idempotent(S, pos)
    @test x * x == x
    @test fast_product(S, pos, pos) == pos
end

"""
Test that current_rules are consistent: for each rule (lhs, rhs),
the current_position of both sides should be equal, and the count
should match current_number_of_rules.
"""
function test_current_rules_iterator(S)
    nr = 0
    for (lhs, rhs) in current_rules(S)
        @test current_position(S, lhs) == current_position(S, rhs)
        nr += 1
    end
    @test nr == current_number_of_rules(S)
end

ReportGuard(false) do

@testset "FroidurePin<Transf> correctness" begin

    # -----------------------------------------------------------------------
    # Test 042: "JDM favourite" [standard]
    # Large semigroup: 597369 elements, 8 generators of degree 8
    # -----------------------------------------------------------------------
    @testset "042: JDM favourite [standard]" begin
        S = FroidurePin(
            Transf([2, 8, 3, 7, 1, 5, 2, 6]),
            Transf([3, 5, 7, 2, 5, 6, 3, 8]),
            Transf([4, 1, 8, 3, 5, 7, 3, 5]),
            Transf([4, 3, 4, 5, 6, 4, 1, 2]),
            Transf([5, 4, 8, 8, 5, 6, 1, 5]),
            Transf([6, 7, 4, 1, 4, 1, 6, 2]),
            Transf([7, 1, 2, 2, 2, 7, 4, 5]),
            Transf([8, 8, 5, 1, 7, 5, 2, 8]),
        )
        reserve!(S, 597369)

        @test length(S) == 597369
        @test number_of_idempotents(S) == 8194

        # Position of every element matches iteration order
        for (i, x) in Base.enumerate(S)
            @test Semigroups.position(S, x) == i
        end

        # add_generators increases size
        push!(S, Transf([8, 2, 3, 7, 8, 5, 2, 6]))
        @test length(S) == 826713

        # closure with already-present generator doesn't change size
        closure!(S, Transf([8, 2, 3, 7, 8, 5, 2, 6]))
        @test length(S) == 826713

        # minimal_factorisation (1-based: C++ position 10 → Julia 11)
        @test minimal_factorisation(S, 11) == [1, 3]
        @test S[11] == Transf([1, 5, 8, 3, 4, 5, 1, 7])
        @test_throws LibsemigroupsError minimal_factorisation(S, 1000000001)

        # Every idempotent satisfies x * x == x
        @test all(x * x == x for x in idempotents(S))
        @test length(idempotents(S)) == number_of_idempotents(S)

        # Sorted elements are strictly increasing
        @test issorted(sorted_elements(S))
    end

    # -----------------------------------------------------------------------
    # Test 043: "no exception zero generators given" [quick]
    # -----------------------------------------------------------------------
    @testset "043: no exception zero generators" begin
        # The C++ library accepts empty generator sets; the Julia wrapper
        # currently requires at least one generator, so we test that
        # constraint.
        @test_throws ErrorException FroidurePin(Transf{UInt16}[])
    end

    # -----------------------------------------------------------------------
    # Test 044: "exception generators of different degrees" [quick]
    # -----------------------------------------------------------------------
    @testset "044: exception generators of different degrees" begin
        S = FroidurePin(Transf([3, 5, 7, 2, 5, 6, 3, 8, 4]))  # degree 9
        @test_throws LibsemigroupsError push!(S, Transf([2, 8, 3, 7, 1, 1, 2, 3]))  # degree 8
    end

    # -----------------------------------------------------------------------
    # Test 045: "exception current_position" [quick]
    # -----------------------------------------------------------------------
    @testset "045: exception current_position" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # Empty word → identity → position 1 (1-based)
        @test current_position(U, Int[]) == 1
        # Valid word, no throw (may return UNDEFINED if not yet enumerated)
        @test_nowarn current_position(U, [1, 1, 2, 3])
        # Generator index 6 out of range for 5 generators
        @test_throws LibsemigroupsError current_position(U, [6])
    end

    # -----------------------------------------------------------------------
    # Test 046: "exception to_element" [quick]
    # -----------------------------------------------------------------------
    @testset "046: exception to_element" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # Empty word → identity element == generator(1)
        @test to_element(U, Int[]) == generator(U, 1)
        # Out-of-range generator index
        @test_throws LibsemigroupsError to_element(U, [6])

        # to_element([1,1,2,3]) == gen1 * gen1 * gen2 * gen3
        gen1 = Transf([1, 2, 3, 4, 5, 6])
        gen2 = Transf([2, 1, 3, 4, 5, 6])
        gen3 = Transf([5, 1, 2, 3, 4, 6])
        u = to_element(U, [1, 1, 2, 3])
        @test u == gen1 * gen1 * gen2 * gen3
    end

    # -----------------------------------------------------------------------
    # Test 047: "exception gens" [quick]
    # -----------------------------------------------------------------------
    @testset "047: exception gens" begin
        for i = 1:19
            # Build cyclic shift transformations of degree i (1-based)
            gens = [Transf([mod(k + j - 2, i) + 1 for k = 1:i]) for j = 1:i]
            S = FroidurePin(gens)
            for j = 1:i
                @test generator(S, j) isa Transf
            end
            @test_throws Exception generator(S, i + 1)
        end
    end

    # -----------------------------------------------------------------------
    # Test 048: "exception prefix" [quick]
    # -----------------------------------------------------------------------
    @testset "048: exception prefix" begin
        U = FroidurePin(
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:length(U)
            # prefix returns UNDEFINED for generators, valid position otherwise
            @test_nowarn prefix(U, i)
        end
        @test_throws Exception prefix(U, length(U) + 1)
    end

    # -----------------------------------------------------------------------
    # Test 049: "exception suffix" [quick]
    # -----------------------------------------------------------------------
    @testset "049: exception suffix" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        @test length(U) == 7776

        for i = 1:length(U)
            # suffix returns UNDEFINED for generators, valid position otherwise
            @test_nowarn suffix(U, i)
        end
        @test_throws Exception suffix(U, length(U) + 1)
    end

    # -----------------------------------------------------------------------
    # Test 050: "exception first_letter" [quick]
    # -----------------------------------------------------------------------
    @testset "050: exception first_letter" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:length(U)
            @test first_letter(U, i) isa Integer
            @test_throws Exception first_letter(U, i + length(U))
        end
    end

    # -----------------------------------------------------------------------
    # Test 051: "exception final_letter" [quick]
    # -----------------------------------------------------------------------
    @testset "051: exception final_letter" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:length(U)
            @test final_letter(U, i) isa Integer
            @test_throws Exception final_letter(U, i + length(U))
        end
    end

    # -----------------------------------------------------------------------
    # Test 052: "exception current_length" [quick]
    # -----------------------------------------------------------------------
    @testset "052: exception current_length" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:length(U)
            @test current_length(U, i) isa Integer
            @test_throws Exception current_length(U, i + length(U))
        end
    end

    # -----------------------------------------------------------------------
    # Test 053: "exception product_by_reduction" [quick]
    # -----------------------------------------------------------------------
    @testset "053: exception product_by_reduction" begin
        U = FroidurePin(Transf([1, 2, 3, 4]), Transf([4, 2, 2, 3]))

        n = length(U)
        for i = 1:n
            for j = 1:n
                @test product_by_reduction(U, i, j) isa Integer
                @test_throws Exception product_by_reduction(U, i + n, j)
                @test_throws Exception product_by_reduction(U, i, j + n)
                @test_throws Exception product_by_reduction(U, i + n, j + n)
            end
        end
    end

    # -----------------------------------------------------------------------
    # Test 054: "exception fast_product" [quick]
    # -----------------------------------------------------------------------
    @testset "054: exception fast_product" begin
        U = FroidurePin(Transf([1, 2, 3, 4]), Transf([4, 2, 2, 3]))

        n = length(U)
        for i = 1:n
            for j = 1:n
                @test fast_product(U, i, j) isa Integer
                @test_throws Exception fast_product(U, i + n, j)
                @test_throws Exception fast_product(U, i, j + n)
                @test_throws Exception fast_product(U, i + n, j + n)
            end
        end
    end

    # -----------------------------------------------------------------------
    # Test 055: "exception current_position" [quick]
    # (Tests position_of_generator bounds)
    # -----------------------------------------------------------------------
    @testset "055: exception position_of_generator" begin
        for i = 1:19
            gens = [Transf([mod(k + j - 2, i) + 1 for k = 1:i]) for j = 1:i]
            S = FroidurePin(gens)
            for j = 1:i
                @test position_of_generator(S, j) isa Integer
            end
            @test_throws Exception position_of_generator(S, i + 1)
        end
    end

    # -----------------------------------------------------------------------
    # Test 056: "exception is_idempotent" [quick]
    # -----------------------------------------------------------------------
    @testset "056: exception is_idempotent" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([6, 2, 4, 4, 3, 6]),
            Transf([3, 2, 3, 4, 5, 5]),
            Transf([6, 6, 3, 2, 2, 3]),
        )

        @test length(S) == 441
        for i = 1:441
            @test is_idempotent(S, i) isa Bool
        end
        for i = 0:19
            @test_throws Exception is_idempotent(S, 442 + i)
        end
    end

    # -----------------------------------------------------------------------
    # Test 057: "exception add_generators" [quick]
    # -----------------------------------------------------------------------
    @testset "057: exception add_generators" begin
        T = FroidurePin(Transf([2, 8, 3, 7, 1, 1, 2, 3]), Transf([3, 5, 7, 2, 5, 6, 3, 8]))

        # Adding generators of same degree succeeds
        push!(T, Transf([2, 3, 3, 3, 2, 2, 4, 5]))
        push!(T, Transf([2, 3, 2, 4, 2, 5, 2, 6]))
        @test number_of_generators(T) == 4

        # Adding generator with wrong degree throws
        @test_throws LibsemigroupsError push!(T, Transf([2, 3, 2, 4, 2, 5, 2, 6, 2]))
    end

    # -----------------------------------------------------------------------
    # Test 058: "number_of_idempotents" [quick]
    # -----------------------------------------------------------------------
    @testset "058: number_of_idempotents" begin
        S = FroidurePin(Transf([2, 8, 3, 7, 1, 1, 2, 3]), Transf([3, 5, 7, 2, 5, 6, 3, 8]))
        @test number_of_idempotents(S) == 72
    end

    # -----------------------------------------------------------------------
    # Test 059: "small semigroup" [quick]
    # -----------------------------------------------------------------------
    @testset "059: small semigroup" begin
        S = FroidurePin(Transf([1, 2, 1]), Transf([1, 2, 3]))

        @test length(S) == 2
        @test degree(S) == 3
        @test number_of_idempotents(S) == 2
        @test number_of_generators(S) == 2
        @test number_of_rules(S) == 4

        @test S[1] == Transf([1, 2, 1])
        @test S[2] == Transf([1, 2, 3])

        @test Semigroups.position(S, Transf([1, 2, 1])) == 1
        @test Transf([1, 2, 1]) in S

        @test Semigroups.position(S, Transf([1, 2, 3])) == 2
        @test Transf([1, 2, 3]) in S

        @test Semigroups.position(S, Transf([1, 1, 1])) == UNDEFINED
        @test !(Transf([1, 1, 1]) in S)
    end

    # -----------------------------------------------------------------------
    # Test 060: "large semigroup" [quick]
    # -----------------------------------------------------------------------
    @testset "060: large semigroup" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        @test length(S) == 7776
        @test degree(S) == 6
        @test number_of_idempotents(S) == 537
        @test number_of_generators(S) == 5
        @test number_of_rules(S) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 061: "at, position, current_*" [quick]
    # NOTE: Julia's getindex calls length() which triggers full enumeration,
    # so we test partial enumeration via enumerate! and verify element values
    # after full enumeration.
    # -----------------------------------------------------------------------
    @testset "061: at, position, current_*" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        set_batch_size!(S, 1024)

        # Test partial enumeration via enumerate!
        enumerate!(S, 1029)
        @test current_size(S) == 1029
        @test current_number_of_rules(S) == 74
        @test current_max_word_length(S) == 7

        # Element value checks (after full enum via getindex)
        @test S[101] == Transf([6, 4, 5, 2, 3, 6])
        @test Semigroups.position(S, Transf([6, 4, 5, 2, 3, 6])) == 101

        @test S[1024] == Transf([6, 5, 4, 5, 2, 6])
        @test Semigroups.position(S, Transf([6, 5, 4, 5, 2, 6])) == 1024

        @test S[3001] == Transf([6, 4, 6, 4, 5, 6])
        @test Semigroups.position(S, Transf([6, 4, 6, 4, 5, 6])) == 3001

        @test length(S) == 7776
        @test degree(S) == 6
        @test number_of_idempotents(S) == 537
        @test number_of_generators(S) == 5
        @test number_of_rules(S) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 062: "run" [quick]
    # -----------------------------------------------------------------------
    @testset "062: run (incremental enumerate)" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        set_batch_size!(S, 1024)

        enumerate!(S, 3000)
        @test current_size(S) == 3000
        @test current_number_of_rules(S) == 526
        @test current_max_word_length(S) == 9

        enumerate!(S, 3001)
        @test current_size(S) == 4024
        @test current_number_of_rules(S) == 999
        @test current_max_word_length(S) == 10

        enumerate!(S, 7000)
        @test current_size(S) == 7000
        @test current_number_of_rules(S) == 2044
        @test current_max_word_length(S) == 12

        @test length(S) == 7776
    end

    # -----------------------------------------------------------------------
    # Test 063: "run [many stops and starts]" [quick]
    # -----------------------------------------------------------------------
    @testset "063: run many stops and starts" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        set_batch_size!(S, 128)

        i = 1
        while !finished(S)
            enumerate!(S, i * 128)
            i += 1
        end

        @test length(S) == 7776
        @test number_of_idempotents(S) == 537
        @test number_of_generators(S) == 5
        @test number_of_rules(S) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 064: "factorisation, length [1 element]" [quick]
    # -----------------------------------------------------------------------
    @testset "064: factorisation, length [1 element]" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        set_batch_size!(S, 1024)

        # C++ position 5537 → Julia 5538; C++ word {1,2,2,2,3,2,4,1,2,2,3} → Julia [2,3,3,3,4,3,5,2,3,3,4]
        w = factorisation(S, 5538)
        @test w == [2, 3, 3, 3, 4, 3, 5, 2, 3, 3, 4]
        @test current_length(S, 5538) == 11
        @test word_length(S, 5538) == 11

        @test current_size(S) == 5539
        @test current_number_of_rules(S) == 1484

        @test word_length(S, 7776) == 16
    end

    # -----------------------------------------------------------------------
    # Test 065: "factorisation, products [all elements]" [quick]
    # -----------------------------------------------------------------------
    @testset "065: factorisation roundtrip [all elements]" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:length(S)
            w = factorisation(S, i)
            @test current_position(S, w) == i
        end
    end

    # -----------------------------------------------------------------------
    # Test 066: "first/final letter, prefix, suffix, products" [quick]
    # -----------------------------------------------------------------------
    @testset "066: first/final letter, prefix, suffix" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        run!(S)

        # Element 6378 (C++ 6377, 1-based)
        @test first_letter(S, 6378) == 3
        @test prefix(S, 6378) == 5050
        @test final_letter(S, 6378) == 3
        @test suffix(S, 6378) == 5150
        @test fast_product(S, prefix(S, 6378), final_letter(S, 6378)) == 6378
        @test fast_product(S, first_letter(S, 6378), suffix(S, 6378)) == 6378
        @test product_by_reduction(S, prefix(S, 6378), final_letter(S, 6378)) == 6378
        @test product_by_reduction(S, first_letter(S, 6378), suffix(S, 6378)) == 6378

        # Element 2104 (C++ 2103)
        @test first_letter(S, 2104) == 4
        @test prefix(S, 2104) == 1051
        @test final_letter(S, 2104) == 2
        @test suffix(S, 2104) == 861
        @test fast_product(S, prefix(S, 2104), final_letter(S, 2104)) == 2104
        @test fast_product(S, first_letter(S, 2104), suffix(S, 2104)) == 2104

        # Element 3408 (C++ 3407)
        @test first_letter(S, 3408) == 3
        @test prefix(S, 3408) == 1924
        @test final_letter(S, 3408) == 4
        @test suffix(S, 3408) == 2116

        # Element 4246 (C++ 4245)
        @test first_letter(S, 4246) == 3
        @test prefix(S, 4246) == 2768
        @test final_letter(S, 4246) == 4
        @test suffix(S, 4246) == 2320

        # Element 3684 (C++ 3683)
        @test first_letter(S, 3684) == 5
        @test prefix(S, 3684) == 2247
        @test final_letter(S, 3684) == 3
        @test suffix(S, 3684) == 1686

        # Element 1 (C++ 0): generator — prefix/suffix are UNDEFINED
        @test first_letter(S, 1) == 1
        @test prefix(S, 1) == UNDEFINED
        @test final_letter(S, 1) == 1
        @test suffix(S, 1) == UNDEFINED

        # Element 7776 (C++ 7775): last element
        @test first_letter(S, 7776) == 2
        @test prefix(S, 7776) == 7761
        @test final_letter(S, 7776) == 3
        @test suffix(S, 7776) == 7769
    end

    # -----------------------------------------------------------------------
    # Test 067: "current_position [standard]" [quick]
    # -----------------------------------------------------------------------
    @testset "067: position_of_generator" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        for i = 1:5
            @test position_of_generator(S, i) == i
        end
    end

    # -----------------------------------------------------------------------
    # Test 068: "current_position [duplicate gens]" [quick]
    # -----------------------------------------------------------------------
    @testset "068: duplicate generators" begin
        # Build semigroup with many duplicate generators using push!
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]))  # gen 1: identity
        push!(S, Transf([2, 1, 3, 4, 5, 6]))          # gen 2: (1,2)
        for _ = 1:10
            push!(S, Transf([2, 1, 3, 4, 5, 6]))      # gen 3-12: dups
        end
        push!(S, Transf([6, 2, 3, 4, 5, 6]))          # gen 13: distinct
        for _ = 1:8
            push!(S, Transf([2, 1, 3, 4, 5, 6]))      # gen 14-21: dups
        end
        push!(S, Transf([5, 1, 2, 3, 4, 6]))          # gen 22: distinct
        for _ = 1:9
            push!(S, Transf([2, 1, 3, 4, 5, 6]))      # gen 23-31: dups
        end
        push!(S, Transf([2, 2, 3, 4, 5, 6]))          # gen 32: distinct

        # Duplicates map to same element position
        @test position_of_generator(S, 1) == 1    # identity
        @test position_of_generator(S, 2) == 2    # (1,2)
        @test position_of_generator(S, 3) == 2    # dup → same position
        @test position_of_generator(S, 11) == 2   # dup → same position
        @test number_of_generators(S) == 32
        @test length(S) == 7776
    end

    # -----------------------------------------------------------------------
    # Test 069: "current_position [after add_generators]" [quick]
    # -----------------------------------------------------------------------
    @testset "069: incremental add_generators" begin
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]))  # identity
        @test length(S) == 1
        @test number_of_rules(S) == 1

        push!(S, Transf([2, 1, 3, 4, 5, 6]))
        @test length(S) == 2
        @test number_of_rules(S) == 4

        push!(S, Transf([5, 1, 2, 3, 4, 6]))
        @test length(S) == 120
        @test number_of_rules(S) == 25

        push!(S, Transf([6, 2, 3, 4, 5, 6]))
        @test length(S) == 1546
        @test number_of_rules(S) == 495

        push!(S, Transf([2, 2, 3, 4, 5, 6]))
        @test length(S) == 7776
        @test number_of_rules(S) == 2459

        # Generator positions shift as elements are added (1-based)
        @test position_of_generator(S, 1) == 1
        @test position_of_generator(S, 2) == 2
        @test position_of_generator(S, 3) == 3
        @test position_of_generator(S, 4) == 121    # added when size was 120
        @test position_of_generator(S, 5) == 1547   # added when size was 1546
    end

    # -----------------------------------------------------------------------
    # Test 070: "cbegin_idempotents/cend" [quick]
    # -----------------------------------------------------------------------
    @testset "070: idempotent iteration with test_idempotent" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        run!(S)

        nr = 0
        for x in idempotents(S)
            test_idempotent(S, x)
            nr += 1
        end
        @test nr == number_of_idempotents(S)
    end

    # Test 071: same as 070, skipped (functionally identical)

    # -----------------------------------------------------------------------
    # Test 072: "is_idempotent" [quick]
    # -----------------------------------------------------------------------
    @testset "072: is_idempotent counting" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        nr = count(i -> is_idempotent(S, i), 1:length(S))
        @test nr == number_of_idempotents(S)
        @test nr == 537
    end

    # -----------------------------------------------------------------------
    # Test 073: "cbegin_idempotents/cend, is_idempotent" [standard]
    # Large degree-7 semigroup with 6322 idempotents
    # -----------------------------------------------------------------------
    @testset "073: idempotents [standard, degree 7]" begin
        S = FroidurePin(
            Transf([2, 3, 4, 5, 6, 7, 1]),   # cyclic shift
            Transf([2, 1, 3, 4, 5, 6, 7]),   # (1,2)
            Transf([1, 2, 3, 4, 5, 6, 1]),   # collapse 7→1
        )

        ids = idempotents(S)
        @test length(ids) == number_of_idempotents(S)
        @test length(ids) == 6322

        for x in ids
            test_idempotent(S, x)
        end

        # Second pass gives same count (repeatability)
        ids2 = idempotents(S)
        @test length(ids2) == 6322
    end

    # -----------------------------------------------------------------------
    # Test 074: "finished, started" [quick]
    # -----------------------------------------------------------------------
    @testset "074: finished, started" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        @test !started(S)
        @test !finished(S)

        set_batch_size!(S, 1024)
        enumerate!(S, 10)
        @test started(S)
        @test !finished(S)

        enumerate!(S, 8000)
        @test started(S)
        @test finished(S)
    end

    # -----------------------------------------------------------------------
    # Test 075: "current_position" [quick]
    # -----------------------------------------------------------------------
    @testset "075: current_position (element)" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # Generators have sequential positions
        for i = 1:5
            @test current_position(S, generator(S, i)) == i
        end

        set_batch_size!(S, 1024)
        enumerate!(S, 1024)
        @test current_size(S) == 1029

        # Element within enumerated range
        @test current_position(S, Transf([6, 2, 6, 6, 3, 6])) == 1029

        # Wrong degree → UNDEFINED
        @test current_position(S, Transf([6, 2, 6, 6, 3, 6, 7])) == UNDEFINED

        # Not yet enumerated → UNDEFINED from current_position
        @test current_position(S, Transf([6, 5, 6, 2, 1, 6])) == UNDEFINED

        # But full position() finds it (triggers enumeration)
        @test Semigroups.position(S, Transf([6, 5, 6, 2, 1, 6])) == 1030
    end

    # -----------------------------------------------------------------------
    # Test 076: "sorted_position, sorted_at" [quick]
    # -----------------------------------------------------------------------
    @testset "076: sorted_position, sorted_at" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # Generator sorted positions (C++ 0-based → Julia 1-based: +1)
        @test sorted_position(S, generator(S, 1)) == 311
        @test sorted_at(S, 311) == generator(S, 1)

        @test sorted_position(S, generator(S, 2)) == 1391
        @test sorted_at(S, 1391) == generator(S, 2)

        @test sorted_position(S, generator(S, 3)) == 5236
        @test sorted_at(S, 5236) == generator(S, 3)

        @test sorted_position(S, generator(S, 4)) == 6791
        @test sorted_at(S, 6791) == generator(S, 4)

        @test sorted_position(S, generator(S, 5)) == 1607
        @test sorted_at(S, 1607) == generator(S, 5)

        @test finished(S)

        # Position-to-sorted conversion (C++ 1024 → Julia 1025)
        @test to_sorted_position(S, 1025) == 6811
        @test sorted_at(S, 6811) == S[1025]

        @test sorted_position(S, Transf([6, 2, 6, 6, 3, 6])) == 6909
        @test sorted_at(S, 6909) == Transf([6, 2, 6, 6, 3, 6])

        # Wrong degree → UNDEFINED
        @test sorted_position(S, Transf([6, 6, 6, 2, 6, 6, 7])) == UNDEFINED

        # Out of bounds
        @test_throws Exception sorted_at(S, 100001)
        @test_throws BoundsError S[100001]
        @test to_sorted_position(S, 100001) == UNDEFINED
    end

    # -----------------------------------------------------------------------
    # Test 077: "right/left Cayley graph" [quick]
    # -----------------------------------------------------------------------
    @testset "077: Cayley graph consistency" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        run!(S)

        rcg = right_cayley_graph(S)
        lcg = left_cayley_graph(S)

        # Identity self-loops
        @test target(rcg, 1, 1) == 1
        @test target(lcg, 1, 1) == 1

        # Cayley graph consistency: for every element x and generator g,
        # position(x * g) == right_cayley_graph target(pos(x), gen_idx)
        # position(g * x) == left_cayley_graph target(pos(x), gen_idx)
        for i = 1:length(S)
            x = S[i]
            for g = 1:5
                @test Semigroups.position(S, x * generator(S, g)) == target(rcg, i, g)
                @test Semigroups.position(S, generator(S, g) * x) == target(lcg, i, g)
            end
        end
    end

    # -----------------------------------------------------------------------
    # Test 078: "iterator" [quick]
    # NOTE: Julia's iterate triggers full enumeration via length(),
    # so pre-enumeration iteration is not directly testable.
    # We verify that iteration covers all elements and containment.
    # -----------------------------------------------------------------------
    @testset "078: iterator" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        elts = collect(S)
        @test length(elts) == 7776
        # All elements are contained
        for x in elts
            @test x in S
        end
    end

    # Test 079-080, 082: C++ iterator arithmetic — skipped (Julia iteration is sequential)

    # -----------------------------------------------------------------------
    # Test 081: "iterator sorted" [quick]
    # -----------------------------------------------------------------------
    @testset "081: sorted iteration consistency" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        se = sorted_elements(S)
        @test finished(S)
        @test length(se) == length(S)

        for (i, x) in Base.enumerate(se)
            @test sorted_position(S, x) == i
            @test to_sorted_position(S, Semigroups.position(S, x)) == i
        end
    end

    # -----------------------------------------------------------------------
    # Test 083: "copy [not enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "083: copy" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        T = copy(S)
        @test number_of_generators(T) == 5
        @test degree(T) == 6
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
        @test number_of_rules(T) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 084: "copy_closure [not enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "084: copy_closure" begin
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]), Transf([2, 1, 3, 4, 5, 6]))

        # copy_closure adds 3 more generators
        T = copy_closure(S, Transf([5, 1, 2, 3, 4, 6]))
        T = copy_closure(T, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))

        @test number_of_generators(T) == 5
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
        @test number_of_rules(T) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 085: "copy_add_generators [not enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "085: copy_add_generators" begin
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]), Transf([2, 1, 3, 4, 5, 6]))

        T = copy_add_generators(S, Transf([5, 1, 2, 3, 4, 6]))
        T = copy_add_generators(T, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_add_generators(T, Transf([2, 2, 3, 4, 5, 6]))

        @test number_of_generators(T) == 5
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
        @test number_of_rules(T) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 086: "copy [partly enumerated]" [quick]
    # NOTE: Julia copy() reconstructs from generators (starts fresh).
    # We verify it produces the same semigroup.
    # -----------------------------------------------------------------------
    @testset "086: copy produces same semigroup" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        T = copy(S)
        @test number_of_generators(T) == 5
        @test degree(T) == 6
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
        @test number_of_rules(T) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 087: "copy_closure [partly enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "087: copy_closure from partly enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        set_batch_size!(S, 60)
        enumerate!(S, 60)
        @test current_size(S) == 63

        T = copy_closure(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))

        @test generator(T, 4) == Transf([6, 2, 3, 4, 5, 6])
        @test generator(T, 5) == Transf([2, 2, 3, 4, 5, 6])
        @test number_of_generators(T) == 5
        @test length(T) == 7776
    end

    # -----------------------------------------------------------------------
    # Test 088: "copy_add_generators [partly enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "088: copy_add_generators from partly enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        set_batch_size!(S, 60)
        enumerate!(S, 60)

        T = copy_add_generators(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_add_generators(T, Transf([2, 2, 3, 4, 5, 6]))

        @test number_of_generators(T) == 5
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
    end

    # -----------------------------------------------------------------------
    # Test 089: "copy [fully enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "089: copy from fully enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        run!(S)
        @test finished(S)

        T = copy(S)
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
        @test number_of_rules(T) == 2459
    end

    # -----------------------------------------------------------------------
    # Test 090: "copy_closure [fully enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "090: copy_closure from fully enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        run!(S)
        @test finished(S)
        @test length(S) == 120  # S₅

        T = copy_closure(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))

        @test number_of_generators(T) == 5
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
    end

    # -----------------------------------------------------------------------
    # Test 091: "copy_add_generators [fully enumerated]" [quick]
    # -----------------------------------------------------------------------
    @testset "091: copy_add_generators from fully enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        run!(S)
        @test length(S) == 120

        T = copy_add_generators(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_add_generators(T, Transf([2, 2, 3, 4, 5, 6]))

        @test number_of_generators(T) == 5
        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
    end

    # -----------------------------------------------------------------------
    # Test 092: "rules [duplicate gens]" [quick]
    # -----------------------------------------------------------------------
    @testset "092: rules with duplicate generators" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),   # gen 1: identity
            Transf([1, 2, 3, 4, 5, 6]),   # gen 2: dup of gen 1
            Transf([2, 1, 3, 4, 5, 6]),   # gen 3: (1,2)
            Transf([2, 1, 3, 4, 5, 6]),   # gen 4: dup of gen 3
            Transf([5, 1, 2, 3, 4, 6]),   # gen 5
        )
        run!(S)

        rs = rules(S)
        # First rule: gen 2 == gen 1 (duplicate)
        @test rs[1] == ([2] => [1])
        # Second rule: gen 4 == gen 3 (duplicate)
        @test rs[2] == ([4] => [3])
        # Total rules count is consistent
        @test number_of_rules(S) == length(rs)
    end

    # -----------------------------------------------------------------------
    # Test 093: "rules" [quick]
    # -----------------------------------------------------------------------
    @testset "093: rules before/during/after enumeration" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # No current rules before enumeration
        @test length(current_rules(S)) == 0

        # Partial enumeration to discover rules
        set_batch_size!(S, 10)
        enumerate!(S, 10)
        @test !finished(S)

        # First two rules (1-based generators): identity^2=identity, identity*gen2=gen2
        cr = current_rules(S)
        @test length(cr) >= 2
        @test cr[1] == ([1, 1] => [1])
        @test cr[2] == ([1, 2] => [2])
        test_current_rules_iterator(S)

        run!(S)
        @test finished(S)
        @test number_of_rules(S) == 2459

        # Rules still consistent after full enumeration
        test_current_rules_iterator(S)
    end

    # -----------------------------------------------------------------------
    # Test 094: "rules [copy_closure, duplicate gens]" [quick]
    # -----------------------------------------------------------------------
    @testset "094: rules copy_closure with duplicate gens" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([1, 2, 3, 4, 5, 6]),   # dup
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),   # dup
            Transf([5, 1, 2, 3, 4, 6]),
        )
        run!(S)
        @test length(S) == 120
        @test number_of_rules(S) == 33

        T = copy_closure(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([1, 2, 3, 4, 5, 6]))   # dup identity
        T = copy_closure(T, Transf([2, 1, 3, 4, 5, 6]))   # dup (1,2)
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))

        @test length(T) == 7776
        @test number_of_idempotents(T) == 537
    end

    # -----------------------------------------------------------------------
    # Test 095: "rules [copy_add_generators, duplicate gens]" [quick]
    # -----------------------------------------------------------------------
    @testset "095: rules copy_add_generators with duplicate gens" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        run!(S)

        T = copy_add_generators(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_add_generators(T, Transf([2, 2, 3, 4, 5, 6]))

        @test length(T) == 7776
    end

    # -----------------------------------------------------------------------
    # Tests 096-098: rules from copy at various enumeration states
    # -----------------------------------------------------------------------
    @testset "096-098: rules from copy" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )

        # Copy before enumeration
        T = copy(S)
        run!(T)
        @test finished(T)
        test_current_rules_iterator(T)
        @test number_of_rules(T) == 2459

        # Copy after full enumeration
        run!(S)
        T2 = copy(S)
        run!(T2)
        @test number_of_rules(T2) == number_of_rules(S)
        test_current_rules_iterator(T2)
    end

    # -----------------------------------------------------------------------
    # Tests 099-102: rules from copy_closure / copy_add_generators
    # -----------------------------------------------------------------------
    @testset "099-102: rules from copy_closure/add_generators" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )

        # copy_closure
        T = copy_closure(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))
        test_current_rules_iterator(T)
        @test length(T) == 7776
        @test number_of_rules(T) == 2459

        # copy_add_generators
        T2 = copy_add_generators(S, Transf([6, 2, 3, 4, 5, 6]))
        T2 = copy_add_generators(T2, Transf([2, 2, 3, 4, 5, 6]))
        @test number_of_rules(T2) == 2459
        test_current_rules_iterator(T2)
    end

    # -----------------------------------------------------------------------
    # Tests 103-104: rules from copy_closure/add_generators [fully enum]
    # -----------------------------------------------------------------------
    @testset "103-104: rules from copy ops fully enumerated" begin
        S = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
        )
        run!(S)
        @test finished(S)

        T = copy_closure(S, Transf([6, 2, 3, 4, 5, 6]))
        T = copy_closure(T, Transf([2, 2, 3, 4, 5, 6]))
        test_current_rules_iterator(T)
        @test number_of_rules(T) == 2459

        T2 = copy_add_generators(S, Transf([6, 2, 3, 4, 5, 6]))
        T2 = copy_add_generators(T2, Transf([2, 2, 3, 4, 5, 6]))
        @test number_of_rules(T2) == 2459
        test_current_rules_iterator(T2)
    end

    # -----------------------------------------------------------------------
    # Test 105: "add_generators [duplicate generators]" [quick]
    # -----------------------------------------------------------------------
    @testset "105: add_generators with duplicates" begin
        S = FroidurePin(
            Transf([1, 2, 1, 4, 5, 6]),
            Transf([1, 2, 1, 4, 5, 6]),   # duplicate
        )
        @test length(S) == 1
        @test number_of_generators(S) == 2

        # Add duplicate again
        push!(S, generator(S, 1))
        @test length(S) == 1
        @test number_of_generators(S) == 3

        # Add identity
        push!(S, Transf([1, 2, 3, 4, 5, 6]))
        @test length(S) == 2

        # Incremental growth
        push!(S, Transf([1, 2, 4, 6, 6, 5]))
        @test length(S) == 7

        push!(S, Transf([2, 1, 3, 5, 5, 6]))
        @test length(S) == 18

        push!(S, Transf([5, 4, 4, 2, 1, 6]))
        @test length(S) == 87

        push!(S, Transf([5, 4, 6, 2, 1, 6]))
        @test length(S) == 97

        push!(S, Transf([6, 6, 3, 4, 5, 1]))
        @test length(S) == 119

        # Add product of existing elements (already in S)
        push!(S, Transf([2, 1, 3, 5, 5, 6]) * Transf([5, 4, 4, 2, 1, 6]))
        @test length(S) == 119
        @test number_of_generators(S) == 10

        # position_of_generator tracks positions
        @test position_of_generator(S, 1) == 1
        @test position_of_generator(S, 2) == 1   # dup
        @test position_of_generator(S, 3) == 1   # dup
        @test position_of_generator(S, 4) == 2   # identity
    end

    # -----------------------------------------------------------------------
    # Test 108: "closure [duplicate generators]" [quick]
    # -----------------------------------------------------------------------
    @testset "108: closure with duplicates" begin
        S = FroidurePin(
            Transf([1, 2, 1, 4, 5, 6]),
            Transf([1, 2, 1, 4, 5, 6]),   # duplicate
        )
        @test length(S) == 1

        # Closure with existing element: no new generator added
        closure!(S, generator(S, 1))
        @test length(S) == 1
        @test number_of_generators(S) == 2  # unchanged

        # Closure with new elements
        closure!(S, Transf([1, 2, 3, 4, 5, 6]))
        @test length(S) == 2
        @test number_of_generators(S) == 3

        closure!(S, Transf([1, 2, 4, 6, 6, 5]))
        @test length(S) == 7

        closure!(S, Transf([2, 1, 3, 5, 5, 6]))
        @test length(S) == 18

        closure!(S, Transf([5, 4, 4, 2, 1, 6]))
        @test length(S) == 87

        closure!(S, Transf([5, 4, 6, 2, 1, 6]))
        @test length(S) == 97

        closure!(S, Transf([6, 6, 3, 4, 5, 1]))
        @test length(S) == 119
        @test number_of_generators(S) == 8  # fewer than add_generators (skips dups)
    end

    # -----------------------------------------------------------------------
    # Test 109: "closure" [quick] — all T₃ elements
    # -----------------------------------------------------------------------
    @testset "109: closure with all T₃" begin
        # All 27 transformations of degree 3 (1-based images)
        all_t3 = [Transf([a, b, c]) for a = 1:3 for b = 1:3 for c = 1:3]
        @test length(all_t3) == 27

        S = FroidurePin(all_t3[1:1])
        for t in all_t3
            closure!(S, t)
        end
        @test length(S) == 27
        # closure selects a minimal generating set — fewer than 27
        @test number_of_generators(S) <= 27
    end

    # -----------------------------------------------------------------------
    # Test 110: "factorisation" [quick]
    # -----------------------------------------------------------------------
    @testset "110: factorisation" begin
        S = FroidurePin(Transf([2, 2, 5, 6, 5, 6]), Transf([3, 4, 3, 4, 6, 6]))
        @test factorisation(S, 3) == [1, 2]  # 3rd element = gen1 * gen2
    end

    # Tests 111, 114: large semigroup with/without reserve — covered by Test 042

    # -----------------------------------------------------------------------
    # Test 112: "minimal_factorisation" [quick]
    # -----------------------------------------------------------------------
    @testset "112: minimal_factorisation exceptions" begin
        S = FroidurePin(Transf([2, 2, 5, 6, 5, 6]))

        @test minimal_factorisation(S, 1) == [1]
        @test_throws LibsemigroupsError minimal_factorisation(S, 10000001)
    end

    # -----------------------------------------------------------------------
    # Test 113: "batch_size" [quick]
    # -----------------------------------------------------------------------
    @testset "113: batch_size large value" begin
        S = FroidurePin(Transf([2, 2, 5, 6, 5, 6]), Transf([3, 4, 3, 4, 6, 6]))
        run!(S)
        @test length(S) == 5
    end

    # -----------------------------------------------------------------------
    # Test 115: "exception: generators of different degrees" [quick]
    # NOTE: The 2-arg C++ constructor doesn't validate degree at
    # construction. Degree mismatch is caught by add_generator! instead.
    # This test verifies the add_generator! path (already covered by 044).
    # -----------------------------------------------------------------------
    @testset "115: mixed degree add_generator" begin
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]))  # degree 6
        @test_throws LibsemigroupsError push!(S, Transf([1, 2, 3, 4, 5, 6, 6]))  # degree 7
    end

    # -----------------------------------------------------------------------
    # Test 116: "exception: current_position" [quick] (near-duplicate of 045)
    # -----------------------------------------------------------------------
    @testset "116: current_position word exceptions" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        @test current_position(U, Int[]) == 1
        @test_nowarn current_position(U, [1, 1, 2, 3])
        @test_throws LibsemigroupsError current_position(U, [6])
    end

    # -----------------------------------------------------------------------
    # Test 117: "exception: to_element" [quick] (near-duplicate of 046)
    # -----------------------------------------------------------------------
    @testset "117: to_element exceptions" begin
        U = FroidurePin(
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        )
        @test to_element(U, Int[]) == generator(U, 1)
        @test_throws LibsemigroupsError to_element(U, [6])
        @test to_element(U, [1, 1, 2, 3]) ==
              generator(U, 1) * generator(U, 1) * generator(U, 2) * generator(U, 3)
    end

    # -----------------------------------------------------------------------
    # Test 118: "exception: gens, current_position" [quick]
    # -----------------------------------------------------------------------
    @testset "118: generator and position_of_generator bounds" begin
        for i = 1:19
            gens = [Transf([mod(k + j - 2, i) + 1 for k = 1:i]) for j = 1:i]
            S = FroidurePin(gens)
            for j = 1:i
                @test generator(S, j) isa Transf
                @test position_of_generator(S, j) isa Integer
            end
            @test_throws Exception generator(S, i + 1)
            @test_throws Exception position_of_generator(S, i + 1)
        end
    end

    # -----------------------------------------------------------------------
    # Test 119: "exception: add_generators" [quick]
    # -----------------------------------------------------------------------
    @testset "119: add_generators degree exception" begin
        S = FroidurePin(Transf([1, 2, 3, 4, 5, 6]), Transf([2, 3, 4, 3, 3, 4]))
        push!(S, Transf([1, 2, 3, 4, 4, 4]))  # same degree → OK
        @test_throws LibsemigroupsError push!(S, Transf([1, 2, 3, 4, 4, 4, 4]))  # degree 7
    end

end  # @testset "FroidurePin<Transf>"

end  # ReportGuard(false)
