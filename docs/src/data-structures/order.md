# Orders

This page describes the [`Order`](@ref) enum and the word-comparator helpers
in Semigroups.jl. Words are `Vector{Int}` with 1-based letter indices; the
comparators mirror libsemigroups's `order.hpp` free functions.

## The `Order` enum

```@docs
Semigroups.Order
Semigroups.ORDER_NONE
Semigroups.ORDER_SHORTLEX
Semigroups.ORDER_LEX
Semigroups.ORDER_RECURSIVE
```

## Contents

| Function                                                                                                                                          | Description                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| [`lex_less`](@ref Semigroups.lex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))                                                  | Compare two words using lexicographic order.           |
| [`shortlex_less`](@ref Semigroups.shortlex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))                                        | Compare two words using short-lex order.               |
| [`recursive_path_less`](@ref Semigroups.recursive_path_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))                            | Compare two words using the recursive-path ordering.   |
| [`weighted_lex_less`](@ref Semigroups.weighted_lex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))   | Compare two words using weighted lex.                  |
| [`weighted_shortlex_less`](@ref Semigroups.weighted_shortlex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Compare two words using weighted short-lex.     |

## Full API

```@docs
Semigroups.lex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.shortlex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.recursive_path_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.weighted_lex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.weighted_shortlex_less(::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```
