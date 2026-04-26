# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
paths.jl - Paths wrapper

Stateful range over paths in a [`WordGraph`](@ref). The Julia wrapper struct
holds the underlying CxxWrap handle plus a reference to the source `WordGraph`,
which serves as a GC pin: libsemigroups' `Paths<Node>` stores only a raw
pointer to the `WordGraph`, so the Julia wrapper is responsible for keeping the
graph alive for as long as the [`Paths`](@ref) exists.

Index conventions (1-based at the boundary, 0-based in C++) and sentinel
mapping ([`UNDEFINED`](@ref Semigroups.UNDEFINED) ↔ `typemax(UInt32)`,
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) ↔ `typemax(UInt) - 1`)
are handled by the private helpers at the top of this file.
"""

# ============================================================================
# Index / sentinel conversion (private, file-local)
# ----------------------------------------------------------------------------
# The C++ binding is pure pass-through: all conversion happens here, on the
# Julia side. `_to_cpp` calls live OUTSIDE @wrap_libsemigroups_call so that a
# native InexactError (from a zero or negative input being cast to UInt32 /
# UInt) propagates as InexactError rather than being re-wrapped.
# ============================================================================

# Nodes (uint32_t). UNDEFINED = typemax(UInt32).
@inline _node_to_cpp(x::Integer) = UInt32(x - 1)
@inline _node_to_cpp(::UndefinedType) = typemax(UInt32)
@inline _node_from_cpp(x::Integer) =
    x == typemax(UInt32) ? UNDEFINED : Int(x) + 1

# Path lengths (size_t). POSITIVE_INFINITY = typemax(UInt) - 1.
@inline _length_to_cpp(x::Integer) = UInt(x)
@inline _length_to_cpp(::PositiveInfinityType) = convert(UInt, POSITIVE_INFINITY)
@inline function _length_from_cpp(x::Integer)
    x == convert(UInt, POSITIVE_INFINITY) ? POSITIVE_INFINITY : Int(x)
end

# `_word_from_cpp` (1-based letter conversion) is reused from `src/order.jl`,
# included earlier in `src/Semigroups.jl`.

# ============================================================================
# Wrapper struct
# ============================================================================

"""
    Paths

Type for a stateful range over paths in a [`WordGraph`](@ref).

A `Paths` object wraps libsemigroups' `Paths<uint32_t>` together with a
reference to the source [`WordGraph`](@ref) that pins it for garbage
collection. The C++ object stores only a raw pointer to the word graph, so
keeping the Julia wrapper alive is what keeps the underlying graph alive.

Configure with [`source!`](@ref), [`target!`](@ref), [`min!`](@ref),
[`max!`](@ref), [`order!`](@ref), then iterate with the standard Julia
iteration protocol (`for w in p`, `collect(p)`) or via the manual interface
([`Base.get`](@ref), [`next!`](@ref), [`at_end`](@ref), [`Base.count`](@ref)).

# Example
```jldoctest
julia> using Semigroups

julia> g = WordGraph(3, 2);

julia> target!(g, 1, 1, 2); target!(g, 1, 2, 3); target!(g, 2, 1, 3);

julia> p = paths(g; source = 1, max = 3, order = ORDER_SHORTLEX);

julia> collect(p)
4-element Vector{Vector{Int64}}:
 []
 [1]
 [2]
 [1, 1]
```
"""
mutable struct Paths
    g::WordGraph
    cxx::LibSemigroups.PathsCxx
end

"""
    Paths(g::WordGraph) -> Paths

Construct a new [`Paths`](@ref) over `g`.

The new range has source and target [`UNDEFINED`](@ref Semigroups.UNDEFINED),
minimum length `0`, maximum length [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY),
and order [`ORDER_SHORTLEX`](@ref). At least the source must be set (via
[`source!`](@ref)) before the range can be iterated.

# Arguments
- `g::WordGraph`: the word graph.

See also [`paths`](@ref).
"""
Paths(g::WordGraph) = Paths(g, LibSemigroups.PathsCxx(g))

# ============================================================================
# Read-only getters
# ============================================================================

"""
    source(p::Paths) -> Union{Int, UndefinedType}

Return the current source node of `p`.

Returns [`UNDEFINED`](@ref Semigroups.UNDEFINED) if no source has been set.

See also [`source!`](@ref).
"""
source(p::Paths) = _node_from_cpp(LibSemigroups.source(p.cxx))

"""
    target(p::Paths) -> Union{Int, UndefinedType}

Return the current target node of `p`.

Returns [`UNDEFINED`](@ref Semigroups.UNDEFINED) if no specific target has been
set, in which case the range yields paths to *any* reachable node.

See also [`target!`](@ref).
"""
target(p::Paths) = _node_from_cpp(LibSemigroups.target(p.cxx))

"""
    Base.min(p::Paths) -> Int

Return the current minimum path length of `p`.

This getter is not exported; call as `Semigroups.min(p)` or `Base.min(p)`.

See also [`min!`](@ref).
"""
Base.min(p::Paths) = _length_from_cpp(LibSemigroups.min(p.cxx))

"""
    Base.max(p::Paths) -> Union{Int, PositiveInfinityType}

Return the current maximum path length of `p`.

Returns [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) if no upper
bound is set. This getter is not exported; call as `Semigroups.max(p)` or
`Base.max(p)`.

See also [`max!`](@ref).
"""
Base.max(p::Paths) = _length_from_cpp(LibSemigroups.max(p.cxx))

"""
    order(p::Paths) -> Order

Return the current word [`Order`](@ref) of `p`.

The value is either [`ORDER_SHORTLEX`](@ref) or [`ORDER_LEX`](@ref).

See also [`order!`](@ref).
"""
AbstractAlgebra.order(p::Paths) = LibSemigroups.order(p.cxx)

"""
    current_target(p::Paths) -> Union{Int, UndefinedType}

Return the current target node of the path labelled by [`Base.get`](@ref).

If there is no such path (for example because [`source`](@ref) is undefined),
returns [`UNDEFINED`](@ref Semigroups.UNDEFINED).
"""
current_target(p::Paths) = _node_from_cpp(LibSemigroups.current_target(p.cxx))

"""
    word_graph(p::Paths) -> WordGraph

Return the [`WordGraph`](@ref) over which `p` ranges.

This is the Julia wrapper's pinned graph reference; no C++ trip is required.
"""
word_graph(p::Paths) = p.g

# ============================================================================
# Setters
# ============================================================================

"""
    source!(p::Paths, n::Integer) -> Paths

Set the source node of `p` to `n`.

# Arguments
- `n::Integer`: the source node (1-based).

# Throws
- `LibsemigroupsError`: if `n` is not a node of [`word_graph`](@ref)`(p)`.
- `InexactError`: if `n` is zero or negative (the 1-based guard fires before
  the call reaches C++).

See also [`source`](@ref).
"""
function source!(p::Paths, n::Integer)
    s = _node_to_cpp(n)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.source!(p.cxx, s)
    end
    return p
end

"""
    target!(p::Paths, n::Integer) -> Paths
    target!(p::Paths, ::UndefinedType) -> Paths

Set the target node of `p` to `n`, or clear it (yielding "any reachable
target") with [`UNDEFINED`](@ref Semigroups.UNDEFINED).

# Arguments
- `n`: the target node (1-based), or [`UNDEFINED`](@ref Semigroups.UNDEFINED).

# Throws
- `LibsemigroupsError`: if `n` is not a node of [`word_graph`](@ref)`(p)`.
- `InexactError`: if `n` is zero or negative.

See also [`target`](@ref).
"""
function target!(p::Paths, n::Integer)
    t = _node_to_cpp(n)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.target!(p.cxx, t)
    end
    return p
end

function target!(p::Paths, ::UndefinedType)
    t = _node_to_cpp(UNDEFINED)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.target!(p.cxx, t)
    end
    return p
end

"""
    min!(p::Paths, n::Integer) -> Paths

Set the minimum path length of `p` to `n`.

# Arguments
- `n::Integer`: the new minimum length (non-negative).

# Throws
- `InexactError`: if `n` is negative (the unsigned-cast guard fires before
  the call reaches C++).

See also [`Base.min`](@ref).
"""
function min!(p::Paths, n::Integer)
    v = _length_to_cpp(n)
    # No `@wrap_libsemigroups_call`: the underlying C++ setter is `noexcept`
    # (paths.hpp:1014), so wrapping would hide nothing. The asymmetry with
    # `source!` / `target!` / `order!` mirrors the libsemigroups noexcept
    # annotations.
    GC.@preserve p begin
        LibSemigroups.min!(p.cxx, v)
    end
    return p
end

"""
    max!(p::Paths, n::Integer) -> Paths
    max!(p::Paths, ::PositiveInfinityType) -> Paths

Set the maximum path length of `p` to `n`, or remove the upper bound by
passing [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY).

# Arguments
- `n`: the new maximum length, or
  [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY).

# Throws
- `InexactError`: if `n` is negative (the unsigned-cast guard fires before
  the call reaches C++).

See also [`Base.max`](@ref).
"""
function max!(p::Paths, n::Integer)
    v = _length_to_cpp(n)
    # See `min!` re: noexcept setter; no `@wrap_libsemigroups_call` needed.
    GC.@preserve p begin
        LibSemigroups.max!(p.cxx, v)
    end
    return p
end

function max!(p::Paths, ::PositiveInfinityType)
    v = _length_to_cpp(POSITIVE_INFINITY)
    GC.@preserve p begin
        LibSemigroups.max!(p.cxx, v)
    end
    return p
end

"""
    order!(p::Paths, o::Order) -> Paths

Set the word ordering of `p` to `o`.

# Arguments
- `o::Order`: the ordering; must be [`ORDER_SHORTLEX`](@ref) or
  [`ORDER_LEX`](@ref).

# Throws
- `LibsemigroupsError`: if `o` is neither [`ORDER_SHORTLEX`](@ref) nor
  [`ORDER_LEX`](@ref).

See also [`order`](@ref).
"""
function order!(p::Paths, o::Order)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.order!(p.cxx, o)
    end
    return p
end

# ============================================================================
# Validation
# ============================================================================

"""
    throw_if_source_undefined(p::Paths) -> nothing

Throw if the source node of `p` has not been set.

This function is the Julia mirror of libsemigroups'
`Paths::throw_if_source_undefined()`. It is called automatically by
[`Base.get`](@ref), [`next!`](@ref), [`at_end`](@ref), and
[`Base.count`](@ref) since the underlying C++ implementation does *not*
internally guard those operations.

# Throws
- `LibsemigroupsError`: if [`source`](@ref)`(p)` is
  [`UNDEFINED`](@ref Semigroups.UNDEFINED).
"""
function throw_if_source_undefined(p::Paths)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.throw_if_source_undefined(p.cxx)
    end
    return nothing
end

# ============================================================================
# Range / iteration interface
# ============================================================================

"""
    Base.get(p::Paths) -> Vector{Int}

Get the current path in the range as a vector of 1-based edge labels.

# Throws
- `LibsemigroupsError`: if [`source`](@ref)`(p)` is
  [`UNDEFINED`](@ref Semigroups.UNDEFINED).

See also [`next!`](@ref), [`at_end`](@ref).
"""
function Base.get(p::Paths)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.throw_if_source_undefined(p.cxx)
        w = @wrap_libsemigroups_call LibSemigroups.get(p.cxx)
    end
    return _word_from_cpp(w)
end

"""
    next!(p::Paths) -> Paths

Advance `p` to the next path (if any).

# Throws
- `LibsemigroupsError`: if [`source`](@ref)`(p)` is
  [`UNDEFINED`](@ref Semigroups.UNDEFINED).

See also [`Base.get`](@ref), [`at_end`](@ref).
"""
function next!(p::Paths)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.throw_if_source_undefined(p.cxx)
        @wrap_libsemigroups_call LibSemigroups.next!(p.cxx)
    end
    return p
end

"""
    at_end(p::Paths) -> Bool

Return `true` if `p` has been exhausted, and `false` otherwise.

# Throws
- `LibsemigroupsError`: if [`source`](@ref)`(p)` is
  [`UNDEFINED`](@ref Semigroups.UNDEFINED).

See also [`next!`](@ref).
"""
function at_end(p::Paths)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.throw_if_source_undefined(p.cxx)
        result = @wrap_libsemigroups_call LibSemigroups.at_end(p.cxx)
    end
    return result
end

"""
    Base.count(p::Paths) -> Union{Int, PositiveInfinityType}

Return the number of paths in the range.

If the range is infinite (cyclic graph with no upper bound on length), returns
[`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY).

# Throws
- `LibsemigroupsError`: if [`source`](@ref)`(p)` is
  [`UNDEFINED`](@ref Semigroups.UNDEFINED).
"""
function Base.count(p::Paths)
    GC.@preserve p begin
        @wrap_libsemigroups_call LibSemigroups.throw_if_source_undefined(p.cxx)
        c = @wrap_libsemigroups_call LibSemigroups.count(p.cxx)
    end
    return _length_from_cpp(c)
end

# ============================================================================
# Julia iteration protocol
# ============================================================================
# Destructive iteration matches the WordRange precedent (`src/word-range.jl`).
# A `for w in p; ...; end` loop or `collect(p)` advances `p` itself; after
# completion, `at_end(p)` is true.

Base.IteratorSize(::Type{Paths}) = Base.SizeUnknown()
Base.eltype(::Type{Paths}) = Vector{Int}

function Base.iterate(p::Paths, state = nothing)
    at_end(p) && return nothing
    w = Base.get(p)
    next!(p)
    return (w, nothing)
end

# ============================================================================
# Display
# ============================================================================

function Base.show(io::IO, p::Paths)
    print(io, LibSemigroups.to_human_readable_repr(p.cxx))
end

# ============================================================================
# Keyword-arg factory
# ============================================================================

"""
    paths(g::WordGraph;
          source = UNDEFINED,
          target = UNDEFINED,
          min::Integer = 0,
          max = POSITIVE_INFINITY,
          order::Order = ORDER_SHORTLEX) -> Paths

Construct a [`Paths`](@ref) over `g` configured by keyword arguments.

This is a convenience factory equivalent to constructing a `Paths(g)` and
chaining the relevant `!`-suffixed setters. Argument names mirror the
underlying setting names ([`source!`](@ref), [`target!`](@ref),
[`min!`](@ref), [`max!`](@ref), [`order!`](@ref)).

# Arguments
- `g::WordGraph`: the word graph.

# Keywords
- `source`: the source node (1-based `Integer`) or
  [`UNDEFINED`](@ref Semigroups.UNDEFINED) (default).
- `target`: the target node (1-based `Integer`) or
  [`UNDEFINED`](@ref Semigroups.UNDEFINED) (default), meaning "any reachable
  target".
- `min::Integer`: minimum path length (default `0`).
- `max`: maximum path length (`Integer` or
  [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) — the default).
- `order::Order`: [`ORDER_SHORTLEX`](@ref) (default) or [`ORDER_LEX`](@ref).

# Example
```jldoctest
julia> using Semigroups

julia> g = WordGraph(3, 2);

julia> target!(g, 1, 1, 2); target!(g, 2, 1, 3);

julia> count(paths(g; source = 1, max = 5))
3
```
"""
function paths(g::WordGraph;
               source = UNDEFINED,
               target = UNDEFINED,
               min::Integer = 0,
               max = POSITIVE_INFINITY,
               order::Order = ORDER_SHORTLEX)
    p = Paths(g)
    if !(source isa UndefinedType)
        source!(p, source)
    end
    target!(p, target)
    min!(p, min)
    max!(p, max)
    order!(p, order)
    return p
end
