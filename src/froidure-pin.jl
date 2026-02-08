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

# Wrap C++ element back to high-level Julia type
_wrap_element(::Type{Transf{T}}, cxx_elem) where {T} = Transf{T}(cxx_elem)
_wrap_element(::Type{PPerm{T}}, cxx_elem) where {T} = PPerm{T}(cxx_elem)
_wrap_element(::Type{Perm{T}}, cxx_elem) where {T} = Perm{T}(cxx_elem)

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
