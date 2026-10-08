"""
to-todd-coxeter.jl - conversions to ToddCoxeter
"""

"""
    to(::Type{ToddCoxeter}, kind::congruence_kind, fp::FroidurePin,
       wg::WordGraph) -> ToddCoxeter

Convert a Froidure-Pin graph to a Todd-Coxeter.

Julia implementation of libsemigroups' `to<ToddCoxeter>(kind, fp, wg)`
conversion. `wg` must be either the left or right Cayley graph of `fp`.
The result represents the trivial congruence over the semigroup defined by
`fp`.
`kind` selects whether the resulting congruence is one-sided or two-sided.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `wg` is not
    the left or right Cayley graph of `fp`.
"""
to(::Type{ToddCoxeter}, kind::congruence_kind, fp::FroidurePin, wg) =
    @wrap_libsemigroups_call LibSemigroups.to_todd_coxeter_from_fpb(kind, fp.cxx_obj, wg)

"""
    to(::Type{ToddCoxeter}, kind::congruence_kind, kb::KnuthBendix) -> ToddCoxeter

Convert a Knuth-Bendix to a Todd-Coxeter.

Julia implementation of libsemigroups' `to<ToddCoxeter>(kind, kb)`
conversion. It uses the right Cayley graph of the semigroup represented by
`kb` and returns the corresponding trivial congruence.
`kind` selects whether the resulting congruence is one-sided or two-sided.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `kb` does not
    represent a two-sided congruence or has infinitely many classes. In the
    infinite case, use `ToddCoxeter(kind, presentation(kb))` instead.
"""
to(::Type{ToddCoxeter}, kind::congruence_kind, kb::KnuthBendix) =
    @wrap_libsemigroups_call LibSemigroups.to_todd_coxeter_from_kb(kind, kb)
