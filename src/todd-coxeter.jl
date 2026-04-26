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
