# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
todd-coxeter.jl - ToddCoxeter wrapper (Layer 2 + 3)
"""

# ============================================================================
# Type alias and enum constants
# ============================================================================

"""
    ToddCoxeter

Type implementing the Todd-Coxeter algorithm for computing 1- and 2-sided
congruences on finitely presented semigroups and monoids.

A `ToddCoxeter` object represents a coset enumeration over a presentation,
producing a [`WordGraph`](@ref Semigroups.WordGraph) whose nodes correspond
to the congruence classes. It is constructed from a
[`congruence_kind`](@ref Semigroups.congruence_kind) and a
[`Presentation`](@ref Semigroups.Presentation), or from another
`ToddCoxeter` (a quotient construction), or from a `WordGraph`.

`ToddCoxeter` is a subtype of [`CongruenceCommon`](@ref
Semigroups.CongruenceCommon) (and hence of [`Runner`](@ref Semigroups.Runner)),
so all runner methods (`run!`, `run_for!`, `run_until!`, `finished`,
`timed_out`, `current_state`, etc.) and all common congruence helpers
(`reduce`, `contains`, `currently_contains`, `add_generating_pair!`,
`normal_forms`, `partition`, `non_trivial_classes`) work on `ToddCoxeter`
objects.

# Constructors

    ToddCoxeter(kind::congruence_kind, p::Presentation) -> ToddCoxeter
    ToddCoxeter(kind::congruence_kind, tc::ToddCoxeter) -> ToddCoxeter
    ToddCoxeter(kind::congruence_kind, wg::WordGraph) -> ToddCoxeter
    ToddCoxeter(other::ToddCoxeter) -> ToddCoxeter

# Throws

- `LibsemigroupsError` if `p` is not valid (Presentation form).
- `LibsemigroupsError` if `kind` and `tc.kind()` are incompatible
  (ToddCoxeter form).

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `ToddCoxeter{word_type}` only. String-alphabet
    presentations are deferred to v1.1.
"""
const ToddCoxeter = LibSemigroups.ToddCoxeterWord

# --- strategy ---------------------------------------------------------------

"""
    strategy_hlt

Strategy enum value: HLT (Hazelgrove-Leech-Trotter) coset enumeration.
See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_hlt = LibSemigroups.strategy_hlt

"""
    strategy_felsch

Strategy enum value: Felsch-style coset enumeration. Definitions are made
greedily, applying the relations of the presentation immediately to identify
classes. See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_felsch = LibSemigroups.strategy_felsch

"""
    strategy_CR

Strategy enum value: alternating between HLT (Cosets) and Felsch (Relations).
See Holt, Eick, O'Brien, *Handbook of Computational Group Theory*, §5.3.
See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_CR = LibSemigroups.strategy_CR

"""
    strategy_R_over_C

Strategy enum value: HLT phase, followed by Felsch phase.
See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_R_over_C = LibSemigroups.strategy_R_over_C

"""
    strategy_Cr

Strategy enum value: short Felsch phase, followed by HLT, with one final
Felsch sweep at the end. See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_Cr = LibSemigroups.strategy_Cr

"""
    strategy_Rc

Strategy enum value: short HLT phase, followed by Felsch, with one final
HLT sweep at the end. See [`strategy!`](@ref Semigroups.strategy!).
"""
const strategy_Rc = LibSemigroups.strategy_Rc

# --- lookahead_extent -------------------------------------------------------

"""
    lookahead_extent_full

Lookahead-extent enum value: lookahead processes the full word graph.
See [`lookahead_extent!`](@ref Semigroups.lookahead_extent!).
"""
const lookahead_extent_full = LibSemigroups.lookahead_extent_full

"""
    lookahead_extent_partial

Lookahead-extent enum value: lookahead processes only part of the word
graph. See [`lookahead_extent!`](@ref Semigroups.lookahead_extent!).
"""
const lookahead_extent_partial = LibSemigroups.lookahead_extent_partial

# --- lookahead_style --------------------------------------------------------

"""
    lookahead_style_hlt

Lookahead-style enum value: HLT-style lookahead.
See [`lookahead_style!`](@ref Semigroups.lookahead_style!).
"""
const lookahead_style_hlt = LibSemigroups.lookahead_style_hlt

"""
    lookahead_style_felsch

Lookahead-style enum value: Felsch-style lookahead.
See [`lookahead_style!`](@ref Semigroups.lookahead_style!).
"""
const lookahead_style_felsch = LibSemigroups.lookahead_style_felsch

# --- def_policy -------------------------------------------------------------

"""
    def_policy_no_stack_if_no_space

Definition-policy enum value: do not stack a deduction if there is no space
left. See [`def_policy!`](@ref Semigroups.def_policy!).
"""
const def_policy_no_stack_if_no_space =
    LibSemigroups.def_policy_no_stack_if_no_space

"""
    def_policy_purge_from_top

Definition-policy enum value: purge from the top of the deduction stack
when full. See [`def_policy!`](@ref Semigroups.def_policy!).
"""
const def_policy_purge_from_top = LibSemigroups.def_policy_purge_from_top

"""
    def_policy_purge_all

Definition-policy enum value: purge all deductions when the stack is full.
See [`def_policy!`](@ref Semigroups.def_policy!).
"""
const def_policy_purge_all = LibSemigroups.def_policy_purge_all

"""
    def_policy_discard_all_if_no_space

Definition-policy enum value: discard all deductions if there is no space
left. See [`def_policy!`](@ref Semigroups.def_policy!).
"""
const def_policy_discard_all_if_no_space =
    LibSemigroups.def_policy_discard_all_if_no_space

"""
    def_policy_unlimited

Definition-policy enum value: do not limit the number of stacked deductions.
See [`def_policy!`](@ref Semigroups.def_policy!).
"""
const def_policy_unlimited = LibSemigroups.def_policy_unlimited

# --- def_version ------------------------------------------------------------

"""
    def_version_one

Definition-version enum value: version 1 of the definition routine.
See [`def_version!`](@ref Semigroups.def_version!).
"""
const def_version_one = LibSemigroups.def_version_one

"""
    def_version_two

Definition-version enum value: version 2 of the definition routine.
See [`def_version!`](@ref Semigroups.def_version!).
"""
const def_version_two = LibSemigroups.def_version_two

# ============================================================================
# Class-index conversion (private, file-local)
# ============================================================================
# C++ uses 0-based class indices and `typemax(size_t)` for UNDEFINED. These
# helpers translate at the Julia<->C++ boundary; keep their calls *outside*
# `@wrap_libsemigroups_call` so that native Julia errors (e.g., `InexactError`
# from `UInt(0 - 1)`) propagate as themselves rather than being re-wrapped.

@inline _index_to_cpp(i::Integer) = UInt(i - 1)
@inline _index_from_cpp(i::Integer) =
    i == typemax(UInt) ? UNDEFINED : Int(i) + 1

# ============================================================================
# Initialization
# ============================================================================

"""
    init!(tc::ToddCoxeter) -> ToddCoxeter
    init!(tc::ToddCoxeter, kind::congruence_kind, p::Presentation) -> ToddCoxeter
    init!(tc::ToddCoxeter, kind::congruence_kind, other::ToddCoxeter) -> ToddCoxeter
    init!(tc::ToddCoxeter, kind::congruence_kind, wg::WordGraph) -> ToddCoxeter

Re-initialize `tc`.

The one-argument form clears the underlying word graph, presentation,
generating pairs, settings, and statistics from `tc`, putting it back into
the same state as a newly default-constructed [`ToddCoxeter`](@ref
Semigroups.ToddCoxeter).

The three-argument forms reinitialize `tc` as if it had just been
constructed from the corresponding arguments — `(kind, p)` for a
[`Presentation`](@ref Semigroups.Presentation), `(kind, other)` for a
quotient construction from another `ToddCoxeter`, or `(kind, wg)` for a
construction from a [`WordGraph`](@ref Semigroups.WordGraph).

Returns `tc` for chaining.

# Throws

- `LibsemigroupsError` if `p` is not valid (Presentation form).
- `LibsemigroupsError` if `kind` and `other.kind()` are incompatible
  (ToddCoxeter form).
"""
function init!(tc::ToddCoxeter)
    @wrap_libsemigroups_call LibSemigroups.init!(tc)
    return tc
end

function init!(tc::ToddCoxeter, kind::congruence_kind, p::Presentation)
    @wrap_libsemigroups_call LibSemigroups.init!(tc, kind, p)
    return tc
end

function init!(tc::ToddCoxeter, kind::congruence_kind, other::ToddCoxeter)
    @wrap_libsemigroups_call LibSemigroups.init!(tc, kind, other)
    return tc
end

function init!(tc::ToddCoxeter, kind::congruence_kind, wg::WordGraph)
    @wrap_libsemigroups_call LibSemigroups.init!(tc, kind, wg)
    return tc
end

# ============================================================================
# Settings — getter / setter pairs
# ============================================================================

"""
    strategy(tc::ToddCoxeter)

Return the current coset enumeration strategy of `tc`.

The returned value is one of [`strategy_hlt`](@ref Semigroups.strategy_hlt),
[`strategy_felsch`](@ref Semigroups.strategy_felsch),
[`strategy_CR`](@ref Semigroups.strategy_CR),
[`strategy_R_over_C`](@ref Semigroups.strategy_R_over_C),
[`strategy_Cr`](@ref Semigroups.strategy_Cr), or
[`strategy_Rc`](@ref Semigroups.strategy_Rc).

# See also

[`strategy!`](@ref Semigroups.strategy!)
"""
strategy(tc::ToddCoxeter) = LibSemigroups.strategy(tc)

"""
    strategy!(tc::ToddCoxeter, val) -> ToddCoxeter

Set the coset enumeration strategy of `tc` to `val`. Returns `tc` for
chaining. `val` must be one of the `strategy_*` enum constants.

# See also

[`strategy`](@ref Semigroups.strategy)
"""
function strategy!(tc::ToddCoxeter, val)
    LibSemigroups.set_strategy!(tc, val)
    return tc
end

"""
    lookahead_extent(tc::ToddCoxeter)

Return the current lookahead extent of `tc`.

The returned value is one of
[`lookahead_extent_full`](@ref Semigroups.lookahead_extent_full) or
[`lookahead_extent_partial`](@ref Semigroups.lookahead_extent_partial).

# See also

[`lookahead_extent!`](@ref Semigroups.lookahead_extent!)
"""
lookahead_extent(tc::ToddCoxeter) = LibSemigroups.lookahead_extent(tc)

"""
    lookahead_extent!(tc::ToddCoxeter, val) -> ToddCoxeter

Set the lookahead extent of `tc` to `val`. Returns `tc` for chaining.

# See also

[`lookahead_extent`](@ref Semigroups.lookahead_extent)
"""
function lookahead_extent!(tc::ToddCoxeter, val)
    LibSemigroups.set_lookahead_extent!(tc, val)
    return tc
end

"""
    lookahead_style(tc::ToddCoxeter)

Return the current lookahead style of `tc`.

The returned value is one of
[`lookahead_style_hlt`](@ref Semigroups.lookahead_style_hlt) or
[`lookahead_style_felsch`](@ref Semigroups.lookahead_style_felsch).

# See also

[`lookahead_style!`](@ref Semigroups.lookahead_style!)
"""
lookahead_style(tc::ToddCoxeter) = LibSemigroups.lookahead_style(tc)

"""
    lookahead_style!(tc::ToddCoxeter, val) -> ToddCoxeter

Set the lookahead style of `tc` to `val`. Returns `tc` for chaining.

# See also

[`lookahead_style`](@ref Semigroups.lookahead_style)
"""
function lookahead_style!(tc::ToddCoxeter, val)
    LibSemigroups.set_lookahead_style!(tc, val)
    return tc
end

"""
    save(tc::ToddCoxeter) -> Bool

Return whether deductions made during HLT enumeration are processed in
the same way as those made during Felsch enumeration.

# See also

[`save!`](@ref Semigroups.save!)
"""
save(tc::ToddCoxeter) = LibSemigroups.save(tc)

"""
    save!(tc::ToddCoxeter, val::Bool) -> ToddCoxeter

Set the value of the `save` setting on `tc`. Returns `tc` for chaining.

If `val` is `true`, deductions made during HLT enumeration are processed
in the same way as those made during Felsch enumeration. This typically
slows down HLT enumeration but may reduce the size of the underlying word
graph.

# See also

[`save`](@ref Semigroups.save)
"""
function save!(tc::ToddCoxeter, val::Bool)
    LibSemigroups.set_save!(tc, val)
    return tc
end

"""
    use_relations_in_extra(tc::ToddCoxeter) -> Bool

Return whether the relations of the underlying presentation are used in
the Felsch part of the algorithm when applied to the generating pairs.

# See also

[`use_relations_in_extra!`](@ref Semigroups.use_relations_in_extra!)
"""
use_relations_in_extra(tc::ToddCoxeter) =
    LibSemigroups.use_relations_in_extra(tc)

"""
    use_relations_in_extra!(tc::ToddCoxeter, val::Bool) -> ToddCoxeter

Set whether the relations of the underlying presentation are used in
the Felsch part of the algorithm when applied to the generating pairs.
Returns `tc` for chaining.

# See also

[`use_relations_in_extra`](@ref Semigroups.use_relations_in_extra)
"""
function use_relations_in_extra!(tc::ToddCoxeter, val::Bool)
    LibSemigroups.set_use_relations_in_extra!(tc, val)
    return tc
end

"""
    lower_bound(tc::ToddCoxeter) -> Int

Return the current lower bound on the number of classes of the congruence
represented by `tc`. A value of `0` means no bound has been set.

# See also

[`lower_bound!`](@ref Semigroups.lower_bound!)
"""
lower_bound(tc::ToddCoxeter) = Int(LibSemigroups.lower_bound(tc))

"""
    lower_bound!(tc::ToddCoxeter, val::Integer) -> ToddCoxeter

Set a lower bound on the number of classes of the congruence represented
by `tc` to `val`. Returns `tc` for chaining.

If the number of currently active nodes during enumeration reaches `val`
and the word graph is complete, the algorithm can stop early. A value of
`0` indicates no lower bound.

# See also

[`lower_bound`](@ref Semigroups.lower_bound)
"""
function lower_bound!(tc::ToddCoxeter, val::Integer)
    LibSemigroups.set_lower_bound!(tc, UInt(val))
    return tc
end

"""
    def_version(tc::ToddCoxeter)

Return the current definition-routine version of `tc`.

The returned value is one of
[`def_version_one`](@ref Semigroups.def_version_one) or
[`def_version_two`](@ref Semigroups.def_version_two).

# See also

[`def_version!`](@ref Semigroups.def_version!)
"""
def_version(tc::ToddCoxeter) = LibSemigroups.def_version(tc)

"""
    def_version!(tc::ToddCoxeter, val) -> ToddCoxeter

Set the definition-routine version of `tc` to `val`. Returns `tc` for
chaining.

# See also

[`def_version`](@ref Semigroups.def_version)
"""
function def_version!(tc::ToddCoxeter, val)
    LibSemigroups.set_def_version!(tc, val)
    return tc
end

"""
    def_policy(tc::ToddCoxeter)

Return the current definition-stack policy of `tc`.

The returned value is one of
[`def_policy_no_stack_if_no_space`](@ref Semigroups.def_policy_no_stack_if_no_space),
[`def_policy_purge_from_top`](@ref Semigroups.def_policy_purge_from_top),
[`def_policy_purge_all`](@ref Semigroups.def_policy_purge_all),
[`def_policy_discard_all_if_no_space`](@ref Semigroups.def_policy_discard_all_if_no_space),
or [`def_policy_unlimited`](@ref Semigroups.def_policy_unlimited).

# See also

[`def_policy!`](@ref Semigroups.def_policy!)
"""
def_policy(tc::ToddCoxeter) = LibSemigroups.def_policy(tc)

"""
    def_policy!(tc::ToddCoxeter, val) -> ToddCoxeter

Set the definition-stack policy of `tc` to `val`. Returns `tc` for
chaining.

# See also

[`def_policy`](@ref Semigroups.def_policy)
"""
function def_policy!(tc::ToddCoxeter, val)
    LibSemigroups.set_def_policy!(tc, val)
    return tc
end

# ============================================================================
# Standardize / word-graph access
# ============================================================================

"""
    standardize!(tc::ToddCoxeter, ord::Order) -> Bool

Standardize the underlying word graph of `tc` according to the order
`ord`.

Standardization renumbers the nodes of the word graph so that the words
labelling its nodes appear in the order specified by `ord`. Returns
`true` if the underlying word graph was modified, `false` otherwise.

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance to standardize.
- `ord::Order`: the order to standardize by — typically
  [`ORDER_SHORTLEX`](@ref Semigroups.ORDER_SHORTLEX) or
  [`ORDER_LEX`](@ref Semigroups.ORDER_LEX).

# See also

[`is_standardized`](@ref Semigroups.is_standardized)
"""
function standardize!(tc::ToddCoxeter, ord::Order)
    return @wrap_libsemigroups_call LibSemigroups.standardize!(tc, ord)
end

"""
    is_standardized(tc::ToddCoxeter) -> Bool
    is_standardized(tc::ToddCoxeter, ord::Order) -> Bool

Return whether the underlying word graph of `tc` is standardized.

The one-argument form returns `true` if the word graph has been
standardized according to *some* order. The two-argument form returns
`true` only if it has been standardized according to `ord`.

# See also

[`standardize!`](@ref Semigroups.standardize!)
"""
is_standardized(tc::ToddCoxeter) = LibSemigroups.is_standardized(tc)

is_standardized(tc::ToddCoxeter, ord::Order) =
    LibSemigroups.is_standardized(tc, ord)

"""
    current_word_graph(tc::ToddCoxeter) -> WordGraph

Return the current state of the underlying word graph of `tc`, without
triggering a run.

If `tc` has not been run, the returned word graph reflects whatever
incomplete state has been built so far.

# See also

[`word_graph`](@ref Semigroups.word_graph)
"""
@cxxdereference current_word_graph(tc::ToddCoxeter) =
    LibSemigroups.current_word_graph(tc)

"""
    word_graph(tc::ToddCoxeter) -> WordGraph

Return the underlying word graph of `tc`, after running the algorithm to
completion and standardizing.

This function triggers a full enumeration of `tc`, which may never
terminate.

# See also

[`current_word_graph`](@ref Semigroups.current_word_graph)
"""
@cxxdereference word_graph(tc::ToddCoxeter) = LibSemigroups.word_graph(tc)

# ============================================================================
# Word <-> class index conversions
# ============================================================================

"""
    index_of(tc::ToddCoxeter, w::AbstractVector{<:Integer}) -> Int

Return the 1-based index of the congruence class containing `w`.

This function triggers a full enumeration of `tc`, which may never
terminate.

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance.
- `w::AbstractVector{<:Integer}`: a 1-based `Vector{Int}` of letter
  indices.

# Throws

- `LibsemigroupsError` if any letter in `w` is not in the alphabet of the
  underlying presentation.

# See also

[`current_index_of`](@ref Semigroups.current_index_of),
[`word_of`](@ref Semigroups.word_of)
"""
function index_of(tc::ToddCoxeter, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    cpp_i = @wrap_libsemigroups_call LibSemigroups.index_of(tc, cpp_w)
    return _index_from_cpp(cpp_i)
end

"""
    current_index_of(tc::ToddCoxeter, w::AbstractVector{<:Integer}) -> Union{Int, UndefinedType}

Return the 1-based index of the congruence class containing `w` if it is
already known, without triggering a run.

If the class of `w` is not currently known, returns
[`UNDEFINED`](@ref Semigroups.UNDEFINED).

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance.
- `w::AbstractVector{<:Integer}`: a 1-based `Vector{Int}` of letter
  indices.

# Throws

- `LibsemigroupsError` if any letter in `w` is not in the alphabet of the
  underlying presentation.

# See also

[`index_of`](@ref Semigroups.index_of),
[`current_word_of`](@ref Semigroups.current_word_of)
"""
function current_index_of(tc::ToddCoxeter, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    cpp_i = @wrap_libsemigroups_call LibSemigroups.current_index_of(tc, cpp_w)
    return _index_from_cpp(cpp_i)
end

"""
    word_of(tc::ToddCoxeter, i::Integer) -> Vector{Int}

Return a representative word for the `i`-th congruence class of `tc`
(1-based).

This function triggers a full enumeration of `tc`, which may never
terminate.

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance.
- `i::Integer`: a 1-based class index.

# Throws

- `LibsemigroupsError` if `i` is out of range.

# See also

[`current_word_of`](@ref Semigroups.current_word_of),
[`index_of`](@ref Semigroups.index_of)
"""
function word_of(tc::ToddCoxeter, i::Integer)
    cpp_i = _index_to_cpp(i)
    out = @wrap_libsemigroups_call LibSemigroups.word_of(tc, cpp_i)
    return _word_from_cpp(out)
end

"""
    current_word_of(tc::ToddCoxeter, i::Integer) -> Vector{Int}

Return a representative word for the `i`-th congruence class of `tc`
(1-based), without triggering a run.

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance.
- `i::Integer`: a 1-based class index.

# Throws

- `LibsemigroupsError` if `i` is out of range relative to the current
  state of `tc`.

# See also

[`word_of`](@ref Semigroups.word_of),
[`current_index_of`](@ref Semigroups.current_index_of)
"""
function current_word_of(tc::ToddCoxeter, i::Integer)
    cpp_i = _index_to_cpp(i)
    out = @wrap_libsemigroups_call LibSemigroups.current_word_of(tc, cpp_i)
    return _word_from_cpp(out)
end

# ============================================================================
# Query methods
# ============================================================================

"""
    number_of_classes(tc::ToddCoxeter) -> UInt64

Compute the number of congruence classes, triggering a full run if
needed.

Returns [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) if the
congruence has infinitely many classes.

!!! warning
    This function may not terminate if the congruence has infinitely many
    classes and the algorithm cannot detect this.
"""
number_of_classes(tc::ToddCoxeter) = LibSemigroups.number_of_classes(tc)

"""
    kind(tc::ToddCoxeter) -> congruence_kind

Return the kind of the congruence represented by `tc` — either
[`twosided`](@ref Semigroups.twosided) or
[`onesided`](@ref Semigroups.onesided).
"""
kind(tc::ToddCoxeter) = LibSemigroups.kind(tc)

"""
    number_of_generating_pairs(tc::ToddCoxeter) -> Int

Return the number of generating pairs added to `tc`.

This equals the length of [`generating_pairs`](@ref
Semigroups.generating_pairs).
"""
number_of_generating_pairs(tc::ToddCoxeter) =
    Int(LibSemigroups.number_of_generating_pairs(tc))

"""
    generating_pairs(tc::ToddCoxeter) -> Vector{Tuple{Vector{Int}, Vector{Int}}}

Return the generating pairs of `tc` as 1-based word pairs.

These are the pairs added via [`add_generating_pair!`](@ref
Semigroups.add_generating_pair!). Words are returned as 1-based
`Vector{Int}` letter indices.
"""
function generating_pairs(tc::ToddCoxeter)
    flat = LibSemigroups.generating_pairs(tc)
    result = Tuple{Vector{Int},Vector{Int}}[]
    for i = 1:2:length(flat)
        push!(result, (_word_from_cpp(flat[i]), _word_from_cpp(flat[i+1])))
    end
    return result
end

"""
    presentation(tc::ToddCoxeter) -> Presentation

Return a copy of the presentation used by `tc`.
"""
presentation(tc::ToddCoxeter) = LibSemigroups.presentation(tc)

# ============================================================================
# Base.* overloads
# ============================================================================

"""
    Base.length(tc::ToddCoxeter) -> UInt64

Return the number of congruence classes. Equivalent to
[`number_of_classes`](@ref Semigroups.number_of_classes).
"""
Base.length(tc::ToddCoxeter) = number_of_classes(tc)

"""
    Base.show(io::IO, tc::ToddCoxeter)

Print a human-readable representation of `tc`.
"""
function Base.show(io::IO, tc::ToddCoxeter)
    print(io, LibSemigroups.to_human_readable_repr(tc))
end

"""
    Base.copy(tc::ToddCoxeter) -> ToddCoxeter

Create an independent copy of `tc`.
"""
Base.copy(tc::ToddCoxeter) = LibSemigroups.ToddCoxeterWord(tc)

Base.deepcopy_internal(tc::ToddCoxeter, ::IdDict) =
    LibSemigroups.ToddCoxeterWord(tc)

# ============================================================================
# Free functions (todd_coxeter:: namespace)
# ============================================================================

"""
    is_non_trivial(tc::ToddCoxeter;
                   tries::Integer = 10,
                   try_for::TimePeriod = Dates.Millisecond(100),
                   threshold::Real = 0.99) -> [`tril`](@ref Semigroups.tril)

Heuristically check whether the congruence represented by `tc` is
non-trivial.

Repeatedly runs the algorithm for at most `try_for` time, with a random
subset of the generating pairs removed, up to `tries` times. If the ratio
of the number of classes in the modified system to the number in `tc` is
at most `threshold`, the function returns [`tril_TRUE`](@ref
Semigroups.tril_TRUE) (the congruence is likely non-trivial). If after
`tries` attempts no such ratio is observed, returns
[`tril_FALSE`](@ref Semigroups.tril_FALSE). Returns
[`tril_unknown`](@ref Semigroups.tril_unknown) if the function cannot
decide.

# Arguments

- `tc::ToddCoxeter`: the `ToddCoxeter` instance to check.
- `tries::Integer`: number of attempts (default `10`).
- `try_for::TimePeriod`: time budget per attempt (default
  `Millisecond(100)`).
- `threshold::Real`: ratio threshold (default `0.99`).

!!! note
    The libsemigroups helper takes `std::chrono::milliseconds` internally;
    the C++ binding receives nanoseconds and casts down, truncating
    sub-millisecond values to zero. The default of `Millisecond(100)` is
    safely above this precision boundary.
"""
function is_non_trivial(
    tc::ToddCoxeter;
    tries::Integer = 10,
    try_for::TimePeriod = Dates.Millisecond(100),
    threshold::Real = 0.99,
)
    ns = convert(Nanosecond, try_for)
    return @wrap_libsemigroups_call LibSemigroups.tc_is_non_trivial(
        tc,
        UInt(tries),
        Int64(Dates.value(ns)),
        Float32(threshold),
    )
end

"""
    tc_redundant_rule(p::Presentation, timeout::TimePeriod) -> Union{Int, Nothing}

Find a redundant rule in `p` using the Todd-Coxeter algorithm, with the
given timeout.

Starting with the last rule in `p`, this function attempts to run
Todd-Coxeter on the rules of `p` with each rule omitted in turn. For each
omitted rule, Todd-Coxeter is run for at most `timeout`, then it checks
whether the omitted rule follows from the remaining rules. Returns the
1-based rule-pair index of the first redundant rule found, or `nothing`
if no redundant rule is identified within the timeout.

!!! warning
    This function is non-deterministic: results may differ between calls
    with identical parameters.

# Arguments

- `p::Presentation`: the presentation to search.
- `timeout::TimePeriod`: maximum time per omitted rule (e.g.
  `Millisecond(100)`, `Second(5)`).

# See also

[`redundant_rule`](@ref Semigroups.redundant_rule) — the analogous
Knuth-Bendix-based helper.
"""
function tc_redundant_rule(p::Presentation, timeout::TimePeriod)
    ns = convert(Nanosecond, timeout)
    idx = @wrap_libsemigroups_call LibSemigroups.tc_redundant_rule(
        p,
        Int64(Dates.value(ns)),
    )
    n_flat = 2 * number_of_rules(p)
    if idx >= n_flat
        return nothing
    end
    # Convert from 0-based flat index (lhs position, always even) to
    # 1-based rule-pair index. C++ contract guarantees lhs position.
    return div(Int(idx), 2) + 1
end
