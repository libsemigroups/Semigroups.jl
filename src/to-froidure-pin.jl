"""
to-froidure-pin.jl - conversions to FroidurePin
"""

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
