# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

using Test
using Semigroups

@testset verbose = true "WordGraph" begin

    @testset "bindings exist" begin
        @test hasmethod(WordGraph, Tuple{Integer,Integer})
        @test hasmethod(number_of_nodes, Tuple{WordGraph})
        @test hasmethod(out_degree, Tuple{WordGraph})
        @test hasmethod(target, Tuple{WordGraph,Integer,Integer})
        @test hasmethod(target!, Tuple{WordGraph,Integer,Integer,Integer})
        @test hasmethod(target!, Tuple{WordGraph,Integer,Integer,Semigroups.UndefinedType})
        @test hasmethod(add_nodes!, Tuple{WordGraph,Integer})
    end

    @testset "construction" begin
        g = WordGraph(3, 2)
        @test number_of_nodes(g) == 3
        @test out_degree(g) == 2
        for s = 1:3, a = 1:2
            @test is_undefined(target(g, s, a))
        end

        add_nodes!(g, 2)
        @test number_of_nodes(g) == 5
    end

    @testset "edge round-trip" begin
        g = WordGraph(3, 1)
        target!(g, 1, 1, 2)
        target!(g, 2, 1, 3)
        target!(g, 3, 1, 1)

        @test target(g, 1, 1) == 2
        @test target(g, 2, 1) == 3
        @test target(g, 3, 1) == 1
    end

    @testset "bounds errors" begin
        g = WordGraph(2, 2)
        @test_throws LibsemigroupsError target(g, 99, 1)
        @test_throws LibsemigroupsError target!(g, 1, 1, 99)
    end

    @testset "index conversion" begin
        # --- Boundary: first 1-based index maps to C++ 0 ---
        g = WordGraph(3, 2)
        target!(g, 1, 1, 1)
        @test target(g, 1, 1) == 1

        # --- Boundary: last valid index ---
        target!(g, 3, 2, 3)
        @test target(g, 3, 2) == 3

        # --- All (source, label) slots are distinct ---
        g2 = WordGraph(4, 3)
        expected(s, a) = ((s + a) % 4) + 1
        for s = 1:4, a = 1:3
            target!(g2, s, a, expected(s, a))
        end
        for s = 1:4, a = 1:3
            @test target(g2, s, a) == expected(s, a)
        end

        # --- Source, label, target are not crosswired ---
        g3 = WordGraph(3, 3)
        target!(g3, 1, 2, 3)
        @test target(g3, 1, 2) == 3
        @test is_undefined(target(g3, 2, 1))
        @test is_undefined(target(g3, 3, 1))

        # --- Return type: UNDEFINED is the singleton, not typemax ---
        g4 = WordGraph(2, 1)
        r = target(g4, 1, 1)
        @test r === UNDEFINED
        @test is_undefined(r)
        @test !(r isa Integer)

        # --- UNDEFINED round-trip at a boundary slot ---
        target!(g4, 1, 1, 2)
        @test target(g4, 1, 1) == 2
        target!(g4, 1, 1, UNDEFINED)
        @test is_undefined(target(g4, 1, 1))

        # --- Invalid input rejected before reaching C++ ---
        @test_throws InexactError target(g4, 0, 1)
        @test_throws InexactError target(g4, 1, 0)
        @test_throws InexactError target!(g4, 0, 1, 1)
        @test_throws InexactError target!(g4, 1, 1, -1)

        # --- add_nodes! preserves existing edges (no index shifting) ---
        g5 = WordGraph(2, 1)
        target!(g5, 1, 1, 2)
        add_nodes!(g5, 3)
        @test number_of_nodes(g5) == 5
        @test target(g5, 1, 1) == 2
        @test is_undefined(target(g5, 3, 1))
        @test is_undefined(target(g5, 5, 1))
    end

end
