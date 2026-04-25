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

Type implementing the Knuth-Bendix completion algorithm for semigroups and
monoids.

A `KnuthBendix` object represents a [string rewriting
system](https://w.wiki/9Re) defining a 1- or 2-sided congruence on a finitely
presented semigroup or monoid. It is constructed from a
[`congruence_kind`](@ref Semigroups.congruence_kind) and a
[`Presentation`](@ref Semigroups.Presentation), and runs the Knuth-Bendix
algorithm to find a confluent rewriting system.

`KnuthBendix` is a subtype of [`Runner`](@ref Semigroups.Runner), so all
runner methods (`run!`, `run_for!`, `run_until!`, `finished`, `timed_out`,
`current_state`, etc.) work on `KnuthBendix` objects.

# Constructors

    KnuthBendix(kind::congruence_kind, p::Presentation) -> KnuthBendix
    KnuthBendix(other::KnuthBendix) -> KnuthBendix

The first form constructs a `KnuthBendix` from a congruence kind and a
presentation. The second form copies an existing `KnuthBendix`.

# Throws

- `LibsemigroupsError` if `p` is not valid.
- `LibsemigroupsError` if `p` has more than 256 letters in its alphabet
  (the internal rewriting trie uses 1-byte letter indices).

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `KnuthBendix{word_type, RewriteTrie}` only.

# Example

The example below mirrors the [libsemigroups `KnuthBendix`
example](https://libsemigroups.github.io/libsemigroups/group__knuth__bendix__class__group.html)
for the free group on two generators with relations ``ab = ba^{-1}`` and
``cd = dc^{-1}``. Letters `1, 2, 3, 4` correspond to ``a, b, c, d``.

```julia
using Semigroups

p = Presentation()
set_contains_empty_word!(p, true)
set_alphabet!(p, 4)                    # letters 1, 2, 3, 4 <-> a, b, c, d
add_rule_no_checks!(p, [1, 2], Int[])  # ab = ε
add_rule_no_checks!(p, [2, 1], Int[])  # ba = ε
add_rule_no_checks!(p, [3, 4], Int[])  # cd = ε
add_rule_no_checks!(p, [4, 3], Int[])  # dc = ε

kb = KnuthBendix(twosided, p)

number_of_active_rules(kb)              # 0
number_of_pending_rules(kb)             # 4
run!(kb)
number_of_active_rules(kb)              # 4
number_of_pending_rules(kb)             # 0
confluent(kb)                           # true
number_of_classes(kb)                   # POSITIVE_INFINITY
```
"""
const KnuthBendix = LibSemigroups.KnuthBendixRewriteTrie

"""
    overlap_ABC

Overlap policy: measure ``d(AB, BC) = |A| + |B| + |C|``.

The overlap of words ``AB`` and ``BC`` is measured as the sum of the lengths
of the three constituent parts. See [`overlap_policy!`](@ref
Semigroups.overlap_policy!) for how to apply this policy to a
[`KnuthBendix`](@ref Semigroups.KnuthBendix) instance.
"""
const overlap_ABC = LibSemigroups.overlap_ABC

"""
    overlap_AB_BC

Overlap policy: measure ``d(AB, BC) = |AB| + |BC|``.

The overlap of words ``AB`` and ``BC`` is measured as the sum of the lengths
of the two overlapping words. See [`overlap_policy!`](@ref
Semigroups.overlap_policy!) for how to apply this policy.
"""
const overlap_AB_BC = LibSemigroups.overlap_AB_BC

"""
    overlap_MAX_AB_BC

Overlap policy: measure ``d(AB, BC) = \\max(|AB|, |BC|)``.

The overlap of words ``AB`` and ``BC`` is measured as the maximum of the
lengths of the two overlapping words. See [`overlap_policy!`](@ref
Semigroups.overlap_policy!) for how to apply this policy.
"""
const overlap_MAX_AB_BC = LibSemigroups.overlap_MAX_AB_BC

# ============================================================================
# Initialization
# ============================================================================

"""
    init!(kb::KnuthBendix) -> KnuthBendix
    init!(kb::KnuthBendix, kind::congruence_kind, p::Presentation) -> KnuthBendix

Re-initialize `kb`.

The one-argument form clears the rewriter, presentation, settings, and
statistics from `kb`, putting it back into the same state as a newly
default-constructed [`KnuthBendix`](@ref Semigroups.KnuthBendix).

The three-argument form reinitializes `kb` as if it had just been constructed
from `kind` and `p`.

# Throws

- `LibsemigroupsError` if `p` is not valid (three-argument form).
- `LibsemigroupsError` if `p` has more than 256 letters in its alphabet
  (three-argument form).

!!! warning
    At present it is only possible to create `KnuthBendix` objects from
    presentations with at most 256 letters in the alphabet.
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

Return the current maximum number of pending rules before processing.

Pending rules accumulate until there are `max_pending_rules(kb)` of them, at
which point they are reduced, processed, and added to the active system. The
default value is `128`. Set to `1` to process each rule immediately.

# See also

[`max_pending_rules!`](@ref Semigroups.max_pending_rules!)
"""
max_pending_rules(kb::KnuthBendix) = Int(LibSemigroups.max_pending_rules(kb))

"""
    max_pending_rules!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the maximum number of pending rules to `n`. Returns `kb` for chaining.

Pending rules accumulate until there are `n` of them, at which point they are
reduced, processed, and added to the active system. The default is `128`. Set
to `1` to process each new rule immediately as it is created.

# See also

[`max_pending_rules`](@ref Semigroups.max_pending_rules)
"""
function max_pending_rules!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_pending_rules!(kb, UInt(n))
    return kb
end

"""
    check_confluence_interval(kb::KnuthBendix) -> Int

Return the current interval at which confluence is checked during `run!`.

This is the number of new overlaps considered between confluence checks.
The default value is `4096`. Returns `LIMIT_MAX` if confluence is never
checked mid-run.

# See also

[`check_confluence_interval!`](@ref Semigroups.check_confluence_interval!),
[`run!`](@ref Semigroups.run!)
"""
check_confluence_interval(kb::KnuthBendix) =
    Int(LibSemigroups.check_confluence_interval(kb))

"""
    check_confluence_interval!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the confluence-check interval to `n`. Returns `kb` for chaining.

[`run!`](@ref Semigroups.run!) periodically checks whether the system is
already confluent; `n` is the number of new overlaps to consider between
consecutive checks. Setting `n` too low can adversely affect performance. The
default is `4096`. Set to `LIMIT_MAX` to disable mid-run confluence checks.

# See also

[`check_confluence_interval`](@ref Semigroups.check_confluence_interval),
[`run!`](@ref Semigroups.run!)
"""
function check_confluence_interval!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_check_confluence_interval!(kb, UInt(n))
    return kb
end

"""
    max_overlap(kb::KnuthBendix) -> Int

Return the maximum overlap length currently set.

This is the maximum length of the overlap of two left-hand sides of rules
considered during [`run!`](@ref Semigroups.run!). If set to a value less than
the longest left-hand side of any rule, `run!` may terminate without the
system being confluent.

# See also

[`max_overlap!`](@ref Semigroups.max_overlap!)
"""
max_overlap(kb::KnuthBendix) = Int(LibSemigroups.max_overlap(kb))

"""
    max_overlap!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the maximum overlap length to `n`. Returns `kb` for chaining.

Overlaps of length greater than `n` are not considered during [`run!`](@ref
Semigroups.run!). If `n` is smaller than the longest left-hand side of any
rule, `run!` may terminate without producing a confluent system.

# See also

[`max_overlap`](@ref Semigroups.max_overlap), [`run!`](@ref Semigroups.run!)
"""
function max_overlap!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_overlap!(kb, UInt(n))
    return kb
end

"""
    max_rules(kb::KnuthBendix) -> Int

Return the approximate maximum number of rules currently set.

If the number of rules exceeds this value during [`run!`](@ref
Semigroups.run!) or [`by_overlap_length!`](@ref Semigroups.by_overlap_length!),
those functions terminate early and the system may not be confluent. The
default is `POSITIVE_INFINITY`.

# See also

[`max_rules!`](@ref Semigroups.max_rules!)
"""
max_rules(kb::KnuthBendix) = Int(LibSemigroups.max_rules(kb))

"""
    max_rules!(kb::KnuthBendix, n::Integer) -> KnuthBendix

Set the approximate maximum number of rules to `n`. Returns `kb` for chaining.

If the number of rules exceeds `n` during [`run!`](@ref Semigroups.run!) or
[`by_overlap_length!`](@ref Semigroups.by_overlap_length!), those functions
terminate early and the system may not be confluent. The default is
`POSITIVE_INFINITY`.

# See also

[`max_rules`](@ref Semigroups.max_rules), [`run!`](@ref Semigroups.run!)
"""
function max_rules!(kb::KnuthBendix, n::Integer)
    LibSemigroups.set_max_rules!(kb, UInt(n))
    return kb
end

"""
    overlap_policy(kb::KnuthBendix)

Return the current overlap policy.

The overlap policy determines how the length ``d(AB, BC)`` of an overlap of
two words ``AB`` and ``BC`` is measured. See [`overlap_ABC`](@ref
Semigroups.overlap_ABC), [`overlap_AB_BC`](@ref Semigroups.overlap_AB_BC), and
[`overlap_MAX_AB_BC`](@ref Semigroups.overlap_MAX_AB_BC).

# See also

[`overlap_policy!`](@ref Semigroups.overlap_policy!)
"""
overlap_policy(kb::KnuthBendix) = LibSemigroups.overlap_policy(kb)

"""
    overlap_policy!(kb::KnuthBendix, val) -> KnuthBendix

Set the overlap policy. Returns `kb` for chaining.

The overlap policy controls how the length of an overlap of two words is
measured during the algorithm. `val` must be one of [`overlap_ABC`](@ref
Semigroups.overlap_ABC), [`overlap_AB_BC`](@ref Semigroups.overlap_AB_BC), or
[`overlap_MAX_AB_BC`](@ref Semigroups.overlap_MAX_AB_BC).

# See also

[`overlap_policy`](@ref Semigroups.overlap_policy)
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

Return the current number of active rules in the rewriting system.

Active rules are used to perform rewriting. This count changes as the
Knuth-Bendix algorithm runs.

# Complexity

Constant.
"""
number_of_active_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_active_rules(kb))

"""
    number_of_inactive_rules(kb::KnuthBendix) -> Int

Return the current number of inactive rules in the rewriting system.

Inactive rules have been superseded during the algorithm and are no longer
used for rewriting.

# Complexity

Constant.
"""
number_of_inactive_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_inactive_rules(kb))

"""
    number_of_pending_rules(kb::KnuthBendix) -> Int

Return the number of pending rules.

All rules in the system are either active or pending. Active rules are used
for rewriting; pending rules are not until they have been processed and
promoted to active status. Rules from the presentation are initially pending
when a `KnuthBendix` is constructed.

# Complexity

Constant.
"""
number_of_pending_rules(kb::KnuthBendix) = Int(LibSemigroups.number_of_pending_rules(kb))

"""
    total_rules(kb::KnuthBendix) -> Int

Return the total number of rule instances created during the algorithm.

This is the total count of `Rule` objects ever created while Knuth-Bendix has
been running. It is **not** simply
[`number_of_active_rules`](@ref Semigroups.number_of_active_rules) plus
[`number_of_inactive_rules`](@ref Semigroups.number_of_inactive_rules),
because rules are re-initialized and reused where possible.

# Complexity

Constant.
"""
total_rules(kb::KnuthBendix) = Int(LibSemigroups.total_rules(kb))

"""
    confluent(kb::KnuthBendix) -> Bool

Check if the current rewriting system is [confluent](https://w.wiki/9DA).

Returns `true` if the current rules are confluent, `false` otherwise. This
function does not trigger a run; call [`run!`](@ref Semigroups.run!) first to
ensure the system has been fully processed.
"""
confluent(kb::KnuthBendix) = LibSemigroups.confluent(kb)

"""
    confluent_known(kb::KnuthBendix) -> Bool

Return `true` if the confluence status of the current rules is already known.

Reports whether [`confluent`](@ref Semigroups.confluent) would return a
definitive answer without running further. Does not trigger a run.
"""
confluent_known(kb::KnuthBendix) = LibSemigroups.confluent_known(kb)

"""
    number_of_classes(kb::KnuthBendix) -> UInt64

Compute the number of congruence classes, triggering a full run if needed.

Returns `POSITIVE_INFINITY` if the semigroup has infinitely many elements.

If `kb` has already been run to completion, this function determines the
number of classes via the [`gilman_graph`](@ref Semigroups.gilman_graph) in
``O(mn)`` time, where ``m`` is the size of the alphabet and ``n`` is the
number of nodes in the Gilman graph.

!!! warning
    This function may not terminate if the congruence has infinitely many
    classes and Knuth-Bendix cannot detect this.

# See also

[`gilman_graph`](@ref Semigroups.gilman_graph),
[`normal_forms`](@ref Semigroups.normal_forms)
"""
number_of_classes(kb::KnuthBendix) = LibSemigroups.number_of_classes(kb)

"""
    kind(kb::KnuthBendix) -> congruence_kind

Return the kind of the congruence represented by `kb`.

Returns `twosided` or `onesided`. See [`congruence_kind`](@ref
Semigroups.congruence_kind) for details.

# Complexity

Constant.
"""
kind(kb::KnuthBendix) = LibSemigroups.kind(kb)

"""
    number_of_generating_pairs(kb::KnuthBendix) -> Int

Return the number of generating pairs added to `kb`.

This equals the length of [`generating_pairs`](@ref
Semigroups.generating_pairs) divided by 2.

# Complexity

Constant.
"""
number_of_generating_pairs(kb::KnuthBendix) =
    Int(LibSemigroups.number_of_generating_pairs(kb))

"""
    generating_pairs(kb::KnuthBendix) -> Vector{Tuple{Vector{Int}, Vector{Int}}}

Return the generating pairs of `kb` as 1-based word pairs.

These are the pairs added via [`add_generating_pair!`](@ref
Semigroups.add_generating_pair!). Words are returned as 1-based `Vector{Int}`
letter indices.

!!! warning
    If `kb` represents a one-sided congruence ([`kind`](@ref Semigroups.kind)
    is `onesided`) and generating pairs have been added, the presentation's
    alphabet contains one extra letter required by the algorithm. This extra
    letter may appear in the returned words.
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

!!! warning
    If `kb` represents a one-sided congruence ([`kind`](@ref Semigroups.kind)
    is `onesided`) and generating pairs have been added
    ([`number_of_generating_pairs`](@ref Semigroups.number_of_generating_pairs)
    `> 0`), the returned presentation's alphabet contains one extra letter
    required by the algorithm. This extra letter also appears in the output of
    [`active_rules`](@ref Semigroups.active_rules).
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

Return the Gilman [`WordGraph`](@ref Semigroups.WordGraph) of the rewriting
system.

The Gilman WordGraph is a directed graph where paths from the initial node
(corresponding to the empty word) spell out the shortlex normal forms of the
semigroup elements. The semigroup is finite if and only if the graph is
acyclic.

!!! warning
    This function will not return until `kb` is both reduced and confluent,
    which may never happen.

# See also

[`number_of_classes`](@ref Semigroups.number_of_classes),
[`normal_forms`](@ref Semigroups.normal_forms)
"""
@cxxdereference gilman_graph(kb::KnuthBendix) = LibSemigroups.gilman_graph(kb)

"""
    gilman_graph_node_labels(kb::KnuthBendix) -> Vector{Vector{Int}}

Return the node labels of the Gilman graph as 1-based words.

Each label corresponds to a unique prefix of the left-hand sides of the rules
in the rewriting system. Words are returned as 1-based `Vector{Int}` letter
indices.

# See also

[`gilman_graph`](@ref Semigroups.gilman_graph)
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
[`number_of_classes`](@ref Semigroups.number_of_classes).
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

Run the Knuth-Bendix algorithm ordered by overlap length.

This function runs the Knuth-Bendix algorithm by considering all overlaps of
length ``n`` (as measured by the current [`overlap_policy`](@ref
Semigroups.overlap_policy)) before those of length ``n + 1``. Returns `kb`.

!!! warning
    This function will not terminate until `kb` is confluent, which may never
    happen.

# See also

[`run!`](@ref Semigroups.run!),
[`overlap_policy!`](@ref Semigroups.overlap_policy!)
"""
function by_overlap_length!(kb::KnuthBendix)
    @wrap_libsemigroups_call LibSemigroups.kb_by_overlap_length!(kb)
    return kb
end

"""
    is_reduced(kb::KnuthBendix) -> Bool

Check if all rules in the system are reduced with respect to each other.

Returns `true` if for each pair of rules ``(A, B)`` and ``(C, D)`` in `kb`,
the word ``C`` is neither a subword of ``A`` nor of ``B``. Returns `false`
otherwise.
"""
is_reduced(kb::KnuthBendix) = @wrap_libsemigroups_call LibSemigroups.kb_is_reduced(kb)

"""
    redundant_rule(p::Presentation, timeout::TimePeriod) -> Union{Int, Nothing}

Find a redundant rule in `p` using Knuth-Bendix, with the given timeout.

Starting with the last rule in `p`, this function attempts to run
Knuth-Bendix on the rules of `p` with each rule omitted in turn. For each
omitted rule, Knuth-Bendix is run for at most `timeout`, then it checks
whether the omitted rule follows from the remaining rules. Returns the
1-based rule-pair index of the first redundant rule found, or `nothing` if
no redundant rule is identified within the timeout.

!!! warning
    This function is non-deterministic: results may differ between calls
    with identical parameters.

# Arguments

- `p`: the presentation to search.
- `timeout`: maximum time per omitted rule (e.g. `Millisecond(100)`,
  `Second(5)`).
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
