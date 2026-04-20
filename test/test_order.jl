# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

using Test
using Semigroups

@testset verbose = true "Order" begin

    @testset "Order enum" begin
        @test ORDER_NONE !== ORDER_SHORTLEX
        @test ORDER_SHORTLEX !== ORDER_LEX
        @test ORDER_LEX !== ORDER_RECURSIVE
        @test ORDER_NONE isa Order
        @test ORDER_SHORTLEX isa Order
    end

    @testset "lex_less" begin
        @test lex_less(Int[], [1])
        @test !lex_less([1], Int[])
        @test lex_less([1, 2], [2])
        @test !lex_less([2], [1, 2])
        @test lex_less([1, 1], [1, 2])
        @test !lex_less([1, 2], [1, 2])
    end

    @testset "shortlex_less" begin
        @test shortlex_less([1], [1, 1])
        @test shortlex_less([2], [1, 1])
        @test !shortlex_less([1, 1], [2])
        @test shortlex_less([1, 1], [1, 2])
        @test !shortlex_less([1, 2], [1, 1])
        @test !shortlex_less([1, 2], [1, 2])
    end

    @testset "recursive_path_less" begin
        @test recursive_path_less([1], [2])
        @test !recursive_path_less([2], [1])
    end

    @testset "weighted_shortlex_less and weighted_lex_less" begin
        weights = [2, 1, 6, 3, 4]
        @test weighted_shortlex_less([1, 2], [3], weights)
        @test !weighted_shortlex_less([3], [1, 2], weights)
        @test weighted_lex_less([1], [3], weights)
    end
end
