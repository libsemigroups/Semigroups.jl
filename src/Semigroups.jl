# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

module Semigroups

using CxxWrap
using AbstractAlgebra
import Dates
using Dates: TimePeriod, Nanosecond
using libsemigroups_jll

# ============================================================================
# Debug mode
# ============================================================================

const _debug_mode = Ref(false)

"""
    enable_debug(val::Bool=true)

Enable or disable debug mode for libsemigroups tracing.

When debug mode is enabled, the full C++ stack trace from libsemigroups/jlcxx
is shown instead of only the high-level Julia translation.

# Example
```julia
Semigroups.enable_debug()       # enable debug mode
Semigroups.enable_debug(false)  # disable debug mode
```
"""
enable_debug(val::Bool = true) = (_debug_mode[] = val)

"""
    is_debug() -> Bool

Check if debug mode is enabled for libsemigroups error handling.
"""
is_debug() = _debug_mode[]

# ============================================================================
# Package setup
# ============================================================================

# Setup and library location
include("setup.jl")

# Get the library path - this will build if necessary during precompilation
const _libsemigroups_julia_path = Setup.locate_library()

# Low-level CxxWrap bindings
include("LibSemigroups.jl")

# Re-export the low-level module for advanced users
using .LibSemigroups

# Import error handling utilities
include("errors.jl")
using .Errors: LibsemigroupsError, @wrap_libsemigroups_call

# Julia-side wrapper files
include("constants.jl")
include("report.jl")
include("runner.jl")
include("order.jl")
include("word-range.jl")
include("word-graph.jl")
include("presentation.jl")
include("presentation-examples.jl")

# High-level element types
include("bmat8.jl")
include("transf.jl")

# Algorithm types (must come after element types)
include("froidure-pin.jl")

# Module initialization
function __init__()
    # Initialize the CxxWrap module
    LibSemigroups.__init__()
end

# ============================================================================
# Exports
# ============================================================================

export enable_debug, is_debug, LibsemigroupsError, ReportGuard
export UNDEFINED, POSITIVE_INFINITY, NEGATIVE_INFINITY, LIMIT_MAX
export Runner, RunnerState
export STATE_NEVER_RUN, STATE_RUNNING_TO_FINISH, STATE_RUNNING_FOR
export STATE_RUNNING_UNTIL, STATE_TIMED_OUT, STATE_STOPPED_BY_PREDICATE
export STATE_NOT_RUNNING, STATE_DEAD
export run!, run_for!, run_until!, init!, kill!
export finished, started, running, timed_out, stopped, dead
export stopped_by_predicate, running_for, running_until
export current_state, running_for_how_long
export report_why_we_stopped, string_why_we_stopped
export tril, tril_FALSE, tril_TRUE, tril_unknown, tril_to_bool
export is_undefined, is_positive_infinity, is_negative_infinity, is_limit_max

# Order enum and comparators
export Order, ORDER_NONE, ORDER_SHORTLEX, ORDER_LEX, ORDER_RECURSIVE
export lex_less, shortlex_less, recursive_path_less
export weighted_shortlex_less, weighted_lex_less

# WordRange
export WordRange, alphabet_size, set_alphabet_size!
export first_word, last_word, set_first!, set_last!
export order, set_order!, set_upper_bound!, set_min!, set_max!
export number_of_words, random_word
export next!, at_end, valid, init!, size_hint, upper_bound

# WordGraph
export WordGraph, number_of_nodes, out_degree, target, target!, add_nodes!

# Presentation
export Presentation, alphabet, set_alphabet!, alphabet_from_rules!
export letter, index_of, in_alphabet
export contains_empty_word, set_contains_empty_word!
export add_generator!, remove_generator!
export add_rule!, add_rule_no_checks!, add_rules!
export number_of_rules, rule, rule_lhs, rule_rhs, rules, clear_rules!
export throw_if_alphabet_has_duplicates, throw_if_letter_not_in_alphabet
export throw_if_bad_rules, throw_if_bad_alphabet_or_rules
export length_of, longest_rule_length, shortest_rule_length
export longest_rule_index, shortest_rule_index
export first_unused_letter, index_rule, is_rule
export is_normalized, are_rules_sorted, contains_rule
export throw_if_odd_number_of_rules, throw_if_bad_inverses
export normalize_alphabet!, change_alphabet!, sort_rules!, sort_each_rule!
export add_identity_rules!, add_zero_rules!, add_inverse_rules!
export replace_subword!, replace_word!, replace_word_with_new_generator!
export remove_duplicate_rules!, remove_trivial_rules!
export to_gap_string
export InversePresentation, set_inverses!, inverses, inverse_of
export throw_if_bad_alphabet_rules_or_inverses

# presentation::examples
export symmetric_group
export alternating_group, braid_group, not_symmetric_group
export full_transformation_monoid, partial_transformation_monoid
export symmetric_inverse_monoid, cyclic_inverse_monoid
export order_preserving_monoid, order_preserving_cyclic_inverse_monoid
export orientation_preserving_monoid, orientation_preserving_reversing_monoid
export partition_monoid, partial_brauer_monoid, brauer_monoid
export singular_brauer_monoid, temperley_lieb_monoid, motzkin_monoid
export partial_isometries_cycle_graph_monoid, uniform_block_bijection_monoid
export dual_symmetric_inverse_monoid, stellar_monoid, zero_rook_monoid
export abacus_jones_monoid
export plactic_monoid, chinese_monoid, hypo_plactic_monoid, stylic_monoid
export special_linear_group_2
export fibonacci_semigroup, monogenic_semigroup, rectangular_band
export sigma_plactic_monoid
export renner_type_B_monoid, renner_type_D_monoid
export not_renner_type_B_monoid, not_renner_type_D_monoid

# Transformation types and functions
export Transf, PPerm, Perm
export degree, rank, image, domain, inverse
export increase_degree_by!, swap!
export left_one, right_one

# FroidurePin
export FroidurePin, current_size, number_of_generators, enumerate!
export generator, sorted_at

# BMat8
export BMat8, to_int, swap!, degree, random, row_space_basis
export col_space_basis, col_space_size, is_regular_element, minimum_dim
export number_of_cols, number_of_rows, row_space_size, rows

end # module Semigroups
