# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

using Test
using Semigroups

@testset verbose = true "WordRange" begin

    @testset "construction and basic accessors" begin
        r = WordRange()
        @test r isa WordRange
        @test alphabet_size(r) == 0
        @test order(r) isa Order      # default is shortlex upstream, but don't pin it
        @test at_end(r)                # empty by default
    end

    @testset "alphabet size and setters are chainable" begin
        r = WordRange()
        set_alphabet_size!(r, 2)
        set_min!(r, 1)
        set_max!(r, 5)
        @test alphabet_size(r) == 2
        @test count(r) == 30  # 2^1 + 2^2 + 2^3 + 2^4 = 30
    end

    @testset "shortlex enumeration" begin
        r = WordRange()
        set_alphabet_size!(r, 2)
        set_order!(r, ORDER_SHORTLEX)
        set_min!(r, 1)
        set_max!(r, 3)

        words = Vector{Int}[]
        while !at_end(r)
            push!(words, copy(get(r)))
            next!(r)
        end
        # 1-based alphabet: letters 1 and 2
        # length 1: [1], [2]
        # length 2: [1,1], [1,2], [2,1], [2,2]
        @test words == [[1], [2], [1, 1], [1, 2], [2, 1], [2, 2]]
    end

    @testset "shortlex enumeration with bookends" begin
        r = WordRange()
        set_alphabet_size!(r, 2)
        set_order!(r, ORDER_SHORTLEX)
        set_first!(r, [1])              # 0_w in C++
        set_last!(r, [1, 1, 1, 1])      # 0000_w in C++ (length 4 -> stops before length 4)
        # Shortlex over alphabet 2, words of length 1..3: 2 + 4 + 8 = 14.
        @test count(r) == 14
        @test first_word(r) == [1]
        @test last_word(r) == [1, 1, 1, 1]
    end

    @testset "iteration via Julia protocol" begin
        r = WordRange()
        set_alphabet_size!(r, 2)
        set_min!(r, 1)
        set_max!(r, 3)
        collected = collect(r)
        @test length(collected) == 6
        @test first(collected) == [1]
    end

    @testset "number_of_words free function" begin
        @test number_of_words(3, 1, 4) == 39
        @test number_of_words(2, 5, 6) == 32
    end

    @testset "random_word" begin
        w = random_word(5, 3)
        @test length(w) == 5
        @test all(1 <= l <= 3 for l in w)
    end
end
