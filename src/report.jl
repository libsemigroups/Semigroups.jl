# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
report.jl - Julia wrapper for libsemigroups ReportGuard

ReportGuard is an RAII type that enables or disables verbose reporting during
libsemigroups computations. Reporting is enabled (or not) at construction time,
and disabled when the ReportGuard is finalized.
"""

# ============================================================================
# ReportGuard
# ============================================================================

"""
    ReportGuard(val::Bool=true)

Enable or disable verbose reporting during libsemigroups computations.

When `val` is `true`, libsemigroups will print progress information to stderr
during long-running computations. When the `ReportGuard` is garbage collected,
reporting is automatically disabled.

For deterministic scoping, use the do-block form:

    ReportGuard(true) do
        # reporting enabled here
        run!(s)
    end
    # reporting disabled here

# Examples
```julia
ReportGuard(false)  # disable reporting

ReportGuard(true) do
    run!(s)  # reporting enabled during this block
end
```
"""
mutable struct ReportGuard
    cppobj::LibSemigroups.CppReportGuard

    function ReportGuard(val::Bool = true)
        obj = new(LibSemigroups.CppReportGuard(val))
        finalizer(obj) do x
            finalize(x.cppobj)
        end
        return obj
    end
end

"""
    ReportGuard(f::Function, val::Bool=true)

Do-block form for scoped reporting control. Reporting is enabled (or not) for
the duration of `f`, then deterministically disabled when the block exits.

# Examples
```julia
ReportGuard(true) do
    run!(s)  # reporting enabled
end
# reporting disabled
```
"""
function ReportGuard(f::Function, val::Bool = true)
    guard = LibSemigroups.CppReportGuard(val)
    try
        f()
    finally
        finalize(guard)
    end
end
