# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
kambites.jl - Kambites wrapper (Layer 2 + 3)
"""

# ============================================================================
# Type alias
# ============================================================================

"""
    Kambites

Type implementing Kambites's algorithm for computing the word problem in
small overlap monoids - finitely presented monoids whose presentation
satisfies the small overlap condition `C(n)` for `n >= 4` (Kambites,
2009).

A `Kambites` object is constructed from a
[`congruence_kind`](@ref Semigroups.congruence_kind) (must be
[`twosided`](@ref Semigroups.twosided)) and a
[`Presentation`](@ref Semigroups.Presentation), or copied from another
`Kambites`.

`Kambites` is a subtype of [`CongruenceCommon`](@ref
Semigroups.CongruenceCommon) (and hence of [`Runner`](@ref
Semigroups.Runner)), so all runner methods (`run!`, `run_for!`,
`finished`, `timed_out`, etc.) and most common congruence helpers
(`reduce`, `contains`, `currently_contains`, `add_generating_pair!`,
`partition`) work on `Kambites` objects.

Two structural deviations from [`KnuthBendix`](@ref Semigroups.KnuthBendix)
and [`ToddCoxeter`](@ref Semigroups.ToddCoxeter) precedent:

- `Base.length` is intentionally **not** defined for `Kambites`. The
  number of classes is always `POSITIVE_INFINITY` (or throws), so an
  alias would silently misbehave with `for i in 1:length(k)`. Use
  [`number_of_classes`](@ref Semigroups.number_of_classes) explicitly.
- `non_trivial_classes(::Kambites, ::Kambites)` throws `ArgumentError`
  (upstream rationale: both Kambites instances always represent
  infinite-class congruences, so the construction does not generalize).
- `normal_forms(k::Kambites)` (no-arg) throws `ArgumentError` because
  the underlying normal-form range is infinite. Use the bounded form
  `normal_forms(k, n)` to materialize the first `n` normal forms.

# Constructors

    Kambites() -> Kambites
    Kambites(kind::congruence_kind, p::Presentation) -> Kambites
    Kambites(other::Kambites) -> Kambites

# Throws

- `LibsemigroupsError` if `kind` is not [`twosided`](@ref Semigroups.twosided).

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `Kambites{word_type}` only. String-alphabet
    presentations are deferred to v1.1.
"""
const Kambites = LibSemigroups.KambitesWord

# ============================================================================
# Initialization
# ============================================================================

"""
    Kambites(kind::congruence_kind, p::Presentation) -> Kambites

Construct a `Kambites` from a congruence kind and a presentation.

This Julia wrapper builds a default `Kambites` and then calls
[`init!`](@ref Semigroups.init!) so that exceptions raised by
libsemigroups surface as [`LibsemigroupsError`](@ref
Semigroups.LibsemigroupsError) (the direct CxxWrap-bound constructor
would surface them as `Base.ErrorException`).

# Throws

- `LibsemigroupsError` if `kind` is not [`twosided`](@ref Semigroups.twosided).
"""
function Kambites(kind::congruence_kind, p::Presentation)
    k = LibSemigroups.KambitesWord()
    init!(k, kind, p)
    return k
end

"""
    init!(k::Kambites) -> Kambites
    init!(k::Kambites, kind::congruence_kind, p::Presentation) -> Kambites

Re-initialize `k` so that it is in the state it would have been in
immediately after the corresponding constructor.

The one-argument form clears the underlying state, putting `k` back
into the same state as a newly default-constructed
[`Kambites`](@ref Semigroups.Kambites).

The three-argument form reinitializes `k` from `(kind, p)`.

Returns `k` for chaining.

# Throws

- `LibsemigroupsError` if `kind` is not [`twosided`](@ref Semigroups.twosided).
"""
function init!(k::Kambites)
    @wrap_libsemigroups_call LibSemigroups.init!(k)
    return k
end

function init!(k::Kambites, kind::congruence_kind, p::Presentation)
    @wrap_libsemigroups_call LibSemigroups.init!(k, kind, p)
    return k
end

# ============================================================================
# Accessors
# ============================================================================

"""
    presentation(k::Kambites) -> Presentation

Return a copy of the presentation used to construct `k`.
"""
presentation(k::Kambites) = LibSemigroups.presentation(k)

"""
    generating_pairs(k::Kambites) -> Vector{Vector{Int}}

Return the generating pairs of `k` as a flat vector of 1-based words.

Pairs are returned as a flat `Vector` of words, with consecutive entries
forming a pair: `[u1, v1, u2, v2, ...]`. The total length equals
`2 * number_of_generating_pairs(k)`. Words are 1-based `Vector{Int}`
letter indices.
"""
function generating_pairs(k::Kambites)
    flat = LibSemigroups.generating_pairs(k)
    return [_word_from_cpp(w) for w in flat]
end

"""
    kind(k::Kambites) -> congruence_kind

Return the kind of congruence represented by `k`. Always
[`twosided`](@ref Semigroups.twosided) for `Kambites`.
"""
kind(k::Kambites) = LibSemigroups.kind(k)

"""
    number_of_generating_pairs(k::Kambites) -> Int

Return the number of generating pairs added to `k`.
"""
number_of_generating_pairs(k::Kambites) = Int(LibSemigroups.number_of_generating_pairs(k))

"""
    number_of_classes(k::Kambites) -> UInt64

Return the number of congruence classes of `k`. Returns
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) when
[`small_overlap_class`](@ref Semigroups.small_overlap_class) is at least
4.

# Throws

- `LibsemigroupsError` if `small_overlap_class(k) < 4`.
"""
number_of_classes(k::Kambites) = @wrap_libsemigroups_call LibSemigroups.number_of_classes(k)

# ============================================================================
# small_overlap_class (const-overload split)
# ============================================================================

"""
    small_overlap_class(k::Kambites) -> UInt64

Return the small overlap class of the presentation underlying `k`.

This is the greatest positive integer `n` such that the presentation
satisfies the condition `C(n)`, or
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) if no word
occurring in a relation can be written as a product of pieces.

The return type is `UInt64` (rather than `Int`) because
`POSITIVE_INFINITY` is encoded as `typemax(UInt64) - 1` on the wire and
would not round-trip through `Int`. Use
[`is_positive_infinity`](@ref Semigroups.is_positive_infinity) (or
direct comparison `result == POSITIVE_INFINITY`) to detect the infinite
case. This function may trigger computation.

# See also

[`current_small_overlap_class`](@ref Semigroups.current_small_overlap_class)
"""
small_overlap_class(k::Kambites) = LibSemigroups.small_overlap_class(k)

"""
    current_small_overlap_class(k::Kambites) -> Union{UInt64, UndefinedType}

Return the small overlap class of `k` if it is currently known, or
[`UNDEFINED`](@ref Semigroups.UNDEFINED) otherwise.

This function does not trigger any computation. The known value is
returned as `UInt64` (see [`small_overlap_class`](@ref
Semigroups.small_overlap_class) for the rationale).

# See also

[`small_overlap_class`](@ref Semigroups.small_overlap_class)
"""
function current_small_overlap_class(k::Kambites)
    val = LibSemigroups.current_small_overlap_class(k)
    return val == typemax(UInt) ? UNDEFINED : val
end

# ============================================================================
# Validators
# ============================================================================

"""
    throw_if_letter_not_in_alphabet(k::Kambites, w::AbstractVector{<:Integer})

Check that every letter in `w` belongs to the alphabet of the underlying
presentation of `k`.

# Throws

- `LibsemigroupsError` if any letter in `w` is not in the alphabet.
"""
function throw_if_letter_not_in_alphabet(k::Kambites, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    @wrap_libsemigroups_call LibSemigroups.throw_if_letter_not_in_alphabet(k, cpp_w)
    return nothing
end

"""
    throw_if_not_C4(k::Kambites)

Throw a `LibsemigroupsError` unless the small overlap class of `k` is
at least 4.

# Throws

- `LibsemigroupsError` if `small_overlap_class(k) < 4`.
"""
function throw_if_not_C4(k::Kambites)
    @wrap_libsemigroups_call LibSemigroups.throw_if_not_C4(k)
    return nothing
end

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.show(io::IO, k::Kambites)

Print a human-readable representation of `k`.
"""
function Base.show(io::IO, k::Kambites)
    print(io, LibSemigroups.to_human_readable_repr(k))
end

"""
    Base.copy(k::Kambites) -> Kambites

Create an independent copy of `k`.
"""
Base.copy(k::Kambites) = LibSemigroups.KambitesWord(k)

Base.deepcopy_internal(k::Kambites, ::IdDict) = LibSemigroups.KambitesWord(k)

# ============================================================================
# non_trivial_classes override (throws)
# ============================================================================

"""
    non_trivial_classes(k1::Kambites, k2::Kambites)

Always throws `ArgumentError` for `Kambites` arguments.

`non_trivial_classes(Kambites, Kambites)` is intentionally not provided
upstream (see `kambites-helpers.hpp:128-133`) because both Kambites
instances always represent infinite-class congruences, so the
construction does not generalize.
"""
function non_trivial_classes(::Kambites, ::Kambites)
    throw(ArgumentError(
        "non_trivial_classes(::Kambites, ::Kambites) is intentionally not " *
        "supported: both Kambites instances always represent infinite-class " *
        "congruences, so the construction does not generalize " *
        "(see kambites-helpers.hpp:128-133).",
    ))
end

# ============================================================================
# normal_forms (bounded; the no-arg form throws)
# ============================================================================

"""
    normal_forms(k::Kambites, n::Integer) -> Vector{Vector{Int}}

Return the first `n` normal forms of `k`, as 1-based `Vector{Int}` words.

The set of normal forms is infinite for any C(>=4) presentation, so the
caller must specify the bound `n`.

# Throws

- `LibsemigroupsError` if `small_overlap_class(k) < 4`.
"""
function normal_forms(k::Kambites, n::Integer)
    nf = @wrap_libsemigroups_call LibSemigroups.kambites_normal_forms_take(k, UInt(n))
    return [_word_from_cpp(w) for w in nf]
end

"""
    normal_forms(k::Kambites)

Always throws `ArgumentError`. The set of normal forms of a `Kambites`
is infinite, so the no-argument form is unsafe; use the bounded form
[`normal_forms(k, n)`](@ref Semigroups.normal_forms(::Kambites, ::Integer))
instead.
"""
function normal_forms(k::Kambites)
    throw(ArgumentError(
        "Kambites has infinitely many normal forms; use normal_forms(k, n) " *
        "to take the first n.",
    ))
end
