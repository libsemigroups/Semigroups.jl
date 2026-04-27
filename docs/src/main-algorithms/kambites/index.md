# Kambites

This section contains documentation related to the implementation of
Kambites's algorithm for the word problem in small overlap monoids in
Semigroups.jl.

Kambites's algorithm decides the word problem in a finitely presented
monoid whose presentation satisfies the small overlap condition `C(n)`
for some `n >= 4` (Kambites, 2009). For such presentations the
congruence has infinitely many classes, and a normal form for any input
word can be computed in linear time.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `Kambites{word_type}` only. String-alphabet
    presentations are deferred to v1.1. Letter indices are 1-based
    `Int` values throughout the Julia API.

## Deviations from the Knuth-Bendix / Todd-Coxeter precedent

The [`Kambites`](@ref Semigroups.Kambites) binding intentionally
deviates from the [`KnuthBendix`](@ref Semigroups.KnuthBendix) and
`ToddCoxeter` precedent in four places. The motivation in every case is
that a `C(>=4)` presentation has infinitely many congruence classes
(and infinitely many normal forms), so APIs that implicitly assume a
finite class count are unsafe.

- `Base.length` is intentionally **not** defined for `Kambites`. The
  number of classes is always
  [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY) (or throws),
  so an alias for `length(k)` would silently misbehave with
  `for i in 1:length(k)`. Use
  [`number_of_classes`](@ref Semigroups.number_of_classes) explicitly.
- [`non_trivial_classes`](@ref Semigroups.non_trivial_classes)`(::Kambites, ::Kambites)`
  throws `ArgumentError` (mirroring upstream libsemigroups, which
  declines to provide this overload because both arguments always
  represent infinite-class congruences).
- [`normal_forms`](@ref Semigroups.normal_forms)`(::Kambites)` (no-arg)
  throws `ArgumentError` because the underlying normal-form range is
  infinite. Use the bounded form
  [`normal_forms(k, n)`](@ref Semigroups.normal_forms(::Kambites, ::Integer))
  to materialize the first `n` normal forms.
- The `ukkonen()` accessor (and the `Ukkonen` suffix-tree type itself)
  is deferred to a later release; see the v1 design spec
  (`docs/superpowers/specs/2026-04-19-semigroups-jl-v1-design.md`).

## Contents

| Page | Description |
| ---- | ----------- |
| [The Kambites type](kambites.md) | The main [`Kambites`](@ref Semigroups.Kambites) type: construction, queries, small-overlap-class accessors, validators, and bounded normal forms. |

There is no Kambites-specific helper namespace in Semigroups.jl. The
shared word-operation and class-enumeration helpers
([`reduce`](@ref Semigroups.reduce(::CongruenceCommon, ::AbstractVector{<:Integer})),
[`contains`](@ref Semigroups.contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`currently_contains`](@ref Semigroups.currently_contains(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`add_generating_pair!`](@ref Semigroups.add_generating_pair!(::CongruenceCommon, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})),
[`partition`](@ref Semigroups.partition(::CongruenceCommon, ::AbstractVector{<:AbstractVector{<:Integer}})))
are documented on the
[Common congruence helpers](../cong-common-helpers.md) page and apply
uniformly to `Kambites` because it is a subtype of
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon).
