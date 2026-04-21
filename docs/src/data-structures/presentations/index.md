# Presentations

This section documents the [`Presentation`](@ref Semigroups.Presentation) and
[`InversePresentation`](@ref Semigroups.InversePresentation) types, the
namespace of helper free functions that operate on them, and the catalog of
standard example presentations provided by
`libsemigroups::presentation::examples`.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `Presentation<word_type>` only. Alphabets and
    rules use `Vector{Int}` with 1-based letter indices.

## Contents

| Page                                           | Description                                                    |
| ---------------------------------------------- | -------------------------------------------------------------- |
| [Presentation](presentation.md)                | The main `Presentation{word_type}` type.                       |
| [InversePresentation](inverse-presentation.md) | `InversePresentation{word_type}` with per-generator inverses.  |
| [Helper functions](helpers.md)                 | Free functions in `presentation::*`.                           |
| [Examples](examples.md)                        | Standard presentations (symmetric group, partition monoid, ...). |
