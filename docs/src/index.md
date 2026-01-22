# Semigroups.jl

Julia bindings for the [libsemigroups](https://github.com/libsemigroups/libsemigroups) C++ library.

## Overview

Semigroups.jl provides Julia access to algorithms for computing with finite and finitely presented semigroups and monoids. The package wraps libsemigroups using [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl), offering idiomatic Julia interfaces with 1-based indexing.

## Features

- **Transformations**: Full, partial, and permutation transformations
- **Boolean Matrices**: 8-bit boolean matrix operations
- **Constants**: Special values for algorithm bounds and undefined states

## Quick Start

```julia
using Semigroups

# Create a transformation (1-based indexing)
t = Transf([2, 3, 1, 4])

# Get properties
degree(t)    # 4
rank(t)      # 4
images(t)    # [2, 3, 1, 4]

# Create a partial permutation
p = PPerm([1, 2], [3, 4], 5)
```

## Documentation Structure

- **[Package Info](package-info/installation.md)**: Installation, authors, bibliography, and error handling
- **[Data Structures](data-structures/constants/index.md)**: Constants, element types, and their operations
- **[Main Algorithms](main-algorithms/index.md)**: Core algorithms for semigroup computation

## See Also

- [libsemigroups documentation](https://libsemigroups.github.io/libsemigroups/)
- [libsemigroups on GitHub](https://github.com/libsemigroups/libsemigroups)
