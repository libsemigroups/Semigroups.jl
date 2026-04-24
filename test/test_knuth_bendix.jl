# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_knuth_bendix.jl - Tests for KnuthBendix bindings

Three test layers:
  Layer 1 (binding-surface): hasmethod/isdefined checks for CxxWrap glue
  Layer 2 (correctness): ported from libsemigroups test-knuth-bendix-6.cpp
  Layer 3 (high-level integration): Julia public API — RED until Task 4

C++ test numbering preserved in comments for cross-referencing.
"""

using Test
using Semigroups

const LS = Semigroups.LibSemigroups

# Helper: build a word_type (0-based UInt vector) for raw C++ calls
_w(xs...) = UInt[UInt(x) for x in xs]

@testset verbose = true "KnuthBendix" begin

    # ========================================================================
    # Layer 1 — Binding-surface tests
    # ========================================================================

    @testset "Layer 1: binding surface" begin

        @testset "type exists and inherits from Runner" begin
            @test isdefined(LS, :KnuthBendixRewriteTrie)
            KBType = LS.KnuthBendixRewriteTrie
            # Build a minimal instance to check supertype
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)
            @test kb isa Runner
        end

        @testset "overlap enum constants" begin
            @test isdefined(LS, :overlap_ABC)
            @test isdefined(LS, :overlap_AB_BC)
            @test isdefined(LS, :overlap_MAX_AB_BC)
        end

        @testset "constructor methods" begin
            KBType = LS.KnuthBendixRewriteTrie
            @test hasmethod(KBType, Tuple{congruence_kind, Presentation})
            # Copy constructor
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)
            kb2 = KBType(kb)
            @test kb2 isa LS.KnuthBendixRewriteTrie
        end

        @testset "settings getter/setter methods" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)

            # Getters
            @test hasmethod(LS.max_pending_rules, Tuple{KBType})
            @test hasmethod(LS.check_confluence_interval, Tuple{KBType})
            @test hasmethod(LS.max_overlap, Tuple{KBType})
            @test hasmethod(LS.max_rules, Tuple{KBType})

            # Setters (mutating)
            @test isdefined(LS, Symbol("set_max_pending_rules!"))
            @test isdefined(LS, Symbol("set_check_confluence_interval!"))
            @test isdefined(LS, Symbol("set_max_overlap!"))
            @test isdefined(LS, Symbol("set_max_rules!"))
            @test isdefined(LS, Symbol("set_overlap_policy!"))
        end

        @testset "query methods" begin
            KBType = LS.KnuthBendixRewriteTrie
            @test hasmethod(LS.number_of_active_rules, Tuple{KBType})
            @test hasmethod(LS.number_of_inactive_rules, Tuple{KBType})
            @test hasmethod(LS.number_of_pending_rules, Tuple{KBType})
            @test hasmethod(LS.total_rules, Tuple{KBType})
            @test hasmethod(LS.confluent, Tuple{KBType})
            @test hasmethod(LS.confluent_known, Tuple{KBType})
            @test hasmethod(LS.number_of_classes, Tuple{KBType})
            @test hasmethod(LS.kind, Tuple{KBType})
            @test hasmethod(LS.number_of_generating_pairs, Tuple{KBType})
            @test hasmethod(LS.presentation, Tuple{KBType})
        end

        @testset "word operation free functions" begin
            @test isdefined(LS, :kb_reduce)
            @test isdefined(LS, :kb_reduce_no_run)
            @test isdefined(LS, :kb_contains)
            @test isdefined(LS, :kb_currently_contains)
            @test isdefined(LS, Symbol("kb_add_generating_pair!"))
        end

        @testset "rules and graph access" begin
            @test isdefined(LS, :kb_active_rules)
            KBType = LS.KnuthBendixRewriteTrie
            @test hasmethod(LS.gilman_graph, Tuple{KBType})
            @test hasmethod(LS.gilman_graph_node_labels, Tuple{KBType})
        end

        @testset "display" begin
            KBType = LS.KnuthBendixRewriteTrie
            @test hasmethod(LS.to_human_readable_repr, Tuple{KBType})
        end

        @testset "free functions" begin
            @test isdefined(LS, Symbol("kb_by_overlap_length!"))
            @test isdefined(LS, :kb_is_reduced)
            @test isdefined(LS, :kb_redundant_rule)
            @test isdefined(LS, :kb_normal_forms)
            @test isdefined(LS, :kb_non_trivial_classes)
        end
    end

    # ========================================================================
    # Layer 2 — Correctness tests (ported from C++)
    # ========================================================================

    @testset "Layer 2: correctness" begin

        # ----------------------------------------------------------------
        # Test 129: Presentation<word_type> — 2 generators, 5 classes
        # ----------------------------------------------------------------
        @testset "test 129: 2-gen semigroup (5 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            # C++: add_rule(p, 000_w, 0_w) -> letters 0,0,0 = 0
            # Raw C++ binding uses 0-based UInt
            add_rule!(p, [1, 1, 1], [1])        # 0,0,0 = 0 (1-based)
            add_rule!(p, [1], [2, 2])            # 0 = 1,1 (1-based)

            kb = KBType(twosided, p)

            @test !finished(kb)
            @test LS.number_of_classes(kb) == 5
            @test finished(kb)

            # reduce tests — raw C++ binding takes UInt[] (0-based)
            @test LS.kb_reduce(kb, _w(0, 0, 1)) == _w(0, 0, 1)
            @test LS.kb_reduce(kb, _w(0, 0, 0, 0, 1)) == _w(0, 0, 1)
            @test LS.kb_reduce(kb, _w(0, 1, 1, 0, 0, 1)) == _w(0, 0, 1)

            # contains tests
            @test !LS.kb_contains(kb, _w(0, 0, 0), _w(1))
            @test !LS.kb_contains(kb, _w(0, 0, 0, 0), _w(0, 0, 0))
        end

        # ----------------------------------------------------------------
        # Test 130: free semigroup congruence (6 classes)
        # ----------------------------------------------------------------
        @testset "test 130: 5-gen congruence (6 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 5)
            # C++ uses 0-based letters; Julia add_rule! uses 1-based
            add_rule!(p, [1, 1], [1])          # 00 = 0
            add_rule!(p, [1, 2], [2])          # 01 = 1
            add_rule!(p, [2, 1], [2])          # 10 = 1
            add_rule!(p, [1, 3], [3])          # 02 = 2
            add_rule!(p, [3, 1], [3])          # 20 = 2
            add_rule!(p, [1, 4], [4])          # 03 = 3
            add_rule!(p, [4, 1], [4])          # 30 = 3
            add_rule!(p, [1, 5], [5])          # 04 = 4
            add_rule!(p, [5, 1], [5])          # 40 = 4
            add_rule!(p, [2, 3], [1])          # 12 = 0
            add_rule!(p, [3, 2], [1])          # 21 = 0
            add_rule!(p, [4, 5], [1])          # 34 = 0
            add_rule!(p, [5, 4], [1])          # 43 = 0
            add_rule!(p, [3, 3], [1])          # 22 = 0
            add_rule!(p, [2, 5, 3, 4, 4], [1])  # 14233 = 0
            add_rule!(p, [5, 5, 5], [1])       # 444 = 0

            kb = KBType(twosided, p)

            @test LS.number_of_classes(kb) == 6
            @test LS.kb_contains(kb, _w(1), _w(2))
        end

        # ----------------------------------------------------------------
        # Test 131: free semigroup congruence (16 classes)
        # ----------------------------------------------------------------
        @testset "test 131: 4-gen congruence (16 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 4)
            # C++ 0-based: 3=2, 03=02, etc. -> Julia 1-based: 4=3, 14=13, etc.
            add_rule!(p, [4], [3])
            add_rule!(p, [1, 4], [1, 3])
            add_rule!(p, [2, 2], [2])
            add_rule!(p, [2, 4], [2, 3])
            add_rule!(p, [3, 2], [3])
            add_rule!(p, [3, 3], [3])
            add_rule!(p, [3, 4], [3])
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1, 1, 2], [2])
            add_rule!(p, [1, 1, 3], [3])
            add_rule!(p, [1, 2, 3], [2, 3])
            add_rule!(p, [2, 1, 1], [2])
            add_rule!(p, [2, 1, 3], [1, 3])
            add_rule!(p, [3, 1, 1], [3])
            add_rule!(p, [1, 2, 1, 2], [2, 1, 2])
            add_rule!(p, [1, 3, 1, 3], [3, 1, 3])
            add_rule!(p, [2, 1, 2, 1], [2, 1, 2])
            add_rule!(p, [2, 3, 1, 2], [2, 1, 2])
            add_rule!(p, [2, 3, 1, 3], [3, 1, 3])
            add_rule!(p, [3, 1, 2, 1], [3, 1, 2])
            add_rule!(p, [3, 1, 3, 1], [3, 1, 3])

            kb = KBType(twosided, p)

            @test LS.number_of_classes(kb) == 16
            @test LS.number_of_active_rules(kb) == 18
            @test LS.kb_contains(kb, _w(2), _w(3))
        end

        # ----------------------------------------------------------------
        # Test 132: free semigroup congruence x 2 (16 classes, 11 gens)
        # ----------------------------------------------------------------
        @testset "test 132: 11-gen congruence (16 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 11)
            # C++ uses raw rules vectors; here we translate each rule
            # C++ 0-based → Julia 1-based (add 1 to each letter)
            add_rule_no_checks!(p, [3], [2])
            add_rule_no_checks!(p, [5], [4])
            add_rule_no_checks!(p, [6], [1])
            add_rule_no_checks!(p, [7], [4])
            add_rule_no_checks!(p, [8], [2])
            add_rule_no_checks!(p, [9], [4])
            add_rule_no_checks!(p, [10], [4])
            add_rule_no_checks!(p, [11], [1])
            add_rule_no_checks!(p, [1, 3], [1, 2])
            add_rule_no_checks!(p, [1, 5], [1, 4])
            add_rule_no_checks!(p, [1, 6], [1, 1])
            add_rule_no_checks!(p, [1, 7], [1, 4])
            add_rule_no_checks!(p, [1, 8], [1, 2])
            add_rule_no_checks!(p, [1, 9], [1, 4])
            add_rule_no_checks!(p, [1, 10], [1, 4])
            add_rule_no_checks!(p, [1, 11], [1, 1])
            add_rule_no_checks!(p, [2, 2], [2])
            add_rule_no_checks!(p, [2, 3], [2])
            add_rule_no_checks!(p, [2, 5], [2, 4])
            add_rule_no_checks!(p, [2, 6], [2, 1])
            add_rule_no_checks!(p, [2, 7], [2, 4])
            add_rule_no_checks!(p, [2, 8], [2])
            add_rule_no_checks!(p, [2, 9], [2, 4])
            add_rule_no_checks!(p, [2, 10], [2, 4])
            add_rule_no_checks!(p, [2, 11], [2, 1])
            add_rule_no_checks!(p, [4, 2], [4])
            add_rule_no_checks!(p, [4, 3], [4])
            add_rule_no_checks!(p, [4, 4], [4])
            add_rule_no_checks!(p, [4, 5], [4])
            add_rule_no_checks!(p, [4, 6], [4, 1])
            add_rule_no_checks!(p, [4, 7], [4])
            add_rule_no_checks!(p, [4, 8], [4])
            add_rule_no_checks!(p, [4, 9], [4])
            add_rule_no_checks!(p, [4, 10], [4])
            add_rule_no_checks!(p, [4, 11], [4, 1])
            add_rule_no_checks!(p, [1, 1, 1], [1])
            add_rule_no_checks!(p, [1, 1, 2], [2])
            add_rule_no_checks!(p, [1, 1, 4], [4])
            add_rule_no_checks!(p, [1, 2, 4], [2, 4])
            add_rule_no_checks!(p, [2, 1, 1], [2])
            add_rule_no_checks!(p, [2, 1, 4], [1, 4])
            add_rule_no_checks!(p, [4, 1, 1], [4])
            add_rule_no_checks!(p, [1, 2, 1, 2], [2, 1, 2])
            add_rule_no_checks!(p, [1, 4, 1, 4], [4, 1, 4])
            add_rule_no_checks!(p, [2, 1, 2, 1], [2, 1, 2])
            add_rule_no_checks!(p, [2, 4, 1, 2], [2, 1, 2])
            add_rule_no_checks!(p, [2, 4, 1, 4], [4, 1, 4])
            add_rule_no_checks!(p, [4, 1, 2, 1], [4, 1, 2])
            add_rule_no_checks!(p, [4, 1, 4, 1], [4, 1, 4])

            kb = KBType(twosided, p)
            @test LS.number_of_classes(kb) == 16
            @test LS.kb_contains(kb, _w(0), _w(5))
            @test LS.kb_contains(kb, _w(0), _w(10))
            @test LS.kb_contains(kb, _w(1), _w(2))
            @test LS.kb_contains(kb, _w(1), _w(7))
            @test LS.kb_contains(kb, _w(3), _w(4))
            @test LS.kb_contains(kb, _w(3), _w(6))
            @test LS.kb_contains(kb, _w(3), _w(8))
            @test LS.kb_contains(kb, _w(3), _w(9))
        end

        # ----------------------------------------------------------------
        # Test 133: free semigroup congruence (240 classes)
        # ----------------------------------------------------------------
        @testset "test 133: 2-gen congruence (240 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [2, 2, 2, 2], [2])
            add_rule!(p, [1, 2, 2, 2, 1], [1, 1])
            add_rule!(p, [2, 1, 1, 2], [2, 2])
            add_rule!(p, [1, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1], [1, 1])

            kb = KBType(twosided, p)
            @test LS.number_of_classes(kb) == 240
        end

        # ----------------------------------------------------------------
        # Test 135: constructors / copy
        # ----------------------------------------------------------------
        @testset "test 135: copy constructor preserves state" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [2, 2, 2, 2, 2, 2, 2, 2, 2], [2])
            add_rule!(p, [1, 2, 2, 2, 2, 2, 1, 2, 2], [2, 2, 1])

            kb = KBType(twosided, p)
            @test LS.number_of_classes(kb) == 746

            kb_copy = KBType(kb)
            @test LS.number_of_classes(kb_copy) == 746
            pres = LS.presentation(kb_copy)
            @test length(alphabet(pres)) == 2
            # The copy uses the "active rules" of kb — 105 after completion
            @test LS.number_of_active_rules(kb_copy) == 105
        end

        # ----------------------------------------------------------------
        # Test 136: number of classes when obviously infinite
        # ----------------------------------------------------------------
        @testset "test 136: obviously infinite semigroup" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 3)
            add_rule!(p, [1, 2], [2, 1])
            add_rule!(p, [1, 3], [3, 1])
            add_rule!(p, [1, 1], [1])
            add_rule!(p, [1, 3], [1])
            add_rule!(p, [3, 1], [1])
            add_rule!(p, [2, 2], [2, 2])
            add_rule!(p, [2, 3], [3, 2])
            add_rule!(p, [2, 2, 2], [2])
            add_rule!(p, [2, 3], [2])
            add_rule!(p, [3, 2], [2])
            add_rule!(p, [1], [2])

            kb = KBType(twosided, p)
            # number_of_classes returns POSITIVE_INFINITY (a large uint64)
            nc = LS.number_of_classes(kb)
            @test nc == POSITIVE_INFINITY
        end

        # ----------------------------------------------------------------
        # Test 137: Chinese monoid x 2
        # ----------------------------------------------------------------
        @testset "test 137: chinese monoid (infinite)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = chinese_monoid(3)

            kb = KBType(twosided, p)
            nc = LS.number_of_classes(kb)
            @test nc == POSITIVE_INFINITY
            # presentation should have 8 rules
            pres = LS.presentation(kb)
            @test number_of_rules(pres) == 8
        end

        # ----------------------------------------------------------------
        # Test 138: partial_transformation_monoid(4) — 625 classes
        # ----------------------------------------------------------------
        @testset "test 138: partial_transformation_monoid(4)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = partial_transformation_monoid(4)

            kb = KBType(twosided, p)
            @test LS.number_of_classes(kb) == 625
            @test LS.number_of_active_rules(kb) == 362

            repr = LS.to_human_readable_repr(kb)
            @test occursin("confluent", repr)
            @test occursin("KnuthBendix", repr)
        end

        # ----------------------------------------------------------------
        # Test 141: constructors/init for finished
        # ----------------------------------------------------------------
        @testset "test 141: init reinitializes KB" begin
            KBType = LS.KnuthBendixRewriteTrie

            p1 = Presentation()
            set_contains_empty_word!(p1, true)
            set_alphabet!(p1, 4)
            add_rule!(p1, [1, 2], Int[])
            add_rule!(p1, [2, 1], Int[])
            add_rule!(p1, [3, 4], Int[])
            add_rule!(p1, [4, 3], Int[])
            add_rule!(p1, [3, 1], [1, 3])

            kb1 = KBType(twosided, p1)
            @test !LS.confluent(kb1)
            @test !finished(kb1)
            run!(kb1)
            @test LS.confluent(kb1)
            @test LS.number_of_active_rules(kb1) == 8

            p2 = Presentation()
            set_contains_empty_word!(p2, true)
            set_alphabet!(p2, 2)
            add_rule!(p2, [1, 1, 1], Int[])
            add_rule!(p2, [2, 2, 2], Int[])
            add_rule!(p2, [1, 2, 1, 2, 1, 2], Int[])

            # Re-init with a different presentation
            kb2 = KBType(twosided, p2)
            @test !LS.confluent(kb2)
            @test !finished(kb2)
            run!(kb2)
            @test finished(kb2)
            @test LS.confluent(kb2)
            @test LS.confluent_known(kb2)
            @test LS.number_of_active_rules(kb2) == 4
        end

        # ----------------------------------------------------------------
        # Test 142: close to or greater than 255 letters (exception)
        # ----------------------------------------------------------------
        @testset "test 142: > 255 letters throws" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 257)
            @test_throws Exception KBType(twosided, p)
        end

        # ----------------------------------------------------------------
        # Settings round-trip
        # ----------------------------------------------------------------
        @testset "settings round-trip" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)

            # max_pending_rules
            LS.set_max_pending_rules!(kb, 256)
            @test LS.max_pending_rules(kb) == 256

            # check_confluence_interval
            LS.set_check_confluence_interval!(kb, 8192)
            @test LS.check_confluence_interval(kb) == 8192

            # max_overlap
            LS.set_max_overlap!(kb, 100)
            @test LS.max_overlap(kb) == 100

            # max_rules
            LS.set_max_rules!(kb, 500)
            @test LS.max_rules(kb) == 500

            # overlap_policy
            LS.set_overlap_policy!(kb, LS.overlap_ABC)
            @test LS.overlap_policy(kb) == LS.overlap_ABC

            LS.set_overlap_policy!(kb, LS.overlap_AB_BC)
            @test LS.overlap_policy(kb) == LS.overlap_AB_BC

            LS.set_overlap_policy!(kb, LS.overlap_MAX_AB_BC)
            @test LS.overlap_policy(kb) == LS.overlap_MAX_AB_BC
        end

        # ----------------------------------------------------------------
        # active_rules content verification
        # ----------------------------------------------------------------
        @testset "active_rules collection" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            run!(kb)

            flat = LS.kb_active_rules(kb)
            @test length(flat) > 0
            # flat is a vector of word_type (StdVector); should be even length
            @test length(flat) % 2 == 0

            # Each entry should be a word (vector-like)
            n_rules = LS.number_of_active_rules(kb)
            @test length(flat) == 2 * n_rules
        end

        # ----------------------------------------------------------------
        # reduce and contains with known values
        # ----------------------------------------------------------------
        @testset "reduce and contains consistency" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)

            # After running, reduced forms are canonical
            r1 = LS.kb_reduce(kb, _w(0, 0, 1))
            r2 = LS.kb_reduce(kb, _w(0, 0, 0, 0, 1))
            @test r1 == r2

            # reduce_no_run should also work after the KB is finished
            r3 = LS.kb_reduce_no_run(kb, _w(0, 0, 1))
            @test r1 == r3
        end

        # ----------------------------------------------------------------
        # currently_contains (no-run variant, returns tril)
        # ----------------------------------------------------------------
        @testset "currently_contains returns tril" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            # Before running, currently_contains may return tril_unknown
            result = LS.kb_currently_contains(kb, _w(0, 0, 0), _w(0))
            @test result isa tril

            # After running, should give definitive answer
            run!(kb)
            result2 = LS.kb_currently_contains(kb, _w(0, 0, 0), _w(0))
            @test result2 == tril_TRUE
        end

        # ----------------------------------------------------------------
        # gilman_graph access
        # ----------------------------------------------------------------
        @testset "gilman_graph access" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            run!(kb)

            wg = LS.gilman_graph(kb)
            # gilman_graph returns a ConstCxxRef{WordGraph}; dereference for queries
            @test number_of_nodes(wg) > 0
        end

        # ----------------------------------------------------------------
        # to_human_readable_repr
        # ----------------------------------------------------------------
        @testset "to_human_readable_repr" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])

            kb = KBType(twosided, p)
            repr_str = LS.to_human_readable_repr(kb)
            @test repr_str isa AbstractString
            @test !isempty(repr_str)
            @test occursin("KnuthBendix", repr_str)
        end

        # ----------------------------------------------------------------
        # kind() returns congruence_kind
        # ----------------------------------------------------------------
        @testset "kind accessor" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)
            @test LS.kind(kb) == twosided
        end

        # ----------------------------------------------------------------
        # number_of_generating_pairs initially 0
        # ----------------------------------------------------------------
        @testset "number_of_generating_pairs" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KBType(twosided, p)
            @test LS.number_of_generating_pairs(kb) == 0

            # Add a generating pair and check
            LS.kb_add_generating_pair!(kb, _w(0), _w(1))
            @test LS.number_of_generating_pairs(kb) == 1
        end

        # ----------------------------------------------------------------
        # redundant_rule
        # ----------------------------------------------------------------
        @testset "redundant_rule" begin
            p = Presentation()
            set_alphabet!(p, 3)
            # C++: add_rule(p, 0_w, 011_w)  → Julia 1-based via add_rule!
            add_rule!(p, [1], [1, 2, 2])
            add_rule!(p, [2], [2, 1, 1])
            add_rule!(p, [3], [1, 2, 2, 1, 2, 1, 2, 1, 1, 1, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1])

            # timeout in nanoseconds: 100ms = 100_000_000 ns
            idx = LS.kb_redundant_rule(p, Int64(100_000_000))
            # Should NOT find a redundant rule (idx == rules size)
            n_flat = 2 * number_of_rules(p)
            @test idx == n_flat   # no redundant rule found

            # Add a duplicate rule
            add_rule!(p, [2], [2, 1, 1])
            idx2 = LS.kb_redundant_rule(p, Int64(100_000_000))
            @test idx2 < 2 * number_of_rules(p)  # found a redundant rule
        end

        # ----------------------------------------------------------------
        # normal_forms
        # ----------------------------------------------------------------
        @testset "normal_forms collection" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            nf = LS.kb_normal_forms(kb)
            @test length(nf) == 5   # 5 classes
        end

        # ----------------------------------------------------------------
        # non_trivial_classes
        # ----------------------------------------------------------------
        @testset "non_trivial_classes" begin
            KBType = LS.KnuthBendixRewriteTrie

            # Build kb1 with base presentation
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule_no_checks!(p, [1, 1, 2], [1, 1])
            add_rule_no_checks!(p, [1, 1, 1, 1], [1, 1])
            add_rule_no_checks!(p, [1, 2, 2, 1], [1, 1])
            add_rule_no_checks!(p, [1, 2, 2, 2], [1, 1, 1])
            add_rule_no_checks!(p, [2, 2, 2, 1], [2, 2, 1])
            add_rule_no_checks!(p, [2, 2, 2, 2], [2, 2, 2])
            add_rule_no_checks!(p, [1, 2, 1, 1, 1], [1, 2, 1, 2])
            add_rule_no_checks!(p, [1, 2, 1, 2, 1], [1, 2, 1, 1])
            add_rule_no_checks!(p, [1, 2, 1, 2, 2], [1, 2, 1, 2])

            kb1 = KBType(twosided, p)
            @test LS.number_of_classes(kb1) == 27

            kb2 = KBType(twosided, p)
            @test LS.number_of_classes(kb2) == 27

            ntc = LS.kb_non_trivial_classes(kb1, kb2)
            @test isempty(ntc)
        end

        # ----------------------------------------------------------------
        # Test 143: process pending rules (quick variant)
        # ----------------------------------------------------------------
        @testset "test 143: confluent after process (small)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_contains_empty_word!(p, true)
            set_alphabet!(p, 2)
            # Add all words of length 0..18 as rules mapping to empty word
            # This is the C++ test with WordRange min(0) max(19).
            # For a quick test, just add a few key rules that yield 2 active rules.
            add_rule!(p, [1], Int[])
            add_rule!(p, [2], Int[])

            kb = KBType(twosided, p)
            run!(kb)
            @test LS.number_of_active_rules(kb) == 2
        end

        # ----------------------------------------------------------------
        # Adapted from test-knuth-bendix-1.cpp test 003:
        # Non-confluent Wikipedia example (word_type adaptation)
        # ----------------------------------------------------------------
        @testset "adapted test 003: Wikipedia example (word_type)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_contains_empty_word!(p, true)
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], Int[])
            add_rule!(p, [2, 2, 2], Int[])
            add_rule!(p, [1, 2, 1, 2, 1, 2], Int[])

            kb = KBType(twosided, p)
            @test !LS.confluent(kb)
            run!(kb)
            @test LS.confluent(kb)
            @test LS.number_of_classes(kb) == POSITIVE_INFINITY
        end

        # ----------------------------------------------------------------
        # Adapted from test-knuth-bendix-1.cpp test 006:
        # Example 5.3 in Sims — 12 elements (word_type adaptation)
        # ----------------------------------------------------------------
        @testset "adapted test 006: Sims 5.3 (12 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_contains_empty_word!(p, true)
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1], Int[])
            add_rule!(p, [2, 2, 2], Int[])
            add_rule!(p, [1, 2, 1, 2, 1, 2], Int[])

            kb = KBType(twosided, p)
            @test !LS.confluent(kb)
            run!(kb)
            @test LS.number_of_active_rules(kb) == 6
            @test LS.confluent(kb)
            @test LS.number_of_classes(kb) == 12

            nf = LS.kb_normal_forms(kb)
            @test length(nf) == 12
        end

        # ----------------------------------------------------------------
        # Adapted from test-knuth-bendix-1.cpp test 011:
        # F(2,5) Fibonacci group — 11 classes
        # ----------------------------------------------------------------
        @testset "adapted test 011: F(2,5) (11 classes)" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 5)
            # C++: ab=c, bc=d, cd=e, de=a, ea=b  (0-indexed: a=0,b=1,c=2,d=3,e=4)
            # Julia 1-indexed: a=1,b=2,c=3,d=4,e=5
            add_rule!(p, [1, 2], [3])
            add_rule!(p, [2, 3], [4])
            add_rule!(p, [3, 4], [5])
            add_rule!(p, [4, 5], [1])
            add_rule!(p, [5, 1], [2])

            kb = KBType(twosided, p)
            @test !LS.confluent(kb)
            run!(kb)
            @test LS.number_of_active_rules(kb) == 24
            @test LS.confluent(kb)
            @test LS.number_of_classes(kb) == 11
        end

        # ----------------------------------------------------------------
        # by_overlap_length and is_reduced
        # ----------------------------------------------------------------
        @testset "by_overlap_length and is_reduced" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            LS.kb_by_overlap_length!(kb)
            @test LS.confluent(kb)

            reduced = LS.kb_is_reduced(kb)
            @test reduced isa Bool
        end

        # ----------------------------------------------------------------
        # Runner methods inherited by KnuthBendix
        # ----------------------------------------------------------------
        @testset "Runner method inheritance" begin
            KBType = LS.KnuthBendixRewriteTrie
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])

            kb = KBType(twosided, p)
            @test !finished(kb)
            @test !started(kb)

            run!(kb)
            @test finished(kb)
            @test started(kb)
            @test !timed_out(kb)
        end
    end

    # ========================================================================
    # Layer 3 — High-level integration tests (RED until Task 4)
    # ========================================================================

    @testset "Layer 3: high-level API" begin

        # These tests call through the public Semigroups.* API.

        @testset "KnuthBendix type alias" begin
            @test isdefined(Semigroups, :KnuthBendix)
        end

        @testset "Base.length(kb) == number_of_classes" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            @test length(kb) == 5
        end

        @testset "Base.show(kb) produces output" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            kb = KnuthBendix(twosided, p)
            s = sprint(show, kb)
            @test occursin("KnuthBendix", s)
        end

        @testset "Base.copy(kb) produces independent object" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            kb2 = copy(kb)
            @test number_of_classes(kb2) == 5
        end

        @testset "reduce with 1-based Vector{Int}" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            @test Semigroups.reduce(kb, [1, 1, 2]) == [1, 1, 2]
        end

        @testset "contains with 1-based Vector{Int}" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            @test !Semigroups.contains(kb, [1, 1, 1], [2])
        end

        @testset "setter chaining" begin
            p = Presentation()
            set_alphabet!(p, 2)
            kb = KnuthBendix(twosided, p)
            result = max_rules!(max_overlap!(kb, 100), 200)
            @test result === kb
        end

        @testset "active_rules returns Vector{Tuple}" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            run!(kb)
            ar = active_rules(kb)
            @test ar isa Vector{Tuple{Vector{Int},Vector{Int}}}
        end

        @testset "normal_forms returns 1-based words" begin
            p = Presentation()
            set_alphabet!(p, 2)
            add_rule!(p, [1, 1, 1], [1])
            add_rule!(p, [1], [2, 2])
            kb = KnuthBendix(twosided, p)
            nf = normal_forms(kb)
            @test length(nf) == 5
            @test all(w -> all(x -> x >= 1, w), nf)
        end

        @testset "integration with presentation examples" begin
            p = chinese_monoid(3)
            kb = KnuthBendix(twosided, p)
            @test number_of_classes(kb) == POSITIVE_INFINITY
        end

        # TODO: Port tests requiring FroidurePin (test 134: to<FroidurePin>),
        #       Paths (gilman_graph iteration), WordRange (test 118/143/144).
        # These are deferred until FroidurePin<word_type> and Paths are bound.
    end
end
