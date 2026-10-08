"""
to-knuth-bendix.jl - conversions to KnuthBendix
"""

"""
    to(::Type{KnuthBendix}, kind::congruence_kind, fp::FroidurePin) -> KnuthBendix

Julia implementation of libsemigroups' `to<KnuthBendix>(kind, fp)`
conversion. It constructs a Knuth-Bendix instance from the presentation
obtained from `fp` and represents the trivial congruence over that semigroup.
`kind` selects whether the resulting congruence is one-sided or two-sided.

This conversion enumerates `fp` before obtaining its presentation.
"""
to(::Type{KnuthBendix}, kind::congruence_kind, fp::FroidurePin) =
    LibSemigroups.to_knuth_bendix_from_fpb(kind, fp.cxx_obj)

"""
    to(::Type{KnuthBendix}, kind::congruence_kind, tc::ToddCoxeter) -> KnuthBendix

Julia implementation of libsemigroups' `to<KnuthBendix>(kind, tc)`
conversion. It constructs a Knuth-Bendix instance from `tc.presentation()`
and represents the trivial congruence over the semigroup defined by `tc`.
`kind` selects whether the resulting congruence is one-sided or two-sided.
"""
to(::Type{KnuthBendix}, kind::congruence_kind, tc::ToddCoxeter) =
    LibSemigroups.to_knuth_bendix_from_tc(kind, tc)
