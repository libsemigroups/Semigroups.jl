# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
test_kambites.jl - Tests for the Kambites Julia API.
"""

# TODO: Lots of improvements should be made to the
# comprehensiveness of these tests. This was made to
# validate the development process only.

using Test
using Semigroups

@testset "Kambites - construction and small-overlap-class on MT4" begin
    # Alphabet "abcdefg" = 1..7. Rules: abcd = aaaeaa; ef = dg.
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    k = Kambites(twosided, p)

    @test kind(k) == twosided
    @test small_overlap_class(k) >= 4
    @test number_of_classes(k) == POSITIVE_INFINITY

    @test Semigroups.contains(k, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    @test Semigroups.contains(k, [5, 6], [4, 7])
    @test Semigroups.contains(k, [1, 1, 1, 1, 1, 5, 6], [1, 1, 1, 1, 1, 4, 7])
    @test Semigroups.contains(k, [5, 6, 1, 2, 1, 2, 1], [4, 7, 1, 2, 1, 2, 1])
end

@testset "Kambites - small_overlap_class parametric loop" begin
    # For i = 4..19, build over alphabet "ab" = [1, 2]:
    #   lhs(i) = concat over b = 1..i of (1, b copies of 2)
    #   rhs(i) = concat over b = i+1..2i of (1, b copies of 2)
    # The single rule lhs(i) = rhs(i) yields small_overlap_class == i.
    for i = 4:19
        lhs = Int[]
        for b = 1:i
            push!(lhs, 1)
            append!(lhs, fill(2, b))
        end
        rhs = Int[]
        for b = (i+1):(2*i)
            push!(rhs, 1)
            append!(rhs, fill(2, b))
        end

        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, lhs, rhs)

        k = Kambites(twosided, p)
        @test small_overlap_class(k) == i
    end
end

@testset "Kambites - aabc = acba over a 3-letter alphabet" begin
    # Alphabet [c=1, a=2, b=3]; rule aabc = acba -> [2,2,3,1] = [2,1,3,2].
    p = Presentation()
    set_alphabet!(p, 3)
    add_rule_no_checks!(p, [2, 2, 3, 1], [2, 1, 3, 2])

    k = Kambites(twosided, p)

    @test !Semigroups.contains(k, [2], [3])
    @test Semigroups.contains(k, [2, 2, 3, 1, 2, 3, 1], [2, 2, 3, 1, 1, 3, 2])
    @test number_of_classes(k) == POSITIVE_INFINITY
end

@testset "Kambites - free semigroup" begin
    # Empty rule set -> small_overlap_class is POSITIVE_INFINITY.
    p = Presentation()
    set_alphabet!(p, 3)
    k = Kambites(twosided, p)
    @test small_overlap_class(k) == POSITIVE_INFINITY

    p2 = Presentation()
    set_alphabet!(p2, 1)
    k2 = Kambites(twosided, p2)
    @test small_overlap_class(k2) == POSITIVE_INFINITY
end

@testset "Kambites - negated containment" begin
    # Alphabet [a=1, b=2, c=3, d=4, e=5]; rule cadeca = baedba.
    p = Presentation()
    set_alphabet!(p, 5)
    add_rule_no_checks!(p, [3, 1, 4, 5, 3, 1], [2, 1, 5, 4, 2, 1])

    k = Kambites(twosided, p)

    # cadece (= [3,1,4,5,3,5]) is not congruent to baedce (= [2,1,5,4,3,5]).
    @test !Semigroups.contains(k, [3, 1, 4, 5, 3, 5], [2, 1, 5, 4, 3, 5])
end

@testset "Kambites - end-to-end smoke (run!, finished, success, contains, reduce)" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    k = Kambites(twosided, p)
    run!(k)
    @test finished(k)
    @test success(k)

    @test Semigroups.contains(k, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])

    r = Semigroups.reduce(k, [1, 2, 3, 4])
    @test r isa Vector{Int}
    @test Semigroups.contains(k, r, [1, 2, 3, 4])
end

@testset "Kambites - bounded normal_forms" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    k = Kambites(twosided, p)

    nfs = normal_forms(k, 20)
    @test length(nfs) == 20
    @test all(w -> w isa Vector{Int}, nfs)

    # The no-arg form must throw rather than hang on the infinite range.
    @test_throws ArgumentError normal_forms(k)
end

@testset "Kambites - copy round-trip" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    k = Kambites(twosided, p)
    k2 = copy(k)

    @test kind(k2) == twosided
    @test small_overlap_class(k2) == small_overlap_class(k)

    run!(k)
    @test kind(k2) == twosided
end

@testset "Kambites - show" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [5, 6], [4, 7])
    k = Kambites(twosided, p)

    s = sprint(show, k)
    @test s isa String
    @test !isempty(s)
end

@testset "Kambites - error paths" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    # Kambites accepts only twosided congruences.
    @test_throws LibsemigroupsError Kambites(Semigroups.onesided, p)

    # `non_trivial_classes(::Kambites, ::Kambites)` is intentionally
    # unsupported (both arguments always represent infinite-class
    # congruences); the override throws ArgumentError.
    k1 = Kambites(twosided, p)
    k2 = Kambites(twosided, p)
    @test_throws ArgumentError non_trivial_classes(k1, k2)

    # throw_if_not_C4 throws when small_overlap_class < 4. The presentation
    # `{aa = b}` over a 2-letter alphabet has small_overlap_class < 4.
    p_low = Presentation()
    set_alphabet!(p_low, 2)
    add_rule_no_checks!(p_low, [1, 1], [2])
    k_low = Kambites(twosided, p_low)
    @test small_overlap_class(k_low) < 4
    @test_throws LibsemigroupsError throw_if_not_C4(k_low)
end

@testset "Kambites - design constraint: no Base.length" begin
    # `Base.length` is intentionally NOT defined for Kambites because
    # `number_of_classes` is always-infinite-or-throws; defining `length`
    # as an alias would silently misbehave with `for i in 1:length(k)`.
    @test !hasmethod(Base.length, Tuple{Kambites})
end
