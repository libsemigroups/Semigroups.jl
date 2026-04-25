# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_knuth_bendix_6.jl - Ports of libsemigroups test-knuth-bendix-6.cpp

The upstream file is already based on `Presentation<word_type>`, so these
tests translate C++ 0-based word literals to Semigroups.jl's 1-based public
word API and avoid direct `LibSemigroups` calls.
"""

using Test
using Semigroups

_kb6_cword(xs::Integer...) = [Int(x) + 1 for x in xs]
_kb6_cword(xs::AbstractVector{<:Integer}) = [Int(x) + 1 for x in xs]

function _kb6_add_cpp_rule!(p::Presentation, lhs, rhs)
    add_rule!(p, _kb6_cword(lhs), _kb6_cword(rhs))
    return p
end

function _kb6_add_cpp_rule_no_checks!(p::Presentation, lhs, rhs)
    add_rule_no_checks!(p, _kb6_cword(lhs), _kb6_cword(rhs))
    return p
end

function _kb6_presentation(n::Integer, rules; checks::Bool = true)
    p = Presentation()
    set_alphabet!(p, n)
    add = checks ? _kb6_add_cpp_rule! : _kb6_add_cpp_rule_no_checks!
    for (lhs, rhs) in rules
        add(p, lhs, rhs)
    end
    return p
end

function _kb6_words_of_length(n::Integer, len::Integer)
    len == 0 && return [Int[]]
    prev = _kb6_words_of_length(n, len - 1)
    return [[word; a] for word in prev for a = 1:n]
end

function _kb6_normal_forms_count(
    kb::KnuthBendix,
    alphabet_size::Integer,
    min_len::Integer,
    max_len::Integer,
)
    count = 0
    for len = min_len:max_len
        for w in _kb6_words_of_length(alphabet_size, len)
            Semigroups.reduce(kb, w) == w && (count += 1)
        end
    end
    return count
end

@testset verbose = true "KnuthBendix test-knuth-bendix-6.cpp" begin
    ReportGuard(false)

    @testset "129: Presentation{word_type}" begin
        p = _kb6_presentation(2, [([0, 0, 0], [0]), ([0], [1, 1])])
        kb = KnuthBendix(twosided, p)

        @test !finished(kb)
        @test number_of_classes(kb) == 5
        @test finished(kb)
        @test Semigroups.reduce(kb, _kb6_cword(0, 0, 1)) == _kb6_cword(0, 0, 1)
        @test Semigroups.reduce(kb, _kb6_cword(0, 0, 0, 0, 1)) == _kb6_cword(0, 0, 1)
        @test Semigroups.reduce(kb, _kb6_cword(0, 1, 1, 0, 0, 1)) == _kb6_cword(0, 0, 1)
        @test !Semigroups.contains(kb, _kb6_cword(0, 0, 0), _kb6_cword(1))
        @test !Semigroups.contains(kb, _kb6_cword(0, 0, 0, 0), _kb6_cword(0, 0, 0))
    end

    @testset "130: free semigroup congruence (6 classes)" begin
        p = _kb6_presentation(
            5,
            [
                ([0, 0], [0]),
                ([0, 1], [1]),
                ([1, 0], [1]),
                ([0, 2], [2]),
                ([2, 0], [2]),
                ([0, 3], [3]),
                ([3, 0], [3]),
                ([0, 4], [4]),
                ([4, 0], [4]),
                ([1, 2], [0]),
                ([2, 1], [0]),
                ([3, 4], [0]),
                ([4, 3], [0]),
                ([2, 2], [0]),
                ([1, 4, 2, 3, 3], [0]),
                ([4, 4, 4], [0]),
            ],
        )

        kb = KnuthBendix(twosided, p)

        @test number_of_classes(kb) == 6
        @test Semigroups.contains(kb, _kb6_cword(1), _kb6_cword(2))
    end

    @testset "131: free semigroup congruence (16 classes)" begin
        p = _kb6_presentation(
            4,
            [
                ([3], [2]),
                ([0, 3], [0, 2]),
                ([1, 1], [1]),
                ([1, 3], [1, 2]),
                ([2, 1], [2]),
                ([2, 2], [2]),
                ([2, 3], [2]),
                ([0, 0, 0], [0]),
                ([0, 0, 1], [1]),
                ([0, 0, 2], [2]),
                ([0, 1, 2], [1, 2]),
                ([1, 0, 0], [1]),
                ([1, 0, 2], [0, 2]),
                ([2, 0, 0], [2]),
                ([0, 1, 0, 1], [1, 0, 1]),
                ([0, 2, 0, 2], [2, 0, 2]),
                ([1, 0, 1, 0], [1, 0, 1]),
                ([1, 2, 0, 1], [1, 0, 1]),
                ([1, 2, 0, 2], [2, 0, 2]),
                ([2, 0, 1, 0], [2, 0, 1]),
                ([2, 0, 2, 0], [2, 0, 2]),
            ],
        )

        kb = KnuthBendix(twosided, p)

        @test number_of_classes(kb) == 16
        @test number_of_active_rules(kb) == 18
        @test Semigroups.contains(kb, _kb6_cword(2), _kb6_cword(3))
    end

    @testset "132: free semigroup congruence x 2" begin
        p = _kb6_presentation(
            11,
            [
                ([2], [1]),
                ([4], [3]),
                ([5], [0]),
                ([6], [3]),
                ([7], [1]),
                ([8], [3]),
                ([9], [3]),
                ([10], [0]),
                ([0, 2], [0, 1]),
                ([0, 4], [0, 3]),
                ([0, 5], [0, 0]),
                ([0, 6], [0, 3]),
                ([0, 7], [0, 1]),
                ([0, 8], [0, 3]),
                ([0, 9], [0, 3]),
                ([0, 10], [0, 0]),
                ([1, 1], [1]),
                ([1, 2], [1]),
                ([1, 4], [1, 3]),
                ([1, 5], [1, 0]),
                ([1, 6], [1, 3]),
                ([1, 7], [1]),
                ([1, 8], [1, 3]),
                ([1, 9], [1, 3]),
                ([1, 10], [1, 0]),
                ([3, 1], [3]),
                ([3, 2], [3]),
                ([3, 3], [3]),
                ([3, 4], [3]),
                ([3, 5], [3, 0]),
                ([3, 6], [3]),
                ([3, 7], [3]),
                ([3, 8], [3]),
                ([3, 9], [3]),
                ([3, 10], [3, 0]),
                ([0, 0, 0], [0]),
                ([0, 0, 1], [1]),
                ([0, 0, 3], [3]),
                ([0, 1, 3], [1, 3]),
                ([1, 0, 0], [1]),
                ([1, 0, 3], [0, 3]),
                ([3, 0, 0], [3]),
                ([0, 1, 0, 1], [1, 0, 1]),
                ([0, 3, 0, 3], [3, 0, 3]),
                ([1, 0, 1, 0], [1, 0, 1]),
                ([1, 3, 0, 1], [1, 0, 1]),
                ([1, 3, 0, 3], [3, 0, 3]),
                ([3, 0, 1, 0], [3, 0, 1]),
                ([3, 0, 3, 0], [3, 0, 3]),
            ],
            checks = false,
        )

        kb = KnuthBendix(twosided, p)
        @test number_of_classes(kb) == 16
        @test Semigroups.contains(kb, _kb6_cword(0), _kb6_cword(5))
        @test Semigroups.contains(kb, _kb6_cword(0), _kb6_cword(5))
        @test Semigroups.contains(kb, _kb6_cword(0), _kb6_cword(10))
        @test Semigroups.contains(kb, _kb6_cword(1), _kb6_cword(2))
        @test Semigroups.contains(kb, _kb6_cword(1), _kb6_cword(7))
        @test Semigroups.contains(kb, _kb6_cword(3), _kb6_cword(4))
        @test Semigroups.contains(kb, _kb6_cword(3), _kb6_cword(6))
        @test Semigroups.contains(kb, _kb6_cword(3), _kb6_cword(8))
        @test Semigroups.contains(kb, _kb6_cword(3), _kb6_cword(9))
    end

    @testset "133: free semigroup congruence (240 classes)" begin
        p = _kb6_presentation(
            2,
            [
                ([0, 0, 0], [0]),
                ([1, 1, 1, 1], [1]),
                ([0, 1, 1, 1, 0], [0, 0]),
                ([1, 0, 0, 1], [1, 1]),
                ([0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0]),
            ],
        )

        kb = KnuthBendix(twosided, p)
        @test number_of_classes(kb) == 240
    end

    @testset "134: free semigroup congruence x 2 (FroidurePin conversion deferred)" begin
        p = _kb6_presentation(
            2,
            [
                ([0, 0, 0], [0]),
                ([1, 1, 1, 1], [1]),
                ([0, 1, 1, 1, 0], [0, 0]),
                ([1, 0, 0, 1], [1, 1]),
                ([0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0]),
            ],
        )

        kb = KnuthBendix(twosided, p)
        @test number_of_classes(kb) == 240
    end

    @testset "135: constructors" begin
        p = _kb6_presentation(
            2,
            [
                ([0, 0, 0], [0]),
                ([1, 1, 1, 1, 1, 1, 1, 1, 1], [1]),
                ([0, 1, 1, 1, 1, 1, 0, 1, 1], [1, 1, 0]),
            ],
        )

        kb = KnuthBendix(twosided, p)
        @test number_of_classes(kb) == 746

        kb_copy = copy(kb)
        @test number_of_classes(kb_copy) == 746
        @test length(Semigroups.alphabet(presentation(kb_copy))) == 2
        @test number_of_active_rules(kb_copy) == 105
    end

    @testset "136: number of classes when obviously infinite" begin
        p = _kb6_presentation(
            3,
            [
                ([0, 1], [1, 0]),
                ([0, 2], [2, 0]),
                ([0, 0], [0]),
                ([0, 2], [0]),
                ([2, 0], [0]),
                ([1, 1], [1, 1]),
                ([1, 2], [2, 1]),
                ([1, 1, 1], [1]),
                ([1, 2], [1]),
                ([2, 1], [1]),
                ([0], [1]),
            ],
        )

        kb = KnuthBendix(twosided, p)
        @test number_of_classes(kb) == POSITIVE_INFINITY
    end

    @testset "137: Chinese monoid x 2" begin
        p = chinese_monoid(3)
        kb = KnuthBendix(twosided, p)

        @test number_of_classes(kb) == POSITIVE_INFINITY
        @test number_of_rules(presentation(kb)) == 8
        @test _kb6_normal_forms_count(kb, 3, 1, 9) == 1_175
    end

    @testset "138: partial_transformation_monoid(4)" begin
        p = partial_transformation_monoid(4)
        kb = KnuthBendix(twosided, p)

        @test number_of_classes(kb) == 625
        @test number_of_active_rules(kb) == 362
        repr = sprint(show, kb)
        @test occursin("confluent 2-sided KnuthBendix", repr)
        @test occursin("362 active rules", repr)
    end

    @testset "139: partial_transformation_monoid5" begin
        @test_skip "upstream [extreme] test; takes about 1 minute"
    end

    @testset "140: full_transformation_monoid Iwahori" begin
        @test_skip "upstream [extreme] test; intentionally not run in the Julia quick suite"
    end

    @testset "141: constructors/init for finished x 2" begin
        p1 = Presentation()
        set_contains_empty_word!(p1, true)
        set_alphabet!(p1, 4)
        add_rule!(p1, _kb6_cword(0, 1), Int[])
        add_rule!(p1, _kb6_cword(1, 0), Int[])
        add_rule!(p1, _kb6_cword(2, 3), Int[])
        add_rule!(p1, _kb6_cword(3, 2), Int[])
        add_rule!(p1, _kb6_cword(2, 0), _kb6_cword(0, 2))

        p2 = Presentation()
        set_contains_empty_word!(p2, true)
        set_alphabet!(p2, 2)
        add_rule!(p2, _kb6_cword(0, 0, 0), Int[])
        add_rule!(p2, _kb6_cword(1, 1, 1), Int[])
        add_rule!(p2, _kb6_cword(0, 1, 0, 1, 0, 1), Int[])

        kb1 = KnuthBendix(twosided, p1)
        @test !confluent(kb1)
        @test !finished(kb1)
        run!(kb1)
        @test confluent(kb1)
        @test number_of_active_rules(kb1) == 8

        init!(kb1, twosided, p2)
        @test !confluent(kb1)
        @test !finished(kb1)
        run!(kb1)
        @test finished(kb1)
        @test confluent(kb1)
        @test confluent_known(kb1)
        @test number_of_active_rules(kb1) == 4

        init!(kb1, twosided, p1)
        @test !confluent(kb1)
        @test !finished(kb1)
        run!(kb1)
        @test finished(kb1)
        @test confluent(kb1)
        @test confluent_known(kb1)
        @test number_of_active_rules(kb1) == 8

        kb2 = copy(kb1)
        @test confluent(kb2)
        @test confluent_known(kb2)
        @test finished(kb2)
        @test number_of_active_rules(kb2) == 8

        kb1 = copy(kb2)
        @test confluent(kb1)
        @test confluent_known(kb1)
        @test finished(kb1)
        @test number_of_active_rules(kb1) == 8

        init!(kb1, twosided, p1)
        @test !confluent(kb1)
        @test !finished(kb1)
        run!(kb1)
        @test finished(kb1)
        @test confluent(kb1)
        @test confluent_known(kb1)
        @test number_of_active_rules(kb1) == 8

        kb3 = KnuthBendix(twosided, p2)
        @test !confluent(kb3)
        @test !finished(kb3)
        run!(kb3)
        @test finished(kb3)
        @test confluent(kb3)
        @test confluent_known(kb3)
        @test number_of_active_rules(kb3) == 4
    end

    @testset "142: close to or greater than 255 letters" begin
        p = Presentation()
        set_alphabet!(p, 257)
        @test_throws Exception KnuthBendix(twosided, p)
    end

    @testset "118: process pending rules x1" begin
        @test_skip "process_pending_rules is not exposed by the high-level Julia API"
    end

    @testset "143: process pending rules x2" begin
        @test_skip "process_pending_rules is not exposed by the high-level Julia API"
    end

    @testset "144: process pending rules x3" begin
        @test_skip "upstream [extreme] test and process_pending_rules is not exposed"
    end
end
