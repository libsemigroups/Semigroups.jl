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
using Dates: Millisecond, Nanosecond

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

@testset "Kambites{String} - construction and small overlap class" begin
    # Presentation over alphabet "abcdefg" with rules abcd = aaaeaa, ef = dg.
    p = Presentation{String}()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, "abcd", "aaaeaa")
    add_rule_no_checks!(p, "ef", "dg")

    k = Kambites(twosided, p)
    @test k isa Kambites{String}
    @test presentation(k) isa Presentation{String}
    @test presentation(k) == p
    @test kind(k) == twosided
    @test small_overlap_class(k) >= 4
    @test current_small_overlap_class(k) == small_overlap_class(k)
    @test number_of_classes(k) == POSITIVE_INFINITY

    @test Semigroups.contains(k, "abcd", "aaaeaa")
    @test Semigroups.contains(k, "ef", "dg")
    @test Semigroups.contains(k, "aaaaaef", "aaaaadg")
    @test Semigroups.contains(k, "efabababa", "dgabababa")
    @test !Semigroups.contains(k, "a", "b")
end

@testset "Kambites{String} - end-to-end smoke (run!, reduce, normal_forms, partition)" begin
    p = Presentation{String}()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, "abcd", "aaaeaa")
    add_rule_no_checks!(p, "ef", "dg")

    k = Kambites(twosided, p)
    run!(k)
    @test finished(k)
    @test success(k)
    @test !timed_out(k)
    @test !dead(k)
    @test started(k)
    @test !running(k)

    r = Semigroups.reduce(k, "abcd")
    @test r isa String
    @test Semigroups.contains(k, r, "abcd")

    r_norun = Semigroups.reduce_no_run(k, "abcd")
    @test r_norun isa String

    @test currently_contains(k, "abcd", "aaaeaa") == tril_TRUE

    nfs = normal_forms(k, 15)
    @test length(nfs) == 15
    @test all(w -> w isa String, nfs)
    @test_throws ArgumentError normal_forms(k)

    # partition with String
    classes = partition(k, ["abcd", "aaaeaa", "ef", "dg"])
    @test classes isa Vector{Vector{String}}
    @test length(classes) == 2

    # Generating pairs (tested on fresh instance before run!)
    k_fresh = Kambites(twosided, p)
    @test number_of_generating_pairs(k_fresh) == 0
    @test isempty(generating_pairs(k_fresh))
    add_generating_pair!(k_fresh, "a", "a")
    @test number_of_generating_pairs(k_fresh) == 1
    gp = generating_pairs(k_fresh)
    @test gp isa Vector{Tuple{String,String}}
    @test length(gp) == 1
    @test gp[1] == ("a", "a")
end

@testset "Kambites{Vector{Int}} - partition" begin
    p = Presentation()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(p, [5, 6], [4, 7])

    k = Kambites(twosided, p)
    classes = partition(k, [[1, 2, 3, 4], [1, 1, 1, 5, 1, 1], [5, 6], [4, 7]])
    @test classes isa Vector{Vector{Vector{Int}}}
    @test length(classes) == 2
end

@testset "Kambites{String} - copy and show" begin
    p = Presentation{String}()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, "abcd", "aaaeaa")
    add_rule_no_checks!(p, "ef", "dg")

    k = Kambites(twosided, p)
    k2 = copy(k)
    @test k2 isa Kambites{String}
    @test kind(k2) == twosided
    @test small_overlap_class(k2) == small_overlap_class(k)

    s = sprint(show, k)
    @test s isa String
    @test !isempty(s)
end

@testset "Kambites{String} - error paths and validation" begin
    p = Presentation{String}()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, "abcd", "aaaeaa")
    add_rule_no_checks!(p, "ef", "dg")

    k = Kambites(twosided, p)
    @test_throws LibsemigroupsError Kambites(Semigroups.onesided, p)

    # Valid alphabet check
    @test throw_if_letter_not_in_alphabet(k, "abc") === nothing
    # Letter out of alphabet
    @test_throws LibsemigroupsError throw_if_letter_not_in_alphabet(k, "z")
    # Non-ASCII throws ArgumentError
    @test_throws ArgumentError throw_if_letter_not_in_alphabet(k, "café")
    @test_throws ArgumentError Semigroups.reduce(k, "café")

    # non_trivial_classes throws
    k_other = Kambites(twosided, p)
    @test_throws ArgumentError non_trivial_classes(k, k_other)

    # small_overlap_class < 4
    p_low = Presentation{String}()
    set_alphabet!(p_low, 2)
    add_rule_no_checks!(p_low, "aa", "b")
    k_low = Kambites(twosided, p_low)
    @test small_overlap_class(k_low) < 4
    @test_throws LibsemigroupsError throw_if_not_C4(k_low)
    @test_throws LibsemigroupsError number_of_classes(k_low)
    @test_throws LibsemigroupsError normal_forms(k_low, 5)
end

@testset "Kambites{W} - default construction and init!" begin
    @test Kambites() isa Kambites{Vector{Int}}
    @test Kambites{Vector{Int}}() isa Kambites{Vector{Int}}
    k = Kambites{String}()
    @test k isa Kambites{String}
    # Kambites{W} is a CongruenceCommon (and hence a Runner) for every W.
    @test k isa Semigroups.CongruenceCommon
    @test k isa Semigroups.Runner
    @test Kambites() isa Semigroups.CongruenceCommon

    p = Presentation{String}()
    set_alphabet!(p, "abcdefg")
    add_rule!(p, "abcd", "aaaeaa")
    add_rule!(p, "ef", "dg")

    @test init!(k, twosided, p) === k
    @test presentation(k) == p
    @test small_overlap_class(k) >= 4
    @test Semigroups.contains(k, "efabc", "dgabc")

    # init!(k) resets to the default-constructed state.
    @test init!(k) === k
    @test isempty(rules(presentation(k)))
    @test number_of_generating_pairs(k) == 0

    # Word types of Kambites and Presentation must agree.
    @test_throws ArgumentError init!(Kambites{Vector{Int}}(), twosided, p)
end

@testset "Kambites{W} - current_small_overlap_class before computation" begin
    for p in (Presentation(), Presentation{String}())
        set_alphabet!(p, 7)
        k = Kambites(twosided, p)
        @test current_small_overlap_class(k) === UNDEFINED
        small_overlap_class(k)
        @test current_small_overlap_class(k) == POSITIVE_INFINITY
    end
end

@testset "Kambites{String} - copies are independent" begin
    p = Presentation{String}()
    set_alphabet!(p, 7)
    add_rule_no_checks!(p, "abcd", "aaaeaa")
    add_rule_no_checks!(p, "ef", "dg")

    k = Kambites(twosided, p)
    for k2 in (copy(k), deepcopy(k), Kambites(k))
        @test k2 isa Kambites{String}
        @test k2.cxx_obj !== k.cxx_obj
        add_generating_pair!(k2, "a", "b")
        @test number_of_generating_pairs(k2) == 1
        @test number_of_generating_pairs(k) == 0
    end

    # presentation(k) returns an independent copy.
    q = presentation(k)
    add_rule_no_checks!(q, "g", "a")
    @test length(rules(presentation(k))) == 2
end

@testset "Kambites{W} - runner methods" begin
    for (p, u, v) in
        ((Presentation(), [5, 6], [4, 7]), (Presentation{String}(), "ef", "dg"))
        set_alphabet!(p, 7)
        add_rule_no_checks!(p, u, v)

        k = Kambites(twosided, p)
        @test !started(k)
        @test current_state(k) == Semigroups.STATE_NEVER_RUN
        @test !running_for(k)
        @test !running_until(k)

        run_for!(k, Millisecond(10))
        @test running_for_how_long(k) isa Nanosecond
        @test !running_for(k)

        run!(k)
        @test finished(k)
        @test string_why_we_stopped(k) isa AbstractString
        kill!(k)
        @test dead(k)
    end
end

@testset "Kambites - Vector{Int} and String encodings agree" begin
    pw = Presentation()
    set_alphabet!(pw, 7)
    add_rule_no_checks!(pw, [1, 2, 3, 4], [1, 1, 1, 5, 1, 1])
    add_rule_no_checks!(pw, [5, 6], [4, 7])

    ps = Presentation{String}()
    set_alphabet!(ps, "abcdefg")
    add_rule_no_checks!(ps, "abcd", "aaaeaa")
    add_rule_no_checks!(ps, "ef", "dg")

    kw = Kambites(twosided, pw)
    ks = Kambites(twosided, ps)

    to_str(w) = String([Char('a' + i - 1) for i in w])

    @test small_overlap_class(kw) == small_overlap_class(ks)
    @test map(to_str, normal_forms(kw, 50)) == normal_forms(ks, 50)
    for w in ([1, 2, 3, 4], [5, 6, 1, 2, 3, 4], [1, 1, 1, 5, 6, 2, 3, 4])
        @test to_str(Semigroups.reduce(kw, w)) == Semigroups.reduce(ks, to_str(w))
    end
    @test Semigroups.to(Presentation{String}, kw) == ps
end

@testset "Kambites{W} - word type mismatches and bad input" begin
    ps = Presentation{String}()
    set_alphabet!(ps, 7)
    add_rule_no_checks!(ps, "ef", "dg")
    ks = Kambites(twosided, ps)

    pw = Presentation()
    set_alphabet!(pw, 7)
    add_rule_no_checks!(pw, [5, 6], [4, 7])
    kw = Kambites(twosided, pw)

    @test_throws ArgumentError Semigroups.reduce(kw, "ab")
    @test_throws ArgumentError Semigroups.contains(kw, "ab", "ab")
    @test_throws ArgumentError partition(ks, [[1, 2]])
    @test_throws ArgumentError partition(kw, ["ab"])

    @test_throws ArgumentError partition(ks, ["ab", "café"])
    @test_throws ArgumentError add_generating_pair!(ks, "é", "a")
    @test_throws LibsemigroupsError add_generating_pair!(ks, "z", "a")
    @test_throws LibsemigroupsError Semigroups.contains(kw, [8], [1])
    @test_throws InexactError normal_forms(kw, -1)
end

@testset "Kambites{String} - generic CongruenceCommon helpers" begin
    p = Presentation{String}()
    set_alphabet!(p, "abcdefg")
    add_rule!(p, "abcd", "aaaeaa")
    add_rule!(p, "ef", "dg")
    k = Kambites(twosided, p)

    # The generic Runner / CongruenceCommon methods reach the C++ object via
    # `_cxx` and convert words using `_cong_word_type`.
    @test Semigroups._cxx(k) === k.cxx_obj
    @test Semigroups._cong_word_type(k) === String
    @test Semigroups._cong_word_type(Kambites()) === Vector{Int}

    # These dispatch to the generic CongruenceCommon methods in cong-common.jl.
    @test presentation(k) isa Presentation{String}
    @test kind(k) == twosided
    @test Semigroups.reduce(k, SubString("xefx", 2, 3)) == Semigroups.reduce(k, "ef")
    classes = partition(k, SubString{String}["ef", "dg", "a"])
    @test classes isa Vector{Vector{String}}
    @test sort(sort.(classes)) == [["a"], ["dg", "ef"]]

    # A KnuthBendix (word_type only) rejects String words with a clear error.
    pw = Presentation()
    set_alphabet!(pw, 2)
    add_rule!(pw, [1, 1], [1])
    kb = KnuthBendix(twosided, pw)
    @test_throws ArgumentError Semigroups.contains(kb, "a", "aa")
end
