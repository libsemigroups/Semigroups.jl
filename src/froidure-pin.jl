# Copyright (c) 2026, James W. Swent, J. D. Mitchell
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
froidure-pin.jl - FroidurePin{E} high-level Julia wrapper

Provides a parametric `FroidurePin{E}` type wrapping the CxxWrap-bound
C++ `FroidurePin<E>` template instantiations. Follows the same three-layer
pattern as `transf.jl`: CxxWrap type aliases, union type, private helpers,
mutable struct, constructors, and method wrappers.
"""

# ============================================================================
# CxxWrap type aliases — concrete FroidurePin<E> instantiations
# ============================================================================

const FroidurePinBase = LibSemigroups.FroidurePinBase

const FroidurePinTransf1 = LibSemigroups.FroidurePinTransf1
const FroidurePinTransf2 = LibSemigroups.FroidurePinTransf2
const FroidurePinTransf4 = LibSemigroups.FroidurePinTransf4

const FroidurePinPPerm1 = LibSemigroups.FroidurePinPPerm1
const FroidurePinPPerm2 = LibSemigroups.FroidurePinPPerm2
const FroidurePinPPerm4 = LibSemigroups.FroidurePinPPerm4

const FroidurePinPerm1 = LibSemigroups.FroidurePinPerm1
const FroidurePinPerm2 = LibSemigroups.FroidurePinPerm2
const FroidurePinPerm4 = LibSemigroups.FroidurePinPerm4

const FroidurePinBMat8 = LibSemigroups.FroidurePinBMat8

# ============================================================================
# Union type for cxx_obj field
# ============================================================================

const _FroidurePinCxx = Union{
    FroidurePinTransf1,
    FroidurePinTransf2,
    FroidurePinTransf4,
    FroidurePinPPerm1,
    FroidurePinPPerm2,
    FroidurePinPPerm4,
    FroidurePinPerm1,
    FroidurePinPerm2,
    FroidurePinPerm4,
    FroidurePinBMat8,
}

# ============================================================================
# Private helpers
# ============================================================================
# Index/word conversion helpers (_to_cpp, _from_cpp, _word_to_cpp,
# _word_from_cpp) are defined in word-graph.jl, transf.jl, and order.jl
# respectively. We reuse them here without redefinition.

# ============================================================================
# Type dispatch helpers
# ============================================================================

"""
    _cxx_fp_type(::Type{E}) -> Type

Map a high-level Julia element type to its CxxWrap FroidurePin constructor type.
"""
_cxx_fp_type(::Type{Transf{UInt8}}) = FroidurePinTransf1
_cxx_fp_type(::Type{Transf{UInt16}}) = FroidurePinTransf2
_cxx_fp_type(::Type{Transf{UInt32}}) = FroidurePinTransf4

_cxx_fp_type(::Type{PPerm{UInt8}}) = FroidurePinPPerm1
_cxx_fp_type(::Type{PPerm{UInt16}}) = FroidurePinPPerm2
_cxx_fp_type(::Type{PPerm{UInt32}}) = FroidurePinPPerm4

_cxx_fp_type(::Type{Perm{UInt8}}) = FroidurePinPerm1
_cxx_fp_type(::Type{Perm{UInt16}}) = FroidurePinPerm2
_cxx_fp_type(::Type{Perm{UInt32}}) = FroidurePinPerm4

_cxx_fp_type(::Type{T}) where {T<:BMat8} = FroidurePinBMat8

"""
    _wrap_element(::Type{E}, raw) -> E

Wrap a raw CxxWrap element back into the high-level Julia type.
"""
_wrap_element(::Type{Transf{T}}, raw) where {T} = Transf{T}(raw)
_wrap_element(::Type{PPerm{T}}, raw) where {T} = PPerm{T}(raw)
_wrap_element(::Type{Perm{T}}, raw) where {T} = Perm{T}(raw)
_wrap_element(::Type{T}, raw) where {T<:BMat8} = raw  # BMat8 is a direct alias

"""
    _cxx_element(x) -> CxxWrap object

Extract the CxxWrap object from a high-level Julia element.
"""
_cxx_element(x::Transf) = x.cxx_obj
_cxx_element(x::PPerm) = x.cxx_obj
_cxx_element(x::Perm) = x.cxx_obj
_cxx_element(x::BMat8) = x  # BMat8 is a direct alias

"""
    _fp_element_type(::Type{E}) -> Type

Normalize element type for the FroidurePin{E} type parameter.
CxxWrap creates BMat8Allocated as a subtype of BMat8; we normalize
to BMat8 so that FroidurePin{BMat8} is the canonical type.
"""
_fp_element_type(::Type{E}) where {E} = E
_fp_element_type(::Type{T}) where {T<:BMat8} = BMat8

# ============================================================================
# FroidurePin{E} mutable struct
# ============================================================================

"""
    FroidurePin{E}

A Froidure-Pin semigroup over elements of type `E`.

The Froidure-Pin algorithm is used to enumerate all elements of a finitely
generated semigroup. This type wraps the C++ `FroidurePin<E>` class from
libsemigroups.

Supported element types:
- `Transf{UInt8}`, `Transf{UInt16}`, `Transf{UInt32}` (transformations)
- `PPerm{UInt8}`, `PPerm{UInt16}`, `PPerm{UInt32}` (partial permutations)
- `Perm{UInt8}`, `Perm{UInt16}`, `Perm{UInt32}` (permutations)
- `BMat8` (boolean matrices up to 8x8)

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6 (S_3)
```
"""
mutable struct FroidurePin{E}
    cxx_obj::_FroidurePinCxx
end

# ============================================================================
# Constructors
# ============================================================================

"""
    FroidurePin(gens::Vector{E}) where {E}

Construct a `FroidurePin{E}` from a vector of generators.

# Example
```julia
using Semigroups

S = FroidurePin([Transf([2, 1, 3]), Transf([2, 3, 1])])
length(S)  # 6
```
"""
function FroidurePin(gens::Vector{E}) where {E}
    isempty(gens) && error("At least one generator is required")

    # Normalize element type (BMat8Allocated -> BMat8)
    NE = _fp_element_type(E)

    FPType = _cxx_fp_type(NE)
    cxx_gens = [_cxx_element(g) for g in gens]

    n = length(cxx_gens)
    if n == 1
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1])
    elseif n == 2
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1], cxx_gens[2])
    elseif n == 3
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1], cxx_gens[2], cxx_gens[3])
    elseif n == 4
        cxx_obj = @wrap_libsemigroups_call FPType(
            cxx_gens[1],
            cxx_gens[2],
            cxx_gens[3],
            cxx_gens[4],
        )
    else
        # >4 generators: construct with first, then add the rest
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1])
        for i in 2:n
            @wrap_libsemigroups_call LibSemigroups.add_generator!(cxx_obj, cxx_gens[i])
        end
    end

    return FroidurePin{NE}(cxx_obj)
end

"""
    FroidurePin(x::E, xs::E...) where {E}

Construct a `FroidurePin{E}` from one or more generators (variadic).

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6
```
"""
function FroidurePin(x::E, xs::E...) where {E}
    return FroidurePin(E[x, xs...])
end

# ============================================================================
# Size queries
# ============================================================================

"""
    Base.length(fp::FroidurePin) -> Int

Return the total number of elements in the semigroup.

Triggers full enumeration if not already complete.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6
```
"""
Base.length(fp::FroidurePin) = Int(LibSemigroups.size(fp.cxx_obj))

"""
    current_size(fp::FroidurePin) -> Int

Return the number of elements enumerated so far (without triggering
further enumeration).

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
current_size(S)  # 2 (only generators known)
```
"""
current_size(fp::FroidurePin) = Int(LibSemigroups.current_size(fp.cxx_obj))

"""
    degree(fp::FroidurePin) -> Int

Return the degree of the elements in the semigroup.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
degree(S)  # 3
```
"""
degree(fp::FroidurePin) = Int(LibSemigroups.degree(fp.cxx_obj))

"""
    number_of_generators(fp::FroidurePin) -> Int

Return the number of generators of the semigroup.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
number_of_generators(S)  # 2
```
"""
number_of_generators(fp::FroidurePin) = Int(LibSemigroups.number_of_generators(fp.cxx_obj))

"""
    enumerate!(fp::FroidurePin, limit::Integer)

Enumerate elements until at least `limit` elements have been found.

This partially enumerates the semigroup. After calling this, `current_size`
will be at least `min(limit, length(fp))`.
"""
function enumerate!(fp::FroidurePin, limit::Integer)
    @wrap_libsemigroups_call LibSemigroups.enumerate!(fp.cxx_obj, UInt(limit))
    return fp
end
