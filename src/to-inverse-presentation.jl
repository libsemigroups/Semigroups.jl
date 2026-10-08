"""
to-inverse-presentation.jl - conversions to InversePresentation
"""

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
