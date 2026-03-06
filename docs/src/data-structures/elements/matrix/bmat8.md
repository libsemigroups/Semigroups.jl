# The BMat8 type

This page contains the documentation of the type [`BMat8`](@ref).

## Contents

| Function                                                                           | Description                                                     |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`BMat8`](@ref Semigroups.BMat8(::Vector{Vector{T}}) where {T<:Union{Bool,Int64}}) | Construct from `Vector{Vector{T}} where {T<:Union{Bool,Int64}}` |
| [`col_space_basis`](@ref Semigroups.col_space_basis(::BMat8))                      | Find a basis for the column space of a [`BMat8`](@ref).         |
| [`col_space_size`](@ref Semigroups.col_space_size(::BMat8))                        | Returns the size of the column space of a [`BMat8`](@ref).      |
| [`degree`](@ref Semigroups.degree(::BMat8))                                        | Returns the degree of a [`BMat8`](@ref).                        |
| [`number_of_cols`](@ref Semigroups.number_of_cols(::BMat8))                        | Returns the number of non-zero columns in a [`BMat8`](@ref).    |
| [`number_of_rows`](@ref Semigroups.number_of_rows(::BMat8))                        | Returns the number of non-zero rows in a [`BMat8`](@ref).       |
| [`is_regular_element`](@ref Semigroups.is_regular_element(::BMat8))                | Check whether a [`BMat8`](@ref) is regular.                     |
| [`minimum_dim`](@ref Semigroups.minimum_dim(::BMat8))                              | Returns the minimum dimension of a [`BMat8`](@ref).             |
| [`one`](@ref Base.one(::BMat8, ::Int64))                                           | Returns the identity [`BMat8`](@ref) of a given dimension.      |
| [`one`](@ref Base.one(::Type{BMat8}, ::Int64))                                     | Returns the identity [`BMat8`](@ref) of a given dimension.      |
| [`random`](@ref Semigroups.random(::BMat8, ::Int64))                               | Returns a random [`BMat8`](@ref) of a given dimension.          |
| [`random`](@ref Semigroups.random(::Type{BMat8}, ::Int64))                         | Returns a random [`BMat8`](@ref) of a given dimension.          |
| [`row_space_basis`](@ref Semigroups.row_space_basis(::BMat8))                      | Find a basis for the row space of a [`BMat8`](@ref).            |
| [`row_space_size`](@ref Semigroups.row_space_size(::BMat8))                        | Returns the size of the row space of a [`BMat8`](@ref).         |
| [`rows`](@ref Semigroups.rows(::BMat8))                                            | Returns the rows of a [`BMat8`](@ref).                          |
| [`swap!`](@ref Semigroups.swap!(::BMat8,::BMat8))                                  | Swaps two [`BMat8`](@ref) objects.                              |
| [`to_int`](@ref Semigroups.to_int(::BMat8))                                        | Returns the integer representation of a [`BMat8`](@ref).        |

## Full API

```@docs
Semigroups.BMat8
Semigroups.BMat8(::Vector{Vector{T}}) where {T<:Union{Bool,Int64}}
Semigroups.col_space_basis(::BMat8)
Semigroups.col_space_size(::BMat8)
Semigroups.degree(::BMat8)
Semigroups.is_regular_element(::BMat8)
Semigroups.minimum_dim(::BMat8)
Semigroups.number_of_cols(::BMat8)
Semigroups.number_of_rows(::BMat8)
Base.one(::Type{BMat8}, ::Int64)
Base.one(::BMat8, ::Int64)
Semigroups.random(::Type{BMat8}, ::Int64)
Semigroups.random(::BMat8, ::Int64)
Semigroups.row_space_basis(::BMat8)
Semigroups.row_space_size(::BMat8)
Semigroups.rows(::BMat8)
Semigroups.swap!(::BMat8,::BMat8)
Semigroups.to_int(::BMat8)
```
