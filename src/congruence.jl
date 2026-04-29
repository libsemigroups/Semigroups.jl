# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
congruence.jl - Congruence wrapper (Layer 2 + 3)
"""

# ============================================================================
# Type alias
# ============================================================================

"""
    Congruence

Type implementing a congruence on the free monoid or semigroup defined
by a [`Presentation`](@ref Semigroups.Presentation), via a race between
the [`Kambites`](@ref Semigroups.Kambites),
[`KnuthBendix`](@ref Semigroups.KnuthBendix), and
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter) algorithms. The race
returns the answer of whichever algorithm finishes first; the user does
not need to choose an algorithm up front.

A `Congruence` instance represents a congruence on the free monoid or
semigroup containing the rules of the
[`Presentation`](@ref Semigroups.Presentation) used to construct the
instance, together with the
[`generating_pairs`](@ref Semigroups.generating_pairs) added via
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!). As such,
generating pairs and presentation rules are interchangeable in the
context of `Congruence` objects.

A `Congruence` object is constructed from a
[`congruence_kind`](@ref Semigroups.congruence_kind) and a
[`Presentation`](@ref Semigroups.Presentation), or copied from another
`Congruence`.

`Congruence` is a subtype of
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) (and hence of
[`Runner`](@ref Semigroups.Runner)), so all runner methods (`run!`,
`run_for!`, `finished`, `timed_out`, etc.) and most common congruence
helpers ([`reduce`](@ref Semigroups.reduce),
[`contains`](@ref Semigroups.contains),
[`currently_contains`](@ref Semigroups.currently_contains),
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!),
[`partition`](@ref Semigroups.partition)) work on `Congruence` objects.

# Race introspection

After (or during) a run, the user can query which underlying runners
the race spawned and reach into the winning runner via
[`has`](@ref Semigroups.has) and `Base.get`:

    has(c, KnuthBendix)       # -> Bool
    Base.get(c, KnuthBendix)  # -> KnuthBendix (independent copy)

# Structural deviations from `KnuthBendix` / `ToddCoxeter` precedent

- `Base.length` is intentionally **not** defined. The number of
  classes is finite when the race is won by Todd-Coxeter or
  Knuth-Bendix, but infinite when the winner is Kambites; a uniform
  `length` would silently misbehave. Use
  [`number_of_classes`](@ref Semigroups.number_of_classes) explicitly.
- `max_threads` getter/setter is deferred with the wider threading
  story.

# Constructors

    Congruence() -> Congruence
    Congruence(kind::congruence_kind, p::Presentation) -> Congruence
    Congruence(c::Congruence) -> Congruence

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `p` is
  not valid.

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `Congruence{word_type}` only. String-
    alphabet presentations are deferred to later versions. See the
    [v1 design](https://github.com/libsemigroups/Semigroups.jl/blob/main/docs/superpowers/specs/2026-04-19-semigroups-jl-v1-design.md)
    for the deferred-features list.
"""
const Congruence = LibSemigroups.CongruenceWord

# ============================================================================
# Initialization
# ============================================================================

"""
    Congruence(kind::congruence_kind, p::Presentation) -> Congruence

Construct a [`Congruence`](@ref Semigroups.Congruence) instance
representing a congruence of kind `kind` over the semigroup or monoid
defined by the presentation `p`.

This Julia wrapper builds a default `Congruence` and then calls
[`init!`](@ref Semigroups.init!) so that exceptions raised by
libsemigroups surface as
[`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) (the direct
CxxWrap-bound constructor would surface them as `Base.ErrorException`).

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `p` is
  not valid.
"""
function Congruence(kind::congruence_kind, p::Presentation)
    c = LibSemigroups.CongruenceWord()
    init!(c, kind, p)
    return c
end

"""
    init!(c::Congruence) -> Congruence
    init!(c::Congruence, kind::congruence_kind, p::Presentation) -> Congruence

Re-initialize `c` so that it is in the state it would have been in
immediately after the corresponding constructor.

The one-argument form puts `c` back into the same state as a newly
default-constructed [`Congruence`](@ref Semigroups.Congruence).

The three-argument form puts `c` back into the state it would have been
in if it had just been newly constructed from `kind` and `p`.

Returns `c` for chaining.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `p` is
  not valid (three-argument form only).
"""
function init!(c::Congruence)
    @wrap_libsemigroups_call LibSemigroups.init!(c)
    return c
end

function init!(c::Congruence, kind::congruence_kind, p::Presentation)
    @wrap_libsemigroups_call LibSemigroups.init!(c, kind, p)
    return c
end

# ============================================================================
# Accessors
# ============================================================================

"""
    presentation(c::Congruence) -> Presentation

Return a copy of the [`Presentation`](@ref Semigroups.Presentation) used
to construct or initialize `c` (if any).

The Julia binding returns by value (an independent copy) rather than by
reference; mutating the returned object does not affect `c`.
"""
presentation(c::Congruence) = LibSemigroups.presentation(c)

"""
    generating_pairs(c::Congruence) -> Vector{Tuple{Vector{Int}, Vector{Int}}}

Return the generating pairs of `c` as a vector of 1-based word pairs.

These are the pairs added via
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!). Each pair
`(u, v)` is returned as a 2-tuple of 1-based `Vector{Int}` letter
indices. The length of the returned vector equals
[`number_of_generating_pairs`](@ref Semigroups.number_of_generating_pairs).
"""
function generating_pairs(c::Congruence)
    flat = LibSemigroups.generating_pairs(c)
    result = Tuple{Vector{Int},Vector{Int}}[]
    for i = 1:2:length(flat)
        push!(result, (_word_from_cpp(flat[i]), _word_from_cpp(flat[i+1])))
    end
    return result
end

"""
    kind(c::Congruence) -> congruence_kind

Return the kind of congruence (one- or two-sided) represented by `c`;
see [`congruence_kind`](@ref Semigroups.congruence_kind) for details.

Complexity: constant.
"""
kind(c::Congruence) = LibSemigroups.kind(c)

"""
    number_of_generating_pairs(c::Congruence) -> Int

Return the number of generating pairs added to `c`. Equals the length
of [`generating_pairs`](@ref Semigroups.generating_pairs)`(c)`.

Complexity: constant.
"""
number_of_generating_pairs(c::Congruence) = Int(LibSemigroups.number_of_generating_pairs(c))

"""
    number_of_classes(c::Congruence) -> UInt64

Compute the number of congruence classes of `c`.

This function may trigger a run of the underlying race. The returned
value is finite if the race is won by Todd-Coxeter or Knuth-Bendix on a
finite-class input, and equal to
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) otherwise.

The return type is `UInt64` because
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) is encoded as a
sentinel that does not round-trip through `Int`. Use
[`is_positive_infinity`](@ref Semigroups.is_positive_infinity) (or
direct comparison `result == POSITIVE_INFINITY`) to detect the infinite
case.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if the
  number of classes cannot be computed (e.g. only the Kambites runner
  is available and the small-overlap class is too small).
"""
number_of_classes(c::Congruence) = @wrap_libsemigroups_call LibSemigroups.number_of_classes(c)

"""
    number_of_runners(c::Congruence) -> Int

Return the number of underlying runners that the race in `c` has
spawned. Combined with [`has`](@ref Semigroups.has), useful for
inspecting the race state.

Complexity: constant.
"""
number_of_runners(c::Congruence) = Int(LibSemigroups.number_of_runners(c))

# ============================================================================
# Validators
# ============================================================================

"""
    throw_if_letter_not_in_alphabet(c::Congruence, w::AbstractVector{<:Integer})

Throw if any letter in `w` is out of bounds.

This function throws a
[`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if any
letter of `w` is out of bounds -- i.e. does not belong to the alphabet
of the [`Presentation`](@ref Semigroups.Presentation) used to construct
`c`. Letters in `w` are 1-based indices.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if any
  letter in `w` is not in the alphabet.
"""
function throw_if_letter_not_in_alphabet(c::Congruence, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    @wrap_libsemigroups_call LibSemigroups.throw_if_letter_not_in_alphabet(c, cpp_w)
    return nothing
end

# ============================================================================
# Free function: is_obviously_infinite
# ============================================================================

"""
    is_obviously_infinite(c::Congruence) -> Bool

Return `true` if `c` is *obviously* infinite. Useful as a short-circuit
before calling [`number_of_classes`](@ref Semigroups.number_of_classes),
which may otherwise block on a run of the underlying race for an
infinite-class input.

A return value of `false` does not imply that `c` is finite; it only
means that the conservative analysis used by libsemigroups was unable
to prove infiniteness without running.
"""
is_obviously_infinite(c::Congruence) = LibSemigroups.is_obviously_infinite(c)

# ============================================================================
# Race introspection: has / Base.get
# ============================================================================

"""
    has(c::Congruence, ::Type{T}) -> Bool

Return `true` if the race in `c` has spawned a runner of type `T`,
where `T` is one of [`Kambites`](@ref Semigroups.Kambites),
[`KnuthBendix`](@ref Semigroups.KnuthBendix), or
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter).

# See also

`Base.get(c::Congruence, ::Type{T})` for retrieving the runner.
"""
has(c::Congruence, ::Type{Kambites})    = LibSemigroups.cong_has_kambites(c)
has(c::Congruence, ::Type{KnuthBendix}) = LibSemigroups.cong_has_knuth_bendix(c)
has(c::Congruence, ::Type{ToddCoxeter}) = LibSemigroups.cong_has_todd_coxeter(c)

"""
    Base.get(c::Congruence, ::Type{T}) -> T

Return a copy of the runner of type `T` spawned by the race in `c`,
where `T` is one of [`Kambites`](@ref Semigroups.Kambites),
[`KnuthBendix`](@ref Semigroups.KnuthBendix), or
[`ToddCoxeter`](@ref Semigroups.ToddCoxeter).

The returned value is an **independent copy** of the runner -- mutating
it does not affect the underlying race state in `c`. This matches the
return-by-value choice made in the pybind11 sibling project
(`libsemigroups_pybind11/src/cong.cpp:153-158`); the alternative of
returning a shared-pointer handle would force viral polymorphism
across the wrapper layer.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if no
  runner of type `T` is present in the race (e.g. asking for
  [`Kambites`](@ref Semigroups.Kambites) on a one-sided `Congruence`).

# See also

[`has`](@ref Semigroups.has) for testing without throwing.
"""
Base.get(c::Congruence, ::Type{Kambites}) =
    @wrap_libsemigroups_call LibSemigroups.cong_get_kambites(c)
Base.get(c::Congruence, ::Type{KnuthBendix}) =
    @wrap_libsemigroups_call LibSemigroups.cong_get_knuth_bendix(c)
Base.get(c::Congruence, ::Type{ToddCoxeter}) =
    @wrap_libsemigroups_call LibSemigroups.cong_get_todd_coxeter(c)

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.show(io::IO, c::Congruence)

Print a human-readable representation of `c`. Delegates to
libsemigroups' `to_human_readable_repr`.
"""
function Base.show(io::IO, c::Congruence)
    print(io, LibSemigroups.to_human_readable_repr(c))
end

"""
    Base.copy(c::Congruence) -> Congruence

Create an independent copy of `c` via the C++ copy constructor.
"""
Base.copy(c::Congruence) = LibSemigroups.CongruenceWord(c)

Base.deepcopy_internal(c::Congruence, ::IdDict) = LibSemigroups.CongruenceWord(c)

