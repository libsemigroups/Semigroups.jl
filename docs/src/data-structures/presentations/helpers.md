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
| [`throw_if_bad_inverses`](@ref Semigroups.throw_if_bad_inverses(::Presentation, ::AbstractVector{<:Integer})) | Throw if a proposed inverses vector is not a valid involution.           |

### Full API

```@docs
Semigroups.throw_if_alphabet_has_duplicates(::Presentation)
Semigroups.throw_if_letter_not_in_alphabet(::Presentation, ::Integer)
Semigroups.throw_if_bad_rules(::Presentation)
Semigroups.throw_if_bad_alphabet_or_rules(::Presentation)
Semigroups.throw_if_odd_number_of_rules(::Presentation)
Semigroups.throw_if_bad_inverses(::Presentation, ::AbstractVector{<:Integer})
```

## Queries

Scalar-valued, non-mutating queries.

### Contents

| Function                                                                                                          | Description                                                            |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [`length_of`](@ref Semigroups.length_of(::Presentation))                                                          | Total length of all rule words.                                        |
| [`longest_rule_length`](@ref Semigroups.longest_rule_length(::Presentation))                                      | Length of the longest single rule word.                                |
| [`shortest_rule_length`](@ref Semigroups.shortest_rule_length(::Presentation))                                    | Length of the shortest single rule word.                               |
| [`is_normalized`](@ref Semigroups.is_normalized(::Presentation))                                                  | `true` iff the alphabet is `[1, ..., n]`.                                |
| [`are_rules_sorted`](@ref Semigroups.are_rules_sorted(::Presentation))                                            | `true` iff the rule list is sorted.                                    |
| [`contains_rule`](@ref Semigroups.contains_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Whether a given `lhs = rhs` appears as a rule.                         |
| [`is_rule`](@ref Semigroups.is_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))    | Validated-form test for `lhs = rhs`.                                   |
| [`index_rule`](@ref Semigroups.index_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | 1-based rule-pair index of `lhs = rhs`, or [`UNDEFINED`](@ref Semigroups.UNDEFINED). |
| [`first_unused_letter`](@ref Semigroups.first_unused_letter(::Presentation))                                      | Smallest letter not in the alphabet.                                   |
| [`longest_rule_index`](@ref Semigroups.longest_rule_index(::Presentation))                                        | 1-based index of the first rule of maximal length.                     |
| [`shortest_rule_index`](@ref Semigroups.shortest_rule_index(::Presentation))                                      | 1-based index of the first rule of minimal length.                     |

### Full API

```@docs
Semigroups.length_of(::Presentation)
Semigroups.longest_rule_length(::Presentation)
Semigroups.shortest_rule_length(::Presentation)
Semigroups.is_normalized(::Presentation)
Semigroups.are_rules_sorted(::Presentation)
Semigroups.contains_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.is_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.index_rule(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.first_unused_letter(::Presentation)
Semigroups.longest_rule_index(::Presentation)
Semigroups.shortest_rule_index(::Presentation)
```

## Mutators

Shape mutators reorder or rewrite the alphabet / rule words; rule-set
mutators add or remove rules.

### Shape mutators

| Function                                                                                               | Description                                                              |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [`normalize_alphabet!`](@ref Semigroups.normalize_alphabet!(::Presentation))                           | Rewrite `p` so the alphabet is `[1, ..., n]`.                             |
| [`change_alphabet!`](@ref Semigroups.change_alphabet!(::Presentation, ::AbstractVector{<:Integer}))    | Rewrite under `old[i] ↦ new[i]`.                                         |
| [`Base.reverse!`](@ref Base.reverse!(::Presentation))                                                  | Reverse each rule word in place (extends `Base.reverse!`; not exported). |
| [`sort_rules!`](@ref Semigroups.sort_rules!(::Presentation))                                           | Sort the rule list.                                                      |
| [`sort_each_rule!`](@ref Semigroups.sort_each_rule!(::Presentation))                                   | Order each rule so that `lhs ≥ rhs`.                                     |

### Rule-set mutators

| Function                                                                                               | Description                                                              |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [`add_identity_rules!`](@ref Semigroups.add_identity_rules!(::Presentation, ::Integer))                | Add `e·a = a·e = a` for every letter `a`.                                |
| [`add_zero_rules!`](@ref Semigroups.add_zero_rules!(::Presentation, ::Integer))                        | Add `z·a = a·z = z` for every letter `a`.                                |
| [`add_rules!`](@ref Semigroups.add_rules!(::Presentation, ::Presentation))                             | Copy every rule of `q` into `p`.                                         |
| [`add_inverse_rules!`](@ref Semigroups.add_inverse_rules!(::Presentation, ::AbstractVector{<:Integer})) | Add rules `aᵢ·bᵢ = e` for a matching list of inverses.                   |
| [`replace_subword!`](@ref Semigroups.replace_subword!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Replace every non-overlapping occurrence of a subword. |
| [`replace_word!`](@ref Semigroups.replace_word!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))       | Replace a word wherever it appears as a full side of a rule. |
| [`replace_word_with_new_generator!`](@ref Semigroups.replace_word_with_new_generator!(::Presentation, ::AbstractVector{<:Integer})) | Replace non-overlapping occurrences with a fresh generator. |
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
Semigroups.add_rules!(::Presentation, ::Presentation)
Semigroups.add_inverse_rules!(::Presentation, ::AbstractVector{<:Integer})
Semigroups.replace_subword!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.replace_word!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.replace_word_with_new_generator!(::Presentation, ::AbstractVector{<:Integer})
Semigroups.remove_duplicate_rules!(::Presentation)
Semigroups.remove_trivial_rules!(::Presentation)
```

## Export

Helpers that serialize a presentation to another language's source code.

| Function                                                                            | Description                                                     |
| ----------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`to_gap_string`](@ref Semigroups.to_gap_string(::Presentation, ::AbstractString)) | GAP source code that would reconstruct the presentation.        |

### Full API

```@docs
Semigroups.to_gap_string(::Presentation, ::AbstractString)
```
