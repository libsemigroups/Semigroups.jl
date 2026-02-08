# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_froidure_pin.jl - Tests for FroidurePin<E> C++ bindings
"""

using CxxWrap.StdLib: StdVector

@testset "FroidurePin type registration" begin
    LS = Semigroups.LibSemigroups

    # All 9 types exist
    @test isdefined(LS, :FroidurePinTransf1)
    @test isdefined(LS, :FroidurePinTransf2)
    @test isdefined(LS, :FroidurePinTransf4)
    @test isdefined(LS, :FroidurePinPPerm1)
    @test isdefined(LS, :FroidurePinPPerm2)
    @test isdefined(LS, :FroidurePinPPerm4)
    @test isdefined(LS, :FroidurePinPerm1)
    @test isdefined(LS, :FroidurePinPerm2)
    @test isdefined(LS, :FroidurePinPerm4)

    # All inherit from FroidurePinBase
    @test LS.FroidurePinTransf1 <: FroidurePinBase
    @test LS.FroidurePinTransf2 <: FroidurePinBase
    @test LS.FroidurePinTransf4 <: FroidurePinBase
    @test LS.FroidurePinPPerm1 <: FroidurePinBase
    @test LS.FroidurePinPPerm2 <: FroidurePinBase
    @test LS.FroidurePinPPerm4 <: FroidurePinBase
    @test LS.FroidurePinPerm1 <: FroidurePinBase
    @test LS.FroidurePinPerm2 <: FroidurePinBase
    @test LS.FroidurePinPerm4 <: FroidurePinBase

    # Transitive inheritance from Runner
    @test LS.FroidurePinTransf1 <: Runner
    @test LS.FroidurePinPPerm1 <: Runner
    @test LS.FroidurePinPerm1 <: Runner
end

@testset "FroidurePin construction and enumeration (Transf)" begin
    LS = Semigroups.LibSemigroups

    # S3 = symmetric group on 3 letters (0-based images)
    # swap(0,1): [1, 0, 2]
    # cycle(0->1->2): [1, 2, 0]
    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))

    fp = LS.FroidurePinTransf1(t1, t2)

    @test !LS.finished(fp)
    LS.run!(fp)
    @test LS.finished(fp)
    @test LS.size(fp) == 6
    @test LS.number_of_generators(fp) == 2
    @test LS.degree(fp) == 3
end

@testset "FroidurePin element access" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)
    LS.run!(fp)

    # generator access (0-based)
    g0 = LS.generator(fp, UInt32(0))
    @test LS.is_equal(g0, t1)
    g1 = LS.generator(fp, UInt32(1))
    @test LS.is_equal(g1, t2)

    # at access (0-based)
    e0 = LS.at(fp, UInt32(0))
    @test LS.is_equal(e0, t1)

    # position_element round-trip
    pos = LS.position_element(fp, t1)
    @test pos == UInt32(0)

    pos2 = LS.position_element(fp, t2)
    @test pos2 == UInt32(1)

    # contains_element
    @test LS.contains_element(fp, t1)
    @test LS.contains_element(fp, t2)
end

@testset "FroidurePin idempotents" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)

    # S3 has exactly 1 idempotent (the identity)
    @test LS.number_of_idempotents(fp) == 1
end

@testset "FroidurePin fast_product" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)
    LS.run!(fp)

    # fast_product(i, j) returns position of fp[i] * fp[j]
    prod_pos = LS.fast_product(fp, UInt32(0), UInt32(1))
    @test prod_pos isa UInt32
    @test prod_pos < UInt32(LS.size(fp))
end

@testset "FroidurePin inherited FroidurePinBase methods" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)
    LS.run!(fp)

    # number_of_rules works via inheritance
    @test LS.number_of_rules(fp) > 0

    # Cayley graphs work via inheritance
    rg = LS.right_cayley_graph(fp)
    @test Semigroups.number_of_nodes(rg) == LS.size(fp)

    lg = LS.left_cayley_graph(fp)
    @test Semigroups.number_of_nodes(lg) == LS.size(fp)

    # contains_one works via inheritance
    @test LS.contains_one(fp)
end

@testset "FroidurePin with Perm" begin
    LS = Semigroups.LibSemigroups

    # S3 with Perm1
    p1 = LS.Perm1(StdVector{UInt8}(UInt8[1, 0, 2]))
    p2 = LS.Perm1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinPerm1(p1, p2)

    @test LS.size(fp) == 6
    @test LS.number_of_generators(fp) == 2
    @test LS.contains_one(fp)
end

@testset "FroidurePin with PPerm" begin
    LS = Semigroups.LibSemigroups

    # S3 as partial perms (total, so same as perms)
    pp1 = LS.PPerm1(StdVector{UInt8}(UInt8[1, 0, 2]))
    pp2 = LS.PPerm1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinPPerm1(pp1, pp2)

    @test LS.size(fp) == 6
    @test LS.number_of_generators(fp) == 2
end

@testset "FroidurePin elements_vector" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)

    elems = LS.elements_vector(fp)
    @test length(elems) == 6
end

@testset "FroidurePin copy" begin
    LS = Semigroups.LibSemigroups

    t1 = LS.Transf1(StdVector{UInt8}(UInt8[1, 0, 2]))
    t2 = LS.Transf1(StdVector{UInt8}(UInt8[1, 2, 0]))
    fp = LS.FroidurePinTransf1(t1, t2)
    LS.run!(fp)

    fp2 = LS.copy(fp)
    @test LS.size(fp2) == 6
    @test LS.finished(fp2)
end
