"""
to-presentation.jl - <Type> to Presentation conversion
"""

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
