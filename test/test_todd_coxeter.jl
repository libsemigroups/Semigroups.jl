# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
test_todd_coxeter.jl - Tests for ToddCoxeter

Phase 3b of the v1 design. Ports a focused subset of [quick] cases from
libsemigroups/tests/test-todd-coxeter.cpp, plus binding-surface and high-level
integration tests.

This file is brought in **before** the Julia wrapper for ToddCoxeter is fully
implemented — by design. Many assertions will fail with `MethodError` or
`UndefVarError` until Stage 3 implements the wrapper methods one slice at a
time. The constructor and `number_of_classes` work directly off the C++ glue
and so a handful of assertions may already pass.
"""

using Test
using Semigroups
using Dates

# ToddCoxeter and the enum constants are not yet exported from `Semigroups`
# (Stage 4 adds the exports). Bring them into local scope under their public
# names for readability.
const ToddCoxeter = Semigroups.ToddCoxeter

const strategy_hlt      = Semigroups.strategy_hlt
const strategy_felsch   = Semigroups.strategy_felsch
const strategy_CR       = Semigroups.strategy_CR
const strategy_R_over_C = Semigroups.strategy_R_over_C
const strategy_Cr       = Semigroups.strategy_Cr
const strategy_Rc       = Semigroups.strategy_Rc

const lookahead_extent_full    = Semigroups.lookahead_extent_full
const lookahead_extent_partial = Semigroups.lookahead_extent_partial

const lookahead_style_hlt    = Semigroups.lookahead_style_hlt
const lookahead_style_felsch = Semigroups.lookahead_style_felsch

const def_policy_no_stack_if_no_space    = Semigroups.def_policy_no_stack_if_no_space
const def_policy_purge_from_top          = Semigroups.def_policy_purge_from_top
const def_policy_purge_all               = Semigroups.def_policy_purge_all
const def_policy_discard_all_if_no_space = Semigroups.def_policy_discard_all_if_no_space
const def_policy_unlimited               = Semigroups.def_policy_unlimited

const def_version_one = Semigroups.def_version_one
const def_version_two = Semigroups.def_version_two

# ---- Word conversion helpers (1-based Julia <-> 0-based C++ in libsemigroups) ----

# Mirror the KB pattern: `_tc_cword(0, 0, 1)` builds the Julia word `[1, 1, 2]`.
_tc_cword(xs::Integer...) = [Int(x) + 1 for x in xs]

# ============================================================================
# Layer 1 — binding-surface tests
# ============================================================================

@testset "ToddCoxeter binding surface" begin
    @test isdefined(Semigroups, :ToddCoxeter)

    # Constructors (4 forms)
    @test hasmethod(ToddCoxeter, Tuple{Semigroups.congruence_kind, Presentation})
    @test hasmethod(ToddCoxeter, Tuple{Semigroups.congruence_kind, ToddCoxeter})
    @test hasmethod(ToddCoxeter, Tuple{Semigroups.congruence_kind, WordGraph})
    @test hasmethod(ToddCoxeter, Tuple{ToddCoxeter})

    # init! overloads (4 forms)
    @test hasmethod(init!, Tuple{ToddCoxeter})
    @test hasmethod(init!, Tuple{ToddCoxeter, Semigroups.congruence_kind, Presentation})
    @test hasmethod(init!, Tuple{ToddCoxeter, Semigroups.congruence_kind, ToddCoxeter})
    @test hasmethod(init!, Tuple{ToddCoxeter, Semigroups.congruence_kind, WordGraph})

    # Settings (8 getter / 8 setter pairs)
    @test hasmethod(Semigroups.strategy, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.strategy!, Tuple{ToddCoxeter, Any})
    @test hasmethod(Semigroups.lookahead_extent, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.lookahead_extent!, Tuple{ToddCoxeter, Any})
    @test hasmethod(Semigroups.lookahead_style, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.lookahead_style!, Tuple{ToddCoxeter, Any})
    @test hasmethod(Semigroups.save, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.save!, Tuple{ToddCoxeter, Bool})
    @test hasmethod(Semigroups.use_relations_in_extra, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.use_relations_in_extra!, Tuple{ToddCoxeter, Bool})
    @test hasmethod(Semigroups.lower_bound, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.lower_bound!, Tuple{ToddCoxeter, Integer})
    @test hasmethod(Semigroups.def_version, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.def_version!, Tuple{ToddCoxeter, Any})
    @test hasmethod(Semigroups.def_policy, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.def_policy!, Tuple{ToddCoxeter, Any})

    # Standardize and word-graph access
    @test hasmethod(standardize!, Tuple{ToddCoxeter, Order})
    @test hasmethod(Semigroups.is_standardized, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.is_standardized, Tuple{ToddCoxeter, Order})
    @test hasmethod(Semigroups.current_word_graph, Tuple{ToddCoxeter})
    @test hasmethod(word_graph, Tuple{ToddCoxeter})

    # Word <-> class index
    @test hasmethod(Semigroups.index_of, Tuple{ToddCoxeter, AbstractVector{<:Integer}})
    @test hasmethod(Semigroups.current_index_of, Tuple{ToddCoxeter, AbstractVector{<:Integer}})
    @test hasmethod(Semigroups.word_of, Tuple{ToddCoxeter, Integer})
    @test hasmethod(Semigroups.current_word_of, Tuple{ToddCoxeter, Integer})

    # Query methods
    @test hasmethod(number_of_classes, Tuple{ToddCoxeter})
    @test hasmethod(kind, Tuple{ToddCoxeter})
    @test hasmethod(number_of_generating_pairs, Tuple{ToddCoxeter})
    @test hasmethod(generating_pairs, Tuple{ToddCoxeter})
    @test hasmethod(presentation, Tuple{ToddCoxeter})

    # Free functions
    @test hasmethod(Semigroups.is_non_trivial, Tuple{ToddCoxeter})
    @test hasmethod(Semigroups.tc_redundant_rule, Tuple{Presentation, TimePeriod})

    # Base.* overloads
    @test hasmethod(Base.length, Tuple{ToddCoxeter})
    @test hasmethod(Base.show, Tuple{IO, ToddCoxeter})
    @test hasmethod(Base.copy, Tuple{ToddCoxeter})

    # Inherited from CongruenceCommon (already wrapped in src/cong-common.jl)
    @test hasmethod(add_generating_pair!, Tuple{Semigroups.CongruenceCommon, AbstractVector{<:Integer}, AbstractVector{<:Integer}})
    @test hasmethod(currently_contains, Tuple{Semigroups.CongruenceCommon, AbstractVector{<:Integer}, AbstractVector{<:Integer}})
    @test hasmethod(contains, Tuple{Semigroups.CongruenceCommon, AbstractVector{<:Integer}, AbstractVector{<:Integer}})
    @test hasmethod(Semigroups.reduce, Tuple{Semigroups.CongruenceCommon, AbstractVector{<:Integer}})
    @test hasmethod(reduce_no_run, Tuple{Semigroups.CongruenceCommon, AbstractVector{<:Integer}})
    @test hasmethod(normal_forms, Tuple{Semigroups.CongruenceCommon})
    @test hasmethod(non_trivial_classes, Tuple{Semigroups.CongruenceCommon, Semigroups.CongruenceCommon})
end

# ============================================================================
# Layer 2 — correctness (ported from test-todd-coxeter.cpp)
# ============================================================================

@testset "TC000 - small 2-sided congruence (27 classes)" begin
    # Port of libsemigroups TC000 (test-todd-coxeter.cpp:294-341).
    # 2-generator semigroup, rules: 000 = 0, 1111 = 1, 0101 = 00.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(1, 1, 1, 1), _tc_cword(1))
    add_rule_no_checks!(p, _tc_cword(0, 1, 0, 1), _tc_cword(0, 0))

    tc = ToddCoxeter(twosided, p)
    @test number_of_classes(tc) == 27
    @test finished(tc)

    # standardize + normal_forms count matches number_of_classes
    standardize!(tc, ORDER_SHORTLEX)
    nfs = normal_forms(tc)
    @test length(nfs) == 27
end

@testset "TC001 - small 2-sided congruence (5 classes)" begin
    # Port of libsemigroups TC001 (test-todd-coxeter.cpp:343-441).
    # 2-generator semigroup, rules: 000 = 0, 0 = 11.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))

    tc = ToddCoxeter(twosided, p)
    run!(tc)
    @test number_of_classes(tc) == 5
    @test finished(tc)

    # Index-of: 001 == 00001 (1-based: [1,1,2] == [1,1,1,1,2])
    @test Semigroups.index_of(tc, _tc_cword(0, 0, 1)) ==
          Semigroups.index_of(tc, _tc_cword(0, 0, 0, 0, 1))
    @test Semigroups.index_of(tc, _tc_cword(0, 1, 1, 0, 0, 1)) ==
          Semigroups.index_of(tc, _tc_cword(0, 0, 0, 0, 1))
    @test Semigroups.index_of(tc, _tc_cword(0, 0, 0)) !=
          Semigroups.index_of(tc, _tc_cword(1))

    # Standardize for shortlex (TC001 lines 371-374)
    standardize!(tc, ORDER_SHORTLEX)
    @test Semigroups.word_of(tc, 1) == _tc_cword(0)        # C++ index 0
    @test Semigroups.word_of(tc, 2) == _tc_cword(1)        # C++ index 1
    @test Semigroups.word_of(tc, 3) == _tc_cword(0, 0)     # C++ index 2

    # Standardize for lex (TC001 lines 375-391)
    standardize!(tc, ORDER_LEX)
    @test Semigroups.is_standardized(tc, ORDER_LEX)
    @test Semigroups.is_standardized(tc)
    @test !Semigroups.is_standardized(tc, ORDER_SHORTLEX)

    @test Semigroups.word_of(tc, 1) == _tc_cword(0)           # 0
    @test Semigroups.word_of(tc, 2) == _tc_cword(0, 0)        # 00
    @test Semigroups.word_of(tc, 3) == _tc_cword(0, 0, 1)     # 001
    @test Semigroups.word_of(tc, 4) == _tc_cword(0, 0, 1, 0)  # 0010
    @test Semigroups.word_of(tc, 5) == _tc_cword(1)           # 1

    # word_of/index_of round-trip (1-based on the Julia side)
    for i in 1:5
        @test Semigroups.index_of(tc, Semigroups.word_of(tc, i)) == i
    end

    # Standardize for shortlex again, and check normal_forms equals expected.
    standardize!(tc, ORDER_SHORTLEX)
    @test Semigroups.is_standardized(tc, ORDER_SHORTLEX)
    @test normal_forms(tc) == [
        _tc_cword(0),
        _tc_cword(1),
        _tc_cword(0, 0),
        _tc_cword(0, 1),
        _tc_cword(0, 0, 1),
    ]
end

@testset "TC - quotient construction (kind, ToddCoxeter)" begin
    # Port of libsemigroups TC025 (test-todd-coxeter.cpp:1447-1468), reduced.
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))

    tc1 = ToddCoxeter(twosided, p)
    @test number_of_classes(tc1) == 5

    tc2 = ToddCoxeter(onesided, tc1)
    add_generating_pair!(tc2, _tc_cword(0), _tc_cword(0, 0))
    @test number_of_classes(tc2) == 3
end

@testset "TC024 - constructor from WordGraph" begin
    # Port of libsemigroups TC024 (test-todd-coxeter.cpp:1435-1445).
    wg = WordGraph(1, 2)
    @test out_degree(wg) == 2
    @test number_of_nodes(wg) == 1
    tc = ToddCoxeter(twosided, wg)
    @test tc isa ToddCoxeter
end

@testset "TC settings round-trip (8 pairs)" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))
    tc = ToddCoxeter(twosided, p)

    Semigroups.strategy!(tc, strategy_felsch)
    @test Semigroups.strategy(tc) == strategy_felsch

    Semigroups.lookahead_extent!(tc, lookahead_extent_full)
    @test Semigroups.lookahead_extent(tc) == lookahead_extent_full

    Semigroups.lookahead_style!(tc, lookahead_style_felsch)
    @test Semigroups.lookahead_style(tc) == lookahead_style_felsch

    Semigroups.save!(tc, true)
    @test Semigroups.save(tc) == true

    Semigroups.use_relations_in_extra!(tc, false)
    @test Semigroups.use_relations_in_extra(tc) == false

    Semigroups.lower_bound!(tc, 5)
    @test Semigroups.lower_bound(tc) == 5

    Semigroups.def_version!(tc, def_version_two)
    @test Semigroups.def_version(tc) == def_version_two

    Semigroups.def_policy!(tc, def_policy_purge_all)
    @test Semigroups.def_policy(tc) == def_policy_purge_all
end

@testset "TC - current_word_graph after run!" begin
    # TC1 (5 classes). Presentation does NOT contain the empty word, so
    # number_of_nodes(current_word_graph(tc)) == number_of_classes(tc) + 1
    # (the +1 accounts for the inactive "absorbing" node).
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))

    tc = ToddCoxeter(twosided, p)
    run!(tc)
    wg = Semigroups.current_word_graph(tc)
    @test wg isa WordGraph
    @test number_of_nodes(wg) == number_of_classes(tc) + 1
end

@testset "TC - is_non_trivial on free monogenic" begin
    # Port of libsemigroups TC031 fragment (test-todd-coxeter.cpp:1730-1739).
    # Free monogenic semigroup is non-trivial.
    p = Presentation()
    set_alphabet!(p, 1)
    tc = ToddCoxeter(twosided, p)
    @test Semigroups.is_non_trivial(tc) == tril_TRUE
end

@testset "TC - tc_redundant_rule" begin
    # Irredundant: TC103-style presentation (single rule on a 1-letter alphabet
    # cannot be redundant).
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))
    @test Semigroups.tc_redundant_rule(p, Millisecond(50)) === nothing

    # Trivially redundant: add a duplicate rule.
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    idx = Semigroups.tc_redundant_rule(p, Millisecond(100))
    @test idx isa Integer
    @test 1 <= idx <= number_of_rules(p)
end

@testset "TC - cong-common helpers (reduce, contains, currently_contains, normal_forms)" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))
    tc = ToddCoxeter(twosided, p)

    # contains triggers a run; should agree with index_of equality
    @test contains(tc, _tc_cword(0, 0, 1), _tc_cword(0, 0, 0, 0, 1))
    @test currently_contains(tc, _tc_cword(0, 0, 1), _tc_cword(0, 0, 0, 0, 1)) ==
          tril_TRUE

    # reduce returns the standardized representative
    r = Semigroups.reduce(tc, _tc_cword(0, 0, 0, 0, 1))
    @test r isa Vector{Int}
    @test contains(tc, r, _tc_cword(0, 0, 0, 0, 1))

    # normal_forms count == number_of_classes
    nfs = normal_forms(tc)
    @test length(nfs) == number_of_classes(tc)
end

@testset "TC - non_trivial_classes(tc1, tc2) for a quotient pair" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))

    tc1 = ToddCoxeter(twosided, p)
    @test number_of_classes(tc1) == 5

    # tc2 is a quotient of tc1 collapsing 0 ~ 1; should produce a smaller
    # number_of_classes.
    tc2 = ToddCoxeter(twosided, p)
    add_generating_pair!(tc2, _tc_cword(0), _tc_cword(1))
    @test number_of_classes(tc2) < number_of_classes(tc1)

    classes = non_trivial_classes(tc1, tc2)
    @test classes isa AbstractVector
end

# ============================================================================
# Layer 3 — high-level integration
# ============================================================================

@testset "ToddCoxeter high-level Julia API" begin
    p = Presentation()
    set_alphabet!(p, 2)
    add_rule_no_checks!(p, _tc_cword(0, 0, 0), _tc_cword(0))
    add_rule_no_checks!(p, _tc_cword(0), _tc_cword(1, 1))

    tc = ToddCoxeter(twosided, p)
    @test length(tc) == number_of_classes(tc)
    @test !isempty(sprint(show, tc))

    # copy: independent objects. Mutate one setting on the copy.
    tc2 = copy(tc)
    @test length(tc2) == length(tc)
    Semigroups.strategy!(tc2, strategy_felsch)
    @test Semigroups.strategy(tc2) == strategy_felsch

    # 1-based round-trip for index_of / word_of
    standardize!(tc, ORDER_SHORTLEX)
    for i in 1:Int(number_of_classes(tc))
        @test Semigroups.index_of(tc, Semigroups.word_of(tc, i)) == i
    end

    # Setter chaining (chained left-to-right; both effects must persist).
    Semigroups.save!(Semigroups.strategy!(tc, strategy_felsch), false)
    @test Semigroups.strategy(tc) == strategy_felsch
    @test Semigroups.save(tc) == false

    # standardize! returns a Bool
    fresh = ToddCoxeter(twosided, p)
    run!(fresh)
    @test standardize!(fresh, ORDER_SHORTLEX) isa Bool
end

# ============================================================================
# TODO — deferred test cases (re-port when their dependencies land)
# ============================================================================
# - class_by_index / class_of (deferred; needs Paths-with-alphabet-transform)
# - to<>(tc) conversions (Phase 4b: to<FroidurePin>(tc), to<KnuthBendix>(tc),
#   to<ToddCoxeter>(...), to<WordGraph>(tc))
# - Numeric setters (def_max, f_defs, hlt_defs, large_collapse, lookahead_*
#   numerics, lookbehind_threshold) — v1.1
# - perform_lookahead / perform_lookahead_for / perform_lookahead_until /
#   perform_lookbehind member callbacks — v1.1
# - All [extreme]-tagged libsemigroups tests
# - Tests that depend on `presentation::examples::*` not yet exercised
# - RewriteFromLeft-related KB cross-comparisons
# - shrink_to_fit (not yet bound)
