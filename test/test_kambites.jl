# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
test_kambites.jl - Tests for Kambites (Phase 3c of the v1 design).

Ports a focused subset of [quick] cases from
libsemigroups/tests/test-kambites.cpp, plus binding-surface and high-level
integration tests. Tests that depend on Ukkonen helpers
(`ukkonen::number_of_pieces`, `number_of_distinct_subwords`), FroidurePin
conversion, or long random multi-character string presentations are
deferred or substituted with smaller `word_type`-native equivalents (see
the design spec at
docs/superpowers/specs/2026-04-27-kambites-phase-3c-design.md).

The binding-surface tests may pass for inherited cong-common methods as
soon as the C++ glue compiles, but the `isdefined(Semigroups, :Kambites)`
gate and all correctness/integration tests will fail until Task 4 lands
the Julia wrapper at `src/kambites.jl`.
"""

using Test
using Semigroups

# Phase 3a/3b precedent: alias the low-level CxxWrap type to the public
# Julia name. Until Task 4 adds `const Kambites = LibSemigroups.KambitesWord`
# to `src/Semigroups.jl`, the surface-level `isdefined(Semigroups, :Kambites)`
# assertion below is the RED signal.
const Kambites = Semigroups.LibSemigroups.KambitesWord

# Build a 1-based Julia word from 0-based libsemigroups indices.
# `_test_kambites_cword(0, 0, 1)` -> `[1, 1, 2]`. Long file-prefixed name
# avoids shadowing in shared test scope.
_test_kambites_cword(xs::Integer...) = [Int(x) + 1 for x in xs]

@testset "Kambites binding surface" begin
    # This is the primary RED gate: the alias only exists once Task 4 adds
    # `const Kambites = LibSemigroups.KambitesWord` to `src/Semigroups.jl`.
    @test isdefined(Semigroups, :Kambites)

    # Constructors (3 forms): default; (kind, presentation); copy.
    @test hasmethod(Kambites, Tuple{})
    @test hasmethod(Kambites, Tuple{congruence_kind,Presentation})
    @test hasmethod(Kambites, Tuple{Kambites})

    # init! overloads (2 forms): zero-arg and (kind, presentation).
    @test hasmethod(init!, Tuple{Kambites})
    @test hasmethod(init!, Tuple{Kambites,congruence_kind,Presentation})

    # Accessors
    @test hasmethod(presentation, Tuple{Kambites})
    @test hasmethod(generating_pairs, Tuple{Kambites})
    @test hasmethod(kind, Tuple{Kambites})
    @test hasmethod(number_of_generating_pairs, Tuple{Kambites})
    @test hasmethod(number_of_classes, Tuple{Kambites})

    # Runner-inherited
    @test hasmethod(success, Tuple{Semigroups.Runner})

    # small_overlap_class const-overload split
    @test hasmethod(small_overlap_class, Tuple{Kambites})
    @test hasmethod(current_small_overlap_class, Tuple{Kambites})

    # Validators
    @test hasmethod(throw_if_not_C4, Tuple{Kambites})
    @test hasmethod(
        throw_if_letter_not_in_alphabet,
        Tuple{Kambites,AbstractVector{<:Integer}},
    )

    # Cong-common helpers reachable via CongruenceCommon dispatch.
    # `contains` and `reduce` shadow Base, so they stay module-qualified.
    @test hasmethod(
        add_generating_pair!,
        Tuple{CongruenceCommon,AbstractVector{<:Integer},AbstractVector{<:Integer}},
    )
    @test hasmethod(
        currently_contains,
        Tuple{CongruenceCommon,AbstractVector{<:Integer},AbstractVector{<:Integer}},
    )
    @test hasmethod(
        Semigroups.contains,
        Tuple{CongruenceCommon,AbstractVector{<:Integer},AbstractVector{<:Integer}},
    )
    @test hasmethod(Semigroups.reduce, Tuple{CongruenceCommon,AbstractVector{<:Integer}})
    @test hasmethod(reduce_no_run, Tuple{CongruenceCommon,AbstractVector{<:Integer}})
    @test hasmethod(normal_forms, Tuple{CongruenceCommon})
    @test hasmethod(
        partition,
        Tuple{CongruenceCommon,AbstractVector{<:AbstractVector{<:Integer}}},
    )

    # Base.* overloads
    @test hasmethod(Base.show, Tuple{IO,Kambites})
    @test hasmethod(Base.copy, Tuple{Kambites})

    # Negative assertion: design-spec deviation from Phase 3a/3b precedent.
    # `Base.length` is intentionally NOT defined for Kambites because
    # `number_of_classes` is always-infinite-or-throws; defining `length` as
    # an alias would silently misbehave with `for i in 1:length(k)`.
    @test !hasmethod(Base.length, Tuple{Kambites})
end

# ============================================================================
# correctness tests inspired by test-kambites.cpp
# ============================================================================

@testset "Kambites 000 - MT test 4" begin
    # Port of libsemigroups Kambites 000 (test-kambites.cpp:148-190).
    # Alphabet "abcdefg" -> 1-based [a=1, b=2, c=3, d=4, e=5, f=6, g=7].
    # Rules: abcd = aaaeaa; ef = dg.
    # The to<FroidurePin>(k) and non_trivial_classes(k, StringRange) parts of
    # the upstream test are out of scope for Phase 3c.
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))

    k = Kambites(twosided, p)

    @test Semigroups.contains(
        k,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    @test Semigroups.contains(
        k,
        _test_kambites_cword(4, 5),
        _test_kambites_cword(3, 6),
    )
    @test Semigroups.contains(
        k,
        _test_kambites_cword(0, 0, 0, 0, 0, 4, 5),
        _test_kambites_cword(0, 0, 0, 0, 0, 3, 6),
    )
    @test Semigroups.contains(
        k,
        _test_kambites_cword(4, 5, 0, 1, 0, 1, 0),
        _test_kambites_cword(3, 6, 0, 1, 0, 1, 0),
    )
end

@testset "Kambites 002 - small_overlap_class parametric loop" begin
    # Port of libsemigroups Kambites 002 (test-kambites.cpp:251-276).
    # For i = 4..19, build:
    #   lhs(i) = concat over b=1..i of (a, b copies of b)
    #   rhs(i) = concat over b=i+1..2i of (a, b copies of b)
    # over alphabet "ab" (1-based: a=1, b=2).
    # Assert k.small_overlap_class() == i.
    #
    # The upstream test also asserts ukkonen::number_of_pieces; that
    # part is deferred to v1.1 with the Ukkonen binding.
    for i = 4:19
        lhs = Int[]
        for b = 1:i
            push!(lhs, 1)
            for _ = 1:b
                push!(lhs, 2)
            end
        end
        rhs = Int[]
        for b = (i+1):(2*i)
            push!(rhs, 1)
            for _ = 1:b
                push!(rhs, 2)
            end
        end

        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, lhs, rhs)

        k = Kambites(twosided, p)
        @test small_overlap_class(k) == i
    end
end

@testset "Kambites 005 - smalloverlap/gap/test.gi:85" begin
    # Port of libsemigroups Kambites 005 (test-kambites.cpp:476-503), reduced
    # to the parts that don't depend on StringRange / number_of_words.
    # Alphabet "cab" -> 1-based [c=1, a=2, b=3]. Rule: aabc = acba ->
    # [2,2,3,1] = [2,1,3,2].
    p = Presentation()
    set_alphabet!(p, 3)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(1, 1, 2, 0),    # aabc with c=0,a=1,b=2 0-based
        _test_kambites_cword(1, 0, 2, 1),    # acba
    )

    k = Kambites(twosided, p)

    @test !Semigroups.contains(k, _test_kambites_cword(1), _test_kambites_cword(2))
    @test Semigroups.contains(
        k,
        _test_kambites_cword(1, 1, 2, 0, 1, 2, 0),  # aabcabc
        _test_kambites_cword(1, 1, 2, 0, 0, 2, 1),  # aabccba
    )

    @test number_of_classes(k) == POSITIVE_INFINITY
end

@testset "Kambites 006 - free semigroup" begin
    # Port of libsemigroups Kambites 006 (test-kambites.cpp:507-522).
    # Empty rule set over alphabet "cab" -> small_overlap_class is
    # POSITIVE_INFINITY (i.e. the free semigroup trivially satisfies every
    # small overlap condition).
    p = Presentation()
    set_alphabet!(p, 3)
    k = Kambites(twosided, p)
    @test small_overlap_class(k) == POSITIVE_INFINITY

    # And again with the smallest non-empty alphabet.
    p2 = Presentation()
    set_alphabet!(p2, 1)
    k2 = Kambites(twosided, p2)
    @test small_overlap_class(k2) == POSITIVE_INFINITY
end

@testset "Kambites 011 - code coverage (negated containment)" begin
    # Port of libsemigroups Kambites 011 (test-kambites.cpp:717-715).
    # Alphabet "abcde" -> 1-based [a=1, b=2, c=3, d=4, e=5].
    # Rule: cadeca = baedba -> [3,1,4,5,3,1] = [2,1,5,4,2,1].
    p = Presentation()
    set_alphabet!(p, 5)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(2, 0, 3, 4, 2, 0),  # cadeca
        _test_kambites_cword(1, 0, 4, 3, 1, 0),  # baedba
    )

    k = Kambites(twosided, p)

    # Upstream: REQUIRE(!contains(k, "cadece", "baedce")).
    # cadece = c,a,d,e,c,e -> [3,1,4,5,3,5]; baedce = b,a,e,d,c,e -> [2,1,5,4,3,5].
    @test !Semigroups.contains(
        k,
        _test_kambites_cword(2, 0, 3, 4, 2, 4),  # cadece
        _test_kambites_cword(1, 0, 4, 3, 2, 4),  # baedce
    )
end

# ============================================================================
# high-level integration tests
# ============================================================================

@testset "Kambites - end-to-end smoke (run!, finished, success, contains, reduce)" begin
    # Reuse the MT4 presentation: small_overlap_class >= 4, so the algorithm
    # makes progress and `success` should be true after a run.
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))

    k = Kambites(twosided, p)
    run!(k)
    @test finished(k)
    @test success(k)

    @test Semigroups.contains(
        k,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )

    r = Semigroups.reduce(k, _test_kambites_cword(0, 1, 2, 3))
    @test r isa Vector{Int}
    @test Semigroups.contains(k, r, _test_kambites_cword(0, 1, 2, 3))
end

@testset "Kambites - normal_forms finite-prefix iteration" begin
    # The set of normal forms is infinite for any C(>=4) presentation, so
    # callers must specify a bound. Task 4 added the Kambites-specific
    # `normal_forms(k, n)` binding (a lazy take from the underlying rx
    # range) and made the no-arg `normal_forms(k)` form throw
    # `ArgumentError` so the inherited eager
    # `normal_forms(::CongruenceCommon)` cannot accidentally hang.
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))

    k = Kambites(twosided, p)

    nfs = normal_forms(k, 20)
    @test length(nfs) == 20
    @test all(w -> w isa Vector{Int}, nfs)

    # The no-arg form must throw, not hang on the infinite range.
    @test_throws ArgumentError normal_forms(k)
end

@testset "Kambites - copy round-trip" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))

    k = Kambites(twosided, p)
    k2 = copy(k)

    # k2 is independent: running k does not change k2's small_overlap_class,
    # and the kind / presentation surface remains stable.
    @test kind(k2) == twosided
    @test small_overlap_class(k2) == small_overlap_class(k)

    run!(k)
    @test kind(k2) == twosided
end

@testset "Kambites - Base.show non-empty" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))
    k = Kambites(twosided, p)

    s = sprint(show, k)
    @test s isa String
    @test !isempty(s)
end

@testset "Kambites - negative cases" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(
        p,
        _test_kambites_cword(0, 1, 2, 3),
        _test_kambites_cword(0, 0, 0, 4, 0, 0),
    )
    add_rule_no_checks!(p, _test_kambites_cword(4, 5), _test_kambites_cword(3, 6))

    # (1) Kambites only accepts twosided congruences upstream.
    @test_throws LibsemigroupsError Kambites(Semigroups.onesided, p)

    # (2) non_trivial_classes(k1, k2) is intentionally not provided upstream
    # for two Kambites instances because both represent infinite-class
    # congruences (kambites-helpers.hpp:128-133). Task 4 adds an
    # `ArgumentError`-throwing override on the (Kambites, Kambites) signature;
    # until then this falls through to the generic CongruenceCommon dispatch
    # and computes nonsense (or errors with something other than ArgumentError),
    # which is the RED signal.
    k1 = Kambites(twosided, p)
    k2 = Kambites(twosided, p)
    @test_throws ArgumentError non_trivial_classes(k1, k2)

    # (3) throw_if_not_C4 throws when small_overlap_class < 4. The presentation
    # `{aa = b}` over a 2-letter alphabet has small_overlap_class < 4
    # (the rule's left side `aa` is short enough that pieces collapse).
    p_low = Presentation()
    set_alphabet!(p_low, 2)
    add_rule_no_checks!(p_low, _test_kambites_cword(0, 0), _test_kambites_cword(1))
    k_low = Kambites(twosided, p_low)
    # First confirm the precondition: the algorithm computes a small overlap
    # class strictly below 4 for this presentation.
    @test small_overlap_class(k_low) < 4
    @test_throws LibsemigroupsError throw_if_not_C4(k_low)
end

# ============================================================================
# TODO - port deferred test-kambites.cpp test cases when their dependencies land:
#   - Tests 001, 002 (number_of_pieces parts), 003 (random/long-string presentations)
#     depend on the Ukkonen binding (deferred to v1.1).
#   - Tests 004, 007-014, ... that exercise to<FroidurePin>(k) depend on
#     Phase 2b / Phase 5 conversions and are deferred.
#   - Tests over std::string presentations are deferred to v1.1's
#     string-presentation track.
# ============================================================================
