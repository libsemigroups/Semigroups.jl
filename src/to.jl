# ============================================================================
# Conversions to Congruence
# ============================================================================

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

# ============================================================================
# Conversions to ToddCoxeter
# ============================================================================

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

# ============================================================================
# Conversions to Presentation
# ============================================================================

"""
    to(::Type{Presentation}, p::Presentation) -> Presentation

Julia implementation of the identity conversion for `Presentation`. The
returned presentation is a copy of `p`.
"""
to(::Type{Presentation}, p::Presentation) = Presentation(p)

"""
    to(::Type{Presentation}, c::Congruence) -> Presentation

Julia implementation of libsemigroups' `to<Presentation>(c)` conversion.
Return the presentation used to construct or initialise `c`.

This conversion returns the presentation used to construct or initialise `c`.
Congruence-generating pairs are not added to the returned presentation by
running `c`.
"""
to(::Type{Presentation}, c::Congruence) = LibSemigroups.to_presentation_word(c)

"""
    to(::Type{Presentation}, k::Kambites) -> Presentation

Julia implementation of libsemigroups' `to<Presentation>(k)` conversion.
Return a presentation equivalent to the presentation used to construct or
initialise `k`.

This conversion does not enumerate `k`.
"""
to(::Type{Presentation}, k::Kambites) = LibSemigroups.to_presentation_word(k)

"""
    to(::Type{Presentation}, tc::ToddCoxeter) -> Presentation

Julia implementation of libsemigroups' `to<Presentation>(tc)` conversion.
Return the presentation used to construct or initialise `tc`.

This conversion does not enumerate `tc`.
"""
to(::Type{Presentation}, tc::ToddCoxeter) = LibSemigroups.to_presentation_word(tc)

"""
    to(::Type{Presentation}, kb::KnuthBendix) -> Presentation

Julia implementation of libsemigroups' `to<Presentation>(kb)` conversion.
Return a presentation using the currently active rules of `kb`.

This conversion does not enumerate `kb`, so the returned presentation may not
yet describe the completed semigroup or monoid. Run `kb` first if a fully
processed presentation is required.
"""
to(::Type{Presentation}, kb::KnuthBendix) = LibSemigroups.to_presentation_word(kb)

"""
    to(::Type{Presentation}, fp::FroidurePin) -> Presentation

Julia implementation of libsemigroups' `to<Presentation>(fp)` conversion.
Return a presentation using the currently known rules of `fp`.

This conversion enumerates `fp` before obtaining its presentation.
"""
to(::Type{Presentation}, fp::FroidurePin) = LibSemigroups.to_presentation_word(fp.cxx_obj)

# ============================================================================
# Conversions to KnuthBendix
# ============================================================================

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

# ============================================================================
# Conversions to FroidurePin
# ============================================================================

"""
    to(::Type{FroidurePin}, wg::WordGraph) -> FroidurePin{Transf{UInt32}}

Convert a complete `WordGraph` to a Froidure-Pin whose elements are
`Transf{UInt32}`. This is the Julia implementation of
libsemigroups' `to<FroidurePin>(wg)` conversion. Each graph label becomes a
transformation generator, with the transformation image determined by the
edge target for each node.

The graph must be complete, and every target must be a node of the graph.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if the graph is
    incomplete or contains an out-of-range target.
"""
@cxxdereference to(::Type{FroidurePin}, wg::WordGraph) =
    FroidurePin{Transf{UInt32}}(@wrap_libsemigroups_call begin
        LibSemigroups.to_froidure_pin_from_wg(wg)
    end)

# ============================================================================
# Conversions to InversePresentation
# ============================================================================

"""
    to(::Type{InversePresentation}, p::Presentation) -> InversePresentation

Convert a Presentation to an InversePresentation.

Julia implementation of libsemigroups' `to<InversePresentation>(p)`
conversion. The resulting inverse presentation has rules equivalent to
those of `p`, over a normalised alphabet with a corresponding inverse
letter for each letter of `p`.
"""
to(::Type{InversePresentation}, p::Presentation) =
    @wrap_libsemigroups_call LibSemigroups.to_inverse_presentation_word(p)

"""
    to(::Type{InversePresentation}, ip::InversePresentation) -> InversePresentation

Convert an InversePresentation to an InversePresentation.

Return a copy of `ip`.
"""
to(::Type{InversePresentation}, ip::InversePresentation) = InversePresentation(ip)
