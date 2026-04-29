# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
to.jl - Single dispatch surface for libsemigroups' `to<>` conversions.

Each `to(::Type{T}, args...)` method wraps a libsemigroups
`to<T>(args...)` overload. The function name `to` is intentionally
generic: additional methods will be appended in later phases as more
target types come online.
"""

# ============================================================================
# to(::Type{Congruence}, ...)
# ============================================================================

"""
    to(::Type{Congruence}, kind::congruence_kind, fpb::FroidurePinBase, wg::WordGraph) -> Congruence

Convert a [`FroidurePinBase`](@ref Semigroups.FroidurePinBase) and one
of its Cayley graphs into a [`Congruence`](@ref Semigroups.Congruence)
of the given `kind`.

`wg` must be `fpb`'s left or right Cayley graph (see
[`right_cayley_graph`](@ref Semigroups.right_cayley_graph) and
[`left_cayley_graph`](@ref Semigroups.left_cayley_graph)); the
underlying libsemigroups conversion verifies this and throws
otherwise.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `wg` is
  neither the left nor the right Cayley graph of `fpb`.
"""
to(::Type{Congruence}, kind::congruence_kind, fpb::FroidurePinBase, wg::WordGraph) =
    @wrap_libsemigroups_call LibSemigroups.to_congruence_from_fpb(kind, fpb, wg)

# `FroidurePin{E}` is the high-level Julia parametric wrapper around a
# concrete C++ FroidurePin instance (`fp.cxx_obj`); accept it directly and
# unwrap. Without this overload, callers would have to write
# `to(Congruence, kind, fp.cxx_obj, wg)`, which leaks the wrapper layout.
to(::Type{Congruence}, kind::congruence_kind, fp::FroidurePin, wg) =
    @wrap_libsemigroups_call LibSemigroups.to_congruence_from_fpb(kind, fp.cxx_obj, wg)

"""
    to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) -> Congruence

Construct a [`Congruence`](@ref Semigroups.Congruence) of the given
`kind` directly from a [`WordGraph`](@ref Semigroups.WordGraph).

This form performs no validation of `wg`; the caller is responsible for
ensuring that `wg` is a valid input. The upstream `to(...)` helper is
documented as adding `wg` "as is" to the constructed congruence, with
no checks that the constructed object is valid (see `to-cong.hpp:106-108`).
"""
to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) =
    @wrap_libsemigroups_call LibSemigroups.to_congruence_from_wg(kind, wg)
