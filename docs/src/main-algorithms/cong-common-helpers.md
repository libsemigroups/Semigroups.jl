# Common congruence helpers

This page documents the helper functions that are shared by every
congruence-style algorithm in Semigroups.jl. They mirror the
`libsemigroups::congruence_common::*` namespace and are dispatched on
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon), so the same
function names work uniformly across [`KnuthBendix`](@ref
Semigroups.KnuthBendix) (and, in later phases, `ToddCoxeter`,
`Kambites`, and `Congruence`).

Words are accepted and returned as 1-based `Vector{Int}` letter indices
throughout.

!!! warning "v1 limitation"
    [`KnuthBendix`](@ref Semigroups.KnuthBendix) is the only concrete
    subtype of [`CongruenceCommon`](@ref Semigroups.CongruenceCommon)
    bound in v1. The same helpers will apply to `ToddCoxeter`,
    `Kambites`, and `Congruence` once those types land.

!!! note
    `Semigroups.reduce` and `Semigroups.contains` are not exported, to
    avoid shadowing `Base.reduce` and `Base.contains`. Call them with
    the module-qualified form: `Semigroups.reduce(cong, w)`,
    `Semigroups.contains(cong, u, v)`.

## Table of contents

| Section | Description |
| ------- | ----------- |
| [Add generating pairs](@ref) | Extend a congruence with extra generating pairs. |
| [Containment](@ref) | Test whether two words are equivalent under a congruence. |
| [Reduce a word](@ref) | Reduce a word to a normal form (or a current-rules form). |
| [Normal forms](@ref) | Enumerate one normal form per congruence class. |
| [Partitioning](@ref) | Partition input words into congruence classes. |

```@docs
Semigroups.CongruenceCommon
```

## Add generating pairs

### Contents

| Function | Description |
| -------- | ----------- |
| [`add_generating_pair!`](@ref Semigroups.add_generating_pair!(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Add an extra generating pair `(u, v)` to a congruence. |

### Full API

```@docs
Semigroups.add_generating_pair!(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```

## Containment

These functions test whether two words are equivalent under a
congruence. The `currently_*` variant performs no enumeration and may
return [`tril_unknown`](@ref Semigroups.tril_unknown).

### Contents

| Function | Description |
| -------- | ----------- |
| [`Semigroups.contains`](@ref Semigroups.contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Test equivalence; triggers a full run. |
| [`currently_contains`](@ref Semigroups.currently_contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Test equivalence using current rules; returns [`tril`](@ref Semigroups.tril). |

### Full API

```@docs
Semigroups.contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.currently_contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```

## Reduce a word

These functions return a word equivalent to the input under the
congruence. The `_no_run` variant uses only the current rules and does
not trigger an enumeration.

### Contents

| Function | Description |
| -------- | ----------- |
| [`Semigroups.reduce`](@ref Semigroups.reduce(::CongruenceCommon, ::AbstractVector{<:Integer})) | Reduce to a normal form; triggers a full run. |
| [`reduce_no_run`](@ref Semigroups.reduce_no_run(::CongruenceCommon, ::AbstractVector{<:Integer})) | Reduce using current rules; no run. |

### Full API

```@docs
Semigroups.reduce(::CongruenceCommon, ::AbstractVector{<:Integer})
Semigroups.reduce_no_run(::CongruenceCommon, ::AbstractVector{<:Integer})
```

## Normal forms

### Contents

| Function | Description |
| -------- | ----------- |
| [`normal_forms`](@ref Semigroups.normal_forms(::CongruenceCommon)) | One normal form per congruence class. |

### Full API

```@docs
Semigroups.normal_forms(::CongruenceCommon)
```

## Partitioning

### Contents

| Function | Description |
| -------- | ----------- |
| [`partition`](@ref Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})) | Partition a list of words into congruence classes. |
| [`non_trivial_classes`](@ref Semigroups.non_trivial_classes(::CongruenceCommon, ::CongruenceCommon)) | Classes of size ≥ 2 in the partition of the normal forms of one congruence by another. |

### Full API

```@docs
Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})
Semigroups.non_trivial_classes(::CongruenceCommon, ::CongruenceCommon)
```
