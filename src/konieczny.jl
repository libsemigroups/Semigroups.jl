# Copyright (c) 2026, James Sullivan
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
konieczny.jl - Konieczny{E} high-level Julia wrapper

Provides a parametric `Konieczny{E}` type wrapping the CxxWrap-bound C++
`Konieczny<E>` template instantiations, and a `KoniecznyDClass{E}` handle
for the D-classes it computes. Follows the same pattern as
`froidure-pin.jl`: CxxWrap type aliases, union type, type dispatch helpers,
mutable struct, constructors, and method wrappers. The element helpers
`_cxx_element`, `_wrap_element` and `_fp_element_type` are reused from
`froidure-pin.jl`, which must be included before this file.
"""

# ============================================================================
# CxxWrap type aliases — concrete Konieczny<E> instantiations
# ============================================================================

const KoniecznyTransf1 = LibSemigroups.KoniecznyTransf1
const KoniecznyTransf2 = LibSemigroups.KoniecznyTransf2
const KoniecznyTransf4 = LibSemigroups.KoniecznyTransf4

const KoniecznyPPerm1 = LibSemigroups.KoniecznyPPerm1
const KoniecznyPPerm2 = LibSemigroups.KoniecznyPPerm2
const KoniecznyPPerm4 = LibSemigroups.KoniecznyPPerm4

const KoniecznyBMat8 = LibSemigroups.KoniecznyBMat8

# ============================================================================
# Union types for cxx_obj fields
# ============================================================================

const _KoniecznyCxx = Union{
    KoniecznyTransf1,
    KoniecznyTransf2,
    KoniecznyTransf4,
    KoniecznyPPerm1,
    KoniecznyPPerm2,
    KoniecznyPPerm4,
    KoniecznyBMat8,
}

# The C++ side returns D-classes as non-owning references (DClass&), which
# CxxWrap surfaces as CxxRef{<DClass type>} rather than as the type itself.
const _KoniecznyDClassCxx = Union{
    CxxWrap.CxxRef{LibSemigroups.KoniecznyTransf1DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyTransf2DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyTransf4DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyPPerm1DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyPPerm2DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyPPerm4DClass},
    CxxWrap.CxxRef{LibSemigroups.KoniecznyBMat8DClass},
}

# ============================================================================
# Type dispatch helpers
# ============================================================================

"""
    _cxx_konieczny_type(::Type{E}) -> Type

Map a high-level Julia element type to its CxxWrap Konieczny constructor type.
"""
_cxx_konieczny_type(::Type{Transf{UInt8}}) = KoniecznyTransf1
_cxx_konieczny_type(::Type{Transf{UInt16}}) = KoniecznyTransf2
_cxx_konieczny_type(::Type{Transf{UInt32}}) = KoniecznyTransf4

_cxx_konieczny_type(::Type{PPerm{UInt8}}) = KoniecznyPPerm1
_cxx_konieczny_type(::Type{PPerm{UInt16}}) = KoniecznyPPerm2
_cxx_konieczny_type(::Type{PPerm{UInt32}}) = KoniecznyPPerm4

_cxx_konieczny_type(::Type{T}) where {T<:BMat8} = KoniecznyBMat8

# Convert a 1-based Julia index to a 0-based C++ index via the shared
# `_to_cpp` helper (transf.jl). The lower bound is checked here, with a
# readable error, since `_to_cpp(0, UInt)` would raise an InexactError; the
# upper bound is checked on the C++ side, which throws a LibsemigroupsError.
function _konieczny_index(i::Integer)
    i >= 1 || throw(ArgumentError("expected a positive index, got $i"))
    return _to_cpp(i, UInt)
end

# ============================================================================
# Konieczny{E} mutable struct
# ============================================================================

"""
    Konieczny{E}

Type implementing Konieczny's algorithm for computing the Green's structure
of a finite semigroup.

A `Konieczny{E}` instance is defined by a generating set of elements of
type `E`. The main function is [`run!`](@ref), which implements a
generalisation of the algorithms described in *Green's equivalences in
finite semigroups of binary relations* by Konieczny.

`Konieczny{E}` is a subtype of [`Runner`](@ref Semigroups.Runner), so all
runner methods ([`run!`](@ref), [`run_for!`](@ref), [`finished`](@ref),
etc.) are available.

Supported element types:
- [`Transf{UInt8}`](@ref Semigroups.Transf), [`Transf{UInt16}`](@ref Semigroups.Transf), [`Transf{UInt32}`](@ref Semigroups.Transf) (transformations)
- [`PPerm{UInt8}`](@ref Semigroups.PPerm), [`PPerm{UInt16}`](@ref Semigroups.PPerm), [`PPerm{UInt32}`](@ref Semigroups.PPerm) (partial permutations)
- [`BMat8`](@ref Semigroups.BMat8) (boolean matrices up to 8x8)

# Example
```julia
using Semigroups

K = Konieczny(Transf([2, 1, 3, 4]), Transf([2, 3, 4, 1]), Transf([1, 1, 3, 4]))
length(K)                # 256 (full transformation monoid T_4)
number_of_D_classes(K)   # 4
number_of_idempotents(K) # 41
```

# See also
- [`KoniecznyDClass`](@ref Semigroups.KoniecznyDClass)
- [`FroidurePin`](@ref Semigroups.FroidurePin)
- [`Runner`](@ref Semigroups.Runner)
"""
mutable struct Konieczny{E}
    cxx_obj::_KoniecznyCxx
end

"""
    KoniecznyDClass{E}

A handle to a D-class computed by a [`Konieczny{E}`](@ref Semigroups.Konieczny)
instance.

Objects of this type are never constructed directly; they are returned by
[`D_class_of_element`](@ref), [`D_class`](@ref), [`regular_D_class`](@ref),
[`D_classes`](@ref) and [`regular_D_classes`](@ref). The underlying C++
object is owned by the parent `Konieczny{E}`, and the handle keeps a
reference to its parent so that the parent cannot be garbage collected
while the handle is in use.

# Example
```julia
using Semigroups

K = Konieczny(Transf([2, 1, 3, 4]), Transf([2, 3, 4, 1]), Transf([1, 1, 3, 4]))
D = D_class_of_element(K, Transf([1, 2, 3, 4]))
length(D)             # 24 (the symmetric group S_4)
is_regular_D_class(D) # true
```

# See also
- [`Konieczny`](@ref Semigroups.Konieczny)
"""
struct KoniecznyDClass{E}
    cxx_obj::_KoniecznyDClassCxx
    parent::Konieczny{E}
end

# ============================================================================
# Constructors
# ============================================================================

"""
    Konieczny(gens::Vector{E}) where {E}

Construct a [`Konieczny{E}`](@ref Semigroups.Konieczny) from a container
of generators.

# Arguments
- `gens::Vector{E}`: a non-empty vector of generators. All generators
  must have the same degree.

# Throws
- `ErrorException`: if `gens` is empty.
- `LibsemigroupsError`: if `degree(x) != degree(y)` for any `x` and `y`
  in `gens`.

# Example
```julia
using Semigroups

K = Konieczny([Transf([2, 1, 3]), Transf([2, 3, 1])])
length(K)  # 6
```

# See also
- [`Konieczny(x::E, xs::E...)`](@ref Semigroups.Konieczny)
"""
function Konieczny(gens::Vector{E}) where {E}
    isempty(gens) && error("At least one generator is required")

    # Normalize element type (BMat8Allocated -> BMat8)
    NE = _fp_element_type(E)

    KType = _cxx_konieczny_type(NE)
    cxx_gens = [_cxx_element(g) for g in gens]

    n = length(cxx_gens)
    if n == 1
        cxx_obj = @wrap_libsemigroups_call KType(cxx_gens[1])
    elseif n == 2
        cxx_obj = @wrap_libsemigroups_call KType(cxx_gens[1], cxx_gens[2])
    elseif n == 3
        cxx_obj = @wrap_libsemigroups_call KType(cxx_gens[1], cxx_gens[2], cxx_gens[3])
    elseif n == 4
        cxx_obj = @wrap_libsemigroups_call KType(
            cxx_gens[1],
            cxx_gens[2],
            cxx_gens[3],
            cxx_gens[4],
        )
    else
        # >4 generators: construct with first, then add the rest
        cxx_obj = @wrap_libsemigroups_call KType(cxx_gens[1])
        for i = 2:n
            @wrap_libsemigroups_call LibSemigroups.add_generator!(cxx_obj, cxx_gens[i])
        end
    end

    return Konieczny{NE}(cxx_obj)
end

"""
    Konieczny(x::E, xs::E...) where {E}

Construct a [`Konieczny{E}`](@ref Semigroups.Konieczny) from one or more
generators given as positional arguments. Equivalent to
`Konieczny(E[x, xs...])`.

# Arguments
- `x::E`: the first generator.
- `xs::E...`: zero or more additional generators of the same type.

# Throws
- `LibsemigroupsError`: if `degree(x) != degree(y)` for any generators
  `x` and `y`.

# Example
```julia
using Semigroups

K = Konieczny(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(K)  # 6
```

# See also
- [`Konieczny(gens::Vector{E})`](@ref Semigroups.Konieczny)
"""
function Konieczny(x::E, xs::E...) where {E}
    return Konieczny(E[x, xs...])
end

# ============================================================================
# Generators
# ============================================================================

"""
    add_generator!(k::Konieczny{E}, x::E) -> Konieczny{E}

Add a generator to `k`. Returns `k` for method chaining.

# Throws
- `LibsemigroupsError`: if `degree(x) != degree(k)`, or if `k` has already
  started running.
"""
function add_generator!(k::Konieczny{E}, x::E) where {E}
    @wrap_libsemigroups_call LibSemigroups.add_generator!(k.cxx_obj, _cxx_element(x))
    return k
end

function add_generator!(k::Konieczny{BMat8}, x::BMat8)
    @wrap_libsemigroups_call LibSemigroups.add_generator!(k.cxx_obj, _cxx_element(x))
    return k
end

"""
    number_of_generators(k::Konieczny) -> Int

Return the number of generators of `k`.

!!! note
    This function does not trigger any enumeration.
"""
number_of_generators(k::Konieczny) = Int(LibSemigroups.number_of_generators(k.cxx_obj))

"""
    generator(k::Konieczny{E}, i::Integer) -> E

Return the `i`-th generator of `k` (1-based).

# Throws
- `LibsemigroupsError`: if `i` exceeds [`number_of_generators`](@ref)`(k)`.
"""
function generator(k::Konieczny{E}, i::Integer) where {E}
    idx = _konieczny_index(i)
    raw = @wrap_libsemigroups_call LibSemigroups.generator(k.cxx_obj, idx)
    return _wrap_element(E, raw)
end

# ============================================================================
# Size and degree
# ============================================================================

"""
    Base.length(k::Konieczny) -> Int

Return the size of the semigroup represented by `k`.

!!! note
    This function triggers a full run of the algorithm.

# See also
- [`current_size`](@ref)
"""
Base.length(k::Konieczny) = Int(LibSemigroups.size(k.cxx_obj))

"""
    current_size(k::Konieczny) -> Int

Return the number of elements in the D-classes found so far.

!!! note
    This function does not trigger any enumeration.
"""
current_size(k::Konieczny) = Int(LibSemigroups.current_size(k.cxx_obj))

"""
    degree(k::Konieczny) -> Int

Return the degree of any (and hence all) elements of `k`.
"""
degree(k::Konieczny) = Int(LibSemigroups.degree(k.cxx_obj))

# ============================================================================
# Counts of Green's classes, idempotents, regular elements
# ============================================================================

"""
    number_of_D_classes(k::Konieczny) -> Int

Return the number of D-classes of the semigroup represented by `k`.
Triggers a full run. See [`current_number_of_D_classes`](@ref).
"""
number_of_D_classes(k::Konieczny) = Int(LibSemigroups.number_of_D_classes(k.cxx_obj))

"""
    current_number_of_D_classes(k::Konieczny) -> Int

Return the number of D-classes found so far, without triggering a run.
"""
current_number_of_D_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_D_classes(k.cxx_obj))

"""
    number_of_regular_D_classes(k::Konieczny) -> Int

Return the number of regular D-classes. Triggers a full run.
"""
number_of_regular_D_classes(k::Konieczny) =
    Int(LibSemigroups.number_of_regular_D_classes(k.cxx_obj))

"""
    current_number_of_regular_D_classes(k::Konieczny) -> Int

Return the number of regular D-classes found so far, without triggering a run.
"""
current_number_of_regular_D_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_regular_D_classes(k.cxx_obj))

"""
    number_of_L_classes(k::Konieczny) -> Int

Return the number of L-classes. Triggers a full run.
"""
number_of_L_classes(k::Konieczny) = Int(LibSemigroups.number_of_L_classes(k.cxx_obj))

"""
    current_number_of_L_classes(k::Konieczny) -> Int

Return the number of L-classes in the D-classes found so far.
"""
current_number_of_L_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_L_classes(k.cxx_obj))

"""
    number_of_regular_L_classes(k::Konieczny) -> Int

Return the number of regular L-classes. Triggers a full run.
"""
number_of_regular_L_classes(k::Konieczny) =
    Int(LibSemigroups.number_of_regular_L_classes(k.cxx_obj))

"""
    current_number_of_regular_L_classes(k::Konieczny) -> Int

Return the number of regular L-classes in the D-classes found so far.
"""
current_number_of_regular_L_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_regular_L_classes(k.cxx_obj))

"""
    number_of_R_classes(k::Konieczny) -> Int

Return the number of R-classes. Triggers a full run.
"""
number_of_R_classes(k::Konieczny) = Int(LibSemigroups.number_of_R_classes(k.cxx_obj))

"""
    current_number_of_R_classes(k::Konieczny) -> Int

Return the number of R-classes in the D-classes found so far.
"""
current_number_of_R_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_R_classes(k.cxx_obj))

"""
    number_of_regular_R_classes(k::Konieczny) -> Int

Return the number of regular R-classes. Triggers a full run.
"""
number_of_regular_R_classes(k::Konieczny) =
    Int(LibSemigroups.number_of_regular_R_classes(k.cxx_obj))

"""
    current_number_of_regular_R_classes(k::Konieczny) -> Int

Return the number of regular R-classes in the D-classes found so far.
"""
current_number_of_regular_R_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_regular_R_classes(k.cxx_obj))

"""
    number_of_H_classes(k::Konieczny) -> Int

Return the number of H-classes. Triggers a full run.
"""
number_of_H_classes(k::Konieczny) = Int(LibSemigroups.number_of_H_classes(k.cxx_obj))

"""
    current_number_of_H_classes(k::Konieczny) -> Int

Return the number of H-classes in the D-classes found so far.
"""
current_number_of_H_classes(k::Konieczny) =
    Int(LibSemigroups.current_number_of_H_classes(k.cxx_obj))

"""
    number_of_idempotents(k::Konieczny) -> Int

Return the number of idempotents. Triggers a full run.
"""
number_of_idempotents(k::Konieczny) = Int(LibSemigroups.number_of_idempotents(k.cxx_obj))

"""
    current_number_of_idempotents(k::Konieczny) -> Int

Return the number of idempotents in the regular D-classes found so far.
"""
current_number_of_idempotents(k::Konieczny) =
    Int(LibSemigroups.current_number_of_idempotents(k.cxx_obj))

"""
    number_of_regular_elements(k::Konieczny) -> Int

Return the number of regular elements. Triggers a full run.
"""
number_of_regular_elements(k::Konieczny) =
    Int(LibSemigroups.number_of_regular_elements(k.cxx_obj))

"""
    current_number_of_regular_elements(k::Konieczny) -> Int

Return the number of elements in the regular D-classes found so far.
"""
current_number_of_regular_elements(k::Konieczny) =
    Int(LibSemigroups.current_number_of_regular_elements(k.cxx_obj))

# ============================================================================
# Membership
# ============================================================================

"""
    Base.in(x::E, k::Konieczny{E}) -> Bool

Test membership of `x` in the semigroup represented by `k`. Returns `false`
(rather than throwing) if `degree(x) != degree(k)`.

!!! note
    This may trigger a partial run of the algorithm.
"""
function Base.in(x::E, k::Konieczny{E}) where {E}
    return @wrap_libsemigroups_call LibSemigroups.contains(k.cxx_obj, _cxx_element(x))
end

# BMat8 dispatch: BMat8Allocated <: BMat8, so we need a fallback
function Base.in(x::BMat8, k::Konieczny{BMat8})
    return @wrap_libsemigroups_call LibSemigroups.contains(k.cxx_obj, _cxx_element(x))
end

"""
    is_regular_element(k::Konieczny{E}, x::E) -> Bool

Return `true` if `x` is a regular element of the semigroup represented by
`k`, and `false` otherwise (including when `x` is not in `k`).
"""
function is_regular_element(k::Konieczny{E}, x::E) where {E}
    return @wrap_libsemigroups_call LibSemigroups.is_regular_element(
        k.cxx_obj,
        _cxx_element(x),
    )
end

function is_regular_element(k::Konieczny{BMat8}, x::BMat8)
    return @wrap_libsemigroups_call LibSemigroups.is_regular_element(
        k.cxx_obj,
        _cxx_element(x),
    )
end

# ============================================================================
# D-class access
# ============================================================================

"""
    D_class_of_element(k::Konieczny{E}, x::E) -> KoniecznyDClass{E}

Return the D-class of `k` containing `x`.

# Throws
- `LibsemigroupsError`: if `x` does not belong to `k`.
"""
function D_class_of_element(k::Konieczny{E}, x::E) where {E}
    raw = @wrap_libsemigroups_call LibSemigroups.D_class_of_element(
        k.cxx_obj,
        _cxx_element(x),
    )
    return KoniecznyDClass{E}(raw, k)
end

function D_class_of_element(k::Konieczny{BMat8}, x::BMat8)
    raw = @wrap_libsemigroups_call LibSemigroups.D_class_of_element(
        k.cxx_obj,
        _cxx_element(x),
    )
    return KoniecznyDClass{BMat8}(raw, k)
end

"""
    D_class(k::Konieczny{E}, i::Integer) -> KoniecznyDClass{E}

Return the `i`-th D-class of `k` (1-based), in the order in which the
D-classes were found. Triggers a full run.

# Throws
- `LibsemigroupsError`: if `i` exceeds [`number_of_D_classes`](@ref)`(k)`.
"""
function D_class(k::Konieczny{E}, i::Integer) where {E}
    idx = _konieczny_index(i)
    raw = @wrap_libsemigroups_call LibSemigroups.D_class(k.cxx_obj, idx)
    return KoniecznyDClass{E}(raw, k)
end

"""
    regular_D_class(k::Konieczny{E}, i::Integer) -> KoniecznyDClass{E}

Return the `i`-th regular D-class of `k` (1-based). Triggers a full run.

# Throws
- `LibsemigroupsError`: if `i` exceeds [`number_of_regular_D_classes`](@ref)`(k)`.
"""
function regular_D_class(k::Konieczny{E}, i::Integer) where {E}
    idx = _konieczny_index(i)
    raw = @wrap_libsemigroups_call LibSemigroups.regular_D_class(k.cxx_obj, idx)
    return KoniecznyDClass{E}(raw, k)
end

"""
    D_classes(k::Konieczny{E}) -> Vector{KoniecznyDClass{E}}

Return a vector of all D-classes of `k`. Triggers a full run.
"""
D_classes(k::Konieczny) = [D_class(k, i) for i = 1:number_of_D_classes(k)]

"""
    regular_D_classes(k::Konieczny{E}) -> Vector{KoniecznyDClass{E}}

Return a vector of all regular D-classes of `k`. Triggers a full run.
"""
regular_D_classes(k::Konieczny) =
    [regular_D_class(k, i) for i = 1:number_of_regular_D_classes(k)]

# ============================================================================
# KoniecznyDClass methods
# ============================================================================

"""
    rep(d::KoniecznyDClass{E}) -> E

Return a representative of the D-class `d`.
"""
rep(d::KoniecznyDClass{E}) where {E} = _wrap_element(E, LibSemigroups.rep(d.cxx_obj))

"""
    Base.length(d::KoniecznyDClass) -> Int

Return the number of elements in the D-class `d`.
"""
Base.length(d::KoniecznyDClass) = Int(LibSemigroups.size(d.cxx_obj))

"""
    number_of_L_classes(d::KoniecznyDClass) -> Int

Return the number of L-classes in the D-class `d`.
"""
number_of_L_classes(d::KoniecznyDClass) = Int(LibSemigroups.number_of_L_classes(d.cxx_obj))

"""
    number_of_R_classes(d::KoniecznyDClass) -> Int

Return the number of R-classes in the D-class `d`.
"""
number_of_R_classes(d::KoniecznyDClass) = Int(LibSemigroups.number_of_R_classes(d.cxx_obj))

"""
    size_H_class(d::KoniecznyDClass) -> Int

Return the size of any (and hence every) H-class in the D-class `d`.
"""
size_H_class(d::KoniecznyDClass) = Int(LibSemigroups.size_H_class(d.cxx_obj))

"""
    is_regular_D_class(d::KoniecznyDClass) -> Bool

Return `true` if the D-class `d` is regular.
"""
is_regular_D_class(d::KoniecznyDClass) = LibSemigroups.is_regular_D_class(d.cxx_obj)

"""
    number_of_idempotents(d::KoniecznyDClass) -> Int

Return the number of idempotents in the D-class `d` (zero if `d` is not
regular).
"""
number_of_idempotents(d::KoniecznyDClass) =
    Int(LibSemigroups.number_of_idempotents(d.cxx_obj))

"""
    Base.in(x::E, d::KoniecznyDClass{E}) -> Bool

Test whether `x` belongs to the D-class `d`.
"""
function Base.in(x::E, d::KoniecznyDClass{E}) where {E}
    return @wrap_libsemigroups_call LibSemigroups.contains(d.cxx_obj, _cxx_element(x))
end

function Base.in(x::BMat8, d::KoniecznyDClass{BMat8})
    return @wrap_libsemigroups_call LibSemigroups.contains(d.cxx_obj, _cxx_element(x))
end

function Base.show(io::IO, d::KoniecznyDClass)
    kind = is_regular_D_class(d) ? "regular" : "non-regular"
    print(
        io,
        "<",
        kind,
        " D-class with ",
        number_of_R_classes(d),
        " R-classes, ",
        number_of_L_classes(d),
        " L-classes, H-class size ",
        size_H_class(d),
        ">",
    )
end

# ============================================================================
# Display
# ============================================================================

function Base.show(io::IO, k::Konieczny)
    print(io, @wrap_libsemigroups_call LibSemigroups.to_human_readable_repr(k.cxx_obj))
end

# ============================================================================
# Runner delegation
# ============================================================================
# Every public Runner method is delegated through k.cxx_obj.
# Mutating methods return k for chaining; query methods return the result.

"""
    run!(k::Konieczny) -> Konieczny

Run Konieczny's algorithm until [`finished`](@ref). Returns `k` for method
chaining.
"""
function run!(k::Konieczny)
    LibSemigroups.run!(k.cxx_obj)
    return k
end

"""
    run_for!(k::Konieczny, t::TimePeriod) -> Konieczny

Run Konieczny's algorithm for a specified amount of time. Returns `k`.
"""
function run_for!(k::Konieczny, t::TimePeriod)
    ns = convert(Nanosecond, t)
    Dates.value(ns) >= 0 ||
        throw(ArgumentError("run_for! requires a non-negative duration, got $t"))
    LibSemigroups.run_for!(k.cxx_obj, Int64(Dates.value(ns)))
    return k
end

"""
    run_until!(f::Function, k::Konieczny) -> Konieczny

Run Konieczny's algorithm until the nullary predicate `f` returns `true`.
Returns `k`.
"""
function run_until!(f::Function, k::Konieczny)
    sf = @safe_cfunction($f, Cuchar, ())
    GC.@preserve sf LibSemigroups.run_until!(k.cxx_obj, sf)
    return k
end

run_until!(k::Konieczny, f::Function) = run_until!(f, k)

kill!(k::Konieczny) = LibSemigroups.kill!(k.cxx_obj)
finished(k::Konieczny) = LibSemigroups.finished(k.cxx_obj)
started(k::Konieczny) = LibSemigroups.started(k.cxx_obj)
running(k::Konieczny) = LibSemigroups.running(k.cxx_obj)
timed_out(k::Konieczny) = LibSemigroups.timed_out(k.cxx_obj)
stopped(k::Konieczny) = LibSemigroups.stopped(k.cxx_obj)
dead(k::Konieczny) = LibSemigroups.dead(k.cxx_obj)
stopped_by_predicate(k::Konieczny) = LibSemigroups.stopped_by_predicate(k.cxx_obj)
running_for(k::Konieczny) = LibSemigroups.running_for(k.cxx_obj)
running_for_how_long(k::Konieczny) =
    Nanosecond(LibSemigroups.running_for_how_long(k.cxx_obj))
running_until(k::Konieczny) = LibSemigroups.running_until(k.cxx_obj)
current_state(k::Konieczny) = LibSemigroups.current_state(k.cxx_obj)
report_why_we_stopped(k::Konieczny) = LibSemigroups.report_why_we_stopped(k.cxx_obj)
string_why_we_stopped(k::Konieczny) = LibSemigroups.string_why_we_stopped(k.cxx_obj)
