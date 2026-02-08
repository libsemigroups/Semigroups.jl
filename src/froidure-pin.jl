# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
froidure-pin.jl - High-level Julia API for FroidurePin

This file provides the user-facing `FroidurePin{E}` parametric type wrapping
the C++ FroidurePin<Element> template instantiations. All indices are 1-based
following Julia conventions.
"""

# ============================================================================
# Helper functions (private)
# ============================================================================

# Map from CxxWrap element type → FroidurePin constructor function
const _FP_CONSTRUCTOR_MAP = Dict{DataType,Any}(
    Transf1 => LibSemigroups.FroidurePinTransf1,
    Transf2 => LibSemigroups.FroidurePinTransf2,
    Transf4 => LibSemigroups.FroidurePinTransf4,
    PPerm1 => LibSemigroups.FroidurePinPPerm1,
    PPerm2 => LibSemigroups.FroidurePinPPerm2,
    PPerm4 => LibSemigroups.FroidurePinPPerm4,
    Perm1 => LibSemigroups.FroidurePinPerm1,
    Perm2 => LibSemigroups.FroidurePinPerm2,
    Perm4 => LibSemigroups.FroidurePinPerm4,
)

# Map Julia element type → CxxWrap FroidurePin constructor
function _cxx_fp_constructor(::Type{Transf{T}}) where {T}
    return _FP_CONSTRUCTOR_MAP[_transf_type_from_scalar_type(T)]
end

function _cxx_fp_constructor(::Type{PPerm{T}}) where {T}
    return _FP_CONSTRUCTOR_MAP[_pperm_type_from_scalar_type(T)]
end

function _cxx_fp_constructor(::Type{Perm{T}}) where {T}
    return _FP_CONSTRUCTOR_MAP[_perm_type_from_scalar_type(T)]
end

# Dispatch to 1/2/3/4-arg C++ constructors, or fallback for >4
function _construct_cxx_fp(Constructor, cxx_gens::Vector)
    n = length(cxx_gens)
    if n == 1
        return Constructor(cxx_gens[1])
    elseif n == 2
        return Constructor(cxx_gens[1], cxx_gens[2])
    elseif n == 3
        return Constructor(cxx_gens[1], cxx_gens[2], cxx_gens[3])
    elseif n == 4
        return Constructor(cxx_gens[1], cxx_gens[2], cxx_gens[3], cxx_gens[4])
    else
        # >4: construct with first, then add_generator! for rest
        fp = Constructor(cxx_gens[1])
        for i in 2:n
            LibSemigroups.add_generator!(fp, cxx_gens[i])
        end
        return fp
    end
end

# Wrap C++ element back to high-level Julia type.
# Uses Transf()/PPerm()/Perm() constructors which accept any CxxWrap variant
# (Allocated or Dereferenced). For Dereferenced elements (from C++ vectors),
# these constructors create owned copies via CxxWrap's implicit conversion.
_wrap_element(::Type{Transf{T}}, cxx_elem) where {T} = Transf(LibSemigroups.copy(cxx_elem))
_wrap_element(::Type{PPerm{T}}, cxx_elem) where {T} = PPerm(LibSemigroups.copy(cxx_elem))
_wrap_element(::Type{Perm{T}}, cxx_elem) where {T} = Perm(LibSemigroups.copy(cxx_elem))

# Word conversion (0-based C++ <-> 1-based Julia)
_to_word_1based(cxx_word) = [Int(w) + 1 for w in cxx_word]
_to_word_0based(word) = [UInt(w - 1) for w in word]

# Check if C++ returned UNDEFINED and convert to nothing (with +1 shift)
_maybe_undefined(val::UInt32) = is_undefined(val, UInt32) ? nothing : Int(val) + 1

# ============================================================================
# FroidurePin{E} type
# ============================================================================

"""
    FroidurePin{E}

A semigroup defined by generators of element type `E`, enumerated using the
Froidure-Pin algorithm. `E` is one of `Transf{T}`, `PPerm{T}`, or `Perm{T}`.

All indices are 1-based (Julia convention). The semigroup is lazily enumerated:
elements are computed on demand when queried.

# Construction
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))  # S3
S = FroidurePin([Transf([2, 1, 3]), Transf([2, 3, 1])])  # same, from vector
```
"""
mutable struct FroidurePin{E}
    cxx_obj::Any  # CxxWrap FroidurePinTransf1Allocated, etc.
end

# ============================================================================
# Constructors
# ============================================================================

"""
    FroidurePin(gens::AbstractVector{E}) where {E}

Construct a FroidurePin semigroup from a vector of generators.
Requires at least one generator.

# Example
```julia
S = FroidurePin([Transf([2, 1, 3]), Transf([2, 3, 1])])
```
"""
function FroidurePin(gens::AbstractVector{E}) where {E<:Union{Transf,PPerm,Perm}}
    isempty(gens) && throw(ArgumentError("at least one generator required"))
    Constructor = _cxx_fp_constructor(E)
    cxx_gens = [g.cxx_obj for g in gens]
    cxx_obj = _construct_cxx_fp(Constructor, cxx_gens)
    return FroidurePin{E}(cxx_obj)
end

"""
    FroidurePin(g1::E, gs::E...) where {E}

Construct a FroidurePin semigroup from one or more generators (varargs).

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
```
"""
FroidurePin(g1::E, gs::E...) where {E<:Union{Transf,PPerm,Perm}} =
    FroidurePin(collect(E, (g1, gs...)))

# ============================================================================
# Runner delegation
# ============================================================================

"""
    run!(S::FroidurePin) -> FroidurePin

Run the Froidure-Pin algorithm to completion. Returns `S` for method chaining.
"""
run!(S::FroidurePin) = (LibSemigroups.run!(S.cxx_obj); S)

"""
    run_for!(S::FroidurePin, t::TimePeriod) -> FroidurePin

Run the algorithm for at most duration `t`. Returns `S` for method chaining.
"""
run_for!(S::FroidurePin, t::TimePeriod) = (run_for!(S.cxx_obj, t); S)

"""
    finished(S::FroidurePin) -> Bool

Return `true` if the semigroup has been fully enumerated.
"""
finished(S::FroidurePin) = LibSemigroups.finished(S.cxx_obj)

"""
    started(S::FroidurePin) -> Bool

Return `true` if enumeration has been started.
"""
started(S::FroidurePin) = LibSemigroups.started(S.cxx_obj)

"""
    timed_out(S::FroidurePin) -> Bool

Return `true` if the last `run_for!` call timed out.
"""
timed_out(S::FroidurePin) = LibSemigroups.timed_out(S.cxx_obj)

# ============================================================================
# Size and degree
# ============================================================================

"""
    length(S::FroidurePin) -> Int

Return the number of elements in the semigroup. Triggers full enumeration.
"""
Base.length(S::FroidurePin) = Int(LibSemigroups.size(S.cxx_obj))

"""
    current_size(S::FroidurePin) -> Int

Return the number of elements enumerated so far (no further enumeration).
"""
current_size(S::FroidurePin) = Int(LibSemigroups.current_size(S.cxx_obj))

"""
    degree(S::FroidurePin) -> Int

Return the degree of the elements in the semigroup.
"""
degree(S::FroidurePin) = Int(LibSemigroups.degree(S.cxx_obj))

# ============================================================================
# Generators
# ============================================================================

"""
    number_of_generators(S::FroidurePin) -> Int

Return the number of generators of the semigroup.
"""
number_of_generators(S::FroidurePin) = Int(LibSemigroups.number_of_generators(S.cxx_obj))

"""
    generator(S::FroidurePin{E}, i::Integer) where E -> E

Return the `i`-th generator (1-based indexing).
"""
function generator(S::FroidurePin{E}, i::Integer) where {E}
    (i < 1 || i > number_of_generators(S)) && throw(BoundsError(S, i))
    return _wrap_element(E, LibSemigroups.generator(S.cxx_obj, UInt32(i - 1)))
end

"""
    generators(S::FroidurePin) -> Vector

Return a vector of all generators.
"""
generators(S::FroidurePin) = [generator(S, i) for i in 1:number_of_generators(S)]

# ============================================================================
# Collection protocol
# ============================================================================

"""
    getindex(S::FroidurePin{E}, i::Integer) where E -> E

Return the `i`-th element (1-based). Triggers full enumeration.
"""
function Base.getindex(S::FroidurePin{E}, i::Integer) where {E}
    (i < 1 || i > length(S)) && throw(BoundsError(S, i))
    return _wrap_element(E, LibSemigroups.at(S.cxx_obj, UInt32(i - 1)))
end

"""
    iterate(S::FroidurePin[, state]) -> Union{Tuple, Nothing}

Iterate over elements of the semigroup. Triggers full enumeration.
"""
function Base.iterate(S::FroidurePin, state = 1)
    state > length(S) && return nothing
    return (S[state], state + 1)
end

"""
    in(x::E, S::FroidurePin{E}) -> Bool

Return `true` if element `x` is in the semigroup `S`.
"""
Base.in(x::E, S::FroidurePin{E}) where {E<:Union{Transf,PPerm,Perm}} =
    LibSemigroups.contains_element(S.cxx_obj, x.cxx_obj)

"""
    eltype(::Type{FroidurePin{E}}) -> Type

Return the element type of the semigroup.
"""
Base.eltype(::Type{FroidurePin{E}}) where {E} = E

"""
    copy(S::FroidurePin{E}) -> FroidurePin{E}

Return an independent copy of the semigroup.
"""
Base.copy(S::FroidurePin{E}) where {E} = FroidurePin{E}(LibSemigroups.copy(S.cxx_obj))

# ============================================================================
# Display
# ============================================================================

function Base.show(io::IO, S::FroidurePin{E}) where {E}
    n = number_of_generators(S)
    if finished(S)
        print(io, "<FroidurePin with ", n, " generators, ", length(S), " elements>")
    elseif started(S)
        print(io, "<FroidurePin with ", n, " generators, ", current_size(S), "+ elements>")
    else
        print(io, "<FroidurePin with ", n, " generators, not yet enumerated>")
    end
end

# ============================================================================
# Position / membership
# ============================================================================

"""
    position(S::FroidurePin{E}, x::E) -> Union{Int, Nothing}

Return the 1-based position of `x` in `S`, or `nothing` if not found.
Triggers full enumeration.
"""
function position(S::FroidurePin{E}, x::E) where {E}
    pos = LibSemigroups.position_element(S.cxx_obj, x.cxx_obj)
    return _maybe_undefined(pos)
end

"""
    current_position(S::FroidurePin{E}, x::E) -> Union{Int, Nothing}

Return the 1-based position of `x` among elements enumerated so far,
or `nothing` if not yet found. Does not trigger further enumeration.
"""
function current_position(S::FroidurePin{E}, x::E) where {E}
    pos = LibSemigroups.current_position_element(S.cxx_obj, x.cxx_obj)
    return _maybe_undefined(pos)
end

"""
    sorted_position(S::FroidurePin{E}, x::E) -> Union{Int, Nothing}

Return the 1-based position of `x` in the sorted enumeration order,
or `nothing` if not found. Triggers full enumeration.
"""
function sorted_position(S::FroidurePin{E}, x::E) where {E}
    pos = LibSemigroups.sorted_position_element(S.cxx_obj, x.cxx_obj)
    return _maybe_undefined(pos)
end

"""
    sorted_at(S::FroidurePin{E}, i::Integer) -> E

Return the `i`-th element in sorted order (1-based). Triggers full enumeration.
"""
function sorted_at(S::FroidurePin{E}, i::Integer) where {E}
    (i < 1 || i > length(S)) && throw(BoundsError(S, i))
    return _wrap_element(E, LibSemigroups.sorted_at(S.cxx_obj, UInt32(i - 1)))
end

"""
    to_sorted_position(S::FroidurePin, i::Integer) -> Int

Convert a 1-based enumeration-order position to a 1-based sorted-order position.
"""
function to_sorted_position(S::FroidurePin, i::Integer)
    (i < 1 || i > length(S)) && throw(BoundsError(S, i))
    return Int(LibSemigroups.to_sorted_position(S.cxx_obj, UInt32(i - 1))) + 1
end

# ============================================================================
# Products
# ============================================================================

"""
    fast_product(S::FroidurePin, i::Integer, j::Integer) -> Int

Return the 1-based position of S[i] * S[j]. Both `i` and `j` are 1-based.
The semigroup must be fully enumerated.
"""
function fast_product(S::FroidurePin, i::Integer, j::Integer)
    return Int(LibSemigroups.fast_product(S.cxx_obj, UInt32(i - 1), UInt32(j - 1))) + 1
end

# ============================================================================
# Idempotents
# ============================================================================

"""
    number_of_idempotents(S::FroidurePin) -> Int

Return the number of idempotent elements. Triggers full enumeration.
"""
number_of_idempotents(S::FroidurePin) = Int(LibSemigroups.number_of_idempotents(S.cxx_obj))

"""
    is_idempotent(S::FroidurePin, i::Integer) -> Bool

Return `true` if the element at 1-based position `i` is idempotent.
"""
function is_idempotent(S::FroidurePin, i::Integer)
    (i < 1 || i > length(S)) && throw(BoundsError(S, i))
    return LibSemigroups.is_idempotent(S.cxx_obj, UInt32(i - 1))
end

"""
    idempotents(S::FroidurePin{E}) -> Vector{E}

Return a vector of all idempotent elements.
"""
function idempotents(S::FroidurePin{E}) where {E}
    cxx_vec = LibSemigroups.idempotents_vector(S.cxx_obj)
    return [_wrap_element(E, e) for e in cxx_vec]
end
