# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
test_froidure_pin_temp.jl - FroidurePin binding-surface and integration tests

Section 1: Binding-surface tests against LibSemigroups.* directly.
           These should PASS because the C++ bindings are already wired up.

Section 2: High-level integration tests against FroidurePin{E}.
           These FAIL in the RED phase — the Julia wrapper doesn't exist yet.
"""

# ============================================================================
# Section 1: Binding-surface tests
# ============================================================================

@testset "FroidurePin binding surface" begin

    LS = Semigroups.LibSemigroups
    FPB = LS.FroidurePinBase

    # -----------------------------------------------------------------------
    # FroidurePinBase — existence of the type
    # -----------------------------------------------------------------------
    @testset "FroidurePinBase type exists" begin
        @test FPB isa DataType || FPB isa UnionAll
    end

    # -----------------------------------------------------------------------
    # FroidurePinBase — methods dispatching on the base type
    # -----------------------------------------------------------------------
    @testset "FroidurePinBase methods" begin
        # Size / enumeration
        @test hasmethod(LS.size, Tuple{FPB})
        @test hasmethod(LS.current_size, Tuple{FPB})
        @test hasmethod(LS.degree, Tuple{FPB})
        @test hasmethod(LS.number_of_generators, Tuple{FPB})

        # Settings
        @test hasmethod(LS.batch_size, Tuple{FPB})
        @test hasmethod(LS.set_batch_size!, Tuple{FPB, UInt})

        # Enumeration control
        @test hasmethod(LS.enumerate!, Tuple{FPB, UInt})

        # Rules
        @test hasmethod(LS.number_of_rules, Tuple{FPB})
        @test hasmethod(LS.current_number_of_rules, Tuple{FPB})
        @test hasmethod(LS.current_max_word_length, Tuple{FPB})

        # Identity checks
        @test hasmethod(LS.contains_one, Tuple{FPB})
        @test hasmethod(LS.currently_contains_one, Tuple{FPB})

        # Length distribution
        @test hasmethod(LS.number_of_elements_of_length, Tuple{FPB, UInt})
        @test hasmethod(LS.number_of_elements_of_length_range, Tuple{FPB, UInt, UInt})

        # Index queries — checked variants
        @test hasmethod(LS.prefix, Tuple{FPB, UInt32})
        @test hasmethod(LS.suffix, Tuple{FPB, UInt32})
        @test hasmethod(LS.first_letter, Tuple{FPB, UInt32})
        @test hasmethod(LS.final_letter, Tuple{FPB, UInt32})
        @test hasmethod(LS.current_length, Tuple{FPB, UInt32})
        @test hasmethod(LS.length, Tuple{FPB, UInt32})
        @test hasmethod(LS.position_of_generator, Tuple{FPB, UInt32})

        # Index queries — _no_checks variants
        @test hasmethod(LS.prefix_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.suffix_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.first_letter_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.final_letter_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.current_length_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.length_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.position_of_generator_no_checks, Tuple{FPB, UInt32})

        # Cayley graphs
        @test hasmethod(LS.right_cayley_graph, Tuple{FPB})
        @test hasmethod(LS.current_right_cayley_graph, Tuple{FPB})
        @test hasmethod(LS.left_cayley_graph, Tuple{FPB})
        @test hasmethod(LS.current_left_cayley_graph, Tuple{FPB})
    end

    # -----------------------------------------------------------------------
    # Module-level froidure_pin:: free functions (bound on FPB)
    # -----------------------------------------------------------------------
    @testset "froidure_pin free functions" begin
        @test hasmethod(LS.current_minimal_factorisation, Tuple{FPB, UInt32})
        @test hasmethod(LS.current_minimal_factorisation_no_checks, Tuple{FPB, UInt32})
        @test hasmethod(LS.minimal_factorisation, Tuple{FPB, UInt32})
        @test hasmethod(LS.factorisation, Tuple{FPB, UInt32})

        # Word-position queries (ArrayRef variants detected at runtime)
        @test isdefined(LS, :current_position)
        @test isdefined(LS, :position)
        @test isdefined(LS, :product_by_reduction)
        @test isdefined(LS, :product_by_reduction_no_checks)

        # Rules / normal forms
        @test isdefined(LS, :rules_lhs)
        @test isdefined(LS, :rules_rhs)
        @test isdefined(LS, :current_rules_lhs)
        @test isdefined(LS, :current_rules_rhs)
        @test isdefined(LS, :normal_forms)
        @test isdefined(LS, :current_normal_forms)
    end

    # -----------------------------------------------------------------------
    # FroidurePinTransf1 — representative element-typed type
    # -----------------------------------------------------------------------
    @testset "FroidurePinTransf1 type exists" begin
        @test isdefined(LS, :FroidurePinTransf1)
        FPT1 = LS.FroidurePinTransf1
        @test FPT1 isa DataType || FPT1 isa UnionAll
    end

    @testset "FroidurePinTransf1 element-typed methods" begin
        FPT1 = LS.FroidurePinTransf1
        T1   = LS.Transf1

        # Element access
        @test hasmethod(LS.at, Tuple{FPT1, UInt})
        @test hasmethod(LS.sorted_at, Tuple{FPT1, UInt})
        @test hasmethod(LS.sorted_at_no_checks, Tuple{FPT1, UInt})
        @test hasmethod(LS.generator, Tuple{FPT1, UInt})
        @test hasmethod(LS.generator_no_checks, Tuple{FPT1, UInt})

        # Containment / position
        @test hasmethod(LS.contains, Tuple{FPT1, T1})
        @test hasmethod(LS.position, Tuple{FPT1, T1})
        @test hasmethod(LS.current_position, Tuple{FPT1, T1})
        @test hasmethod(LS.sorted_position, Tuple{FPT1, T1})
        @test hasmethod(LS.to_sorted_position, Tuple{FPT1, UInt})

        # Fast product
        @test hasmethod(LS.fast_product, Tuple{FPT1, UInt, UInt})
        @test hasmethod(LS.fast_product_no_checks, Tuple{FPT1, UInt, UInt})

        # Idempotents
        @test hasmethod(LS.number_of_idempotents, Tuple{FPT1})
        @test hasmethod(LS.is_idempotent, Tuple{FPT1, UInt})
        @test hasmethod(LS.is_idempotent_no_checks, Tuple{FPT1, UInt})

        # Modification
        @test hasmethod(LS.add_generator!, Tuple{FPT1, T1})
        @test hasmethod(LS.add_generator_no_checks!, Tuple{FPT1, T1})
        @test hasmethod(LS.closure!, Tuple{FPT1, T1})
        @test hasmethod(LS.reserve!, Tuple{FPT1, UInt})

        # Display
        @test isdefined(LS, :to_human_readable_repr)

        # Materialized collections
        @test isdefined(LS, :idempotents)
        @test isdefined(LS, :sorted_elements)

        # Word-element conversion
        @test isdefined(LS, :to_element)
        @test isdefined(LS, :to_element_no_checks)
        @test isdefined(LS, :equal_to)
        @test isdefined(LS, :equal_to_no_checks)
    end

    # -----------------------------------------------------------------------
    # All 10 FroidurePin<E> concrete types exist
    # -----------------------------------------------------------------------
    @testset "All FroidurePin<E> concrete types defined" begin
        for sym in (:FroidurePinTransf1, :FroidurePinTransf2, :FroidurePinTransf4,
                    :FroidurePinPPerm1, :FroidurePinPPerm2, :FroidurePinPPerm4,
                    :FroidurePinPerm1,  :FroidurePinPerm2,  :FroidurePinPerm4,
                    :FroidurePinBMat8)
            @test isdefined(LS, sym)
        end
    end

    # -----------------------------------------------------------------------
    # Smoke-test: construct and run a real FroidurePin via LibSemigroups.*
    # directly (no high-level wrapper).  This exercises the constructor
    # lambdas and the size method across the C++ boundary.
    # -----------------------------------------------------------------------
    @testset "FroidurePinTransf1 smoke test (LibSemigroups.* direct)" begin
        # S₃ — symmetric group on 3 letters.
        # Use Transf (high-level wrapper) to build the generators, then extract
        # the raw C++ object (.cxx_obj) to pass to the CxxWrap constructor lambda.
        # Generators in 1-based Julia: (1 2) → [2,1,3], (1 2 3) → [2,3,1].
        g1 = Transf([2, 1, 3]).cxx_obj   # ::Transf1 (the CxxWrap type)
        g2 = Transf([2, 3, 1]).cxx_obj

        fp = LS.FroidurePinTransf1(g1, g2)
        @test LS.size(fp) == 6
        @test LS.number_of_generators(fp) == 2
        @test LS.degree(fp) == 3
    end

end  # @testset "FroidurePin binding surface"


# ============================================================================
# Section 2: High-level integration tests (RED — wrapper doesn't exist yet)
# ============================================================================

# ---------------------------------------------------------------------------
# Parametric helper: basic size/collect contract
# ---------------------------------------------------------------------------
function check_fp_basic(gens, expected_size)
    S = FroidurePin(gens...)
    @test length(S) == expected_size
    @test number_of_generators(S) == length(gens)
    elts = collect(S)
    @test length(elts) == expected_size
    @test length(unique(elts)) == expected_size
end

@testset "FroidurePin{E} high-level API" begin

    # -----------------------------------------------------------------------
    # Construction: type dispatch
    # -----------------------------------------------------------------------
    @testset "Construction and type" begin
        # S₃ from Transf generators
        g1 = Transf([2, 1, 3])   # (1 2) in 1-based
        g2 = Transf([2, 3, 1])   # (1 2 3) in 1-based
        S = FroidurePin(g1, g2)
        @test S isa FroidurePin{Transf{UInt8}}

        # PPerm generators
        p1 = PPerm([2, 1, 3])
        p2 = PPerm([1, 3, 2])
        Sp = FroidurePin(p1, p2)
        @test Sp isa FroidurePin{PPerm{UInt8}}

        # Perm generators
        q1 = Perm([2, 1, 3])
        q2 = Perm([2, 3, 1])
        Sq = FroidurePin(q1, q2)
        @test Sq isa FroidurePin{Perm{UInt8}}

        # BMat8 generators (2×2 blocks)
        b1 = BMat8([[0, 1], [1, 0]])
        b2 = BMat8([[1, 0], [1, 1]])
        Sb = FroidurePin(b1, b2)
        @test Sb isa FroidurePin{BMat8}
    end

    # -----------------------------------------------------------------------
    # S₃ — primary test case throughout
    # -----------------------------------------------------------------------
    @testset "S₃ — length and size" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test length(S) == 6
    end

    @testset "S₃ — check_fp_basic parametric helper" begin
        check_fp_basic([Transf([2, 1, 3]), Transf([2, 3, 1])], 6)
    end

    @testset "S₃ — iteration / collect" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        elts = collect(S)
        @test elts isa Vector{Transf{UInt8}}
        @test length(elts) == 6
        @test length(unique(elts)) == 6
    end

    @testset "S₃ — getindex (1-based)" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        # Valid access
        @test S[1] isa Transf{UInt8}
        @test S[6] isa Transf{UInt8}
        # Out-of-bounds (0-based is invalid)
        @test_throws BoundsError S[0]
        @test_throws BoundsError S[7]
    end

    @testset "S₃ — in / contains" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test Transf([2, 1, 3]) in S
        @test Transf([1, 2, 3]) in S   # identity is in S₃
        @test !(Transf([1, 1, 1]) in S)
    end

    @testset "S₃ — push! adds a generator" begin
        S = FroidurePin(Transf([2, 1, 3]))
        n_before = number_of_generators(S)
        push!(S, Transf([2, 3, 1]))
        @test number_of_generators(S) == n_before + 1
        # After adding the second generator the semigroup is S₃
        @test length(S) == 6
    end

    @testset "S₃ — rules" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        rs = rules(S)
        @test rs isa Vector{Pair{Vector{Int}, Vector{Int}}}
        # There must be at least one rule (|S₃| < |free monoid|)
        @test length(rs) > 0
        # Each lhs and rhs must be non-empty 1-based generator-index vectors
        for (lhs, rhs) in rs
            @test all(x -> 1 <= x <= 2, lhs)
            @test all(x -> 1 <= x <= 2, rhs)
        end
    end

    @testset "S₃ — minimal_factorisation (1-based)" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        # Position 1 is always a generator — its factorisation is a length-1 word
        w = minimal_factorisation(S, 1)
        @test w isa Vector{Int}
        @test length(w) == 1
        @test 1 <= w[1] <= 2
        # Out-of-bounds position
        @test_throws Exception minimal_factorisation(S, 0)
        @test_throws Exception minimal_factorisation(S, 7)
    end

    @testset "S₃ — Cayley graphs" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        rcg = right_cayley_graph(S)
        lcg = left_cayley_graph(S)
        # Should return something non-nothing (WordGraph or similar)
        @test rcg !== nothing
        @test lcg !== nothing
    end

    @testset "S₃ — Runner interface" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test !finished(S)  # not yet run
        run!(S)
        @test finished(S)
    end

    @testset "S₃ — idempotents" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        ids = idempotents(S)
        @test ids isa Vector{Transf{UInt8}}
        # Every element in `ids` must satisfy x*x == x
        for x in ids
            @test x * x == x
        end
        # S₃ has exactly 1 idempotent (the identity)
        @test length(ids) == 1
    end

    @testset "S₃ — sorted_elements" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        se = sorted_elements(S)
        @test se isa Vector{Transf{UInt8}}
        @test length(se) == 6
        # Sorted means weakly increasing
        for i in 2:length(se)
            @test !(se[i] < se[i-1])
        end
    end

    @testset "S₃ — number_of_generators" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test number_of_generators(S) == 2
    end

    # -----------------------------------------------------------------------
    # Multiple element types: PPerm
    # -----------------------------------------------------------------------
    @testset "PPerm generators" begin
        # Symmetric inverse monoid on 2 points: pperm([2,1]) and pperm([], [], 2)
        p1 = PPerm([2, 1])
        p2 = PPerm(Int[], Int[], 2)
        S = FroidurePin(p1, p2)
        @test S isa FroidurePin{PPerm{UInt8}}
        elts = collect(S)
        @test length(elts) > 0
        for x in elts
            @test x isa PPerm{UInt8}
        end
    end

    # -----------------------------------------------------------------------
    # Multiple element types: Perm
    # -----------------------------------------------------------------------
    @testset "Perm generators — S₃" begin
        q1 = Perm([2, 1, 3])
        q2 = Perm([2, 3, 1])
        S = FroidurePin(q1, q2)
        @test S isa FroidurePin{Perm{UInt8}}
        @test length(S) == 6
        elts = collect(S)
        @test all(x -> x isa Perm{UInt8}, elts)
    end

    # -----------------------------------------------------------------------
    # Multiple element types: BMat8
    # -----------------------------------------------------------------------
    @testset "BMat8 generators" begin
        # Small semigroup: 2 boolean 2×2 matrices
        b1 = BMat8([[0, 1], [1, 0]])
        b2 = BMat8([[1, 0], [1, 1]])
        S = FroidurePin(b1, b2)
        @test S isa FroidurePin{BMat8}
        @test length(S) > 0
        elts = collect(S)
        @test all(x -> x isa BMat8, elts)
    end

    # -----------------------------------------------------------------------
    # Larger example: 5-generator transformation semigroup of degree 6
    # Reference: U from test-froidure-pin-transf.cpp test 049 → size 7776
    # -----------------------------------------------------------------------
    @testset "5-generator Transf degree-6 semigroup" begin
        gens = [
            Transf([1, 2, 3, 4, 5, 6]),
            Transf([2, 1, 3, 4, 5, 6]),
            Transf([5, 1, 2, 3, 4, 6]),
            Transf([6, 2, 3, 4, 5, 6]),
            Transf([2, 2, 3, 4, 5, 6]),
        ]
        check_fp_basic(gens, 7776)
    end

    # -----------------------------------------------------------------------
    # current_size: before full enumeration
    # -----------------------------------------------------------------------
    @testset "current_size before enumerate" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        # Without enumerating, current_size == number of generators
        @test current_size(S) == 2
        # After enumerate!, current_size == full size
        enumerate!(S, 100)
        @test current_size(S) == 6
    end

    # -----------------------------------------------------------------------
    # degree
    # -----------------------------------------------------------------------
    @testset "degree" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        @test degree(S) == 3
    end

    # -----------------------------------------------------------------------
    # fast_product
    # -----------------------------------------------------------------------
    @testset "fast_product (0-based internally, 1-based Julia)" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        # Ensure the semigroup is fully enumerated
        run!(S)
        # product of element 1 and element 2 (1-based) must be in [1, 6]
        idx = fast_product(S, 1, 2)
        @test 1 <= idx <= 6
    end

    # -----------------------------------------------------------------------
    # is_idempotent (1-based position)
    # -----------------------------------------------------------------------
    @testset "is_idempotent (1-based)" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        run!(S)
        for i in 1:length(S)
            x = S[i]
            @test is_idempotent(S, i) == (x * x == x)
        end
    end

    # -----------------------------------------------------------------------
    # to_element: word → element round-trip
    # -----------------------------------------------------------------------
    @testset "to_element word round-trip" begin
        S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
        run!(S)
        # Generator 1 (1-based) is S[1] or S[position_of_generator(S,1)]
        w = [1]   # word consisting of first generator
        x = to_element(S, w)
        @test x isa Transf{UInt8}
        # Factorising x should give back a word whose product = x
        wf = minimal_factorisation(S, Semigroups.position(S, x))
        @test to_element(S, wf) == x
    end

end  # @testset "FroidurePin{E} high-level API"
