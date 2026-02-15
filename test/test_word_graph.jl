# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_word_graph.jl - Tests for WordGraph bindings
"""

@testset "WordGraph type alias" begin
    @test WordGraph === Semigroups.LibSemigroups.WordGraph
end

@testset "WordGraph construction" begin
    g = WordGraph(5, 3)
    @test number_of_nodes(g) == 5
    @test out_degree(g) == 3
    @test number_of_edges(g) == 0  # no edges defined yet

    # Default: zero nodes, zero out-degree
    g0 = WordGraph(0, 0)
    @test number_of_nodes(g0) == 0
    @test out_degree(g0) == 0
    @test number_of_edges(g0) == 0

    # Edge case: single node, zero out-degree
    g1 = WordGraph(1, 0)
    @test number_of_nodes(g1) == 1
    @test out_degree(g1) == 0
    @test number_of_edges(g1) == 0

    # Edge case: zero nodes with nonzero out-degree
    g2 = WordGraph(0, 5)
    @test number_of_nodes(g2) == 0
    @test out_degree(g2) == 5
    @test number_of_edges(g2) == 0
end

@testset "WordGraph number_of_edges per node" begin
    g = WordGraph(3, 2)
    # No edges defined, so each node has 0 defined edges (1-based nodes)
    for i = 1:3
        @test number_of_edges(g, i) == 0
    end
end

@testset "WordGraph target on empty graph" begin
    g = WordGraph(3, 2)
    # All targets should be UNDEFINED (0 in 1-based convention)
    for node = 1:3, label = 1:2
        t = target(g, node, label)
        @test t == 0  # UNDEFINED
    end
end

@testset "WordGraph targets vector" begin
    g = WordGraph(3, 2)
    # All targets from node 1 should be UNDEFINED (0 in 1-based convention)
    ts = targets(g, 1)
    @test length(ts) == 2  # out_degree is 2
    for t in ts
        @test t == 0  # UNDEFINED
    end

    # Check all nodes
    for node = 1:3
        ts = targets(g, node)
        @test length(ts) == 2
        @test all(t -> t == 0, ts)
    end
end

@testset "WordGraph next_label_and_target on empty graph" begin
    g = WordGraph(3, 2)
    # No edges defined, so next_label_and_target should return (0, 0) = UNDEFINED
    for node = 1:3, label = 1:2
        lbl, tgt = next_label_and_target(g, node, label)
        @test lbl == 0  # UNDEFINED
        @test tgt == 0  # UNDEFINED
    end
end

@testset "WordGraph comparison" begin
    g1 = WordGraph(3, 2)
    g2 = WordGraph(3, 2)
    @test g1 == g2

    g3 = WordGraph(4, 2)
    @test g1 != g3

    # Ordering
    @test (g1 < g3) || (g3 < g1)  # different graphs have an ordering
end

@testset "WordGraph copy" begin
    g1 = WordGraph(3, 2)
    g2 = copy(g1)
    @test g1 == g2
end

@testset "WordGraph hash" begin
    g1 = WordGraph(3, 2)
    g2 = WordGraph(3, 2)
    @test hash(g1) == hash(g2)

    # Can be used in Sets
    s = Set([g1])
    @test g2 in s

    # Different graphs should (likely) have different hashes
    g3 = WordGraph(4, 2)
    @test hash(g1) != hash(g3)
end

@testset "WordGraph show" begin
    g = WordGraph(5, 3)
    @test sprint(show, g) == "WordGraph(5, 3) with 0 edges"

    g0 = WordGraph(0, 0)
    @test sprint(show, g0) == "WordGraph(0, 0) with 0 edges"
end

@testset "WordGraph method signatures" begin
    @test hasmethod(number_of_nodes, Tuple{WordGraph})
    @test hasmethod(out_degree, Tuple{WordGraph})
    @test hasmethod(number_of_edges, Tuple{WordGraph})
    @test hasmethod(number_of_edges, Tuple{WordGraph,Integer})
    @test hasmethod(target, Tuple{WordGraph,Integer,Integer})
    @test hasmethod(next_label_and_target, Tuple{WordGraph,Integer,Integer})
    @test hasmethod(targets, Tuple{WordGraph,Integer})
    @test hasmethod(copy, Tuple{WordGraph})
    @test hasmethod(hash, Tuple{WordGraph,UInt})
end
