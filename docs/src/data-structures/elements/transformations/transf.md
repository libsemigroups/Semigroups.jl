# The Transf Type

A _transformation_ $f$ is just a function defined on the whole of
$\{1, 2, \ldots, n\}$ for some integer $n$ called the _degree_ of
$f$. A transformation is stored as a vector of the images of
$\{1, 2, \ldots, n\}$, i.e. $((1)f, (2)f, \ldots, (n)f)$.

## Contents

| Function                                                       | Description                         |
| -------------------------------------------------------------- | ----------------------------------- |
| [`Transf`](@ref Semigroups.Transf)                             | Construct a transformation          |
| `t[i]`                                                         | Get the image of a point            |
| [`degree`](@ref Semigroups.degree(::Semigroups.Transf))        | The degree of the transformation    |
| [`rank`](@ref Semigroups.rank(::Semigroups.Transf))            | The number of distinct image values |
| [`image`](@ref Semigroups.image)                               | The sorted set of image values      |
| [`domain`](@ref Semigroups.domain)                             | The sorted set of defined points    |
| [`one`](@ref Semigroups.one(::Type{Semigroups.Transf}, ::Int)) | The identity transformation         |
| [`copy`](@ref Base.copy(::Semigroups.Transf))                  | Copy a transformation               |
| [`t * s`](#Composition)                                        | Compose two transformations         |
| [`==`, `<`, `<=`, `>`, `>=`](#Comparison)                      | Comparison operators                |

## Full API

```@docs
Semigroups.Transf
Semigroups.degree(::Semigroups.Transf)
Semigroups.domain(::Semigroups.Transf)
Semigroups.image(::Semigroups.Transf)
Semigroups.one(::Type{Semigroups.Transf}, ::Int)
Semigroups.rank(::Semigroups.Transf)
```

### Construction

```julia
using Semigroups

# From a vector of images
t = Transf([2, 3, 1, 4])  # maps 1->2, 2->3, 3->1, 4->4
t[1]  # 2

# The degree is inferred from the length
degree(t)  # 4
```

### Composition

Transformations can be composed using `*`:

```julia
s = Transf([2, 1, 3])
t = Transf([3, 2, 1])
s * t  # apply s first, then t
```

### Comparison

Transformations support equality and lexicographic ordering:

```julia
t = Transf([2, 3, 1])
s = copy(t)
t == s  # true
t < Transf([3, 2, 1])  # true
```
