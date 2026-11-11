# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
congruence.jl - Congruence{W} wrapper (Layer 2 + 3)
"""

# ============================================================================
# Type
# ============================================================================

"""
    Congruence{W}

Type for computing a congruence on a finitely presented semigroup or monoid by
running several algorithms ([`KnuthBendix`](@ref Semigroups.KnuthBendix),
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter) and
[`Kambites`](@ref Semigroups.Kambites)) and using whichever finishes first.

The type parameter `W` is the word type of the congruence; see
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon). It is determined by
the presentation used to construct the `Congruence`.

`Congruence` is a subtype of [`CongruenceCommon`](@ref
Semigroups.CongruenceCommon) (and hence of [`Runner`](@ref Semigroups.Runner)),
so all runner methods and the common congruence helpers work on `Congruence`
objects, except [`normal_forms`](@ref Semigroups.normal_forms(::Congruence))
and [`non_trivial_classes`](@ref
Semigroups.non_trivial_classes(::Congruence, ::Congruence)), which
libsemigroups does not provide for `Congruence`.

# Constructors

    Congruence(kind::congruence_kind, p::Presentation) -> Congruence
    Congruence(other::Congruence) -> Congruence
    Congruence() -> Congruence{Vector{Int}}

# Throws

- `LibsemigroupsError` if `p` is not valid.

# Word types

`Congruence{W}` supports both word types: `W = Vector{Int}` (1-based letter
indices) and `W = String` (ASCII characters). The word type is taken from the
presentation, so `Congruence(twosided, p::Presentation{String})` is a
`Congruence{String}`, and all words passed to or returned from it are
`String`s.
"""
struct Congruence{W} <: CongruenceCommon{W}
    cxx_obj::Union{LibSemigroups.CongruenceWord,LibSemigroups.CongruenceString}
end

# The C++ type backing Congruence{W}, and wrapping a C++ object in the
# matching Congruence{W}. Supporting a new word type means adding a method to
# each of these (and widening the `cxx_obj` field type to a Union).
_cxx_congruence_type(::Type{Vector{Int}}) = LibSemigroups.CongruenceWord
_cxx_congruence_type(::Type{String}) = LibSemigroups.CongruenceString

_wrap_congruence(x::LibSemigroups.CongruenceWord) = Congruence{Vector{Int}}(x)
_wrap_congruence(x::LibSemigroups.CongruenceString) = Congruence{String}(x)

# ============================================================================
# Constructors
# ============================================================================

# The C++ binding takes the congruence kind as an Integer and the raw C++
# presentation; adapt the public Julia types to that.
function Congruence(kind::congruence_kind, p::Presentation{W}) where {W}
    cxx = @wrap_libsemigroups_call _cxx_congruence_type(W)(_kind_to_cpp(kind), _cxx(p))
    return _wrap_congruence(cxx)
end

Congruence{W}() where {W} = _wrap_congruence(_cxx_congruence_type(W)())

Congruence() = Congruence{Vector{Int}}()

Congruence(other::Congruence{W}) where {W} =
    _wrap_congruence(_cxx_congruence_type(W)(_cxx(other)))

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.show(io::IO, c::Congruence)

Print a human-readable representation of `c`.
"""
function Base.show(io::IO, c::Congruence)
    print(io, LibSemigroups.to_human_readable_repr(_cxx(c)))
end

"""
    Base.copy(c::Congruence) -> Congruence

Create an independent copy of `c`.
"""
Base.copy(c::Congruence) = Congruence(c)

Base.deepcopy_internal(c::Congruence, ::IdDict) = Congruence(c)

# ============================================================================
# Common helpers not provided for Congruence
# ============================================================================

"""
    normal_forms(c::Congruence)

Always throws `ArgumentError`: libsemigroups does not provide normal forms
for [`Congruence`](@ref Semigroups.Congruence). Use the
[`KnuthBendix`](@ref Semigroups.KnuthBendix) or
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter) algorithm directly instead.
"""
function normal_forms(::Congruence)
    throw(
        ArgumentError(
            "normal_forms is not provided for Congruence by libsemigroups; " *
            "use KnuthBendix or ToddCoxeter directly instead.",
        ),
    )
end

"""
    non_trivial_classes(c1::Congruence, c2::Congruence)

Always throws `ArgumentError`: libsemigroups only provides the
two-congruence form of `non_trivial_classes` for
[`KnuthBendix`](@ref Semigroups.KnuthBendix) and
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter), not for
[`Congruence`](@ref Semigroups.Congruence). Use one of those algorithms
directly instead.
"""
function non_trivial_classes(::Congruence, ::Congruence)
    throw(
        ArgumentError(
            "non_trivial_classes(::Congruence, ::Congruence) is not provided by " *
            "libsemigroups; use KnuthBendix or ToddCoxeter directly instead.",
        ),
    )
end
