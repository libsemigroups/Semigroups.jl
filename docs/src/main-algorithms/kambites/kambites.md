# The Kambites type

This page documents the [`Kambites`](@ref Semigroups.Kambites) type,
which implements Kambites's algorithm for the word problem in small
overlap monoids -- finitely presented monoids whose presentation
satisfies the small overlap condition `C(n)` for some `n >= 4`.

`Kambites` is a subtype of
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) (and hence of
[`Runner`](@ref Semigroups.Runner)), so all runner methods
([`run!`](@ref), [`run_for!`](@ref), [`finished`](@ref), etc.) and the
shared word-operation helpers ([`reduce`](@ref Semigroups.reduce(::CongruenceCommon, ::AbstractVector{<:Integer})),
[`contains`](@ref Semigroups.contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`currently_contains`](@ref Semigroups.currently_contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`partition`](@ref Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})))
are available.

## Table of contents

| Section | Description |
| ------- | ----------- |
| [Construction and re-initialization](#Construction-and-re-initialization) | Constructors and `init!`. |
| [Queries](#Queries) | Class count and number of generating pairs. |
| [Presentation and generating pairs](#Presentation-and-generating-pairs) | Access the underlying presentation and extra generating pairs. |
| [Small overlap class](#Small-overlap-class) | Compute or read the cached small overlap class `C(n)` of the underlying presentation. |
| [Validators](#Validators) | Throw on invalid letters or insufficient small overlap class. |
| [Normal forms](#Normal-forms) | Bounded enumeration of normal forms (the unbounded form throws). |
| [Non-trivial classes (always throws)](#Non-trivial-classes-always-throws) | Why `non_trivial_classes(::Kambites, ::Kambites)` is intentionally not provided. |
| [Display and copy](#Display-and-copy) | `show`, `copy`. |

```@docs
Semigroups.Kambites
```

## Construction and re-initialization

| Function | Description |
| -------- | ----------- |
| `Kambites()` | Construct a default `Kambites`; throws on subsequent use until reinitialized via [`init!`](@ref). |
| `Kambites(kind, p)` | Construct from a [`congruence_kind`](@ref Semigroups.congruence_kind) (must be [`twosided`](@ref Semigroups.twosided)) and a [`Presentation`](@ref Semigroups.Presentation). |
| `Kambites(other)` | Copy an existing `Kambites`. |
| [`init!(k)`](@ref Semigroups.init!(::Kambites)) | Reset to default-constructed state, or reinitialize from a new kind and presentation. |

```@docs
Semigroups.init!(::Kambites)
```

## Queries

| Function | Description |
| -------- | ----------- |
| [`number_of_classes(k)`](@ref Semigroups.number_of_classes(::Kambites)) | Number of congruence classes; returns [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) when `small_overlap_class(k) >= 4`. |
| [`number_of_generating_pairs(k)`](@ref Semigroups.number_of_generating_pairs(::Kambites)) | Number of extra generating pairs. |

```@docs
Semigroups.number_of_classes(::Kambites)
Semigroups.number_of_generating_pairs(::Kambites)
```

## Presentation and generating pairs

| Function | Description |
| -------- | ----------- |
| [`kind(k)`](@ref Semigroups.kind(::Kambites)) | Congruence kind (always `twosided`). |
| [`presentation(k)`](@ref Semigroups.presentation(::Kambites)) | Copy of the underlying presentation. |
| [`generating_pairs(k)`](@ref Semigroups.generating_pairs(::Kambites)) | Extra generating pairs as 1-based word-tuple pairs. |

```@docs
Semigroups.kind(::Kambites)
Semigroups.presentation(::Kambites)
Semigroups.generating_pairs(::Kambites)
```

## Small overlap class

The small overlap class of the underlying presentation is the largest
`n` such that the presentation satisfies the condition `C(n)`. Kambites's
algorithm decides the word problem when this class is at least `4`.

| Function | Description |
| -------- | ----------- |
| [`small_overlap_class(k)`](@ref Semigroups.small_overlap_class(::Kambites)) | Compute the small overlap class (may trigger work). |
| [`current_small_overlap_class(k)`](@ref Semigroups.current_small_overlap_class(::Kambites)) | Return the cached value, or [`UNDEFINED`](@ref Semigroups.UNDEFINED) if not yet computed. |

```@docs
Semigroups.small_overlap_class(::Kambites)
Semigroups.current_small_overlap_class(::Kambites)
```

## Validators

| Function | Description |
| -------- | ----------- |
| [`throw_if_not_C4(k)`](@ref Semigroups.throw_if_not_C4(::Kambites)) | Throw if the small overlap class is less than `4`. |
| [`throw_if_letter_not_in_alphabet(k, w)`](@ref Semigroups.throw_if_letter_not_in_alphabet(::Kambites, ::AbstractVector{<:Integer})) | Throw if `w` contains any letter that is not in the alphabet of `k`'s presentation. |

```@docs
Semigroups.throw_if_not_C4(::Kambites)
Semigroups.throw_if_letter_not_in_alphabet(::Kambites, ::AbstractVector{<:Integer})
```

## Normal forms

For `Kambites`, the set of normal forms is infinite, so only the
bounded form `normal_forms(k, n)` is provided. The no-argument form
[`normal_forms(k)`](@ref Semigroups.normal_forms(::Kambites)) throws an
`ArgumentError` to prevent accidental infinite enumeration.

| Function | Description |
| -------- | ----------- |
| [`normal_forms(k, n)`](@ref Semigroups.normal_forms(::Kambites, ::Integer)) | Return the first `n` normal forms as 1-based `Vector{Int}` words. |
| [`normal_forms(k)`](@ref Semigroups.normal_forms(::Kambites)) | Always throws `ArgumentError`. |

```@docs
Semigroups.normal_forms(::Kambites, ::Integer)
Semigroups.normal_forms(::Kambites)
```

## Non-trivial classes (always throws)

```@docs
Semigroups.non_trivial_classes(::Kambites, ::Kambites)
```

## Word operations

These functions are defined on
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) and work on all
congruence types, including `Kambites`. Words are given and returned
as 1-based `Vector{Int}` letter indices. See the
[Common congruence helpers](../cong-common-helpers.md) page for the
full API.

!!! note
    `Semigroups.reduce` and `Semigroups.contains` are not exported to
    avoid shadowing `Base.reduce` and `Base.contains`. Use the
    module-qualified form: `Semigroups.reduce(k, w)`,
    `Semigroups.contains(k, u, v)`.

| Function | Description |
| -------- | ----------- |
| `Semigroups.reduce(k, w)` | Reduce a word to normal form (triggers a full run). |
| `Semigroups.contains(k, u, v)` | Test if two words are congruent (triggers a full run). |
| `currently_contains(k, u, v)` | Test containment using current state; returns [`tril`](@ref Semigroups.tril). |
| `add_generating_pair!(k, u, v)` | Add an extra generating pair. |
| `partition(k, ws)` | Partition a list of words into congruence classes. |

## Display and copy

```@docs
Base.show(::IO, ::Kambites)
Base.copy(::Kambites)
```
