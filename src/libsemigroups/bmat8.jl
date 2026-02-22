# Copyright (c) 2026, James W. Swent, J. D. Mitchell
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.


"""
bmat8.jl - Julia wrappers for BMat8 in libsemigroups

This file provides low-level Julia wrappers for the C++ BMat8 exposed via
CxxWrap. These are thin wrappers that provide memory safety via GC.@preserve
and convenient access to the C++ bindings.
"""

# TODO I don't really understand why this file needs to exist at all
