# ============================================================================
# Limits on conversions to String words
# ============================================================================
# Converting to String words gives each letter (alphabet letter, generator or
# edge label) an ASCII character. libsemigroups 3.6.1 uses different letter
# schemes in different conversions, so the number of letters that stay ASCII
# differs: 31 where the letters are 'a', 'b', ... (up to '\x7f'), and 128
# where every ASCII character is used. Beyond that, libsemigroups silently
# creates non-ASCII letters; check up front instead.
#
# For FroidurePin -> KnuthBendix{String} the limit is 26: beyond 'z',
# libsemigroups 3.6.1's KnuthBendix and the presentation it builds from the
# FroidurePin use different letters, and the conversion fails.
function _check_string_letters(n::Integer, max::Integer, what::AbstractString)
    n <= max || throw(
        ArgumentError("converting to String words supports at most $max $what, got $n"),
    )
    return nothing
end

# ============================================================================
# Conversions to Congruence
# ============================================================================

"""
    to(::Type{Congruence}, kind::congruence_kind, fp::FroidurePin,
       wg) -> Congruence{Vector{Int}}
    to(::Type{Congruence{W}}, kind::congruence_kind, fp::FroidurePin,
       wg) -> Congruence{W}

Convert a Froidure-Pin graph to a Congruence.

Julia implementation of libsemigroups' `to<Congruence>(kind, fp, wg)`
conversion. `wg` must be either the left or right Cayley graph of `fp`.
The result represents the trivial congruence over the semigroup defined by
`fp`.

`kind` selects whether the resulting congruence is one-sided or two-sided.

With an unparameterised target the result uses `Vector{Int}` words; give the
word type explicitly (e.g. `{String}`) for a result over `String` words.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `wg` is not
    the left or right Cayley graph of `fp`.
"""
to(::Type{Congruence}, kind::congruence_kind, fp::FroidurePin, wg) =
    to(Congruence{Vector{Int}}, kind, fp, wg)

to(::Type{Congruence{Vector{Int}}}, kind::congruence_kind, fp::FroidurePin, wg) =
    _wrap_congruence(
        @wrap_libsemigroups_call LibSemigroups.to_congruence_from_fpb(kind, fp.cxx_obj, wg)
    )

function to(::Type{Congruence{String}}, kind::congruence_kind, fp::FroidurePin, wg)
    _check_string_letters(out_degree(wg), 31, "edge labels")
    return _wrap_congruence(
        @wrap_libsemigroups_call LibSemigroups.to_congruence_string_from_fpb(
            kind,
            fp.cxx_obj,
            wg,
        )
    )
end

"""
    to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) -> Congruence{Vector{Int}}
    to(::Type{Congruence{W}}, kind::congruence_kind, wg::WordGraph) -> Congruence{W}

Convert a WordGraph to a Congruence.

Julia implementation of libsemigroups' `to<Congruence>(kind, wg)`
conversion. The result represents the trivial congruence over `wg`.

`kind` selects whether the resulting congruence is one-sided or two-sided.

The graph is added to the constructed congruence as-is; no checks are made
that the resulting Todd-Coxeter or Congruence object is valid.

With an unparameterised target the result uses `Vector{Int}` words; give the
word type explicitly (e.g. `{String}`) for a result over `String` words.
"""
@cxxdereference to(::Type{Congruence}, kind::congruence_kind, wg::WordGraph) =
    to(Congruence{Vector{Int}}, kind, wg)

@cxxdereference to(::Type{Congruence{Vector{Int}}}, kind::congruence_kind, wg::WordGraph) =
    _wrap_congruence(@wrap_libsemigroups_call LibSemigroups.to_congruence_from_wg(kind, wg))

@cxxdereference function to(
    ::Type{Congruence{String}},
    kind::congruence_kind,
    wg::WordGraph,
)
    _check_string_letters(out_degree(wg), 31, "edge labels")
    return _wrap_congruence(
        @wrap_libsemigroups_call LibSemigroups.to_congruence_string_from_wg(kind, wg)
    )
end

# ============================================================================
# Conversions to ToddCoxeter
# ============================================================================

"""
    to(::Type{ToddCoxeter}, kind::congruence_kind, fp::FroidurePin,
       wg::WordGraph) -> ToddCoxeter{Vector{Int}}
    to(::Type{ToddCoxeter{W}}, kind::congruence_kind, fp::FroidurePin,
       wg::WordGraph) -> ToddCoxeter{W}

Convert a Froidure-Pin graph to a Todd-Coxeter.

Julia implementation of libsemigroups' `to<ToddCoxeter>(kind, fp, wg)`
conversion. `wg` must be either the left or right Cayley graph of `fp`.
The result represents the trivial congruence over the semigroup defined by
`fp`.
`kind` selects whether the resulting congruence is one-sided or two-sided.

With an unparameterised target the result uses `Vector{Int}` words; give the
word type explicitly (e.g. `{String}`) for a result over `String` words.

# Throws

- [`LibsemigroupsError`](@ref Semigroups.LibsemigroupsError) if `wg` is not
    the left or right Cayley graph of `fp`.
"""
to(::Type{ToddCoxeter}, kind::congruence_kind, fp::FroidurePin, wg) =
    to(ToddCoxeter{Vector{Int}}, kind, fp, wg)

to(::Type{ToddCoxeter{Vector{Int}}}, kind::congruence_kind, fp::FroidurePin, wg) =
    _wrap_todd_coxeter(
        @wrap_libsemigroups_call LibSemigroups.to_todd_coxeter_from_fpb(
            kind,
            fp.cxx_obj,
            wg,
        )
    )

function to(::Type{ToddCoxeter{String}}, kind::congruence_kind, fp::FroidurePin, wg)
    _check_string_letters(out_degree(wg), 128, "edge labels")
    return _wrap_todd_coxeter(
        @wrap_libsemigroups_call LibSemigroups.to_todd_coxeter_string_from_fpb(
            kind,
            fp.cxx_obj,
            wg,
        )
    )
end

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
to(::Type{ToddCoxeter}, kind::congruence_kind, kb::KnuthBendix) = _wrap_todd_coxeter(
    @wrap_libsemigroups_call LibSemigroups.to_todd_coxeter_from_kb(kind, _cxx(kb))
)

# ============================================================================
# Conversions to Presentation
# ============================================================================

"""
    to(::Type{Presentation}, p::Presentation) -> Presentation
    to(::Type{Presentation{V}}, p::Presentation) -> Presentation{V}

Julia implementation of libsemigroups' presentation conversions.

With an unparameterised `Presentation` target, or a target of the same word
type as `p`, the returned presentation is a copy of `p`. Converting to the
other word type (`Vector{Int}` to `String`, or back) relabels the letters by
alphabet position: the `i`-th letter of the alphabet of `p` becomes the
`i`-th letter of the result, using libsemigroups' default letters (`1, 2, 3,
...` for `Vector{Int}`, `'a', 'b', 'c', ...` for `String`).
"""
to(::Type{Presentation}, p::Presentation) = Presentation(p)

to(::Type{Presentation{W}}, p::Presentation{W}) where {W} = Presentation(p)

function to(::Type{Presentation{String}}, p::Presentation{Vector{Int}})
    _check_string_letters(length(alphabet(p)), 128, "letters")
    return _wrap_presentation(
        @wrap_libsemigroups_call LibSemigroups.to_presentation_string(_cxx(p))
    )
end

to(::Type{Presentation{Vector{Int}}}, p::Presentation{String}) =
    _wrap_presentation(@wrap_libsemigroups_call LibSemigroups.to_presentation_word(_cxx(p)))

"""
    to(::Type{Presentation}, c::Congruence{W}) -> Presentation{W}
    to(::Type{Presentation{V}}, c::Congruence) -> Presentation{V}

Julia implementation of libsemigroups' `to<Presentation>(c)` conversion.
Return the presentation used to construct or initialise `c`.

With an unparameterised `Presentation` target, the returned presentation has
the same word type `W` as `c`. With an explicit target `Presentation{V}`
(`V` is `Vector{Int}` or `String`), the presentation is converted to that
word type.

Congruence-generating pairs are not added to the returned presentation by
running `c`.
"""
to(::Type{Presentation}, c::Congruence{W}) where {W} = to(Presentation{W}, c)

to(::Type{Presentation{Vector{Int}}}, c::Congruence) =
    _wrap_presentation(LibSemigroups.to_presentation_word(_cxx(c)))

to(::Type{Presentation{String}}, c::Congruence) =
    _wrap_presentation(LibSemigroups.to_presentation_string(_cxx(c)))

"""
    to(::Type{Presentation}, k::Kambites{W}) -> Presentation{W}
    to(::Type{Presentation{V}}, k::Kambites) -> Presentation{V}

Julia implementation of libsemigroups' `to<Presentation>(k)` conversion.
Return a presentation equivalent to the presentation used to construct or
initialise `k`.

With an unparameterised `Presentation` target, the returned presentation has
the same word type `W` as `k`. With an explicit target `Presentation{V}`
(`V` is `Vector{Int}` or `String`), the presentation is converted to that
word type.

This conversion does not enumerate `k`.
"""
to(::Type{Presentation}, k::Kambites{W}) where {W} = to(Presentation{W}, k)

to(::Type{Presentation{Vector{Int}}}, k::Kambites) =
    _wrap_presentation(LibSemigroups.to_presentation_word(_cxx(k)))

to(::Type{Presentation{String}}, k::Kambites) =
    _wrap_presentation(LibSemigroups.to_presentation_string(_cxx(k)))

"""
    to(::Type{Presentation}, tc::ToddCoxeter{W}) -> Presentation{W}
    to(::Type{Presentation{V}}, tc::ToddCoxeter) -> Presentation{V}

Julia implementation of libsemigroups' `to<Presentation>(tc)` conversion.
Return the presentation used to construct or initialise `tc`.

With an unparameterised `Presentation` target, the returned presentation has
the same word type `W` as `tc`. With an explicit target `Presentation{V}`
(`V` is `Vector{Int}` or `String`), the presentation is converted to that
word type.

This conversion does not enumerate `tc`.
"""
to(::Type{Presentation}, tc::ToddCoxeter{W}) where {W} = to(Presentation{W}, tc)

to(::Type{Presentation{Vector{Int}}}, tc::ToddCoxeter) =
    _wrap_presentation(LibSemigroups.to_presentation_word(_cxx(tc)))

to(::Type{Presentation{String}}, tc::ToddCoxeter) =
    _wrap_presentation(LibSemigroups.to_presentation_string(_cxx(tc)))

"""
    to(::Type{Presentation}, kb::KnuthBendix{W}) -> Presentation{W}
    to(::Type{Presentation{V}}, kb::KnuthBendix) -> Presentation{V}

Julia implementation of libsemigroups' `to<Presentation>(kb)` conversion.
Return a presentation using the currently active rules of `kb`.

With an unparameterised `Presentation` target, the returned presentation has
the same word type `W` as `kb`. With an explicit target `Presentation{V}`
(`V` is `Vector{Int}` or `String`), the presentation is converted to that
word type.

This conversion does not enumerate `kb`, so the returned presentation may not
yet describe the completed semigroup or monoid. Run `kb` first if a fully
processed presentation is required.
"""
to(::Type{Presentation}, kb::KnuthBendix{W}) where {W} = to(Presentation{W}, kb)

to(::Type{Presentation{Vector{Int}}}, kb::KnuthBendix) =
    _wrap_presentation(LibSemigroups.to_presentation_word(_cxx(kb)))

to(::Type{Presentation{String}}, kb::KnuthBendix) =
    _wrap_presentation(LibSemigroups.to_presentation_string(_cxx(kb)))

"""
    to(::Type{Presentation}, fp::FroidurePin) -> Presentation{Vector{Int}}
    to(::Type{Presentation{W}}, fp::FroidurePin) -> Presentation{W}

Julia implementation of libsemigroups' `to<Presentation>(fp)` conversion.
Return a presentation using the currently known rules of `fp`.

This conversion enumerates `fp` before obtaining its presentation.

With an unparameterised target the result uses `Vector{Int}` words; give the
word type explicitly (e.g. `{String}`) for a result over `String` words.
"""
to(::Type{Presentation}, fp::FroidurePin) = to(Presentation{Vector{Int}}, fp)

to(::Type{Presentation{Vector{Int}}}, fp::FroidurePin) =
    _wrap_presentation(LibSemigroups.to_presentation_word(fp.cxx_obj))

function to(::Type{Presentation{String}}, fp::FroidurePin)
    _check_string_letters(number_of_generators(fp), 31, "generators")
    return _wrap_presentation(LibSemigroups.to_presentation_string(fp.cxx_obj))
end

# ============================================================================
# Conversions to KnuthBendix
# ============================================================================

"""
    to(::Type{KnuthBendix}, kind::congruence_kind, fp::FroidurePin) -> KnuthBendix{Vector{Int}}
    to(::Type{KnuthBendix{W}}, kind::congruence_kind, fp::FroidurePin) -> KnuthBendix{W}

Julia implementation of libsemigroups' `to<KnuthBendix>(kind, fp)`
conversion. It constructs a Knuth-Bendix instance from the presentation
obtained from `fp` and represents the trivial congruence over that semigroup.
`kind` selects whether the resulting congruence is one-sided or two-sided.

This conversion enumerates `fp` before obtaining its presentation.

With an unparameterised target the result uses `Vector{Int}` words; give the
word type explicitly (e.g. `{String}`) for a result over `String` words.
"""
to(::Type{KnuthBendix}, kind::congruence_kind, fp::FroidurePin) =
    to(KnuthBendix{Vector{Int}}, kind, fp)

to(::Type{KnuthBendix{Vector{Int}}}, kind::congruence_kind, fp::FroidurePin) =
    _wrap_knuth_bendix(LibSemigroups.to_knuth_bendix_from_fpb(kind, fp.cxx_obj))

function to(::Type{KnuthBendix{String}}, kind::congruence_kind, fp::FroidurePin)
    _check_string_letters(number_of_generators(fp), 26, "generators")
    return _wrap_knuth_bendix(
        LibSemigroups.to_knuth_bendix_string_from_fpb(kind, fp.cxx_obj),
    )
end

"""
    to(::Type{KnuthBendix}, kind::congruence_kind, tc::ToddCoxeter) -> KnuthBendix

Julia implementation of libsemigroups' `to<KnuthBendix>(kind, tc)`
conversion. It constructs a Knuth-Bendix instance from `tc.presentation()`
and represents the trivial congruence over the semigroup defined by `tc`.
`kind` selects whether the resulting congruence is one-sided or two-sided.
The result has the same word type as `tc`.
"""
to(::Type{KnuthBendix}, kind::congruence_kind, tc::ToddCoxeter) =
    _wrap_knuth_bendix(LibSemigroups.to_knuth_bendix_from_tc(kind, _cxx(tc)))

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
    @wrap_libsemigroups_call LibSemigroups.to_inverse_presentation_word(_cxx_word(p))

"""
    to(::Type{InversePresentation}, ip::InversePresentation) -> InversePresentation

Convert an InversePresentation to an InversePresentation.

Return a copy of `ip`.
"""
to(::Type{InversePresentation}, ip::InversePresentation) = InversePresentation(ip)
