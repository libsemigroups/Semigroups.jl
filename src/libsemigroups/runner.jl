# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
runner.jl - Julia wrappers for libsemigroups Runner base class

This file provides low-level Julia wrappers for the C++ Runner class exposed
via CxxWrap. Runner is an abstract base class providing algorithm execution
control (run, run_for, timeout, stop, etc.) used by FroidurePinBase and other
algorithm classes.
"""

# ============================================================================
# Type aliases
# ============================================================================

"""
    Runner

Abstract base type for algorithm runners in libsemigroups. This type is not
directly constructible; it is used as the base type for concrete algorithm
classes such as `FroidurePinBase`.
"""
const Runner = LibSemigroups.Runner

"""
    RunnerState

Enum type for the state of a [`Runner`](@ref). Possible values:

- `STATE_NEVER_RUN` - the runner has never been run
- `STATE_RUNNING_TO_FINISH` - running to completion
- `STATE_RUNNING_FOR` - running for a bounded duration
- `STATE_RUNNING_UNTIL` - running until a predicate is satisfied
- `STATE_TIMED_OUT` - the last `run_for!` call timed out
- `STATE_STOPPED_BY_PREDICATE` - the last `run_until` call was stopped
- `STATE_NOT_RUNNING` - the runner is not currently running
- `STATE_DEAD` - the runner was killed
"""
const RunnerState = LibSemigroups.state

const STATE_NEVER_RUN = LibSemigroups.state_never_run
const STATE_RUNNING_TO_FINISH = LibSemigroups.state_running_to_finish
const STATE_RUNNING_FOR = LibSemigroups.state_running_for
const STATE_RUNNING_UNTIL = LibSemigroups.state_running_until
const STATE_TIMED_OUT = LibSemigroups.state_timed_out
const STATE_STOPPED_BY_PREDICATE = LibSemigroups.state_stopped_by_predicate
const STATE_NOT_RUNNING = LibSemigroups.state_not_running
const STATE_DEAD = LibSemigroups.state_dead

# ============================================================================
# Core algorithm control
# ============================================================================

"""
    run!(r::Runner)

Run the algorithm to completion. This is a blocking call that will not return
until the algorithm has finished, timed out, or been killed.
"""
run!(r::Runner) = LibSemigroups.run!(r)

"""
    run_for!(r::Runner, t::TimePeriod)

Run the algorithm for at most the duration `t`. The algorithm may finish
before the time limit, in which case [`finished`](@ref) will return `true`.
If the time limit is reached, [`timed_out`](@ref) will return `true`.

# Examples
```julia
run_for!(r, Second(1))
run_for!(r, Millisecond(500))
```
"""
function run_for!(r::Runner, t::TimePeriod)
    ns = convert(Nanosecond, t)
    Dates.value(ns) >= 0 ||
        throw(ArgumentError("run_for! requires a non-negative duration, got $t"))
    LibSemigroups.run_for!(r, Int64(Dates.value(ns)))
end


"""
    run_until!(f::Function, r::Runner)
    run_until!(r::Runner, f::Function)

Run the algorithm until the nullary predicate `f` returns `true` or the
algorithm [`finished`](@ref). Supports do-block syntax:

```julia
run_until!(r) do
    some_condition(r)
end
```
"""
function run_until!(f::Function, r::Runner)
    sf = @safe_cfunction($f, Cuchar, ())
    GC.@preserve sf LibSemigroups.run_until!(r, sf)
end
run_until!(r::Runner, f::Function) = run_until!(f, r)

"""
    init!(r::Runner) -> Runner

Re-initialize the runner to its default-constructed state, discarding all
previously computed results.
"""
init!(r::Runner) = LibSemigroups.init!(r)

# ============================================================================
# State queries
# ============================================================================

"""
    finished(r::Runner) -> Bool

Return `true` if the algorithm has run to completion.
"""
finished(r::Runner) = LibSemigroups.finished(r)

"""
    Base.success(r::Runner) -> Bool

Return `true` if the algorithm has completed successfully. This extends
`Base.success` (which checks process exit status) to work with libsemigroups
[`Runner`](@ref) types. By default, this returns the same value as
[`finished`](@ref), but derived classes may override this to distinguish
between completion and successful completion.
"""
Base.success(r::Runner) = LibSemigroups.success(r)

"""
    started(r::Runner) -> Bool

Return `true` if [`run!`](@ref) has been called at least once.
"""
started(r::Runner) = LibSemigroups.started(r)

"""
    running(r::Runner) -> Bool

Return `true` if the algorithm is currently executing.
"""
running(r::Runner) = LibSemigroups.running(r)

"""
    timed_out(r::Runner) -> Bool

Return `true` if the last call to [`run_for!`](@ref) exhausted its time limit
without the algorithm finishing.
"""
timed_out(r::Runner) = LibSemigroups.timed_out(r)

"""
    stopped(r::Runner) -> Bool

Return `true` if the algorithm is stopped for any reason (finished, timed out,
dead, or stopped by predicate).
"""
stopped(r::Runner) = LibSemigroups.stopped(r)

"""
    dead(r::Runner) -> Bool

Return `true` if the runner was killed (e.g. from another thread via
[`kill!`](@ref)).
"""
dead(r::Runner) = LibSemigroups.dead(r)

"""
    stopped_by_predicate(r::Runner) -> Bool

Return `true` if the last `run_until` call was stopped because the predicate
was satisfied.
"""
stopped_by_predicate(r::Runner) = LibSemigroups.stopped_by_predicate(r)

"""
    running_for(r::Runner) -> Bool

Return `true` if the runner is currently executing a [`run_for!`](@ref) call.
"""
running_for(r::Runner) = LibSemigroups.running_for(r)

"""
    running_for_how_long(r::Runner) -> Nanosecond

Return the duration of the most recent [`run_for!`](@ref) call as a
`Dates.Nanosecond` period.
"""
running_for_how_long(r::Runner) = Nanosecond(LibSemigroups.running_for_how_long(r))

"""
    running_until(r::Runner) -> Bool

Return `true` if the runner is currently executing a `run_until` call.
"""
running_until(r::Runner) = LibSemigroups.running_until(r)

"""
    current_state(r::Runner) -> RunnerState

Return the current [`RunnerState`](@ref) of the runner.
"""
current_state(r::Runner) = LibSemigroups.current_state(r)

# ============================================================================
# Control
# ============================================================================

"""
    kill!(r::Runner)

Kill the runner. This is thread-safe and can be called from another thread
to stop a running algorithm. After calling `kill!`, [`dead`](@ref) will return
`true`.
"""
kill!(r::Runner) = LibSemigroups.kill!(r)

# ============================================================================
# Reporting
# ============================================================================

"""
    report_why_we_stopped(r::Runner)

Print the reason the algorithm stopped to `stderr`.
"""
report_why_we_stopped(r::Runner) = LibSemigroups.report_why_we_stopped(r)

"""
    string_why_we_stopped(r::Runner) -> String

Return a human-readable string describing why the algorithm stopped.
"""
string_why_we_stopped(r::Runner) = LibSemigroups.string_why_we_stopped(r)
