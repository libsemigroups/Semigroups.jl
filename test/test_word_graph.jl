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
end

@testset "WordGraph number_of_edges per node" begin
    g = WordGraph(3, 2)
    # No edges defined, so each node has 0 defined edges
    for i = 0:2
        @test number_of_edges(g, i) == 0
    end
end

@testset "WordGraph target on empty graph" begin
    g = WordGraph(3, 2)
    # All targets should be UNDEFINED
    for node = 0:2, label = 0:1
        t = Semigroups.target(g, node, label)
        @test is_undefined(t, UInt32)
    end
end

@testset "WordGraph targets vector" begin
    g = WordGraph(3, 2)
    # All targets from node 0 should be UNDEFINED
    ts = Semigroups.targets(g, 0)
    @test length(ts) == 2  # out_degree is 2
    for t in ts
        @test is_undefined(t, UInt32)
    end
end

@testset "WordGraph comparison" begin
    g1 = WordGraph(3, 2)
    g2 = WordGraph(3, 2)
    @test g1 == g2

    g3 = WordGraph(4, 2)
    @test g1 != g3
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
end

@testset "WordGraph method signatures" begin
    @test hasmethod(number_of_nodes, Tuple{WordGraph})
    @test hasmethod(out_degree, Tuple{WordGraph})
    @test hasmethod(number_of_edges, Tuple{WordGraph})
    @test hasmethod(number_of_edges, Tuple{WordGraph,Integer})
    @test hasmethod(Semigroups.target, Tuple{WordGraph,Integer,Integer})
    @test hasmethod(Semigroups.next_label_and_target, Tuple{WordGraph,Integer,Integer})
    @test hasmethod(Semigroups.targets, Tuple{WordGraph,Integer})
    @test hasmethod(copy, Tuple{WordGraph})
    @test hasmethod(hash, Tuple{WordGraph,UInt})
end
