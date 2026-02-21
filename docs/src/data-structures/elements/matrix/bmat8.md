# The BMat8 type

This page contains the documentation of the type [`BMat8`](@ref).

## Contents

| Function                                                                           | Description                                                     |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`BMat8`](@ref Semigroups.BMat8(::Vector{Vector{T}}) where {T<:Union{Bool,Int64}}) | Construct from `Vector{Vector{T}} where {T<:Union{Bool,Int64}}` |
| [`degree`](@ref Semigroups.degree(::BMat8))                                        | Returns the degree of a [`BMat8`](@ref).                        |
| [`swap!`](@ref Semigroups.swap!(::BMat8,::BMat8))                                  | Swaps two [`BMat8`](@ref) objects.                              |
| [`to_int`](@ref Semigroups.to_int(::BMat8))                                        | Returns the integer representation of a [`BMat8`](@ref).        |

## Full API

```@docs
Semigroups.BMat8
Semigroups.BMat8(::Vector{Vector{T}}) where {T<:Union{Bool,Int64}}
Semigroups.degree(::BMat8)
Semigroups.swap!(::BMat8,::BMat8)
Semigroups.to_int(::BMat8)
```
