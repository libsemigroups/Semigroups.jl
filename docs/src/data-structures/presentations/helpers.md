# Helper functions

This page collects the free functions that operate on a
[`Presentation`](@ref Semigroups.Presentation). They mirror the
`libsemigroups::presentation::*` namespace and are organised into three
groups: validation, scalar queries, and shape / rule-set mutators.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds helpers for `Presentation<word_type>` only.
    Alphabets and rules use `Vector{Int}` with 1-based letter indices.

## Validation

These functions throw `LibsemigroupsError` if the presentation is
ill-formed in some way; otherwise they return `nothing`.

### Contents

| Function                                                                                                 | Description                                                              |
| -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| [`throw_if_alphabet_has_duplicates`](@ref Semigroups.throw_if_alphabet_has_duplicates(::Presentation))   | Throw if the alphabet contains a repeated letter.                        |
| [`throw_if_letter_not_in_alphabet`](@ref Semigroups.throw_if_letter_not_in_alphabet(::Presentation, ::Integer)) | Throw if the given letter is not in the alphabet.                        |
| [`throw_if_bad_rules`](@ref Semigroups.throw_if_bad_rules(::Presentation))                               | Throw if rules refer to letters outside the alphabet or have odd count.  |
| [`throw_if_bad_alphabet_or_rules`](@ref Semigroups.throw_if_bad_alphabet_or_rules(::Presentation))       | Combined alphabet-and-rules check.                                       |
| [`throw_if_odd_number_of_rules`](@ref Semigroups.throw_if_odd_number_of_rules(::Presentation))           | Throw if the underlying rule-word count is odd.                          |

### Full API

```@docs
Semigroups.throw_if_alphabet_has_duplicates(::Presentation)
Semigroups.throw_if_letter_not_in_alphabet(::Presentation, ::Integer)
Semigroups.throw_if_bad_rules(::Presentation)
Semigroups.throw_if_bad_alphabet_or_rules(::Presentation)
Semigroups.throw_if_odd_number_of_rules(::Presentation)
```

## Queries

Scalar-valued, non-mutating queries.

### Contents

| Function                                                                                                          | Description                                                            |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [`length_of`](@ref Semigroups.length_of(::Presentation))                                                          | Total length of all rule words.                                        |
| [`longest_rule_length`](@ref Semigroups.longest_rule_length(::Presentation))                                      | Length of the longest single rule word.                                |
| [`shortest_rule_length`](@ref Semigroups.shortest_rule_length(::Presentation))                                    | Length of the shortest single rule word.                               |
| [`is_normalized`](@ref Semigroups.is_normalized(::Presentation))                                                  | `true` iff the alphabet is `[1, …, n]`.                                |
| [`are_rules_sorted`](@ref Semigroups.are_rules_sorted(::Presentation))                                            | `true` iff the rule list is sorted.                                    |
| [`contains_rule`](@ref Semigroups.contains_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Whether a given `lhs = rhs` appears as a rule.                         |

### Full API

```@docs
Semigroups.length_of(::Presentation)
Semigroups.longest_rule_length(::Presentation)
Semigroups.shortest_rule_length(::Presentation)
Semigroups.is_normalized(::Presentation)
Semigroups.are_rules_sorted(::Presentation)
Semigroups.contains_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```

## Mutators

Shape mutators reorder or rewrite the alphabet / rule words; rule-set
mutators add or remove rules.

### Shape mutators

| Function                                                                                               | Description                                                              |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [`normalize_alphabet!`](@ref Semigroups.normalize_alphabet!(::Presentation))                           | Rewrite `p` so the alphabet is `[1, …, n]`.                             |
| [`change_alphabet!`](@ref Semigroups.change_alphabet!(::Presentation, ::AbstractVector{<:Integer}))    | Rewrite under `old[i] ↦ new[i]`.                                         |
| [`Base.reverse!`](@ref Base.reverse!(::Presentation))                                                  | Reverse each rule word in place (extends `Base.reverse!`; not exported). |
| [`sort_rules!`](@ref Semigroups.sort_rules!(::Presentation))                                           | Sort the rule list.                                                      |
| [`sort_each_rule!`](@ref Semigroups.sort_each_rule!(::Presentation))                                   | Order each rule so that `lhs ≥ rhs`.                                     |

### Rule-set mutators

| Function                                                                                               | Description                                                              |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [`add_identity_rules!`](@ref Semigroups.add_identity_rules!(::Presentation, ::Integer))                | Add `e·a = a·e = a` for every letter `a`.                                |
| [`add_zero_rules!`](@ref Semigroups.add_zero_rules!(::Presentation, ::Integer))                        | Add `z·a = a·z = z` for every letter `a`.                                |
| [`remove_duplicate_rules!`](@ref Semigroups.remove_duplicate_rules!(::Presentation))                   | Drop duplicate rules, keeping the first occurrence.                      |
| [`remove_trivial_rules!`](@ref Semigroups.remove_trivial_rules!(::Presentation))                       | Drop rules of the form `u = u`.                                          |

### Full API

```@docs
Semigroups.normalize_alphabet!(::Presentation)
Semigroups.change_alphabet!(::Presentation, ::AbstractVector{<:Integer})
Base.reverse!(::Presentation)
Semigroups.sort_rules!(::Presentation)
Semigroups.sort_each_rule!(::Presentation)
Semigroups.add_identity_rules!(::Presentation, ::Integer)
Semigroups.add_zero_rules!(::Presentation, ::Integer)
Semigroups.remove_duplicate_rules!(::Presentation)
Semigroups.remove_trivial_rules!(::Presentation)
```
