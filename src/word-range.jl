# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
word-range.jl - WordRange wrapper

Lex/shortlex enumeration of words over an alphabet of a given size, bounded
by min/max length and optional first/last bookends. Uses `_word_to_cpp` /
`_word_from_cpp` helpers defined in `order.jl` to convert 1-based Julia
letter indices to/from 0-based C++ letter indices at the boundary.
"""

# ============================================================================
# Type alias
# ============================================================================

"""
    WordRange

An iterable range over words in an alphabet, in a user-selected order.

Configure with [`set_alphabet_size!`](@ref), [`set_min!`](@ref),
[`set_max!`](@ref), [`set_first!`](@ref), [`set_last!`](@ref),
[`set_order!`](@ref), [`set_upper_bound!`](@ref), then iterate with
[`Base.get(::WordRange)`](@ref) / [`next!`](@ref) / [`at_end`](@ref)
or the standard Julia iteration protocol (`for w in r`, `collect(r)`, etc.).

A default-constructed `WordRange` is empty, with alphabet size `0`, order
[`ORDER_SHORTLEX`](@ref), and empty first/last bookends.

# Example
```jldoctest
julia> using Semigroups

julia> r = WordRange();

julia> set_alphabet_size!(r, 2);

julia> set_min!(r, 1);

julia> set_max!(r, 3);

julia> collect(r)
6-element Vector{Vector{Int64}}:
 [1]
 [2]
 [1, 1]
 [1, 2]
 [2, 1]
 [2, 2]
```
"""
const WordRange = LibSemigroups.WordRange

# ============================================================================
# Iteration protocol primitives
# ============================================================================

"""
    Base.get(r::WordRange) -> Vector{Int}

Get the current word from the range.

Returns the current word in a [`WordRange`](@ref) object as a `Vector{Int}`
of 1-based letter indices.
"""
Base.get(r::WordRange) = _word_from_cpp(LibSemigroups.get(r))

"""
    next!(r::WordRange) -> WordRange

Advance the range to the next word (if any).

# See also
- [`at_end`](@ref)
"""
next!(r::WordRange) = (LibSemigroups.next!(r); r)

"""
    at_end(r::WordRange) -> Bool

Check if the range has been exhausted.

Returns `true` if a [`WordRange`](@ref) object is exhausted, and `false`
otherwise.
"""
at_end(r::WordRange) = LibSemigroups.at_end(r)

"""
    size_hint(r::WordRange) -> Int

The possible size of the range.

Returns the number of words in a [`WordRange`](@ref) object if its order is
[`ORDER_SHORTLEX`](@ref). If the order is not shortlex, then the return value
of this function is meaningless.
"""
size_hint(r::WordRange) = Int(LibSemigroups.size_hint(r))

"""
    count(r::WordRange) -> Int

The actual size of the range.

Returns the number of words in a [`WordRange`](@ref) object. If the order is
[`ORDER_SHORTLEX`](@ref) then [`size_hint`](@ref) is used. If the order is not
shortlex then a copy of the range may have to be looped over in order to
compute the return value.
"""
Base.count(r::WordRange) = Int(LibSemigroups.count(r))

"""
    valid(r::WordRange) -> Bool

Return whether the settings have not changed since the last call to
[`next!`](@ref) or [`Base.get(::WordRange)`](@ref).

Other than by calling [`next!`](@ref), the value returned by
[`Base.get(::WordRange)`](@ref) may be altered by a call to any of:
[`set_order!`](@ref), [`set_alphabet_size!`](@ref), [`set_min!`](@ref),
[`set_max!`](@ref), [`set_first!`](@ref), [`set_last!`](@ref),
[`set_upper_bound!`](@ref).

Returns `true` if none of these settings have changed since the last
[`next!`](@ref) or [`Base.get(::WordRange)`](@ref) call, and `false`
otherwise.
"""
valid(r::WordRange) = LibSemigroups.valid(r)

"""
    init!(r::WordRange) -> WordRange

Re-initialize an existing [`WordRange`](@ref) object.

Puts `r` back into the same state as if it had been newly default-constructed.
"""
init!(r::WordRange) = (LibSemigroups.init!(r); r)

# ============================================================================
# Configuration getters and setters
# ============================================================================

"""
    alphabet_size(r::WordRange) -> Int

Return the current number of letters in the alphabet of `r`.
"""
alphabet_size(r::WordRange) = Int(LibSemigroups.alphabet_size(r))

"""
    set_alphabet_size!(r::WordRange, n::Integer) -> WordRange

Set the number of letters in the alphabet of `r` to `n`.

# Arguments
- `n::Integer`: the number of letters.
"""
set_alphabet_size!(r::WordRange, n::Integer) =
    (LibSemigroups.set_alphabet_size!(r, UInt(n)); r)

# first_word / last_word expose the lower/upper bookends of the range.
# Renamed from upstream `first()` / `last()` to avoid colliding with
# Base.first(itr) / Base.last(itr) whose semantics are iteration-based.
"""
    first_word(r::WordRange) -> Vector{Int}

Return the current first word (lower bookend) of `r`.

Returned as a `Vector{Int}` of 1-based letter indices. See
[`set_first!`](@ref) to configure.
"""
first_word(r::WordRange) = _word_from_cpp(LibSemigroups.first(r))

"""
    set_first!(r::WordRange, w::AbstractVector{<:Integer}) -> WordRange

Set the first word (lower bookend) of `r` to `w`.

Performs no checks on its arguments. If `w` contains letters greater than
[`alphabet_size`](@ref), then `r` will be empty. Similarly, if the first word
is greater than the last word with respect to the current order, `r` will be
empty.

# Arguments
- `w::AbstractVector{<:Integer}`: the first word (1-based letter indices).
"""
set_first!(r::WordRange, w::AbstractVector{<:Integer}) =
    (LibSemigroups.set_first!(r, _word_to_cpp(w)); r)

"""
    last_word(r::WordRange) -> Vector{Int}

Return the current one-past-the-last word (upper bookend) of `r`.

Returned as a `Vector{Int}` of 1-based letter indices. See
[`set_last!`](@ref) to configure.
"""
last_word(r::WordRange) = _word_from_cpp(LibSemigroups.last(r))

"""
    set_last!(r::WordRange, w::AbstractVector{<:Integer}) -> WordRange

Set the one-past-the-last word (upper bookend) of `r` to `w`.

Performs no checks on its arguments. If `w` contains letters greater than
[`alphabet_size`](@ref), then `r` will be empty.

# Arguments
- `w::AbstractVector{<:Integer}`: one past the last word (1-based letter indices).
"""
set_last!(r::WordRange, w::AbstractVector{<:Integer}) =
    (LibSemigroups.set_last!(r, _word_to_cpp(w)); r)

"""
    order(r::WordRange) -> Order

Return the current [`Order`](@ref) of the words in `r`.
"""
AbstractAlgebra.order(r::WordRange) = LibSemigroups.order(r)

"""
    set_order!(r::WordRange, o::Order) -> WordRange

Set the order of the words in `r` to `o`.

# Arguments
- `o::Order`: the order; must be [`ORDER_SHORTLEX`](@ref) or [`ORDER_LEX`](@ref).

# Throws
- `LibsemigroupsError`: if `o` is not [`ORDER_SHORTLEX`](@ref) or
  [`ORDER_LEX`](@ref).
"""
set_order!(r::WordRange, o::Order) = (LibSemigroups.set_order!(r, o); r)

"""
    upper_bound(r::WordRange) -> Int

Return the current upper bound on the length of a word in `r`.

This setting is only used when the order of `r` is [`ORDER_LEX`](@ref).
"""
upper_bound(r::WordRange) = Int(LibSemigroups.upper_bound(r))

"""
    set_upper_bound!(r::WordRange, n::Integer) -> WordRange

Set an upper bound for the length of a word in `r`.

This setting is only used when the order of `r` is [`ORDER_LEX`](@ref).

# Arguments
- `n::Integer`: the upper bound.
"""
set_upper_bound!(r::WordRange, n::Integer) = (LibSemigroups.set_upper_bound!(r, UInt(n)); r)

"""
    set_min!(r::WordRange, n::Integer) -> WordRange

Set the minimum word length of `r` to `n`.

Sets the first word of `r` to the word consisting of `n` copies of letter `1`.

# Arguments
- `n::Integer`: the minimum length.
"""
set_min!(r::WordRange, n::Integer) = (LibSemigroups.set_min!(r, UInt(n)); r)

"""
    set_max!(r::WordRange, n::Integer) -> WordRange

Set one past the maximum word length of `r` to `n`.

Sets the one-past-the-last word of `r` to the word consisting of `n` copies of
letter `1`. So, after `set_max!(r, n)`, `r` contains words of length strictly
less than `n`.

# Arguments
- `n::Integer`: one greater than the maximum length.
"""
set_max!(r::WordRange, n::Integer) = (LibSemigroups.set_max!(r, UInt(n)); r)

# ============================================================================
# Julia iteration protocol
# ============================================================================

Base.IteratorSize(::Type{<:WordRange}) = Base.SizeUnknown()
Base.eltype(::Type{<:WordRange}) = Vector{Int}

function Base.iterate(r::WordRange, state = nothing)
    at_end(r) && return nothing
    w = Base.get(r)
    next!(r)
    return (w, nothing)
end

# ============================================================================
# Free functions
# ============================================================================

"""
    number_of_words(n::Integer, min::Integer, max::Integer) -> Int

Return the number of words over an alphabet of `n` letters with length in the
range `[min, max)`, i.e. ``\\sum_{i=\\min}^{\\max-1} n^i``.

# Arguments
- `n::Integer`: the number of letters in the alphabet.
- `min::Integer`: the minimum word length.
- `max::Integer`: one greater than the maximum word length.

!!! warning
    If the resulting count exceeds `2^64 - 1` the return value will not be
    correct.
"""
number_of_words(n::Integer, min::Integer, max::Integer) =
    Int(LibSemigroups.number_of_words(UInt(n), UInt(min), UInt(max)))

"""
    random_word(length::Integer, nr_letters::Integer) -> Vector{Int}

Return a uniformly random word of the given `length` over an alphabet of
`nr_letters` letters, with 1-based letter indices.

# Arguments
- `length::Integer`: the length of the word.
- `nr_letters::Integer`: the size of the alphabet.

# Throws
- `LibsemigroupsError`: if `nr_letters` is `0`.
"""
random_word(length::Integer, nr_letters::Integer) =
    _word_from_cpp(LibSemigroups.random_word(UInt(length), UInt(nr_letters)))
