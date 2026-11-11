# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_congruence.jl - Tests for the Congruence Julia API.

Behaviour shared with the other congruence algorithms (copying, the common
word helpers, ...) is tested for every algorithm in test_cong_common.jl.
"""

using Test
using Semigroups

# Finite monoid: a^2 = a, b^2 = b, ab = ba. Classes of nonempty words:
# {a}, {b}, {ab}.
function _congruence_test_presentation()
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule!(p, [1, 1], [1])
    add_rule!(p, [2, 2], [2])
    add_rule!(p, [1, 2], [2, 1])
    return p
end

@testset "Congruence - construction" begin
    p = _congruence_test_presentation()
    c = Congruence(twosided, p)
    @test c isa Congruence{Vector{Int}}
    @test kind(c) == twosided
    @test presentation(c) == p
    @test number_of_classes(c) == 3

    @test Congruence(onesided, p) isa Congruence{Vector{Int}}
    @test kind(Congruence(onesided, p)) == onesided

    # Default constructor, and the copy constructor.
    @test Congruence() isa Congruence{Vector{Int}}
    @test Congruence{Vector{Int}}() isa Congruence{Vector{Int}}
    c2 = Congruence(c)
    @test c2 isa Congruence{Vector{Int}}
    @test Semigroups._cxx(c2) !== Semigroups._cxx(c)
    @test number_of_classes(c2) == 3
end

@testset "Congruence - invalid presentation" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, [1], [3])    # letter 3 is not in the alphabet
    @test_throws LibsemigroupsError Congruence(twosided, p)
end

@testset "Congruence - word operations" begin
    c = Congruence(twosided, _congruence_test_presentation())
    @test Semigroups.contains(c, [1, 2], [2, 1])
    @test !Semigroups.contains(c, [1], [2])
    @test Semigroups.contains(c, Semigroups.reduce(c, [2, 1, 1]), [2, 1, 1])
    @test currently_contains(c, [1, 2], [2, 1]) == tril_TRUE
end

@testset "Congruence - runner methods" begin
    c = Congruence(twosided, _congruence_test_presentation())
    @test !finished(c)
    run!(c)
    @test finished(c)
    @test init!(c) === c
end

@testset "Congruence - show" begin
    c = Congruence(twosided, _congruence_test_presentation())
    s = sprint(show, c)
    @test occursin("Congruence", s)
    @test !occursin("Ptr", s)    # libsemigroups' description, not a raw pointer
end

@testset "Congruence - helpers libsemigroups does not provide" begin
    p = _congruence_test_presentation()
    @test_throws ArgumentError normal_forms(Congruence(twosided, p))
    @test_throws ArgumentError non_trivial_classes(
        Congruence(twosided, p),
        Congruence(twosided, p),
    )
end

# ============================================================================
# Congruence{String}
# ============================================================================

function _congruence_string_presentation()
    p = Presentation{String}()
    set_alphabet!(p, "ab")
    add_rule!(p, "aa", "a")
    add_rule!(p, "bb", "b")
    add_rule!(p, "ab", "ba")
    return p
end

@testset "Congruence{String} - construction" begin
    p = _congruence_string_presentation()
    c = Congruence(twosided, p)
    @test c isa Congruence{String}
    @test c isa Semigroups.CongruenceCommon{String}
    @test kind(c) == twosided
    @test presentation(c) == p
    @test presentation(c) isa Presentation{String}
    @test number_of_classes(c) == 3

    @test Congruence{String}() isa Congruence{String}
    @test copy(c) isa Congruence{String}
    @test Congruence(c) isa Congruence{String}
end

@testset "Congruence{String} - word operations" begin
    c = Congruence(twosided, _congruence_string_presentation())
    @test Semigroups.contains(c, "ab", "ba")
    @test !Semigroups.contains(c, "a", "b")
    @test Semigroups.reduce(c, "baa") isa String
    @test Semigroups.contains(c, Semigroups.reduce(c, "baa"), "baa")
    @test currently_contains(c, "ab", "ba") == tril_TRUE
    classes = partition(c, ["a", "aa", "b", "ab", "ba"])
    @test classes isa Vector{Vector{String}}
    @test sort(sort.(classes)) == [["a", "aa"], ["ab", "ba"], ["b"]]

    c2 = Congruence(twosided, _congruence_string_presentation())
    add_generating_pair!(c2, "a", "b")
    @test Semigroups.contains(c2, "a", "b")
    @test !Semigroups.contains(c, "a", "b")
end

@testset "Congruence{String} - infinite C(4) presentation" begin
    # Congruence can decide the word problem here (e.g. via Kambites).
    p = Presentation{String}()
    set_alphabet!(p, "abcdefg")
    add_rule!(p, "abcd", "aaaeaa")
    add_rule!(p, "ef", "dg")
    c = Congruence(twosided, p)
    @test Semigroups.contains(c, "efabc", "dgabc")
    @test !Semigroups.contains(c, "a", "b")
end

@testset "Congruence{String} - errors" begin
    c = Congruence(twosided, _congruence_string_presentation())
    @test_throws ArgumentError Semigroups.contains(c, [1], [2])
    @test_throws ArgumentError Semigroups.reduce(c, "café")
    @test_throws ArgumentError normal_forms(c)
end

@testset "Congruence{String} - agrees with Vector{Int} words" begin
    cs = Congruence(twosided, _congruence_string_presentation())
    cw = Congruence(twosided, _congruence_test_presentation())
    to_str(w) = String([Char('a' + i - 1) for i in w])
    @test number_of_classes(cs) == number_of_classes(cw)
    for (u, v) in (([1, 2], [2, 1]), ([1], [2]), ([2, 1, 1], [1, 2]))
        @test Semigroups.contains(cs, to_str(u), to_str(v)) == Semigroups.contains(cw, u, v)
    end
end

@testset "Congruence{String} - conversions" begin
    ps = _congruence_string_presentation()
    c = Congruence(twosided, ps)
    q = Semigroups.to(Presentation, c)
    @test q isa Presentation{String}
    @test q == ps
    @test Semigroups.to(Presentation{Vector{Int}}, c) == _congruence_test_presentation()
    cw = Congruence(twosided, _congruence_test_presentation())
    @test Semigroups.to(Presentation{String}, cw) == ps
end
