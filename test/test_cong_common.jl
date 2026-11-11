# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_cong_common.jl - Tests for behaviour shared by every CongruenceCommon subtype

Every congruence algorithm (KnuthBendix, ToddCoxeter, Kambites, Congruence) is
a Julia wrapper struct subtyping `CongruenceCommon{W}`. These tests run the
same checks over each of them: the type hierarchy, copying, re-initialisation,
the shared word helpers, and the errors raised for unsupported input.
"""

using Test
using Semigroups

# Finite monoid: a^2 = a, b^2 = b, ab = ba. Classes of nonempty words:
# {a}, {b}, {ab}.
function _cc_finite_presentation()
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule!(p, [1, 1], [1])
    add_rule!(p, [2, 2], [2])
    add_rule!(p, [1, 2], [2, 1])
    return p
end

# A C(4) presentation (abcd = aaaeaa, ef = dg) for Kambites.
function _cc_kambites_presentation()
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])
    return p
end

# (name, constructor) for each algorithm over its presentation.
const _CC_ALGORITHMS = [
    ("ToddCoxeter", () -> ToddCoxeter(twosided, _cc_finite_presentation())),
    ("KnuthBendix", () -> KnuthBendix(twosided, _cc_finite_presentation())),
    ("Congruence", () -> Congruence(twosided, _cc_finite_presentation())),
    ("Kambites", () -> Kambites(twosided, _cc_kambites_presentation())),
]

@testset "CongruenceCommon - $name: type hierarchy" for (name, make) in _CC_ALGORITHMS
    x = make()
    @test x isa Semigroups.CongruenceCommon{Vector{Int}}
    @test x isa Runner
    @test Semigroups._cong_word_type(x) === Vector{Int}
    # The C++ object is held in the wrapper, and is not itself the wrapper.
    @test !(Semigroups._cxx(x) isa Semigroups.CongruenceCommon)
end

@testset "CongruenceCommon - $name: copy is independent" for (name, make) in _CC_ALGORITHMS
    x = make()
    # copy, deepcopy, and the copy constructor (e.g. ToddCoxeter(tc)).
    for y in (copy(x), deepcopy(x), Base.typename(typeof(x)).wrapper(x))
        @test typeof(y) === typeof(x)
        @test Semigroups._cxx(y) !== Semigroups._cxx(x)
        # Changing the copy must not change the original.
        if name == "Kambites"
            # Any short extra pair would break the C(4) condition, after which
            # Kambites cannot answer `contains`; count the pairs instead.
            add_generating_pair!(y, [1, 2, 3, 4], [1, 2, 3, 4])
            @test number_of_generating_pairs(y) == 1
            @test number_of_generating_pairs(x) == 0
        else
            add_generating_pair!(y, [1], [2])
            @test Semigroups.contains(y, [1], [2])
            @test !Semigroups.contains(x, [1], [2])
        end
    end
end

@testset "CongruenceCommon - $name: init! returns its argument" for (name, make) in
                                                                    _CC_ALGORITHMS

    x = make()
    @test init!(x) === x
end

@testset "CongruenceCommon - $name: String words are rejected" for (name, make) in
                                                                   _CC_ALGORITHMS

    x = make()
    # A Vector{Int} congruence rejects String words with a clear ArgumentError
    # (not a MethodError or LibsemigroupsError).
    @test_throws ArgumentError Semigroups.contains(x, "ab", "ba")
    @test_throws ArgumentError currently_contains(x, "ab", "ba")
    @test_throws ArgumentError Semigroups.reduce(x, "ab")
    @test_throws ArgumentError reduce_no_run(x, "ab")
    @test_throws ArgumentError add_generating_pair!(x, "a", "b")
    @test_throws ArgumentError partition(x, ["a", "b"])
end

@testset "CongruenceCommon - $name: partition" for (name, make) in _CC_ALGORITHMS[1:3]
    x = make()
    classes = partition(x, [[1], [2], [1, 2], [2, 1], [1, 1]])
    @test classes isa Vector{Vector{Vector{Int}}}
    @test sort(sort.(classes)) == [[[1], [1, 1]], [[1, 2], [2, 1]], [[2]]]
    @test partition(x, Vector{Int}[]) == Vector{Vector{Int}}[]
end

@testset "CongruenceCommon - Kambites: partition" begin
    k = Kambites(twosided, _cc_kambites_presentation())
    classes = partition(k, [[1, 2, 3, 4], [1, 1, 1, 5, 1, 1], [5, 6], [4, 7], [1]])
    @test sort(sort.(classes)) ==
          [[[1]], [[1, 1, 1, 5, 1, 1], [1, 2, 3, 4]], [[4, 7], [5, 6]]]
end

@testset "CongruenceCommon - non_trivial_classes needs matching types" begin
    p = _cc_finite_presentation()
    @test_throws ArgumentError non_trivial_classes(
        KnuthBendix(twosided, p),
        ToddCoxeter(twosided, p),
    )
    @test_throws ArgumentError non_trivial_classes(
        ToddCoxeter(twosided, p),
        Congruence(twosided, p),
    )
    # Two of the same supported type still work.
    coarse = ToddCoxeter(twosided, p)
    add_generating_pair!(coarse, [1], [2])
    @test sort(sort.(non_trivial_classes(coarse, ToddCoxeter(twosided, p)))) ==
          [[[1], [1, 2], [2]]]
end

@testset "CongruenceCommon - contains checks letters for a rule-free KnuthBendix" begin
    # libsemigroups 3.6.1 short-circuits KnuthBendix::contains to an equality
    # test when there are no rules or generating pairs, skipping the alphabet
    # check; the binding checks the letters itself.
    p = Presentation()
    set_alphabet!(p, 2)
    kb = KnuthBendix(twosided, p)
    @test Semigroups.contains(kb, [1, 2], [1, 2])
    @test !Semigroups.contains(kb, [1, 2], [2, 1])
    @test_throws LibsemigroupsError Semigroups.contains(kb, [3], [3])
end
