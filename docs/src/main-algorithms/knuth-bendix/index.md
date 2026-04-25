# Knuth-Bendix

This section contains documentation related to the implementation of the
Knuth-Bendix completion algorithm in Semigroups.jl.

The Knuth-Bendix algorithm takes a finitely presented semigroup or monoid and
attempts to compute a confluent rewriting system — a finite set of rules that
reduces every word to a unique normal form. When the algorithm terminates, the
congruence is decidable and normal forms enumerate the elements of the
semigroup.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `KnuthBendix{word_type, RewriteTrie}` only.
    Letter indices are 1-based `Int` values throughout the Julia API.

## Contents

| Page | Description |
| ---- | ----------- |
| [The KnuthBendix type](knuth-bendix.md) | The main [`KnuthBendix`](@ref Semigroups.KnuthBendix) type: construction, settings, queries, and graph access. |
| [Helper functions](helpers.md) | KnuthBendix-specific free functions: running by overlap length, checking reducedness, and finding redundant rules. |

The shared word-operation and class-enumeration helpers (`reduce`,
`contains`, `currently_contains`, `add_generating_pair!`, `normal_forms`,
`partition`, `non_trivial_classes`) are documented on the
[Common congruence helpers](../cong-common-helpers.md) page.
