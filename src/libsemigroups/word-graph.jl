# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
word-graph.jl - Julia wrappers for libsemigroups WordGraph

This file provides low-level Julia wrappers for the C++ WordGraph<uint32_t>
class exposed via CxxWrap.

Indices at this layer are **0-based** (matching C++). The high-level
FroidurePin API will add 1-based conversion when exposing Cayley
graphs to users.
"""

# ============================================================================
# Type alias
# ============================================================================

"""
    WordGraph

A word graph (deterministic automaton without initial or accept states).
Nodes are numbered `0` to `number_of_nodes(g) - 1` and every node has the
same out-degree.

Construct with `WordGraph(m, n)` for `m` nodes and out-degree `n`.
"""
const WordGraph = LibSemigroups.WordGraph

# ============================================================================
# Size / structure queries
# ============================================================================

"""
    number_of_nodes(g::WordGraph) -> Int

Return the number of nodes in the word graph.
"""
number_of_nodes(g::WordGraph) = Int(LibSemigroups.number_of_nodes(g))

"""
    out_degree(g::WordGraph) -> Int

Return the out-degree (number of edge labels) of every node.
"""
out_degree(g::WordGraph) = Int(LibSemigroups.out_degree(g))

"""
    number_of_edges(g::WordGraph) -> Int

Return the total number of defined edges in the word graph.
"""
number_of_edges(g::WordGraph) = Int(LibSemigroups.number_of_edges(g))

"""
    number_of_edges(g::WordGraph, s::Integer) -> Int

Return the number of defined edges with source node `s` (0-based).
"""
number_of_edges(g::WordGraph, s::Integer) =
    Int(LibSemigroups.number_of_edges_node(g, UInt32(s)))

# ============================================================================
# Edge lookup
# ============================================================================

"""
    target(g::WordGraph, source::Integer, label::Integer) -> UInt32

Return the target of the edge from `source` with `label` (both 0-based).
Returns the C++ `UNDEFINED` value (as `UInt32`) if no such edge exists.
"""
target(g::WordGraph, source::Integer, label::Integer) =
    LibSemigroups.target(g, UInt32(source), UInt32(label))

"""
    next_label_and_target(g::WordGraph, s::Integer, a::Integer)

Return the next defined edge from node `s` with label >= `a` (both 0-based).
Returns a `(label, target)` tuple; both are `UNDEFINED` if none found.
"""
function next_label_and_target(g::WordGraph, s::Integer, a::Integer)
    s32, a32 = UInt32(s), UInt32(a)
    return (LibSemigroups.next_label(g, s32, a32), LibSemigroups.next_target(g, s32, a32))
end

# ============================================================================
# Iteration helpers
# ============================================================================

"""
    targets(g::WordGraph, source::Integer) -> Vector{UInt32}

Return all edge targets from `source` (0-based) as a vector. Includes
`UNDEFINED` entries for labels with no defined edge.
"""
targets(g::WordGraph, source::Integer) = LibSemigroups.targets_vector(g, UInt32(source))

# ============================================================================
# Comparison operators
# ============================================================================

Base.:(==)(a::WordGraph, b::WordGraph) = LibSemigroups.is_equal(a, b)
Base.:(<)(a::WordGraph, b::WordGraph) = LibSemigroups.is_less(a, b)

# ============================================================================
# Copy and hash
# ============================================================================

Base.copy(g::WordGraph) = LibSemigroups.copy(g)
Base.hash(g::WordGraph, h::UInt) = hash(LibSemigroups.hash(g), h)

# ============================================================================
# Display
# ============================================================================

function Base.show(io::IO, g::WordGraph)
    n = number_of_nodes(g)
    e = number_of_edges(g)
    d = out_degree(g)
    print(io, "WordGraph($n, $d) with $e edges")
end
