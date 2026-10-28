# Overview

This section documents the main algorithms available in Semigroups.jl.

## Available Algorithms

### [Froidure-Pin Algorithm](froidure-pin/index.md)

The Froidure-Pin algorithm enumerates all elements and determines the
structure of a finitely generated semigroup or monoid. See the
[Froidure-Pin section](froidure-pin/index.md) for the full API.

### [Konieczny's Algorithm](konieczny/index.md)

Konieczny's algorithm determines the Green's structure (D-, L-, R- and
H-classes, regularity, idempotents, size) of a finitely generated
semigroup of transformations, partial permutations or boolean matrices
without enumerating its elements. See the
[Konieczny section](konieczny/index.md) for the full API.

## Planned Algorithms

The following algorithms from libsemigroups will be exposed in future
versions of Semigroups.jl:

- **Knuth-Bendix Completion**
- **Todd-Coxeter Algorithm**
- **Kambites' Algorithm** (small overlap monoids)
- **Schreier-Sims Algorithm** (permutation groups)
