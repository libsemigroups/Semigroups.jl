# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
    LibSemigroups

CxxWrap module definition for libsemigroups bindings

This module loads the compiled C++ wrapper library and exposes the
wrapped types and functions to Julia.
"""

module LibSemigroups

using CxxWrap

import ..Semigroups: libsemigroups_julia

# Load the C++ module - this creates all the wrapped types and functions
# The library path is resolved by setup.jl and may be updated in __init__.
@wrapmodule(libsemigroups_julia, :define_julia_module)

function __init__()
    @initcxx
end

end # module LibSemigroups
