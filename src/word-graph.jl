# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
word-graph.jl
"""

# ============================================================================
# Type alias
# ============================================================================

"""
    WordGraph

Type for representing word graphs.

Instances of this type represent word graphs. If the word graph has
`n` nodes, they are represented by the numbers ``\\{1, 2, \\ldots, n\\}``,
and every node has the same number `m` of out-edges (edges with source
that node and target any other node). The number `m` is referred to as
the *out-degree* of the word graph, or any of its nodes. A missing edge
is represented by [`UNDEFINED`](@ref Semigroups.UNDEFINED).

# Example
```jldoctest
julia> using Semigroups

julia> g = WordGraph(3, 2)
WordGraph(3, 2)

julia> target!(g, 1, 1, 2); target!(g, 1, 2, 3);

julia> target(g, 1, 1)
2

julia> target(g, 1, 2)
3

julia> is_undefined(target(g, 2, 1))
true

julia> target!(g, 1, 1, UNDEFINED); is_undefined(target(g, 1, 1))
true
```
"""
const WordGraph = LibSemigroups.WordGraph

# ============================================================================
# Index conversion (private, file-local)
# ============================================================================
# WordGraph<uint32_t> — node_type = label_type = uint32_t. Conversion happens
# here, not in C++: the C++ binding is pure pass-through per project convention.

_to_cpp(x::Integer) = UInt32(x - 1)
_to_cpp(::UndefinedType) = typemax(UInt32)

_from_cpp(x::UInt32) = x == typemax(UInt32) ? UNDEFINED : Int(x) + 1

# ============================================================================
# Constructor docstring
# ============================================================================

"""
    WordGraph(m::Integer, n::Integer) -> WordGraph

Construct from number of nodes and out degree.

This function constructs a word graph with `m` nodes and where the out-
degree of every node is `n`. There are no edges in the defined word
graph (every edge is [`UNDEFINED`](@ref Semigroups.UNDEFINED)).

# Arguments
 - `m::Integer`: the number of nodes in the word graph.
 - `n::Integer`: the out-degree of every node.

# Complexity
``O(mn)`` where ``m`` is the number of nodes and ``n`` is the out-degree
of the word graph.
"""
WordGraph(m::Integer, n::Integer)

# ============================================================================
# Read queries
# ============================================================================

"""
    number_of_nodes(g::WordGraph) -> Int

Returns the number of nodes.

This function returns the number of nodes in the word graph. Nodes are
labelled ``1, 2, \\ldots, \\mathrm{number\\_of\\_nodes}(g)`` in the
Julia API.

# Complexity
Constant.

See also [`out_degree`](@ref), [`add_nodes!`](@ref).
"""
number_of_nodes(g::WordGraph) = Int(LibSemigroups.number_of_nodes(g))

"""
    out_degree(g::WordGraph) -> Int

Returns the out-degree.

This function returns the number of edge labels in the word graph.
Edge labels are drawn from ``1, 2, \\ldots, \\mathrm{out\\_degree}(g)``.
The out-degree is fixed at construction and cannot be changed through
the v1 API.

# Complexity
Constant.

See also [`number_of_nodes`](@ref), [`target`](@ref).
"""
out_degree(g::WordGraph) = Int(LibSemigroups.out_degree(g))

"""
    target(g::WordGraph, source::Integer, label::Integer) -> Union{Int, UndefinedType}

Get the target of the edge with given source node and label.

This function returns the target of the edge with source node `source`
and label `label`, or [`UNDEFINED`](@ref Semigroups.UNDEFINED) if no
such edge is defined.

# Arguments
 - `source::Integer`: the node.
 - `label::Integer`: the label.

# Throws
 - `LibsemigroupsError`: if `source` or `label` is not valid.
 - `InexactError`: if `source` or `label` is zero or negative (the
   1-based guard fires before the call reaches C++).

# Complexity
Constant.

See also [`target!`](@ref), [`is_undefined`](@ref Semigroups.is_undefined).
"""
function target(g::WordGraph, source::Integer, label::Integer)
    # Do _to_cpp conversion outside @wrap_libsemigroups_call so its
    # InexactError (from zero / negative inputs) propagates as-is rather than
    # being re-wrapped as LibsemigroupsError.
    s = _to_cpp(source)
    a = _to_cpp(label)
    _from_cpp(@wrap_libsemigroups_call LibSemigroups.target(g, s, a))
end

# ============================================================================
# Mutators
# ============================================================================

"""
    target!(g::WordGraph, source::Integer, label::Integer, tgt::Integer) -> WordGraph
    target!(g::WordGraph, source::Integer, label::Integer, ::UndefinedType) -> WordGraph

Set the target of the edge with given source node and label.

If `source` and `tgt` are nodes of `g` and `label` is in the range
``1, 2, \\ldots, \\mathrm{out\\_degree}(g)``, this function sets the
target of the edge from `source` labelled `label` to `tgt`. Passing
[`UNDEFINED`](@ref Semigroups.UNDEFINED) as `tgt` clears the edge,
restoring the "no edge" state at that `(source, label)` slot.

The `Integer` arm dispatches to libsemigroups' `target(s, a, t)`; the
`UndefinedType` arm dispatches to `remove_target(s, a)` because
libsemigroups' `target(s, a, t)` bounds-checks `t` against
[`number_of_nodes`](@ref) and rejects
[`UNDEFINED`](@ref Semigroups.UNDEFINED).

# Arguments
 - `source::Integer`: the source node.
 - `label::Integer`: the label of the edge.
 - `tgt`: the target node, or [`UNDEFINED`](@ref Semigroups.UNDEFINED)
   to clear the edge.

# Throws
 - `LibsemigroupsError`: if `source`, `label`, or `tgt` is not valid.
   If an exception is thrown, `g` is guaranteed not to be modified
   (strong exception guarantee).
 - `InexactError`: if `source`, `label`, or `tgt` is zero or negative.

# Complexity
Constant.

See also [`target`](@ref), [`add_nodes!`](@ref).
"""
function target!(g::WordGraph, source::Integer, label::Integer, tgt::Integer)
    s = _to_cpp(source)
    a = _to_cpp(label)
    t = _to_cpp(tgt)
    GC.@preserve g begin
        @wrap_libsemigroups_call LibSemigroups.target!(g, s, a, t)
    end
    return g
end

function target!(g::WordGraph, source::Integer, label::Integer, ::UndefinedType)
    s = _to_cpp(source)
    a = _to_cpp(label)
    GC.@preserve g begin
        @wrap_libsemigroups_call LibSemigroups.remove_target!(g, s, a)
    end
    return g
end

"""
    add_nodes!(g::WordGraph, n::Integer) -> WordGraph

Add a number of new nodes.

This function modifies a word graph in-place so that it has `n` new
nodes added. The added nodes are labelled from
``\\mathrm{number\\_of\\_nodes}(g) + 1`` through
``\\mathrm{number\\_of\\_nodes}(g) + n``, with all outgoing edges
initialized to [`UNDEFINED`](@ref Semigroups.UNDEFINED). Existing nodes
and edges are preserved.

# Arguments
 - `n::Integer`: the number of nodes to add.

# Complexity
``O((m + n) \\cdot k)`` where ``m`` is the current number of nodes,
``n`` is the number added, and ``k`` is the out-degree.

See also [`number_of_nodes`](@ref), [`target!`](@ref).
"""
function add_nodes!(g::WordGraph, n::Integer)
    GC.@preserve g begin
        LibSemigroups.add_nodes!(g, UInt(n))
    end
    return g
end

# ============================================================================
# Display
# ============================================================================

function Base.show(io::IO, g::WordGraph)
    print(io, "WordGraph($(number_of_nodes(g)), $(out_degree(g)))")
end
