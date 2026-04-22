# The InversePresentation type

This page documents the type
[`InversePresentation`](@ref Semigroups.InversePresentation), a
[`Presentation`](@ref Semigroups.Presentation) equipped with per-generator
inverses.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `InversePresentation<word_type>` only. Alphabets,
    rules, and inverses use `Vector{Int}` with 1-based letter indices.

```@docs
Semigroups.InversePresentation
```

## Contents

| Function                                                                                                             | Description                                                            |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [`set_inverses!`](@ref Semigroups.set_inverses!(::InversePresentation, ::AbstractVector{<:Integer}))                 | Set the vector of inverses, one per generator.                         |
| [`inverses`](@ref Semigroups.inverses(::InversePresentation))                                                        | Return the inverses as a `Vector{Int}`.                                |
| [`inverse_of`](@ref Semigroups.inverse_of(::InversePresentation, ::Integer))                                         | Return the inverse of a given letter.                                  |
| [`throw_if_bad_alphabet_rules_or_inverses`](@ref Semigroups.throw_if_bad_alphabet_rules_or_inverses(::InversePresentation)) | Validate the alphabet, rules, and inverses jointly.                    |

## Full API

```@docs
Semigroups.set_inverses!(::InversePresentation, ::AbstractVector{<:Integer})
Semigroups.inverses(::InversePresentation)
Semigroups.inverse_of(::InversePresentation, ::Integer)
Semigroups.throw_if_bad_alphabet_rules_or_inverses(::InversePresentation)
```
