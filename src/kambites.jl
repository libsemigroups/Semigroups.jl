# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
kambites.jl - Kambites{W} wrapper (Layer 2 + 3)

Provides a parametric `Kambites{W}` type wrapping the CxxWrap-bound C++
`Kambites<Word>` instantiations (`W = Vector{Int}` or `W = String`).

`Kambites{W}` subtypes `CongruenceCommon` (and hence `Runner`), mirroring
libsemigroups where `Kambites<Word>` derives from `detail::CongruenceCommon`.
The generic `Runner` and `CongruenceCommon` methods in `runner.jl` and
`cong-common.jl` unwrap it via `_cxx` and use `_cong_word_type` to convert
words, so only Kambites-specific functionality is defined here.
"""

# ============================================================================
# CxxWrap type aliases — concrete Kambites<W> instantiations
# ============================================================================

const KambitesWord = LibSemigroups.KambitesWord
const KambitesString = LibSemigroups.KambitesString

# ============================================================================
# Union type for cxx_obj field
# ============================================================================

const _KambitesCxx = Union{KambitesWord,KambitesString}

# ============================================================================
# Kambites{W} mutable struct
# ============================================================================

"""
    Kambites{W}

Type implementing small overlap class, equality, and normal forms for
small overlap monoids -- finitely presented monoids whose presentation
satisfies the small overlap condition `C(n)` for `n >= 4` (Kambites,
2009).

A [`Kambites`](@ref Semigroups.Kambites) instance represents a
congruence on the free monoid or semigroup containing the rules of the
[`Presentation`](@ref Semigroups.Presentation) used to construct the
instance, together with the
[`generating_pairs`](@ref Semigroups.generating_pairs) added via
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!). As such,
generating pairs and presentation rules are interchangeable in the
context of `Kambites` objects.

A `Kambites` object is constructed from a
[`congruence_kind`](@ref Semigroups.congruence_kind) (which must be
[`twosided`](@ref Semigroups.twosided)) and a
[`Presentation`](@ref Semigroups.Presentation), or copied from another
`Kambites`.

The type parameter `W` specifies the word representation, which can be
`Vector{Int}` (default, 1-based generator indices) or `String` (ASCII
characters). It is determined by the presentation:
`Kambites(twosided, p::Presentation{W})` returns a `Kambites{W}`, and
all words passed to or returned from it have type `W`.

`Kambites` is a subtype of
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) (and hence of
[`Runner`](@ref Semigroups.Runner)), so all runner methods (`run!`,
`run_for!`, `finished`, `timed_out`, etc.) and most common congruence
helpers ([`reduce`](@ref Semigroups.reduce),
[`contains`](@ref Semigroups.contains),
[`currently_contains`](@ref Semigroups.currently_contains),
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!),
[`partition`](@ref Semigroups.partition)) work on `Kambites` objects,
for both word types.

# Structural deviations from `KnuthBendix` / `ToddCoxeter` precedent

- `Base.length` is intentionally **not** defined for `Kambites`. The
  number of classes is always
  [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) (or throws),
  so an alias would silently misbehave with `for i in 1:length(k)`.
  Use [`number_of_classes`](@ref Semigroups.number_of_classes)
  explicitly.
- [`non_trivial_classes`](@ref Semigroups.non_trivial_classes)`(k1::Kambites, k2::Kambites)`
  throws `ArgumentError` (upstream rationale: both `Kambites` instances
  always represent infinite-class congruences, so the construction does
  not generalize; cf. `kambites-helpers.hpp:128-133`).
- [`normal_forms`](@ref Semigroups.normal_forms)`(k::Kambites)` (no-arg)
  throws `ArgumentError` because the underlying normal-form range is
  infinite. Use the bounded form `normal_forms(k, n)` to materialize
  the first `n` normal forms.
- The `ukkonen()` accessor (and the `Ukkonen` type) is deferred to a
  later release.

# Constructors

    Kambites{W}() -> Kambites{W}
    Kambites() -> Kambites{Vector{Int}}
    Kambites(kind::congruence_kind, p::Presentation{W}) -> Kambites{W}
    Kambites(k::Kambites{W}) -> Kambites{W}

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `kind`
  is not [`twosided`](@ref Semigroups.twosided).
"""
mutable struct Kambites{W} <: CongruenceCommon
    cxx_obj::_KambitesCxx
end

# ============================================================================
# Private helpers
# ============================================================================

"""
    _cxx_kambites_type(::Type{W}) -> Type

Map a high-level Julia word type to its CxxWrap Kambites constructor type.
"""
_cxx_kambites_type(::Type{Vector{Int}}) = KambitesWord
_cxx_kambites_type(::Type{String}) = KambitesString

_wrap_kambites(k::KambitesWord) = Kambites{Vector{Int}}(k)
_wrap_kambites(k::KambitesString) = Kambites{String}(k)
_wrap_kambites(k::Kambites) = k

_cxx(k::Kambites) = k.cxx_obj

# Word type used by the generic CongruenceCommon helpers (cong-common.jl).
_cong_word_type(::Kambites{W}) where {W} = W

# ============================================================================
# Constructors & Initialization
# ============================================================================

function Kambites{W}() where {W}
    T = _cxx_kambites_type(W)
    return Kambites{W}(@wrap_libsemigroups_call T())
end

Kambites() = Kambites{Vector{Int}}()

"""
    Kambites(kind::congruence_kind, p::Presentation{W}) -> Kambites{W}

Construct a [`Kambites`](@ref Semigroups.Kambites) instance representing
a congruence of kind `kind` over the semigroup or monoid defined by the
presentation `p`.

`Kambites` instances can only be used to compute two-sided congruences,
so `kind` must always be [`twosided`](@ref Semigroups.twosided). The
parameter is included for uniformity of interface with
[`KnuthBendix`](@ref Semigroups.KnuthBendix), `ToddCoxeter`, and
`Congruence`.

This Julia wrapper builds a default `Kambites` and then calls
[`init!`](@ref Semigroups.init!) so that exceptions raised by
libsemigroups surface as
[`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError).

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `p` is
  not valid.
- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `kind`
  is not [`twosided`](@ref Semigroups.twosided).
"""
function Kambites(kind::congruence_kind, p::Presentation{W}) where {W}
    k = Kambites{W}()
    init!(k, kind, p)
    return k
end

function Kambites(k::Kambites{W}) where {W}
    T = _cxx_kambites_type(W)
    return Kambites{W}(@wrap_libsemigroups_call T(k.cxx_obj))
end

"""
    Base.copy(k::Kambites{W}) -> Kambites{W}

Create an independent copy of `k` via the C++ copy constructor.
"""
Base.copy(k::Kambites) = Kambites(k)

Base.deepcopy_internal(k::Kambites, ::IdDict) = Kambites(k)

"""
    init!(k::Kambites) -> Kambites
    init!(k::Kambites{W}, kind::congruence_kind, p::Presentation{W}) -> Kambites{W}

Re-initialize `k` so that it is in the state it would have been in
immediately after the corresponding constructor.

The one-argument form puts `k` back into the same state as a newly
default-constructed [`Kambites`](@ref Semigroups.Kambites).

The three-argument form puts `k` back into the state it would have been
in if it had just been newly constructed from `kind` and `p`.
`Kambites` instances can only be used to compute two-sided congruences,
so `kind` must always be [`twosided`](@ref Semigroups.twosided); the
parameter is included for uniformity of interface with
[`KnuthBendix`](@ref Semigroups.KnuthBendix), `ToddCoxeter`, and
`Congruence`.

Returns `k` for chaining.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `p` is
  not valid (three-argument form only).
- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `kind`
  is not [`twosided`](@ref Semigroups.twosided) (three-argument form
  only).
"""
function init!(k::Kambites)
    @wrap_libsemigroups_call LibSemigroups.init!(k.cxx_obj)
    return k
end

function init!(k::Kambites{W}, kind::congruence_kind, p::Presentation{W}) where {W}
    @wrap_libsemigroups_call LibSemigroups.init!(k.cxx_obj, kind, p.cxx_obj)
    return k
end

# ============================================================================
# Accessors
# ============================================================================

"""
    presentation(k::Kambites{W}) -> Presentation{W}

Return a copy of the [`Presentation`](@ref Semigroups.Presentation) used
to construct or initialize `k` (if any).

If `k` was constructed or initialized using a presentation, that
presentation is returned. The Julia binding returns by value (an
independent copy) rather than by reference; mutating the returned
object does not affect `k`.
"""
presentation(k::Kambites{W}) where {W} =
    _wrap_presentation(LibSemigroups.presentation(k.cxx_obj))

"""
    generating_pairs(k::Kambites{W}) -> Vector{Tuple{W, W}}

Return the generating pairs of `k` as a vector of word pairs.

These are the pairs added via
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!). The length
of the returned vector equals
[`number_of_generating_pairs`](@ref Semigroups.number_of_generating_pairs).
"""
function generating_pairs(k::Kambites{W}) where {W}
    flat = LibSemigroups.generating_pairs(k.cxx_obj)
    result = Tuple{W,W}[]
    for i = 1:2:length(flat)
        push!(result, (_cong_word_from_cpp(k, flat[i]), _cong_word_from_cpp(k, flat[i+1])))
    end
    return result
end

"""
    kind(k::Kambites) -> congruence_kind

Return the kind of congruence (one- or two-sided) represented by `k`;
see [`congruence_kind`](@ref Semigroups.congruence_kind) for details.
For [`Kambites`](@ref Semigroups.Kambites) this is always
[`twosided`](@ref Semigroups.twosided), since the constructor enforces
that constraint.

Complexity: constant.
"""
kind(k::Kambites) = LibSemigroups.kind(k.cxx_obj)

"""
    number_of_generating_pairs(k::Kambites) -> Int

Return the number of generating pairs added to `k`. Equals the length
of [`generating_pairs`](@ref Semigroups.generating_pairs)`(k)`.

Complexity: constant.
"""
number_of_generating_pairs(k::Kambites) =
    Int(LibSemigroups.number_of_generating_pairs(k.cxx_obj))

"""
    number_of_classes(k::Kambites) -> UInt64

Compute the number of congruence classes of `k`.

`Kambites` instances can only compute the number of classes when
[`small_overlap_class`](@ref Semigroups.small_overlap_class) is at
least 4, and in that case the number is always
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY); otherwise an
exception is thrown. Use
[`is_positive_infinity`](@ref Semigroups.is_positive_infinity) (or
direct comparison `result == POSITIVE_INFINITY`) to detect the infinite
case.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if it is
  not possible to compute the number of classes because the small
  overlap class is too small (`small_overlap_class(k) < 4`).
"""
number_of_classes(k::Kambites) =
    @wrap_libsemigroups_call LibSemigroups.number_of_classes(k.cxx_obj)

# ============================================================================
# small_overlap_class (const-overload split)
# ============================================================================

"""
    small_overlap_class(k::Kambites) -> UInt64

Get the small overlap class of the [`Presentation`](@ref
Semigroups.Presentation) underlying `k`.

If ``S`` is a finitely presented semigroup with generating set ``A``,
then a word ``w`` over ``A`` is a *piece* if ``w`` occurs as a factor
in at least two of the relations defining ``S``, or if it occurs as a
factor of one relation in two different positions (possibly
overlapping). A finitely presented semigroup ``S`` satisfies the
condition ``C(n)`` for a positive integer ``n`` if the minimum number
of pieces in any factorisation of a word occurring as the left or
right hand side of a relation is at least ``n``.

This function returns the greatest positive integer `n` such that the
finitely presented semigroup represented by `k` satisfies the
condition ``C(n)``, or
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) if no word
occurring in a relation can be written as a product of pieces. It may
trigger computation.

The return type is `UInt64` (rather than `Int`) because
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) is encoded as
`typemax(UInt64) - 1` on the wire and would not round-trip through
`Int`. Use [`is_positive_infinity`](@ref Semigroups.is_positive_infinity)
(or direct comparison `result == POSITIVE_INFINITY`) to detect the
infinite case.

Complexity: ``O(m^3)``, where ``m`` is the sum of the lengths of the
words occurring in the relations of the semigroup.

!!! warning
    [`Semigroups.contains`](@ref Semigroups.contains) and
    [`Semigroups.reduce`](@ref Semigroups.reduce) only work if the
    return value of this function is at least 4.

# See also

[`current_small_overlap_class`](@ref Semigroups.current_small_overlap_class)
"""
small_overlap_class(k::Kambites) = LibSemigroups.small_overlap_class(k.cxx_obj)

"""
    current_small_overlap_class(k::Kambites) -> Union{UInt64, UndefinedType}

Get the current value of the small overlap class of `k`, if known.

Returns the small overlap class if it has already been computed, or
[`UNDEFINED`](@ref Semigroups.UNDEFINED) otherwise. This function does
not trigger any computation. The known value is returned as `UInt64`
(see [`small_overlap_class`](@ref Semigroups.small_overlap_class) for
the rationale).

See [`small_overlap_class`](@ref Semigroups.small_overlap_class) for
more details on what the small overlap class is.

# See also

[`small_overlap_class`](@ref Semigroups.small_overlap_class)
"""
function current_small_overlap_class(k::Kambites)
    val = LibSemigroups.current_small_overlap_class(k.cxx_obj)
    return val == convert(UInt, UNDEFINED) ? UNDEFINED : val
end

# ============================================================================
# Validators
# ============================================================================

"""
    throw_if_letter_not_in_alphabet(k::Kambites{W}, w)

Throw if any letter in `w` is out of bounds.

This function throws a
[`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if any
letter of `w` is out of bounds -- i.e. does not belong to the alphabet
of the [`Presentation`](@ref Semigroups.Presentation) used to
construct `k`.

# Arguments

- `k::Kambites{W}`: the [`Kambites`](@ref Semigroups.Kambites) instance.
- `w`: the word to check (a `Vector{Int}` or `String` according to `W`).

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if any
  letter in `w` is not in the alphabet.
"""
function throw_if_letter_not_in_alphabet(k::Kambites{W}, w) where {W}
    cpp_w = _cong_word_to_cpp(W, w)
    @wrap_libsemigroups_call LibSemigroups.throw_if_letter_not_in_alphabet(k.cxx_obj, cpp_w)
    return nothing
end

"""
    throw_if_not_C4(k::Kambites)

Throw if the [`small_overlap_class`](@ref Semigroups.small_overlap_class)
of `k` is not at least 4.

This function throws an exception if the small overlap class of `k` is
not at least 4 (and computes it if necessary).

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if
  `small_overlap_class(k) < 4`.
"""
function throw_if_not_C4(k::Kambites)
    @wrap_libsemigroups_call LibSemigroups.throw_if_not_C4(k.cxx_obj)
    return nothing
end

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.show(io::IO, k::Kambites)

Print a human-readable representation of `k`. Delegates to
libsemigroups' `to_human_readable_repr`.
"""
function Base.show(io::IO, k::Kambites)
    print(io, LibSemigroups.to_human_readable_repr(k.cxx_obj))
end

# ============================================================================
# non_trivial_classes override (throws)
# ============================================================================

"""
    non_trivial_classes(k1::Kambites, k2::Kambites)

Always throws `ArgumentError` for [`Kambites`](@ref Semigroups.Kambites)
arguments.

`non_trivial_classes(Kambites, Kambites)` is intentionally not provided
upstream (see `kambites-helpers.hpp:128-133`) because both `Kambites`
instances always represent infinite-class congruences, so the
construction does not generalize.
"""
function non_trivial_classes(::Kambites, ::Kambites)
    throw(
        ArgumentError(
            "non_trivial_classes(::Kambites, ::Kambites) is intentionally not " *
            "supported: both Kambites instances always represent infinite-class " *
            "congruences, so the construction does not generalize " *
            "(see kambites-helpers.hpp:128-133).",
        ),
    )
end

# ============================================================================
# normal_forms (bounded; the no-arg form throws)
# ============================================================================

"""
    normal_forms(k::Kambites{W}, n::Integer) -> Vector{W}

Return the first `n` short-lex normal forms of the classes of the
congruence represented by `k`, as words of type `W`.

The underlying range of normal forms is always infinite (one per
congruence class, and a `C(>=4)` presentation has infinitely many
classes), so the caller must specify the bound `n`. The bounded form
materializes only the first `n` words and is safe to call.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if
  `small_overlap_class(k) < 4`.
- `InexactError` if `n` is negative.
"""
function normal_forms(k::Kambites{W}, n::Integer) where {W}
    cpp_n = UInt(n)
    nf = @wrap_libsemigroups_call LibSemigroups.kambites_normal_forms_take(k.cxx_obj, cpp_n)
    return [_cong_word_from_cpp(k, w) for w in nf]
end

"""
    normal_forms(k::Kambites)

Always throws `ArgumentError`. The set of normal forms of a `Kambites`
is infinite, so the no-argument form is unsafe; use the bounded form
[`normal_forms(k, n)`](@ref Semigroups.normal_forms(::Kambites, ::Integer))
instead.
"""
function normal_forms(k::Kambites)
    throw(
        ArgumentError(
            "Kambites has infinitely many normal forms; use normal_forms(k, n) " *
            "to take the first n.",
        ),
    )
end
