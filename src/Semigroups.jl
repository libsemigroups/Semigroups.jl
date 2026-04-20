# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

module Semigroups

using CxxWrap
using AbstractAlgebra
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

# High-level element types
include("bmat8.jl")
include("transf.jl")

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

# Transformation types and functions
export Transf, PPerm, Perm
export degree, rank, image, domain, inverse
export increase_degree_by!, swap!
export left_one, right_one

# BMat8
export BMat8, to_int, swap!, degree, random, row_space_basis
export col_space_basis, col_space_size, is_regular_element, minimum_dim
export number_of_cols, number_of_rows, row_space_size, rows

end # module Semigroups
