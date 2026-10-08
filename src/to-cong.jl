"""
to-cong.jl - conversions to Congruence
"""

"""
    to(::Type{Congruence}, kind::congruence_kind, fp::FroidurePin,
       wg) -> Congruence

Convert a Froidure-Pin graph to a Congruence.

Julia implementation of libsemigroups' `to<Congruence>(kind, fp, wg)`
conversion. `wg` must be either the left or right Cayley graph of `fp`.
The result represents the trivial congruence over the semigroup defined by
`fp`.

`kind` selects whether the resulting congruence is one-sided or two-sided.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `wg` is not
    the left or right Cayley graph of `fp`.
"""
to(::Type{Congruence}, kind::congruence_kind, fp::FroidurePin, wg) =
    @wrap_libsemigroups_call LibSemigroups.to_congruence_from_fpb(kind, fp.cxx_obj, wg)

"""
    to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) -> Congruence

Convert a WordGraph to a Congruence.

Julia implementation of libsemigroups' `to<Congruence>(kind, wg)`
conversion. The result represents the trivial congruence over `wg`.

`kind` selects whether the resulting congruence is one-sided or two-sided.

The graph is added to the constructed congruence as-is; no checks are made
that the resulting Todd-Coxeter or Congruence object is valid.
"""
@cxxdereference to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) =
    @wrap_libsemigroups_call LibSemigroups.to_congruence_from_wg(kind, wg)
