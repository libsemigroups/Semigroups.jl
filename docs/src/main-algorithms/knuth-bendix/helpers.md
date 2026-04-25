# Knuth-Bendix helper functions

This page collects the free functions that are specific to the
[`KnuthBendix`](@ref Semigroups.KnuthBendix) type. They mirror the
`libsemigroups::knuth_bendix::*` namespace.

The shared helpers re-exported by `knuth_bendix::` (`reduce`, `contains`,
`currently_contains`, `add_generating_pair!`, `normal_forms`, `partition`,
and `non_trivial_classes`) are documented on the
[Common congruence helpers](../cong-common-helpers.md) page; they apply to
every congruence type, including `KnuthBendix`.

## Table of contents

| Section | Description |
| ------- | ----------- |
| [Running variants](@ref) | Alternate entry points for the Knuth-Bendix algorithm. |
| [Rule utilities](@ref) | Checking reducedness and finding redundant rules. |

## Running variants

These run the Knuth-Bendix algorithm with a different scheduling
discipline from the inherited [`run!`](@ref Semigroups.run!).

### Contents

| Function | Description |
| -------- | ----------- |
| [`by_overlap_length!`](@ref Semigroups.by_overlap_length!(::KnuthBendix)) | Run the algorithm ordered by overlap length. |

### Full API

```@docs
Semigroups.by_overlap_length!(::KnuthBendix)
```

## Rule utilities

Helpers for inspecting and reasoning about the rules of a rewriting
system.

### Contents

| Function | Description |
| -------- | ----------- |
| [`is_reduced`](@ref Semigroups.is_reduced(::KnuthBendix)) | Check whether all rules are reduced with respect to each other. |
| [`redundant_rule`](@ref Semigroups.redundant_rule(::Presentation, ::TimePeriod)) | Find a rule of a presentation that follows from the others. |

### Full API

```@docs
Semigroups.is_reduced(::KnuthBendix)
Semigroups.redundant_rule(::Presentation, ::TimePeriod)
```
