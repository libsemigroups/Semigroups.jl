# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
cong-common.jl - shared CongruenceCommon helper wrappers
"""

"""
    CongruenceCommon{W}

Abstract supertype shared by every congruence-style algorithm in
Semigroups.jl. The helpers documented on the
[Common congruence helpers](../cong-common-helpers.md) page are defined
on this supertype and dispatch to whichever concrete subtype is passed
in.

The type parameter `W` is the word type of the congruence: `Vector{Int}`
(1-based letter indices) or `String` (ASCII characters). It mirrors
libsemigroups, where every congruence helper takes and returns the
algorithm's `native_word_type`.

`CongruenceCommon` is itself a subtype of [`Runner`](@ref
Semigroups.Runner), so all runner methods (`run!`, `run_for!`,
`finished`, `timed_out`, `current_state`, etc.) work on every congruence
algorithm.
"""
abstract type CongruenceCommon{W} <: Runner end

const Congruence = LibSemigroups.CongruenceWord

# The C++ binding takes the congruence kind as an Integer and a raw
# `PresentationWord`; adapt the public Julia types to that.
function Congruence(kind::congruence_kind, p::Presentation)
    return @wrap_libsemigroups_call LibSemigroups.CongruenceWord(
        _kind_to_cpp(kind),
        _cxx_word(p),
    )
end

"""
  number_of_classes(cong::CongruenceCommon) -> UInt64

Return the number of classes of `cong`, triggering a full enumeration if
needed.
"""
number_of_classes(cong::CongruenceCommon) =
    @wrap_libsemigroups_call LibSemigroups.number_of_classes(_cxx(cong))

"""
  presentation(cong::CongruenceCommon) -> Presentation

Return the presentation associated with `cong`.
"""
presentation(cong::CongruenceCommon) =
    _wrap_presentation(LibSemigroups.presentation(_cxx(cong)))

"""
  kind(cong::CongruenceCommon) -> congruence_kind

Return whether `cong` is a one-sided or two-sided congruence.
"""
kind(cong::CongruenceCommon) = LibSemigroups.kind(_cxx(cong))

# ============================================================================
# Word-type plumbing
#
# Mirrors libsemigroups, where every congruence_common helper takes and
# returns `Thing::native_word_type`. `_cong_word_type(cong)` is the Julia
# word type (`Vector{Int}` or `String`) of `cong`, i.e. its type parameter.
# ============================================================================

_cong_word_type(::CongruenceCommon{W}) where {W} = W

_cong_word_to_cpp(::Type{Vector{Int}}, w::AbstractVector{<:Integer}) = _word_to_cpp(w)
_cong_word_to_cpp(::Type{String}, w::AbstractString) = _presentation_ascii_string(w)
_cong_word_to_cpp(::Type{W}, w) where {W} = throw(
    ArgumentError("expected a word of type $W for this congruence, got a $(typeof(w))"),
)
_cong_word_to_cpp(cong::CongruenceCommon, w) = _cong_word_to_cpp(_cong_word_type(cong), w)

_cong_words_to_cpp(cong::CongruenceCommon, words) =
    Any[_cong_word_to_cpp(cong, w) for w in words]

_cong_word_from_cpp(cong::CongruenceCommon, w) =
    _presentation_word_from_cpp(_cong_word_type(cong), w)

_cong_classes_from_cpp(cong::CongruenceCommon, classes) =
    [[_cong_word_from_cpp(cong, w) for w in cls] for cls in classes]

const _CONG_WORDS_NOTE = """
Words are 1-based `Vector{Int}` letter indices, or ASCII `String`s for
congruences over `String` words; the word type must match that of
`cong`."""

"""
    add_generating_pair!(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> CongruenceCommon
    add_generating_pair!(cong::CongruenceCommon, u::AbstractString, v::AbstractString) -> CongruenceCommon

Add a generating pair `(u, v)` to `cong`.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence to add a generating pair to.
- `u::AbstractVector{<:Integer}`: the left-hand side of the pair, as a
  1-based `Vector{Int}` of letter indices.
- `v::AbstractVector{<:Integer}`: the right-hand side of the pair, as a
  1-based `Vector{Int}` of letter indices.

Returns `cong` for chaining.

# Throws

- `LibsemigroupsError` if any letter in `u` or `v` is not in the
  alphabet of the underlying presentation.
"""
function add_generating_pair!(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    return _cong_add_generating_pair!(cong, u, v)
end

add_generating_pair!(cong::CongruenceCommon, u::AbstractString, v::AbstractString) =
    _cong_add_generating_pair!(cong, u, v)

function _cong_add_generating_pair!(cong::CongruenceCommon, u, v)
    cpp_u = _cong_word_to_cpp(cong, u)
    cpp_v = _cong_word_to_cpp(cong, v)
    @wrap_libsemigroups_call LibSemigroups.cong_common_add_generating_pair!(
        _cxx(cong),
        cpp_u,
        cpp_v,
    )
    return cong
end

"""
    currently_contains(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> tril
    currently_contains(cong::CongruenceCommon, u::AbstractString, v::AbstractString) -> tril

Check whether the words `u` and `v` are already known to be equivalent
under `cong`, without triggering a run.

This function performs no enumeration of `cong`, so it is possible for
`u` and `v` to be equivalent in the congruence but for that not yet to
be known.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence to check containment in.
- `u::AbstractVector{<:Integer}`: the first word, as a 1-based
  `Vector{Int}` of letter indices.
- `v::AbstractVector{<:Integer}`: the second word, as a 1-based
  `Vector{Int}` of letter indices.

# Returns

A [`tril`](@ref Semigroups.tril) value:

- `tril_TRUE` if the words are known to belong to the congruence;
- `tril_FALSE` if the words are known not to belong to the congruence;
- `tril_unknown` otherwise.

# Throws

- `LibsemigroupsError` if any letter in `u` or `v` is not in the
  alphabet of the underlying presentation.

# See also

[`contains`](@ref Semigroups.contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))
"""
function currently_contains(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    return _cong_currently_contains(cong, u, v)
end

currently_contains(cong::CongruenceCommon, u::AbstractString, v::AbstractString) =
    _cong_currently_contains(cong, u, v)

function _cong_currently_contains(cong::CongruenceCommon, u, v)
    cpp_u = _cong_word_to_cpp(cong, u)
    cpp_v = _cong_word_to_cpp(cong, v)
    return @wrap_libsemigroups_call LibSemigroups.cong_common_currently_contains(
        _cxx(cong),
        cpp_u,
        cpp_v,
    )
end

"""
    contains(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> Bool
    contains(cong::CongruenceCommon, u::AbstractString, v::AbstractString) -> Bool

Check whether the words `u` and `v` are equivalent under `cong`.

This function triggers a full enumeration of `cong`, which may never
terminate.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence to check containment in.
- `u::AbstractVector{<:Integer}`: the first word, as a 1-based
  `Vector{Int}` of letter indices.
- `v::AbstractVector{<:Integer}`: the second word, as a 1-based
  `Vector{Int}` of letter indices.

# Returns

`true` if `u` and `v` are equivalent under `cong`, `false` otherwise.

# Throws

- `LibsemigroupsError` if any letter in `u` or `v` is not in the
  alphabet of the underlying presentation.

!!! warning
    The Knuth-Bendix algorithm (and several other congruence algorithms)
    may never terminate for an undecidable input.

# See also

[`currently_contains`](@ref Semigroups.currently_contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))
"""
function contains(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    return _cong_contains(cong, u, v)
end

contains(cong::CongruenceCommon, u::AbstractString, v::AbstractString) =
    _cong_contains(cong, u, v)

function _cong_contains(cong::CongruenceCommon, u, v)
    cpp_u = _cong_word_to_cpp(cong, u)
    cpp_v = _cong_word_to_cpp(cong, v)
    return @wrap_libsemigroups_call LibSemigroups.cong_common_contains(
        _cxx(cong),
        cpp_u,
        cpp_v,
    )
end

"""
    reduce_no_run(cong::CongruenceCommon, w::AbstractVector{<:Integer}) -> Vector{Int}
    reduce_no_run(cong::CongruenceCommon, w::AbstractString) -> String

Reduce the word `w` using the current state of `cong`, without
triggering an enumeration.

The output word is equivalent to `w` in the congruence represented by
`cong`. If `cong` is [`finished`](@ref Semigroups.finished), the output
is a normal form for `w`. Otherwise, equivalent input words may produce
different output words.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence to reduce in.
- `w::AbstractVector{<:Integer}`: the word to reduce, as a 1-based
  `Vector{Int}` of letter indices.

# Returns

A 1-based `Vector{Int}` representing a word equivalent to `w` under the
current rules of `cong`.

# Throws

- `LibsemigroupsError` if any letter in `w` is not in the alphabet of
  the underlying presentation.

# See also

[`reduce`](@ref Semigroups.reduce(::CongruenceCommon, ::AbstractVector{<:Integer}))
"""
reduce_no_run(cong::CongruenceCommon, w::AbstractVector{<:Integer}) =
    _cong_reduce_no_run(cong, w)

reduce_no_run(cong::CongruenceCommon, w::AbstractString) = _cong_reduce_no_run(cong, w)

function _cong_reduce_no_run(cong::CongruenceCommon, w)
    cpp_w = _cong_word_to_cpp(cong, w)
    result =
        @wrap_libsemigroups_call LibSemigroups.cong_common_reduce_no_run(_cxx(cong), cpp_w)
    return _cong_word_from_cpp(cong, result)
end

"""
    reduce(cong::CongruenceCommon, w::AbstractVector{<:Integer}) -> Vector{Int}
    reduce(cong::CongruenceCommon, w::AbstractString) -> String

Reduce the word `w` to a normal form under `cong`.

This function triggers a full enumeration of `cong`. The output word is
a normal form for `w` in the congruence.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence to reduce in.
- `w::AbstractVector{<:Integer}`: the word to reduce, as a 1-based
  `Vector{Int}` of letter indices.

# Returns

A 1-based `Vector{Int}` representing a normal form of `w` in `cong`.

# Throws

- `LibsemigroupsError` if any letter in `w` is not in the alphabet of
  the underlying presentation.

!!! warning
    The Knuth-Bendix algorithm (and several other congruence algorithms)
    may never terminate for an undecidable input.

!!! note
    `Semigroups.reduce` is **not** exported, since exporting it would
    shadow `Base.reduce`. Use the module-qualified form
    `Semigroups.reduce(cong, w)`.

# See also

[`reduce_no_run`](@ref Semigroups.reduce_no_run(::CongruenceCommon, ::AbstractVector{<:Integer}))
"""
reduce(cong::CongruenceCommon, w::AbstractVector{<:Integer}) = _cong_reduce(cong, w)

reduce(cong::CongruenceCommon, w::AbstractString) = _cong_reduce(cong, w)

function _cong_reduce(cong::CongruenceCommon, w)
    cpp_w = _cong_word_to_cpp(cong, w)
    result = @wrap_libsemigroups_call LibSemigroups.cong_common_reduce(_cxx(cong), cpp_w)
    return _cong_word_from_cpp(cong, result)
end

"""
    normal_forms(cong::CongruenceCommon) -> Vector{Vector{Int}}

Return the normal forms of every congruence class of `cong`.

The order of the classes, and the normal form chosen for each class,
are determined by the reduction order of `cong`. This function triggers
a full enumeration of `cong`.

# Returns

A `Vector` of 1-based `Vector{Int}` words, one per congruence class.

!!! warning
    The Knuth-Bendix algorithm (and several other congruence algorithms)
    may never terminate for an undecidable input. If the congruence has
    infinitely many classes, this function does not return.

# See also

[`partition`](@ref Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})),
[`non_trivial_classes`](@ref Semigroups.non_trivial_classes(::CongruenceCommon, ::CongruenceCommon))
"""
function normal_forms(cong::CongruenceCommon)
    nf = @wrap_libsemigroups_call LibSemigroups.cong_common_normal_forms(_cxx(cong))
    return [_cong_word_from_cpp(cong, w) for w in nf]
end

"""
    partition(cong::CongruenceCommon, words::AbstractVector{<:AbstractVector{<:Integer}}) -> Vector{Vector{Vector{Int}}}
    partition(cong::CongruenceCommon, words::AbstractVector{<:AbstractString}) -> Vector{Vector{String}}

Partition `words` into congruence classes induced by `cong`.

Each returned class is a list of the input words that belong to the
same congruence class. This function triggers a full enumeration of
`cong`.

$(_CONG_WORDS_NOTE)

# Arguments

- `cong::CongruenceCommon`: the congruence used to partition the words.
- `words::AbstractVector{<:AbstractVector{<:Integer}}`: the input words,
  each a 1-based `Vector{Int}` of letter indices.

# Returns

A `Vector` of classes; each class is a `Vector` of 1-based `Vector{Int}`
words.

# Throws

- `LibsemigroupsError` if `cong` has infinitely many classes (the
  partition would not be finite).

# See also

[`non_trivial_classes`](@ref Semigroups.non_trivial_classes(::CongruenceCommon, ::CongruenceCommon)),
[`normal_forms`](@ref Semigroups.normal_forms(::CongruenceCommon))
"""
function partition(
    cong::CongruenceCommon,
    words::AbstractVector{<:AbstractVector{<:Integer}},
)
    return _cong_partition(cong, words)
end

partition(cong::CongruenceCommon, words::AbstractVector{<:AbstractString}) =
    _cong_partition(cong, words)

function _cong_partition(cong::CongruenceCommon, words)
    # Convert outside @wrap_libsemigroups_call so that word-type/ASCII
    # errors surface as ArgumentError rather than LibsemigroupsError.
    cpp_words = _cong_words_to_cpp(cong, words)
    classes =
        @wrap_libsemigroups_call LibSemigroups.cong_common_partition(_cxx(cong), cpp_words)
    return _cong_classes_from_cpp(cong, classes)
end

"""
    non_trivial_classes(cong1::CongruenceCommon, cong2::CongruenceCommon) -> Vector{Vector{Vector{Int}}}

Return the classes of size at least 2 in the partition of the normal
forms of `cong2` induced by `cong1`.

Here `cong1` must represent a coarser congruence than `cong2` (i.e. one
with fewer classes). This function triggers a full enumeration of both
arguments.

This function does **not** compute the normal forms of `cong2`,
partition them by `cong1`, and filter; it can therefore return the
non-trivial classes even when one of `cong1` or `cong2` has infinitely
many classes, provided there are only finitely many finite non-trivial
classes.

# Arguments

- `cong1::CongruenceCommon`: the coarser congruence.
- `cong2::CongruenceCommon`: the finer congruence.

# Returns

A `Vector` of non-trivial classes; each class is a `Vector` of 1-based
`Vector{Int}` words.

# Throws

- `LibsemigroupsError` if `cong1` has infinitely many classes and
  `cong2` has finitely many classes (so that there is at least one
  infinite non-trivial class).
- `LibsemigroupsError` if the alphabets of the underlying presentations
  of `cong1` and `cong2` are not equal.
- `LibsemigroupsError` if [`gilman_graph`](@ref Semigroups.gilman_graph)
  of `cong1` has fewer nodes than that of `cong2` (Knuth-Bendix only).

!!! warning
    The Knuth-Bendix algorithm (and several other congruence algorithms)
    may never terminate for an undecidable input.

# See also

[`partition`](@ref Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})),
[`normal_forms`](@ref Semigroups.normal_forms(::CongruenceCommon))
"""
function non_trivial_classes(cong1::CongruenceCommon, cong2::CongruenceCommon)
    classes = @wrap_libsemigroups_call LibSemigroups.cong_common_non_trivial_classes(
        _cxx(cong1),
        _cxx(cong2),
    )
    return _cong_classes_from_cpp(cong1, classes)
end
