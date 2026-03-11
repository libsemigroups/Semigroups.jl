# Copyright (c) 2026, James D. Mitchell
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_forest.jl - Tests for Forest bindings
"""

using Test
using Semigroups

@testset verbose = true "Forest" begin
    @testset "Forest type and method definitions" begin
        @test Forest === Semigroups.LibSemigroups.Forest

        @test hasmethod(Forest, Tuple{})
        @test hasmethod(Forest, Tuple{Int64})
        @test hasmethod(Forest, Tuple{Vector{Any},Vector{Any}})

        @test hasmethod(empty, Tuple{Forest})
        @test hasmethod(add_nodes!, Tuple{Forest,Int64})
        @test hasmethod(init!, Tuple{Forest})
        @test hasmethod(init!, Tuple{Forest,Int64})
        @test hasmethod(label, Tuple{Forest,Int64})
        @test hasmethod(labels, Tuple{Forest})
        @test hasmethod(number_of_nodes, Tuple{Forest})
        @test hasmethod(parent_node, Tuple{Forest,Int64})
        @test hasmethod(parents, Tuple{Forest})
        @test hasmethod(depth, Tuple{Forest,Integer})
        @test hasmethod(is_forest, Tuple{Forest})
        @test hasmethod(is_root, Tuple{Forest,Integer})
        @test hasmethod(max_label, Tuple{Forest})
        @test hasmethod(path_from_root, Tuple{Forest,Integer})
        @test hasmethod(path_to_root, Tuple{Forest,Integer})
        @test hasmethod(
            set_parent_and_label!,
            Tuple{Forest,Int64,Int64OrUndefined,Int64OrUndefined},
        )
    end

    @testset "Forest constructors and size operations" begin
        f0 = Forest()
        @test number_of_nodes(f0) == 0
        @test empty(f0)

        f = Forest(3)
        @test number_of_nodes(f) == 3
        @test !empty(f)

        add_nodes!(f, 2)
        @test number_of_nodes(f) == 5
        @test parents(f) == [UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED]
        @test labels(f) == [UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED]

        init!(f, 1)
        @test number_of_nodes(f) == 1
        @test !empty(f)
        @test parents(f) == [UNDEFINED]
        @test labels(f) == [UNDEFINED]

        init!(f)
        @test number_of_nodes(f) == 0
        @test empty(f)
    end

    @testset "Forest parent/label operations" begin
        f = Forest(4)

        @test parent_node(f, 1) === UNDEFINED
        @test parent_node(f, 2) === UNDEFINED
        @test parent_node(f, 3) === UNDEFINED
        @test parent_node(f, 4) === UNDEFINED
        @test label(f, 1) === UNDEFINED
        @test label(f, 2) === UNDEFINED
        @test label(f, 3) === UNDEFINED
        @test label(f, 4) === UNDEFINED

        set_parent_and_label!(f, 2, 1, 7)
        set_parent_and_label!(f, 3, 2, 8)

        @test parent_node(f, 2) == 1
        @test parent_node(f, 3) == 2
        @test label(f, 2) == 7
        @test label(f, 3) == 8
        @test parents(f) == [UNDEFINED, 1, 2, UNDEFINED]
        @test labels(f) == [UNDEFINED, 7, 8, UNDEFINED]
    end

    @testset "Forest constructor from vectors" begin
        expected_parents = [UNDEFINED, 1, 2, UNDEFINED]
        expected_labels = [UNDEFINED, 7, 8, UNDEFINED]

        f = Forest(expected_parents, expected_labels)
        @test number_of_nodes(f) == 4
        @test parents(f) == expected_parents
        @test labels(f) == expected_labels

        @test parent_node(f, 1) === UNDEFINED
        @test parent_node(f, 2) == 1
        @test parent_node(f, 3) == 2
        @test parent_node(f, 4) === UNDEFINED
        @test label(f, 1) === UNDEFINED
        @test label(f, 2) == 7
        @test label(f, 3) == 8
        @test label(f, 4) === UNDEFINED

        @test_throws LibsemigroupsError Forest([1], [1])
        @test_throws LibsemigroupsError Forest([2, 1], [1, 1])
        @test_throws LibsemigroupsError Forest([2, 1], [1])
        @test_throws LibsemigroupsError Forest([UNDEFINED, 2, 1], [UNDEFINED, 1, 1])
    end

    @testset "Forest error behavior" begin
        f = Forest(3)

        @test_throws LibsemigroupsError parent_node(f, 4)
        @test_throws LibsemigroupsError label(f, 4)
        @test_throws LibsemigroupsError set_parent_and_label!(f, 4, 1, 1)
        @test_throws LibsemigroupsError set_parent_and_label!(f, 1, 4, 1)
        @test_throws LibsemigroupsError set_parent_and_label!(f, 1, 1, 1)

        set_parent_and_label!(f, 2, 1, 1)
        @test_throws LibsemigroupsError set_parent_and_label!(f, 1, 2, 1)
    end

    @testset "Forest depth/root/path helpers" begin
        f = Forest(5)
        @test is_forest(f)
        @test max_label(f) === UNDEFINED

        set_parent_and_label!(f, 2, 1, 7)
        set_parent_and_label!(f, 3, 2, 8)
        set_parent_and_label!(f, 5, 4, 9)

        @test depth(f, 1) == 0
        @test depth(f, 2) == 1
        @test depth(f, 3) == 2

        @test is_root(f, 1)
        @test !is_root(f, 2)
        @test is_root(f, 4)
        @test !is_root(f, 5)

        @test max_label(f) == 9

        @test path_from_root(f, 1) == Int64[]
        @test path_from_root(f, 3) == [7, 8]
        @test path_to_root(f, 3) == [8, 7]
        @test path_from_root(f, 5) == [9]
        @test path_to_root(f, 5) == [9]

        @test_throws LibsemigroupsError depth(f, 6)
        @test_throws LibsemigroupsError is_root(f, 6)
        @test_throws LibsemigroupsError path_from_root(f, 6)
        @test_throws LibsemigroupsError path_to_root(f, 6)
    end
end
