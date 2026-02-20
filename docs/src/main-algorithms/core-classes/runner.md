# The Runner class

```@docs
Runner
```

## Contents

| Function                                                        | Description                                                                                                  |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| [`current_state`](@ref current_state(::Runner))                 | Return the current state.                                                                                    |
| [`dead`](@ref dead(::Runner))                                   | Check if the runner is dead.                                                                                 |
| [`finished`](@ref finished(::Runner))                           | Check if run has been run to completion or not.                                                              |
| [`kill!`](@ref kill!(::Runner))                                 | Stop run from running (thread-safe).                                                                         |
| [`report_why_we_stopped`](@ref report_why_we_stopped(::Runner)) | Report why run stopped.                                                                                      |
| [`run!`](@ref run!(::Runner))                                   | Run until finished.                                                                                          |
| [`run_for!`](@ref run_for!(::Runner))                           | Run for a specified amount of time.                                                                          |
| [`run_until!`](@ref run_until!(::Runner))                       | Run until a nullary predicate returns `true` or finished.                                                    |
| [`running`](@ref running(::Runner))                             | Check if currently running.                                                                                  |
| [`running_for`](@ref running_for(::Runner))                     | Check if the runner is currently running for a particular length of time.                                    |
| [`running_until`](@ref running_until(::Runner))                 | Check if the runner is currently running until a nullary predicate returns true.                             |
| [`started`](@ref started(::Runner))                             | Check if run has been called at least once before.                                                           |
| [`success`](@ref success(::Runner))                             | Check if run has been run to completion successfully.                                                        |
| [`stopped`](@ref stopped(::Runner))                             | Check if the runner is stopped.                                                                              |
| [`stopped_by_predicate`](@ref stopped_by_predicate(::Runner))   | Check if the runner was stopped, or should stop, because of the argument last passed to [`run_until`](@ref). |
| [`timed_out`](@ref timed_out(::Runner))                         | Check if the amount of time passed to run_for has elapsed.                                                   |

## Full API

```@docs
current_state(::Runner)
dead(::Runner)
finished(::Runner)
kill!(::Runner)
report_why_we_stopped(::Runner)
run!(::Runner)
run_for!(::Runner, ::TimePeriod)
run_until!(::Runner, ::Function)
running(::Runner)
running_for(::Runner)
running_until(::Runner)
success(::Runner)
started(::Runner)
stopped(::Runner)
stopped_by_predicate(::Runner)
timed_out(::Runner)
```
