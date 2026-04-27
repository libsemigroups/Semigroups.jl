# Kambites

This section links to the documentation for the algorithms in
Semigroups.jl for small overlap monoids by Mark Kambites and the authors
of libsemigroups.

| Page | Description |
| ---- | ----------- |
| [The Kambites type](kambites.md) | The [`Kambites`](@ref Semigroups.Kambites) type: construction, queries, the small-overlap-class accessors, validators, and bounded normal forms. |

Helper functions for [`Kambites`](@ref Semigroups.Kambites) are
documented on the [Common congruence helpers](../cong-common-helpers.md)
page. There are currently no helper functions specific to `Kambites`
beyond those that apply to every
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) subtype.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `Kambites{word_type}` only. String-alphabet
    presentations are deferred to a later release. Letter indices are
    1-based `Int` values throughout the Julia API.
