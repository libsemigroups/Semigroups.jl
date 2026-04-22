# Example presentations

This page documents the catalogue of standard presentations exposed via
`libsemigroups::presentation::examples`. Each function returns a fresh
[`Presentation`](@ref Semigroups.Presentation) with the alphabet and rules
initialised to a well-known construction.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `Presentation<word_type>` only. Alphabets and
    rules use `Vector{Int}` with 1-based letter indices.

## Groups and transformation monoids

### Contents

| Function                                                                                                        | Description                                              |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| [`symmetric_group`](@ref Semigroups.symmetric_group(::Integer))                                                 | Symmetric group `S_n`.                                   |
| [`alternating_group`](@ref Semigroups.alternating_group(::Integer))                                             | Alternating group `A_n`.                                 |
| [`braid_group`](@ref Semigroups.braid_group(::Integer))                                                         | Braid group `B_n`.                                       |
| [`not_symmetric_group`](@ref Semigroups.not_symmetric_group(::Integer))                                         | A presentation that does not define `S_n`.               |
| [`full_transformation_monoid`](@ref Semigroups.full_transformation_monoid(::Integer))                           | Full transformation monoid `T_n`.                        |
| [`partial_transformation_monoid`](@ref Semigroups.partial_transformation_monoid(::Integer))                     | Partial transformation monoid `PT_n`.                    |
| [`symmetric_inverse_monoid`](@ref Semigroups.symmetric_inverse_monoid(::Integer))                               | Symmetric inverse monoid `I_n`.                          |
| [`cyclic_inverse_monoid`](@ref Semigroups.cyclic_inverse_monoid(::Integer))                                     | Cyclic inverse monoid.                                   |
| [`order_preserving_monoid`](@ref Semigroups.order_preserving_monoid(::Integer))                                 | Monoid of order-preserving transformations of `{1,...,n}`. |
| [`order_preserving_cyclic_inverse_monoid`](@ref Semigroups.order_preserving_cyclic_inverse_monoid(::Integer))   | Order-preserving cyclic inverse monoid.                  |
| [`orientation_preserving_monoid`](@ref Semigroups.orientation_preserving_monoid(::Integer))                     | Orientation-preserving monoid.                           |
| [`orientation_preserving_reversing_monoid`](@ref Semigroups.orientation_preserving_reversing_monoid(::Integer)) | Orientation-preserving-or-reversing monoid.              |

### Full API

```@docs
Semigroups.symmetric_group(::Integer)
Semigroups.alternating_group(::Integer)
Semigroups.braid_group(::Integer)
Semigroups.not_symmetric_group(::Integer)
Semigroups.full_transformation_monoid(::Integer)
Semigroups.partial_transformation_monoid(::Integer)
Semigroups.symmetric_inverse_monoid(::Integer)
Semigroups.cyclic_inverse_monoid(::Integer)
Semigroups.order_preserving_monoid(::Integer)
Semigroups.order_preserving_cyclic_inverse_monoid(::Integer)
Semigroups.orientation_preserving_monoid(::Integer)
Semigroups.orientation_preserving_reversing_monoid(::Integer)
```

## Diagram and partition monoids

### Contents

| Function                                                                                                    | Description                            |
| ----------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| [`partition_monoid`](@ref Semigroups.partition_monoid(::Integer))                                           | Partition monoid `P_n`.                |
| [`partial_brauer_monoid`](@ref Semigroups.partial_brauer_monoid(::Integer))                                 | Partial Brauer monoid.                 |
| [`brauer_monoid`](@ref Semigroups.brauer_monoid(::Integer))                                                 | Brauer monoid.                         |
| [`singular_brauer_monoid`](@ref Semigroups.singular_brauer_monoid(::Integer))                               | Singular Brauer monoid.                |
| [`temperley_lieb_monoid`](@ref Semigroups.temperley_lieb_monoid(::Integer))                                 | Temperley-Lieb monoid.                 |
| [`motzkin_monoid`](@ref Semigroups.motzkin_monoid(::Integer))                                               | Motzkin monoid.                        |
| [`partial_isometries_cycle_graph_monoid`](@ref Semigroups.partial_isometries_cycle_graph_monoid(::Integer)) | Partial isometries of the cycle graph. |
| [`uniform_block_bijection_monoid`](@ref Semigroups.uniform_block_bijection_monoid(::Integer))               | Uniform block bijection monoid.        |
| [`dual_symmetric_inverse_monoid`](@ref Semigroups.dual_symmetric_inverse_monoid(::Integer))                 | Dual symmetric inverse monoid.         |
| [`stellar_monoid`](@ref Semigroups.stellar_monoid(::Integer))                                               | Stellar monoid.                        |
| [`zero_rook_monoid`](@ref Semigroups.zero_rook_monoid(::Integer))                                           | 0-rook monoid.                         |
| [`abacus_jones_monoid`](@ref Semigroups.abacus_jones_monoid(::Integer, ::Integer))                          | Abacus Jones monoid.                   |

### Full API

```@docs
Semigroups.partition_monoid(::Integer)
Semigroups.partial_brauer_monoid(::Integer)
Semigroups.brauer_monoid(::Integer)
Semigroups.singular_brauer_monoid(::Integer)
Semigroups.temperley_lieb_monoid(::Integer)
Semigroups.motzkin_monoid(::Integer)
Semigroups.partial_isometries_cycle_graph_monoid(::Integer)
Semigroups.uniform_block_bijection_monoid(::Integer)
Semigroups.dual_symmetric_inverse_monoid(::Integer)
Semigroups.stellar_monoid(::Integer)
Semigroups.zero_rook_monoid(::Integer)
Semigroups.abacus_jones_monoid(::Integer, ::Integer)
```

## Plactic monoids

### Contents

| Function                                                                                    | Description                        |
| ------------------------------------------------------------------------------------------- | ---------------------------------- |
| [`plactic_monoid`](@ref Semigroups.plactic_monoid(::Integer))                               | Plactic monoid on `n` letters.     |
| [`chinese_monoid`](@ref Semigroups.chinese_monoid(::Integer))                               | Chinese monoid on `n` letters.     |
| [`hypo_plactic_monoid`](@ref Semigroups.hypo_plactic_monoid(::Integer))                     | Hypoplactic monoid on `n` letters. |
| [`sigma_plactic_monoid`](@ref Semigroups.sigma_plactic_monoid(::AbstractVector{<:Integer})) | ``\sigma``-plactic monoid for a given `sigma`.  |
| [`stylic_monoid`](@ref Semigroups.stylic_monoid(::Integer))                                 | Stylic monoid on `n` letters.      |

### Full API

```@docs
Semigroups.plactic_monoid(::Integer)
Semigroups.chinese_monoid(::Integer)
Semigroups.hypo_plactic_monoid(::Integer)
Semigroups.sigma_plactic_monoid(::AbstractVector{<:Integer})
Semigroups.stylic_monoid(::Integer)
```

## Other

### Contents

| Function                                                                                     | Description                                                     |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`fibonacci_semigroup`](@ref Semigroups.fibonacci_semigroup(::Integer, ::Integer))           | Fibonacci semigroup `F(r, n)`.                                  |
| [`monogenic_semigroup`](@ref Semigroups.monogenic_semigroup(::Integer, ::Integer))           | Monogenic semigroup with index `m`, period `r`.                 |
| [`rectangular_band`](@ref Semigroups.rectangular_band(::Integer, ::Integer))                 | ``m \times n`` rectangular band.                                |
| [`special_linear_group_2`](@ref Semigroups.special_linear_group_2(::Integer))                | `SL(2, q)`.                                                     |
| [`renner_type_B_monoid`](@ref Semigroups.renner_type_B_monoid(::Integer, ::Integer))         | Renner monoid of type B.                                        |
| [`renner_type_D_monoid`](@ref Semigroups.renner_type_D_monoid(::Integer, ::Integer))         | Renner monoid of type D.                                        |
| [`not_renner_type_B_monoid`](@ref Semigroups.not_renner_type_B_monoid(::Integer, ::Integer)) | A presentation that does _not_ define the type-B Renner monoid. |
| [`not_renner_type_D_monoid`](@ref Semigroups.not_renner_type_D_monoid(::Integer, ::Integer)) | A presentation that does _not_ define the type-D Renner monoid. |

### Full API

```@docs
Semigroups.fibonacci_semigroup(::Integer, ::Integer)
Semigroups.monogenic_semigroup(::Integer, ::Integer)
Semigroups.rectangular_band(::Integer, ::Integer)
Semigroups.special_linear_group_2(::Integer)
Semigroups.renner_type_B_monoid(::Integer, ::Integer)
Semigroups.renner_type_D_monoid(::Integer, ::Integer)
Semigroups.not_renner_type_B_monoid(::Integer, ::Integer)
Semigroups.not_renner_type_D_monoid(::Integer, ::Integer)
```
