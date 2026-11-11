# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
test_todd_coxeter.jl - Tests for ToddCoxeter

Ports a focused subset of [quick] cases from
libsemigroups/tests/test-todd-coxeter.cpp, plus binding-surface and
high-level integration tests.
"""

using Test
using Semigroups
using Dates

# Build a 1-based Julia word from 0-based libsemigroups indices.
# `_tc_word(0, 0, 1)` -> `[1, 1, 2]`. Long prefix avoids shadowing in shared
# test scope.
_tc_word(xs::Integer...) = [Int(x) + 1 for x in xs]

@testset "ToddCoxeter binding surface" begin
    @test isdefined(Semigroups, :ToddCoxeter)

    # Constructors (4 forms)
    @test hasmethod(ToddCoxeter, Tuple{congruence_kind,Presentation})
    @test hasmethod(ToddCoxeter, Tuple{congruence_kind,ToddCoxeter})
    @test hasmethod(ToddCoxeter, Tuple{congruence_kind,WordGraph})
    @test hasmethod(ToddCoxeter, Tuple{ToddCoxeter})

    # init! overloads (4 forms)
    @test hasmethod(init!, Tuple{ToddCoxeter})
    @test hasmethod(init!, Tuple{ToddCoxeter,congruence_kind,Presentation})
    @test hasmethod(init!, Tuple{ToddCoxeter,congruence_kind,ToddCoxeter})
    @test hasmethod(init!, Tuple{ToddCoxeter,congruence_kind,WordGraph})

    # Settings (8 getter / 8 setter pairs)
    @test hasmethod(strategy, Tuple{ToddCoxeter})
    @test hasmethod(strategy!, Tuple{ToddCoxeter,typeof(strategy_hlt)})
    @test hasmethod(lookahead_extent, Tuple{ToddCoxeter})
    @test hasmethod(lookahead_extent!, Tuple{ToddCoxeter,typeof(lookahead_extent_full)})
    @test hasmethod(lookahead_style, Tuple{ToddCoxeter})
    @test hasmethod(lookahead_style!, Tuple{ToddCoxeter,typeof(lookahead_style_hlt)})
    @test hasmethod(save, Tuple{ToddCoxeter})
    @test hasmethod(save!, Tuple{ToddCoxeter,Bool})
    @test hasmethod(use_relations_in_extra, Tuple{ToddCoxeter})
    @test hasmethod(use_relations_in_extra!, Tuple{ToddCoxeter,Bool})
    @test hasmethod(lower_bound, Tuple{ToddCoxeter})
    @test hasmethod(lower_bound!, Tuple{ToddCoxeter,Integer})
    @test hasmethod(def_version, Tuple{ToddCoxeter})
    @test hasmethod(def_version!, Tuple{ToddCoxeter,typeof(def_version_one)})
    @test hasmethod(def_policy, Tuple{ToddCoxeter})
    @test hasmethod(def_policy!, Tuple{ToddCoxeter,typeof(def_policy_purge_all)})

    # Standardize and word-graph access
    @test hasmethod(standardize!, Tuple{ToddCoxeter,Order})
    @test hasmethod(is_standardized, Tuple{ToddCoxeter})
    @test hasmethod(is_standardized, Tuple{ToddCoxeter,Order})
    @test hasmethod(current_word_graph, Tuple{ToddCoxeter})
    @test hasmethod(word_graph, Tuple{ToddCoxeter})

    # Word <-> class index
    @test hasmethod(index_of, Tuple{ToddCoxeter,AbstractVector{<:Integer}})
    @test hasmethod(current_index_of, Tuple{ToddCoxeter,AbstractVector{<:Integer}})
    @test hasmethod(word_of, Tuple{ToddCoxeter,Integer})
    @test hasmethod(current_word_of, Tuple{ToddCoxeter,Integer})
    @test hasmethod(
        throw_if_letter_not_in_alphabet,
        Tuple{ToddCoxeter,AbstractVector{<:Integer}},
    )

    # Query methods
    @test hasmethod(number_of_classes, Tuple{ToddCoxeter})
    @test hasmethod(kind, Tuple{ToddCoxeter})
    @test hasmethod(number_of_generating_pairs, Tuple{ToddCoxeter})
    @test hasmethod(generating_pairs, Tuple{ToddCoxeter})
    @test hasmethod(presentation, Tuple{ToddCoxeter})

    # Free functions
    @test hasmethod(is_non_trivial, Tuple{ToddCoxeter})
    @test hasmethod(tc_redundant_rule, Tuple{Presentation,TimePeriod})

    # Base.* overloads
    @test hasmethod(Base.length, Tuple{ToddCoxeter})
    @test hasmethod(Base.show, Tuple{IO,ToddCoxeter})
    @test hasmethod(Base.copy, Tuple{ToddCoxeter})

    # Inherited from CongruenceCommon (wrapped in src/cong-common.jl).
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
    @test hasmethod(non_trivial_classes, Tuple{CongruenceCommon,CongruenceCommon})
end

# ============================================================================
# correctness tests inspired by test-todd-coxeter.cpp
# ============================================================================

@testset "TC000 - small 2-sided congruence (27 classes)" begin
    # Port of libsemigroups TC000 (test-todd-coxeter.cpp:294-341).
    # 2-generator semigroup, rules: 000 = 0, 1111 = 1, 0101 = 00.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(1, 1, 1, 1), _tc_word(1))
    add_rule_no_checks!(p, _tc_word(0, 1, 0, 1), _tc_word(0, 0))

    tc = ToddCoxeter(twosided, p)
    @test number_of_classes(tc) == 27
    @test finished(tc)

    standardize!(tc, ORDER_SHORTLEX)
    @test length(normal_forms(tc)) == 27
end

@testset "TC001 - small 2-sided congruence (5 classes)" begin
    # Port of libsemigroups TC001 (test-todd-coxeter.cpp:343-441).
    # 2-generator semigroup, rules: 000 = 0, 0 = 11.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))

    tc = ToddCoxeter(twosided, p)
    run!(tc)
    @test number_of_classes(tc) == 5
    @test finished(tc)

    # Index-of: 001 == 00001 (1-based: [1,1,2] == [1,1,1,1,2])
    @test index_of(tc, _tc_word(0, 0, 1)) == index_of(tc, _tc_word(0, 0, 0, 0, 1))
    @test index_of(tc, _tc_word(0, 1, 1, 0, 0, 1)) == index_of(tc, _tc_word(0, 0, 0, 0, 1))
    @test index_of(tc, _tc_word(0, 0, 0)) != index_of(tc, _tc_word(1))

    # Standardize for shortlex (TC001 lines 371-374)
    standardize!(tc, ORDER_SHORTLEX)
    @test word_of(tc, 1) == _tc_word(0)        # C++ index 0
    @test word_of(tc, 2) == _tc_word(1)        # C++ index 1
    @test word_of(tc, 3) == _tc_word(0, 0)     # C++ index 2

    # Standardize for lex (TC001 lines 375-391)
    standardize!(tc, ORDER_LEX)
    @test is_standardized(tc, ORDER_LEX)
    @test is_standardized(tc)
    @test !is_standardized(tc, ORDER_SHORTLEX)

    @test word_of(tc, 1) == _tc_word(0)           # 0
    @test word_of(tc, 2) == _tc_word(0, 0)        # 00
    @test word_of(tc, 3) == _tc_word(0, 0, 1)     # 001
    @test word_of(tc, 4) == _tc_word(0, 0, 1, 0)  # 0010
    @test word_of(tc, 5) == _tc_word(1)           # 1

    # word_of/index_of round-trip (1-based)
    for i = 1:5
        @test index_of(tc, word_of(tc, i)) == i
    end

    standardize!(tc, ORDER_SHORTLEX)
    @test is_standardized(tc, ORDER_SHORTLEX)
    @test normal_forms(tc) ==
          [_tc_word(0), _tc_word(1), _tc_word(0, 0), _tc_word(0, 1), _tc_word(0, 0, 1)]
end

@testset "TC - quotient construction (kind, ToddCoxeter)" begin
    # Port of libsemigroups TC025 (test-todd-coxeter.cpp:1447-1468), reduced.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))

    tc1 = ToddCoxeter(twosided, p)
    @test number_of_classes(tc1) == 5

    tc2 = ToddCoxeter(onesided, tc1)
    add_generating_pair!(tc2, _tc_word(0), _tc_word(0, 0))
    @test number_of_classes(tc2) == 3
end

@testset "TC024 - constructor from WordGraph" begin
    # Port of libsemigroups TC024 (test-todd-coxeter.cpp:1435-1445).
    # Upstream only requires the constructor not to throw; mirror that and add
    # a few cheap state observations. The 1-node, 2-out-degree WordGraph has
    # all-UNDEFINED targets.
    wg = WordGraph(1, 2)
    @test out_degree(wg) == 2
    @test number_of_nodes(wg) == 1

    tc = ToddCoxeter(twosided, wg)
    @test tc isa ToddCoxeter
    @test kind(tc) == twosided
    @test (finished(tc); started(tc); true)
end

@testset "TC settings round-trip (8 pairs)" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))
    tc = ToddCoxeter(twosided, p)

    strategy!(tc, strategy_felsch)
    @test strategy(tc) == strategy_felsch

    lookahead_extent!(tc, lookahead_extent_full)
    @test lookahead_extent(tc) == lookahead_extent_full

    lookahead_style!(tc, lookahead_style_felsch)
    @test lookahead_style(tc) == lookahead_style_felsch

    save!(tc, true)
    @test save(tc) == true

    use_relations_in_extra!(tc, false)
    @test use_relations_in_extra(tc) == false

    # Default is UNDEFINED (no bound). Setting then clearing round-trips.
    @test lower_bound(tc) === UNDEFINED
    lower_bound!(tc, 5)
    @test lower_bound(tc) == 5
    lower_bound!(tc, UNDEFINED)
    @test lower_bound(tc) === UNDEFINED

    def_version!(tc, def_version_two)
    @test def_version(tc) == def_version_two

    def_policy!(tc, def_policy_purge_all)
    @test def_policy(tc) == def_policy_purge_all
end

@testset "TC init! overloads coverage" begin
    p1 = Presentation()
    set_alphabet!(p1, 2)
    add_rule_no_checks!(p1, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p1, _tc_word(0), _tc_word(1, 1))

    p2 = Presentation()
    set_alphabet!(p2, 1)
    add_rule_no_checks!(p2, _tc_word(0, 0), _tc_word(0))

    tc = ToddCoxeter(twosided, p1)
    run!(tc)
    @test number_of_classes(tc) == 5

    # Re-initialize with presentation
    init!(tc, twosided, p2)
    run!(tc)
    @test number_of_classes(tc) == 1

    # Re-initialize with another ToddCoxeter
    tc_other = ToddCoxeter(twosided, p1)
    init!(tc, onesided, tc_other)
    @test tc isa ToddCoxeter

    # Re-initialize with WordGraph
    wg = WordGraph(1, 2)
    init!(tc, twosided, wg)
    @test tc isa ToddCoxeter
end
@testset "TC - current_word_graph after run!" begin
    # After run!, current_word_graph may include inactive allocation slots,
    # so it has at least number_of_classes(tc) + 1 nodes (the +1 accounts for
    # the inactive node 0 for presentations without the empty word).
    # word_graph(tc) standardizes and prunes, giving exactly that count.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))

    tc = ToddCoxeter(twosided, p)
    run!(tc)

    cwg = current_word_graph(tc)
    @test number_of_nodes(cwg) >= number_of_classes(tc) + 1

    swg = word_graph(tc)
    @test number_of_nodes(swg) == number_of_classes(tc) + 1
end

@testset "TC - is_non_trivial on free monogenic" begin
    # Port of libsemigroups TC031 fragment (test-todd-coxeter.cpp:1730-1739).
    # Free monogenic semigroup is non-trivial.
    p = Presentation()
    set_alphabet!(p, 1)
    tc = ToddCoxeter(twosided, p)
    @test is_non_trivial(tc) == tril_TRUE
end

@testset "TC - tc_redundant_rule" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))
    @test tc_redundant_rule(p, Millisecond(50)) === nothing

    # Add a duplicate rule -> trivially redundant.
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    idx = tc_redundant_rule(p, Millisecond(100))
    @test idx isa Integer
    @test 1 <= idx <= number_of_rules(p)
end

@testset "TC - throw_if_letter_not_in_alphabet" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))
    tc = ToddCoxeter(twosided, p)

    @test throw_if_letter_not_in_alphabet(tc, _tc_word(0, 1, 0)) === nothing
    @test_throws LibsemigroupsError throw_if_letter_not_in_alphabet(tc, _tc_word(0, 5))
end

@testset "TC - cong-common helpers (reduce, contains, currently_contains, normal_forms)" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))
    tc = ToddCoxeter(twosided, p)

    # contains triggers a run and agrees with index_of equality.
    @test Semigroups.contains(tc, _tc_word(0, 0, 1), _tc_word(0, 0, 0, 0, 1))
    @test currently_contains(tc, _tc_word(0, 0, 1), _tc_word(0, 0, 0, 0, 1)) == tril_TRUE

    r = Semigroups.reduce(tc, _tc_word(0, 0, 0, 0, 1))
    @test r isa Vector{Int}
    @test Semigroups.contains(tc, r, _tc_word(0, 0, 0, 0, 1))

    @test length(normal_forms(tc)) == number_of_classes(tc)
end

@testset "TC - non_trivial_classes(tc1, tc2) for a quotient pair" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))

    tc1 = ToddCoxeter(twosided, p)
    @test number_of_classes(tc1) == 5

    # tc2 collapses 0 ~ 1 -> strictly fewer classes than tc1.
    tc2 = ToddCoxeter(twosided, p)
    add_generating_pair!(tc2, _tc_word(0), _tc_word(1))
    @test number_of_classes(tc2) < number_of_classes(tc1)

    classes = non_trivial_classes(tc1, tc2)
    @test classes isa AbstractVector
end

@testset "ToddCoxeter high-level Julia API" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_word(0, 0, 0), _tc_word(0))
    add_rule_no_checks!(p, _tc_word(0), _tc_word(1, 1))

    tc = ToddCoxeter(twosided, p)
    @test length(tc) == number_of_classes(tc)
    @test !isempty(sprint(show, tc))

    # copy: independent objects.
    tc2 = copy(tc)
    @test length(tc2) == length(tc)
    strategy!(tc2, strategy_felsch)
    @test strategy(tc2) == strategy_felsch

    # 1-based round-trip for index_of / word_of.
    standardize!(tc, ORDER_SHORTLEX)
    for i = 1:Int(number_of_classes(tc))
        @test index_of(tc, word_of(tc, i)) == i
    end

    # Setter chaining: each setter returns tc, so calls compose left-to-right.
    save!(strategy!(tc, strategy_felsch), false)
    @test strategy(tc) == strategy_felsch
    @test save(tc) == false

    # standardize! returns a Bool.
    fresh = ToddCoxeter(twosided, p)
    run!(fresh)
    @test standardize!(fresh, ORDER_SHORTLEX) isa Bool
end

# ============================================================================
# TODO - port full test-todd-coxeter.cpp test cases
# ============================================================================

@testset "ToddCoxeter - construct and re-initialise from a WordGraph reference" begin
    # word_graph(tc) returns a reference into tc's own graph; constructing a
    # new ToddCoxeter from it, or re-initialising one with it, must work.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule!(p, [1, 1], [1])
    add_rule!(p, [2, 2], [2])
    add_rule!(p, [1, 2], [2, 1])
    tc = ToddCoxeter(twosided, p)
    wg = word_graph(tc)

    tc2 = ToddCoxeter(twosided, wg)
    @test tc2 isa ToddCoxeter{Vector{Int}}
    @test number_of_classes(tc2) == number_of_classes(tc)

    tc3 = ToddCoxeter(twosided, p)
    @test init!(tc3, twosided, wg) === tc3
    @test number_of_classes(tc3) == number_of_classes(tc)
end

# ============================================================================
# ToddCoxeter{String}
# ============================================================================

# Finite monoid: a^2 = a, b^2 = b, ab = ba. Classes of nonempty words:
# {a}, {b}, {ab}.
function _tc_string_presentation()
    p = Presentation{String}()
    set_alphabet!(p, "ab")
    add_rule!(p, "aa", "a")
    add_rule!(p, "bb", "b")
    add_rule!(p, "ab", "ba")
    return p
end

function _tc_word_presentation()
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule!(p, [1, 1], [1])
    add_rule!(p, [2, 2], [2])
    add_rule!(p, [1, 2], [2, 1])
    return p
end

@testset "ToddCoxeter{String} - construction" begin
    p = _tc_string_presentation()
    tc = ToddCoxeter(twosided, p)
    @test tc isa ToddCoxeter{String}
    @test tc isa Semigroups.CongruenceCommon{String}
    @test presentation(tc) == p
    @test presentation(tc) isa Presentation{String}
    @test number_of_classes(tc) == 3

    # Quotient, copy, and construction from a word graph keep the word type.
    @test ToddCoxeter(onesided, tc) isa ToddCoxeter{String}
    @test copy(tc) isa ToddCoxeter{String}
    tc2 = ToddCoxeter{String}(twosided, word_graph(tc))
    @test tc2 isa ToddCoxeter{String}
    @test number_of_classes(tc2) == 3
    # Without a word type, a word graph gives Vector{Int} words.
    @test ToddCoxeter(twosided, word_graph(tc)) isa ToddCoxeter{Vector{Int}}
end

@testset "ToddCoxeter{String} - word operations" begin
    tc = ToddCoxeter(twosided, _tc_string_presentation())
    @test Semigroups.contains(tc, "ab", "ba")
    @test !Semigroups.contains(tc, "a", "b")
    @test Semigroups.reduce(tc, "baa") isa String
    @test Semigroups.contains(tc, Semigroups.reduce(tc, "baa"), "baa")
    @test currently_contains(tc, "ab", "ba") == tril_TRUE

    nfs = normal_forms(tc)
    @test nfs isa Vector{String}
    @test sort(nfs) == ["a", "ab", "b"]

    classes = partition(tc, ["a", "aa", "b", "ab", "ba"])
    @test classes isa Vector{Vector{String}}
    @test sort(sort.(classes)) == [["a", "aa"], ["ab", "ba"], ["b"]]

    # index_of / word_of round-trip through class indices.
    for w in ["a", "b", "ab", "bab"]
        i = index_of(tc, w)
        @test i isa Int
        @test word_of(tc, i) isa String
        @test Semigroups.contains(tc, word_of(tc, i), w)
        @test current_index_of(tc, w) == i
        @test current_word_of(tc, i) isa String
    end
end

@testset "ToddCoxeter{String} - generating pairs" begin
    tc = ToddCoxeter(twosided, _tc_string_presentation())
    @test isempty(generating_pairs(tc))
    add_generating_pair!(tc, "a", "b")
    @test generating_pairs(tc) == [("a", "b")]
    @test generating_pairs(tc) isa Vector{Tuple{String,String}}
    @test Semigroups.contains(tc, "a", "b")
end

@testset "ToddCoxeter{String} - errors" begin
    tc = ToddCoxeter(twosided, _tc_string_presentation())
    @test throw_if_letter_not_in_alphabet(tc, "ab") === nothing
    @test_throws LibsemigroupsError throw_if_letter_not_in_alphabet(tc, "z")
    @test_throws ArgumentError throw_if_letter_not_in_alphabet(tc, "café")
    @test_throws ArgumentError index_of(tc, [1, 2])
    @test_throws ArgumentError Semigroups.contains(tc, [1], [2])

    # init! needs a presentation / ToddCoxeter of the same word type.
    tcw = ToddCoxeter(twosided, _tc_word_presentation())
    @test_throws ArgumentError init!(tcw, twosided, _tc_string_presentation())
    @test_throws ArgumentError init!(tcw, twosided, tc)
    @test init!(tc, twosided, _tc_string_presentation()) === tc
end

@testset "ToddCoxeter{String} - agrees with Vector{Int} words" begin
    tcs = ToddCoxeter(twosided, _tc_string_presentation())
    tcw = ToddCoxeter(twosided, _tc_word_presentation())
    to_str(w) = String([Char('a' + i - 1) for i in w])
    @test number_of_classes(tcs) == number_of_classes(tcw)
    @test sort(normal_forms(tcs)) == sort(map(to_str, normal_forms(tcw)))
    for w in ([1], [2, 1, 1], [1, 2, 1, 2])
        @test to_str(Semigroups.reduce(tcw, w)) == Semigroups.reduce(tcs, to_str(w))
    end
end

@testset "ToddCoxeter{String} - helpers" begin
    p = _tc_string_presentation()
    coarse = ToddCoxeter(twosided, p)
    add_generating_pair!(coarse, "a", "b")
    classes = non_trivial_classes(coarse, ToddCoxeter(twosided, p))
    @test classes isa Vector{Vector{String}}
    @test sort(sort.(classes)) == [["a", "ab", "b"]]

    @test is_non_trivial(ToddCoxeter(twosided, p)) isa tril

    # The added rule "ba" = "ab" duplicates "ab" = "ba", so some rule is
    # redundant.
    q = _tc_string_presentation()
    add_rule!(q, "ba", "ab")
    @test tc_redundant_rule(q, Dates.Millisecond(100)) isa Int
end

@testset "ToddCoxeter{String} - conversions" begin
    ps = _tc_string_presentation()
    tc = ToddCoxeter(twosided, ps)
    # to(Presentation, tc) keeps the word type; an explicit target converts.
    q = Semigroups.to(Presentation, tc)
    @test q isa Presentation{String}
    @test q == ps
    qw = Semigroups.to(Presentation{Vector{Int}}, tc)
    @test qw isa Presentation{Vector{Int}}
    @test qw == _tc_word_presentation()
    tcw = ToddCoxeter(twosided, _tc_word_presentation())
    @test Semigroups.to(Presentation{String}, tcw) == ps

    # KnuthBendix does not support String words yet: a clear error, not an
    # opaque method error.
    @test_throws ArgumentError Semigroups.to(KnuthBendix, twosided, tc)
    @test Semigroups.to(KnuthBendix, twosided, tcw) isa KnuthBendix{Vector{Int}}
end

@testset "ToddCoxeter{String} - word graphs need at most 128 labels" begin
    # One ASCII letter per edge label: 128 fit, 129 do not.
    tc = ToddCoxeter{String}(twosided, WordGraph(2, 128))
    @test all(isascii, alphabet(presentation(tc)))
    @test length(alphabet(presentation(tc))) == 128
    @test_throws ArgumentError ToddCoxeter{String}(twosided, WordGraph(2, 129))
    @test_throws ArgumentError init!(tc, twosided, WordGraph(2, 129))
    # Integer words have no such limit.
    @test ToddCoxeter(twosided, WordGraph(2, 129)) isa ToddCoxeter{Vector{Int}}
end
