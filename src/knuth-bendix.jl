# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
knuth-bendix.jl - KnuthBendix wrapper (Layer 2 + 3)
"""

# ============================================================================
# Type alias and constants
# ============================================================================

"""
    KnuthBendix

Type for Knuth-Bendix completion algorithm objects.

A `KnuthBendix` object computes a confluent rewriting system from a
[`Presentation`](@ref Semigroups.Presentation) and a
[`congruence_kind`](@ref Semigroups.congruence_kind). It is a subtype of
[`Runner`](@ref Semigroups.Runner), so all runner methods (`run!`,
`run_for!`, `finished`, `timed_out`, etc.) work on `KnuthBendix` objects.

# Constructors

    KnuthBendix(kind::congruence_kind, p::Presentation) -> KnuthBendix
    KnuthBendix(other::KnuthBendix) -> KnuthBendix

The first form constructs a `KnuthBendix` from a congruence kind and a
presentation. The second form copies an existing `KnuthBendix`.

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `KnuthBendix<word_type, RewriteTrie>` only.
"""
const KnuthBendix = LibSemigroups.KnuthBendixRewriteTrie

"""
    overlap_ABC

Overlap policy constant: consider overlaps of the form ABC.
"""
const overlap_ABC = LibSemigroups.overlap_ABC

"""
    overlap_AB_BC

Overlap policy constant: consider overlaps of the form AB_BC.
"""
const overlap_AB_BC = LibSemigroups.overlap_AB_BC

"""
    overlap_MAX_AB_BC

Overlap policy constant: consider overlaps of the form MAX_AB_BC.
"""
const overlap_MAX_AB_BC = LibSemigroups.overlap_MAX_AB_BC

# ============================================================================
# Initialization
# ============================================================================

"""
    init!(kb::KnuthBendix) -> KnuthBendix
    init!(kb::KnuthBendix, kind::congruence_kind, p::Presentation) -> KnuthBendix

Re-initialize `kb`.

The one-argument form clears the presentation, generating pairs, settings,
and rewriting data, putting `kb` back into the same state as a newly
default-constructed `KnuthBendix`. The three-argument form reinitializes
`kb` as if it had just been constructed from `kind` and `p`.
"""
function init!(kb::KnuthBendix)
    @wrap_libsemigroups_call LibSemigroups.init!(kb)
    return kb
end

function init!(kb::KnuthBendix, kind::congruence_kind, p::Presentation)
    @wrap_libsemigroups_call LibSemigroups.init!(kb, kind, p)
    return kb
end

# ============================================================================
# Settings — getter / setter pairs
# ============================================================================

"""
    max_pending_rules(kb::KnuthBendix) -> Int

Return the current maximum number of pending rules.
"""
max_pending_rules(kb::KnuthBendix) = Int(LibSemigroups.max_pending_rules(kb))

"""
    max_pending_rules!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the maximum number of pending rules. Returns `kb` for chaining.
"""
function max_pending_rules!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_pending_rules!(kb, UInt(n))
    return kb
end

"""
    check_confluence_interval(kb::KnuthBendix) -> Int

Return the current check-confluence interval.
"""
check_confluence_interval(kb::KnuthBendix) =
    Int(LibSemigroups.check_confluence_interval(kb))

"""
    check_confluence_interval!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the check-confluence interval. Returns `kb` for chaining.
"""
function check_confluence_interval!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_check_confluence_interval!(kb, UInt(n))
    return kb
end

"""
    max_overlap(kb::KnuthBendix) -> Int

Return the current maximum overlap size.
"""
max_overlap(kb::KnuthBendix) = Int(LibSemigroups.max_overlap(kb))

"""
    max_overlap!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the maximum overlap size. Returns `kb` for chaining.
"""
function max_overlap!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_overlap!(kb, UInt(n))
    return kb
end

"""
    max_rules(kb::KnuthBendix) -> Int

Return the current maximum number of rules.
"""
max_rules(kb::KnuthBendix) = Int(LibSemigroups.max_rules(kb))

"""
    max_rules!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the maximum number of rules. Returns `kb` for chaining.
"""
function max_rules!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_rules!(kb, UInt(n))
    return kb
end

"""
    overlap_policy(kb::KnuthBendix)

Return the current overlap policy.
"""
overlap_policy(kb::KnuthBendix) = LibSemigroups.overlap_policy(kb)

"""
    overlap_policy!(kb::KnuthBendix, val) -> KnuthBendix

Set the overlap policy. Returns `kb` for chaining.
"""
function overlap_policy!(kb::KnuthBendix, val)
    LibSemigroups.set_overlap_policy!(kb, val)
    return kb
end

# ============================================================================
# Query methods
# ============================================================================

"""
    number_of_active_rules(kb::KnuthBendix) -> Int

Return the number of active rules in the rewriting system.
"""
number_of_active_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_active_rules(kb))

"""
    number_of_inactive_rules(kb::KnuthBendix) -> Int

Return the number of inactive rules in the rewriting system.
"""
number_of_inactive_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_inactive_rules(kb))

"""
    number_of_pending_rules(kb::KnuthBendix) -> Int

Return the number of pending rules in the rewriting system.
"""
number_of_pending_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_pending_rules(kb))

"""
    total_rules(kb::KnuthBendix) -> Int

Return the total number of rules (active + inactive + pending).
"""
total_rules(kb::KnuthBendix) = Int(LibSemigroups.total_rules(kb))

"""
    confluent(kb::KnuthBendix) -> Bool

Check if the rewriting system is confluent. May trigger a run.
"""
confluent(kb::KnuthBendix) = LibSemigroups.confluent(kb)

"""
    confluent_known(kb::KnuthBendix) -> Bool

Check if confluence status is known without triggering a run.
"""
confluent_known(kb::KnuthBendix) = LibSemigroups.confluent_known(kb)

"""
    number_of_classes(kb::KnuthBendix) -> UInt64

Return the number of congruence classes. May return `POSITIVE_INFINITY`.
"""
number_of_classes(kb::KnuthBendix) = LibSemigroups.number_of_classes(kb)

"""
    kind(kb::KnuthBendix) -> congruence_kind

Return the congruence kind (twosided or onesided).
"""
kind(kb::KnuthBendix) = LibSemigroups.kind(kb)

"""
    number_of_generating_pairs(kb::KnuthBendix) -> Int

Return the number of generating pairs that have been added.
"""
number_of_generating_pairs(kb::KnuthBendix) =
    Int(LibSemigroups.number_of_generating_pairs(kb))

"""
    generating_pairs(kb::KnuthBendix) -> Vector{Tuple{Vector{Int}, Vector{Int}}}

Return the generating pairs of `kb`.

Words are returned as 1-based `Vector{Int}` letter indices.
"""
function generating_pairs(kb::KnuthBendix)
    flat = LibSemigroups.generating_pairs(kb)
    result = Tuple{Vector{Int},Vector{Int}}[]
    for i = 1:2:length(flat)
        push!(result, (_word_from_cpp(flat[i]), _word_from_cpp(flat[i+1])))
    end
    return result
end

"""
    presentation(kb::KnuthBendix) -> Presentation

Return a copy of the presentation used by `kb`.
"""
presentation(kb::KnuthBendix) = LibSemigroups.presentation(kb)

# ============================================================================
# Rules access
# ============================================================================

"""
    active_rules(kb::KnuthBendix) -> Vector{Tuple{Vector{Int}, Vector{Int}}}

Return all active rules as a vector of `(lhs, rhs)` tuples.

Words are returned as 1-based `Vector{Int}` letter indices.
"""
function active_rules(kb::KnuthBendix)
    flat = @wrap_libsemigroups_call LibSemigroups.kb_active_rules(kb)
    result = Tuple{Vector{Int},Vector{Int}}[]
    for i = 1:2:length(flat)
        push!(result, (_word_from_cpp(flat[i]), _word_from_cpp(flat[i+1])))
    end
    return result
end

# ============================================================================
# Graph access
# ============================================================================

"""
    gilman_graph(kb::KnuthBendix) -> WordGraph

Return the Gilman graph of the confluent rewriting system.
"""
@cxxdereference gilman_graph(kb::KnuthBendix) = LibSemigroups.gilman_graph(kb)

"""
    gilman_graph_node_labels(kb::KnuthBendix) -> Vector{Vector{Int}}

Return the node labels of the Gilman graph as 1-based words.
"""
@cxxdereference function gilman_graph_node_labels(kb::KnuthBendix)
    labels = LibSemigroups.gilman_graph_node_labels(kb)
    return [_word_from_cpp(w) for w in labels]
end

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.length(kb::KnuthBendix) -> UInt64

Return the number of congruence classes. Equivalent to
[`number_of_classes`](@ref).
"""
Base.length(kb::KnuthBendix) = number_of_classes(kb)

"""
    Base.show(io::IO, kb::KnuthBendix)

Print a human-readable representation of `kb`.
"""
function Base.show(io::IO, kb::KnuthBendix)
    print(io, LibSemigroups.to_human_readable_repr(kb))
end

"""
    Base.copy(kb::KnuthBendix) -> KnuthBendix

Create an independent copy of `kb`.
"""
Base.copy(kb::KnuthBendix) = LibSemigroups.KnuthBendixRewriteTrie(kb)

Base.deepcopy_internal(kb::KnuthBendix, ::IdDict) = LibSemigroups.KnuthBendixRewriteTrie(kb)

# ============================================================================
# Free functions
# ============================================================================

"""
    by_overlap_length!(kb::KnuthBendix) -> KnuthBendix

Run Knuth-Bendix by overlap length. Mutating.
"""
function by_overlap_length!(kb::KnuthBendix)
    @wrap_libsemigroups_call LibSemigroups.kb_by_overlap_length!(kb)
    return kb
end

"""
    is_reduced(kb::KnuthBendix) -> Bool

Check if the rewriting system is reduced.
"""
is_reduced(kb::KnuthBendix) = @wrap_libsemigroups_call LibSemigroups.kb_is_reduced(kb)

"""
    redundant_rule(p::Presentation, timeout::TimePeriod) -> Union{Int, Nothing}

Find a redundant rule in `p` using Knuth-Bendix, with the given timeout.

Returns the 1-based rule-pair index of a redundant rule, or `nothing` if
no redundant rule is found within the timeout.
"""
function redundant_rule(p::Presentation, timeout::TimePeriod)
    ns = convert(Nanosecond, timeout)
    idx =
        @wrap_libsemigroups_call LibSemigroups.kb_redundant_rule(p, Int64(Dates.value(ns)))
    n_flat = 2 * number_of_rules(p)
    # If idx == n_flat, no redundant rule was found
    if idx >= n_flat
        return nothing
    end
    # Convert from 0-based flat index to 1-based rule-pair index
    return div(Int(idx), 2) + 1
end
