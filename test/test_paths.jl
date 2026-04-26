# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

using Test
using Semigroups

# Pull in private aliases used by Layer 1 binding-surface tests.
const LibSemigroups = Semigroups.LibSemigroups

# ---------------------------------------------------------------------------
# Helpers for building the small word graphs used by the ported tests.
# These mirror the C++ test setup in libsemigroups/tests/test-paths.cpp.
# ---------------------------------------------------------------------------

# 100-node linear path (test 000): node i has edge labelled (i mod 2 + 1)
# pointing to node (i + 1), for i in 1..99 (in 1-based indexing).
function _linear_100()
    g = WordGraph(100, 2)
    for i in 1:99
        # C++ used i % 2 (0-based label), so 1-based label = (i-1) % 2 + 1
        label = (i - 1) % 2 + 1
        target!(g, i, label, i + 1)
    end
    return g
end

# Cycle of n nodes, out_degree 1 (used by tests 002 and 009).
function _cycle(n::Integer)
    g = WordGraph(n, 1)
    for i in 1:(n-1)
        target!(g, i, 1, i + 1)
    end
    target!(g, n, 1, 1)
    return g
end

# Linear chain of n nodes, out_degree 1: node i has its label-1 edge
# pointing to node (i + 1), for i in 1..n-1. Node n has no outgoing edge.
# Mirrors libsemigroups' `chain(n)` (used by test 009).
function _chain(n::Integer)
    g = WordGraph(n, 1)
    for i in 1:(n-1)
        target!(g, i, 1, i + 1)
    end
    return g
end

# Test 001 graph: 9 nodes, out_degree 3.
# C++ targets (0-based): {{1,2,UNDEF}, {}, {3,4,6}, {}, {UNDEF,5}, {},
#                         {UNDEF,7}, {8}, {}}
function _g_paths_001()
    g = WordGraph(9, 3)
    # node 1 (C++ 0): labels 1,2 -> nodes 2,3 (label 3 undefined)
    target!(g, 1, 1, 2)
    target!(g, 1, 2, 3)
    # node 3 (C++ 2): labels 1,2,3 -> 4,5,7
    target!(g, 3, 1, 4)
    target!(g, 3, 2, 5)
    target!(g, 3, 3, 7)
    # node 5 (C++ 4): label 1 undefined; label 2 -> 6
    target!(g, 5, 2, 6)
    # node 7 (C++ 6): label 1 undefined; label 2 -> 8
    target!(g, 7, 2, 8)
    # node 8 (C++ 7): label 1 -> 9
    target!(g, 8, 1, 9)
    return g
end

# Test 003 graph: 15 nodes, out_degree 2, edges {{1,2},{3,4},...,{13,14}}.
function _g_paths_003()
    g = WordGraph(15, 2)
    target!(g, 1, 1, 2);  target!(g, 1, 2, 3)
    target!(g, 2, 1, 4);  target!(g, 2, 2, 5)
    target!(g, 3, 1, 6);  target!(g, 3, 2, 7)
    target!(g, 4, 1, 8);  target!(g, 4, 2, 9)
    target!(g, 5, 1, 10); target!(g, 5, 2, 11)
    target!(g, 6, 1, 12); target!(g, 6, 2, 13)
    target!(g, 7, 1, 14); target!(g, 7, 2, 15)
    return g
end

# Test 007 graph: 6 nodes, out_degree 3.
# C++ targets (0-based): {{1,2,UNDEF}, {2,0,3}, {UNDEF,UNDEF,3}, {4},
#                         {UNDEF,5}, {3}}
function _g_paths_007()
    g = WordGraph(6, 3)
    target!(g, 1, 1, 2);  target!(g, 1, 2, 3)
    target!(g, 2, 1, 3);  target!(g, 2, 2, 1);  target!(g, 2, 3, 4)
    target!(g, 3, 3, 4)
    target!(g, 4, 1, 5)
    target!(g, 5, 2, 6)
    target!(g, 6, 1, 4)
    return g
end

# Test 009 small graph: 5 nodes, out_degree 2,
# C++ edges {{2,1}, {}, {3}, {4}, {2}}.
function _g_paths_009_small()
    g = WordGraph(5, 2)
    target!(g, 1, 1, 3);  target!(g, 1, 2, 2)
    target!(g, 3, 1, 4)
    target!(g, 4, 1, 5)
    target!(g, 5, 1, 3)
    return g
end

@testset verbose = true "Paths" begin

    # =======================================================================
    # Layer 1: binding-surface tests.
    # These hit LibSemigroups.PathsCxx directly to confirm the C++ glue is
    # wired up. They should pass immediately after the Task 1 commit, before
    # any high-level Julia wrapper exists.
    # =======================================================================

    @testset "Paths bindings" begin
        @test isdefined(LibSemigroups, :PathsCxx)
        # Constructor takes a WordGraph. CxxWrap-allocated types don't expose
        # constructors as `hasmethod`-discoverable on the type itself, so
        # smoke-test by actually calling the constructor.
        @test LibSemigroups.PathsCxx(WordGraph(3, 2)) isa LibSemigroups.PathsCxx

        # Validation
        @test hasmethod(LibSemigroups.throw_if_source_undefined,
                        Tuple{LibSemigroups.PathsCxx})

        # Range / iteration interface
        @test hasmethod(LibSemigroups.get, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"next!",
                        Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.at_end, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.count, Tuple{LibSemigroups.PathsCxx})

        # Settings: getter / setter pairs
        @test hasmethod(LibSemigroups.source, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"source!",
                        Tuple{LibSemigroups.PathsCxx,UInt32})
        @test hasmethod(LibSemigroups.target, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"target!",
                        Tuple{LibSemigroups.PathsCxx,UInt32})
        @test hasmethod(LibSemigroups.min, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"min!",
                        Tuple{LibSemigroups.PathsCxx,UInt})
        @test hasmethod(LibSemigroups.max, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"max!",
                        Tuple{LibSemigroups.PathsCxx,UInt})
        @test hasmethod(LibSemigroups.order, Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.var"order!",
                        Tuple{LibSemigroups.PathsCxx,LibSemigroups.Order})

        # Read-only queries
        @test hasmethod(LibSemigroups.current_target,
                        Tuple{LibSemigroups.PathsCxx})
        @test hasmethod(LibSemigroups.word_graph,
                        Tuple{LibSemigroups.PathsCxx})

        # Free function
        @test hasmethod(LibSemigroups.to_human_readable_repr,
                        Tuple{LibSemigroups.PathsCxx})
    end

    # =======================================================================
    # Layer 2: correctness tests ported from libsemigroups/tests/test-paths.cpp.
    # These exercise the high-level Julia API (paths(g; ...), count(p),
    # source!, etc.) which does NOT exist yet — these failures are the RED
    # signal that drives Task 3.
    #
    # All letter values, source nodes, and target nodes are translated to
    # 1-based; min / max (path lengths) are unchanged.
    # =======================================================================

    @testset "Paths correctness" begin

        @testset "Paths 000 / 100 node path" begin
            g = _linear_100()
            p = paths(g; source = 1, order = ORDER_LEX)
            @test count(p) == 100

            source!(p, 51)        # C++ source(50)
            @test count(p) == 50

            source!(p, 1)
            order!(p, ORDER_SHORTLEX)
            @test count(p) == 100

            source!(p, 51)
            @test count(p) == 50

            next!(p)
            @test count(p) == 49
            next!(p)
            @test count(p) == 48

            source!(p, 100)       # C++ source(99)
            @test count(p) == 1

            next!(p)
            @test count(p) == 0
            next!(p)
            @test count(p) == 0
        end

        @testset "Paths 001 / #1" begin
            g = _g_paths_001()

            # source=2 (C++) -> 3 (Julia); min=3; max=3; count=1
            p = paths(g; source = 3, min = 3, max = 3, order = ORDER_LEX)
            @test count(p) == 1
            # The unique path 210_w (C++ 0-based) -> [3, 2, 1] (1-based).
            @test Base.get(p) == [3, 2, 1]

            # source=0, min=0, max=0 -> Julia source=1
            p = paths(g; source = 1, min = 0, max = 0, order = ORDER_LEX)
            @test source(p) == 1
            @test target(p) === UNDEFINED
            @test Semigroups.min(p) == 0
            @test Base.max(p) == 0
            @test !at_end(p)
            @test count(p) == 1

            # min=0, max=1 -> count == 3 (empty + two single letters)
            min!(p, 0); max!(p, 1)
            @test count(p) == 3

            min!(p, 0); max!(p, 2)
            @test count(p) == 6

            min!(p, 0); max!(p, 3)
            @test count(p) == 8

            min!(p, 0); max!(p, 4)
            @test count(p) == 9

            min!(p, 0); max!(p, 10)
            @test count(p) == 9
        end

        @testset "Paths 002 / 100 node cycle" begin
            g = _cycle(100)
            p = paths(g; source = 1, max = 200, order = ORDER_LEX)
            @test Base.get(p) == Int[]
            @test count(p) == 201

            order!(p, ORDER_SHORTLEX)
            @test count(p) == 201
        end

        @testset "Paths 003 / #2" begin
            g = _g_paths_003()
            p = paths(g; source = 1, min = 0, max = 2, order = ORDER_LEX)
            @test count(p) == 7

            order!(p, ORDER_SHORTLEX)
            source!(p, 1); min!(p, 0); max!(p, 2)
            @test count(p) == 7
        end

        @testset "Paths 007 / #6 (POSITIVE_INFINITY round-trip)" begin
            g = _g_paths_007()
            p = paths(g; source = 1, min = 0, max = 9,
                      order = ORDER_SHORTLEX)
            @test count(p) == 75

            max!(p, POSITIVE_INFINITY)
            @test count(p) === POSITIVE_INFINITY

            max!(p, 9)
            @test count(p) == 75
        end

        @testset "Paths 009 / pstilo corner case" begin
            # Small 5-node graph with a single path.
            g = _g_paths_009_small()
            p = paths(g; source = 1, target = 2, order = ORDER_LEX)
            @test Base.get(p) == [2]
            next!(p)
            @test at_end(p)

            # Chain of 5: source==target=1 yields only the empty path.
            g = _chain(5)
            p = paths(g; source = 1, target = 1, min = 0, max = 100,
                      order = ORDER_LEX)
            @test count(p) == 1

            min!(p, 4)
            @test count(p) == 0

            # Cycle of 5: source==target, with various min/max bounds.
            g = _cycle(5)
            p = paths(g; source = 1, target = 1, min = 0, max = 6,
                      order = ORDER_LEX)
            @test count(p) == 2

            max!(p, 100)
            @test count(p) == 21

            min!(p, 4)
            @test count(p) == 20

            min!(p, 0); max!(p, 2)
            @test count(p) == 1
        end
    end

    # =======================================================================
    # Layer 3: high-level Julia API integration tests.
    # =======================================================================

    @testset "Paths Julia API" begin

        @testset "iteration traits" begin
            g = _g_paths_003()
            p = paths(g; source = 1, max = 5)
            @test Base.eltype(typeof(p)) === Vector{Int}
            @test Base.IteratorSize(typeof(p)) === Base.SizeUnknown()
        end

        @testset "collect returns 1-based letter vectors" begin
            g = _g_paths_003()
            p = paths(g; source = 1, target = 3, max = 5,
                      order = ORDER_SHORTLEX)
            words = collect(p)
            @test words isa Vector{Vector{Int}}
            # Every letter must be 1-based.
            for w in words
                for letter in w
                    @test letter >= 1
                end
            end
            # After collect, the underlying iterator is exhausted.
            @test at_end(p) === true
        end

        @testset "manual stepping with while !at_end" begin
            g = _g_paths_003()
            p = paths(g; source = 1, max = 2, order = ORDER_LEX)
            seen = Vector{Vector{Int}}()
            while !at_end(p)
                push!(seen, copy(Base.get(p)))
                next!(p)
            end
            @test length(seen) == 7
        end

        @testset "sentinel round-trips" begin
            g = _g_paths_003()
            @test source(Paths(g)) === UNDEFINED
            @test target(Paths(g)) === UNDEFINED

            p = paths(g; source = 1)
            @test Base.max(p) === POSITIVE_INFINITY
        end

        @testset "error paths" begin
            g = _g_paths_003()
            # Source undefined -> next! should throw.
            @test_throws LibsemigroupsError next!(Paths(g))
            # Out-of-bounds source.
            @test_throws LibsemigroupsError source!(Paths(g), 999)
            # Order other than shortlex/lex is rejected.
            @test_throws LibsemigroupsError order!(Paths(g), ORDER_RECURSIVE)
            # 1-based guard: zero is not a valid node.
            @test_throws InexactError source!(Paths(g), 0)
        end
    end

    # =======================================================================
    # GC stress test: confirms the wrapper struct's `g::WordGraph` field
    # keeps the WordGraph alive after it leaves the surrounding scope.
    # Without that pin, this case would crash.
    # =======================================================================

    @testset "Paths GC pin" begin
        function make_paths()
            g = WordGraph(5, 2)
            target!(g, 1, 1, 2)
            return Paths(g)        # `g` goes out of scope here.
        end

        p = make_paths()
        GC.gc()
        @test number_of_nodes(word_graph(p)) == 5
    end
end
