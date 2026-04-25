# The KnuthBendix type

This page documents the [`KnuthBendix`](@ref Semigroups.KnuthBendix) type,
which implements the Knuth-Bendix completion algorithm for finitely presented
semigroups and monoids.

`KnuthBendix` is a subtype of [`Runner`](@ref Semigroups.Runner), so all
runner methods ([`run!`](@ref), [`run_for!`](@ref), [`finished`](@ref), etc.)
are available.

## Table of contents

| Section | Description |
| ------- | ----------- |
| [Construction and re-initialization](@ref) | Constructors and `init!`. |
| [Settings](@ref) | Overlap policy, rule limits, confluence-check interval. |
| [Queries](@ref) | Confluence state, rule counts, class count. |
| [Presentation and generating pairs](@ref) | Access the underlying presentation and extra generating pairs. |
| [Word operations](@ref) | Reduce words, test containment, add generating pairs. |
| [Rules access](@ref) | Enumerate active rules. |
| [Graph access](@ref) | Gilman WordGraph and its node labels. |
| [Display and copy](@ref) | `show`, `copy`, `length`. |

```@docs
Semigroups.KnuthBendix
```

## Construction and re-initialization

| Function | Description |
| -------- | ----------- |
| `KnuthBendix(kind, p)` | Construct from a [`congruence_kind`](@ref Semigroups.congruence_kind) and a [`Presentation`](@ref Semigroups.Presentation). |
| `KnuthBendix(other)` | Copy an existing `KnuthBendix`. |
| [`init!(kb)`](@ref Semigroups.init!(::KnuthBendix)) | Reset to default-constructed state or reinitialize from a new kind and presentation. |

```@docs
Semigroups.init!(::KnuthBendix)
```

## Settings

| Function | Description |
| -------- | ----------- |
| [`max_pending_rules(kb)`](@ref Semigroups.max_pending_rules(::KnuthBendix)) | Get the pending-rule batch size (default: `128`). |
| [`max_pending_rules!(kb, n)`](@ref Semigroups.max_pending_rules!(::KnuthBendix, ::Integer)) | Set the pending-rule batch size. |
| [`check_confluence_interval(kb)`](@ref Semigroups.check_confluence_interval(::KnuthBendix)) | Get the confluence-check interval (default: `4096`). |
| [`check_confluence_interval!(kb, n)`](@ref Semigroups.check_confluence_interval!(::KnuthBendix, ::Integer)) | Set the confluence-check interval. |
| [`max_overlap(kb)`](@ref Semigroups.max_overlap(::KnuthBendix)) | Get the maximum overlap length. |
| [`max_overlap!(kb, n)`](@ref Semigroups.max_overlap!(::KnuthBendix, ::Integer)) | Set the maximum overlap length. |
| [`max_rules(kb)`](@ref Semigroups.max_rules(::KnuthBendix)) | Get the approximate maximum number of rules (default: `POSITIVE_INFINITY`). |
| [`max_rules!(kb, n)`](@ref Semigroups.max_rules!(::KnuthBendix, ::Integer)) | Set the approximate maximum number of rules. |
| [`overlap_policy(kb)`](@ref Semigroups.overlap_policy(::KnuthBendix)) | Get the overlap measurement policy. |
| [`overlap_policy!(kb, val)`](@ref Semigroups.overlap_policy!(::KnuthBendix, ::Any)) | Set the overlap measurement policy. |

```@docs
Semigroups.overlap_ABC
Semigroups.overlap_AB_BC
Semigroups.overlap_MAX_AB_BC
Semigroups.max_pending_rules(::KnuthBendix)
Semigroups.max_pending_rules!(::KnuthBendix, ::Integer)
Semigroups.check_confluence_interval(::KnuthBendix)
Semigroups.check_confluence_interval!(::KnuthBendix, ::Integer)
Semigroups.max_overlap(::KnuthBendix)
Semigroups.max_overlap!(::KnuthBendix, ::Integer)
Semigroups.max_rules(::KnuthBendix)
Semigroups.max_rules!(::KnuthBendix, ::Integer)
Semigroups.overlap_policy(::KnuthBendix)
Semigroups.overlap_policy!(::KnuthBendix, ::Any)
```

## Queries

| Function | Description |
| -------- | ----------- |
| [`confluent(kb)`](@ref Semigroups.confluent(::KnuthBendix)) | Check if the system is confluent. |
| [`confluent_known(kb)`](@ref Semigroups.confluent_known(::KnuthBendix)) | Check if confluence status is already known. |
| [`number_of_classes(kb)`](@ref Semigroups.number_of_classes(::KnuthBendix)) | Number of congruence classes (triggers full run). |
| [`number_of_active_rules(kb)`](@ref Semigroups.number_of_active_rules(::KnuthBendix)) | Current number of active rules. |
| [`number_of_inactive_rules(kb)`](@ref Semigroups.number_of_inactive_rules(::KnuthBendix)) | Current number of inactive rules. |
| [`number_of_pending_rules(kb)`](@ref Semigroups.number_of_pending_rules(::KnuthBendix)) | Number of pending (unprocessed) rules. |
| [`total_rules(kb)`](@ref Semigroups.total_rules(::KnuthBendix)) | Total rule instances ever created. |

```@docs
Semigroups.confluent(::KnuthBendix)
Semigroups.confluent_known(::KnuthBendix)
Semigroups.number_of_classes(::KnuthBendix)
Semigroups.number_of_active_rules(::KnuthBendix)
Semigroups.number_of_inactive_rules(::KnuthBendix)
Semigroups.number_of_pending_rules(::KnuthBendix)
Semigroups.total_rules(::KnuthBendix)
```

## Presentation and generating pairs

| Function | Description |
| -------- | ----------- |
| [`kind(kb)`](@ref Semigroups.kind(::KnuthBendix)) | Congruence kind (`twosided` or `onesided`). |
| [`presentation(kb)`](@ref Semigroups.presentation(::KnuthBendix)) | Copy of the underlying presentation. |
| [`number_of_generating_pairs(kb)`](@ref Semigroups.number_of_generating_pairs(::KnuthBendix)) | Number of extra generating pairs. |
| [`generating_pairs(kb)`](@ref Semigroups.generating_pairs(::KnuthBendix)) | Extra generating pairs as 1-based word tuples. |

```@docs
Semigroups.kind(::KnuthBendix)
Semigroups.presentation(::KnuthBendix)
Semigroups.number_of_generating_pairs(::KnuthBendix)
Semigroups.generating_pairs(::KnuthBendix)
```

## Word operations

These functions are defined on
[`CongruenceCommon`](@ref Semigroups.CongruenceCommon) and work on all
congruence types, including `KnuthBendix`. Words are given and returned as
1-based `Vector{Int}` letter indices.

!!! note
    `Semigroups.reduce` and `Semigroups.contains` are not exported to avoid
    shadowing `Base.reduce`. Use the module-qualified form:
    `Semigroups.reduce(kb, w)`, `Semigroups.contains(kb, u, v)`.

| Function | Description |
| -------- | ----------- |
| `Semigroups.reduce(kb, w)` | Reduce a word to normal form (triggers full run). |
| `reduce_no_run(kb, w)` | Reduce using current rules only (no run). |
| `Semigroups.contains(kb, u, v)` | Test if two words are congruent (triggers full run). |
| `currently_contains(kb, u, v)` | Test containment using current rules (no run); returns [`tril`](@ref Semigroups.tril). |
| `add_generating_pair!(kb, u, v)` | Add an extra generating pair. |

## Rules access

```@docs
Semigroups.active_rules(::KnuthBendix)
```

## Graph access

```@docs
Semigroups.gilman_graph(::KnuthBendix)
Semigroups.gilman_graph_node_labels(::KnuthBendix)
```

## Display and copy

```@docs
Base.length(::KnuthBendix)
Base.show(::IO, ::KnuthBendix)
Base.copy(::KnuthBendix)
```
