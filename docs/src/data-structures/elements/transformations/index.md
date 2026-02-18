# Transformations

A _partial transformation_ $f$ is just a function defined on a subset of
$\{1, 2, \ldots, n\}$ for some integer $n$ called the _degree_ of $f$. A
partial transformation is stored as a vector of the images of
$\{1, 2, \ldots, n\}$, i.e. $((1)f, (2)f, \ldots, (n)f)$ where the value
[`UNDEFINED`](@ref Semigroups.UNDEFINED) is used to indicate that $(i)f$ is
undefined (i.e. not among the points where $f$ is defined).

## Types

The following concrete types of partial transformation are available:

| Type                               | Description                                                                     |
| ---------------------------------- | ------------------------------------------------------------------------------- |
| [`Transf`](@ref Semigroups.Transf) | A _transformation_: a function on the whole of $\{1, \ldots, n\}$               |
| [`PPerm`](@ref Semigroups.PPerm)   | A _partial permutation_: an injective partial transformation                    |
| [`Perm`](@ref Semigroups.Perm)     | A _permutation_: an injective transformation on the whole of $\{1, \ldots, n\}$ |

These types form a natural hierarchy: every `Perm` is a `Transf`, and every
`Transf` is a special case of a partial transformation (one where every point
has an image). A `PPerm` is a partial transformation that is additionally
injective.

Full documentation for each type and its relevant functions can be found on its corresponding page:

```@contents
Pages = [
    "transf.md",
    "pperm.md",
    "perm.md",
]
Depth = 1
```

## Automatic scalar type selection

Each type is parametric, `Transf{T}`, `PPerm{T}`, and `Perm{T}`, where `T` is
an unsigned integer type (`UInt8`, `UInt16`, or `UInt32`) used to store image
values. When constructed without an explicit type parameter, the smallest
sufficient scalar type is chosen automatically based on the degree:

| Degree           | Scalar type |
| ---------------- | ----------- |
| $1$ to $255$     | `UInt8`     |
| $256$ to $65535$ | `UInt16`    |
| $\geq 65536$     | `UInt32`    |

## Indexing convention

All transformation types use **1-based indexing** (the standard Julia
convention). Internally, indices are converted to 0-based for the underlying
C++ library ([libsemigroups](https://libsemigroups.github.io/libsemigroups/)).

## Full API — shared functions

```@docs
Base.copy(::Semigroups.Transf)
Semigroups.domain(::Union{Semigroups.Transf, Semigroups.PPerm, Semigroups.Perm})
Semigroups.image(::Union{Semigroups.Transf, Semigroups.PPerm, Semigroups.Perm})
Semigroups.increase_degree_by!(::Union{Semigroups.Transf, Semigroups.PPerm, Semigroups.Perm}, ::Integer)
Semigroups.swap!(::T, ::T) where {T<:Union{Semigroups.Transf, Semigroups.PPerm, Semigroups.Perm}}
```
