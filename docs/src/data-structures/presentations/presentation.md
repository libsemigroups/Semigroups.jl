# The Presentation type

This page documents the type [`Presentation`](@ref Semigroups.Presentation),
a finite semigroup or monoid presentation over `word_type` (Julia:
`Vector{Int}` with 1-based letter indices).

!!! warning "v1 limitation"
Semigroups.jl v1 binds `Presentation<word_type>` only. Alphabets and
rules use `Vector{Int}` with 1-based letter indices.

```@docs
Semigroups.Presentation
```

## Contents

| Function                                                                                                                               | Description                               |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| [`init!`](@ref Semigroups.init!(::Presentation))                                                                                       | Reset a presentation to the empty state.  |
| [`alphabet`](@ref Semigroups.alphabet(::Presentation))                                                                                 | Return the alphabet as a `Vector{Int}`.   |
| [`set_alphabet!`](@ref Semigroups.set_alphabet!(::Presentation, ::Integer))                                                            | Set the alphabet to `[1, …, n]`.          |
| [`set_alphabet!`](@ref Semigroups.set_alphabet!(::Presentation, ::AbstractVector{<:Integer}))                                          | Set the alphabet to the given vector.     |
| [`alphabet_from_rules!`](@ref Semigroups.alphabet_from_rules!(::Presentation))                                                         | Infer the alphabet from the rules.        |
| [`letter`](@ref Semigroups.letter(::Presentation, ::Integer))                                                                          | Return the `i`-th letter of the alphabet. |
| [`index_of`](@ref Semigroups.index_of(::Presentation, ::Integer))                                                                      | Return the 1-based index of a letter.     |
| [`in_alphabet`](@ref Semigroups.in_alphabet(::Presentation, ::Integer))                                                                | Test membership in the alphabet.          |
| [`contains_empty_word`](@ref Semigroups.contains_empty_word(::Presentation))                                                           | Query whether the empty word is allowed.  |
| [`set_contains_empty_word!`](@ref Semigroups.set_contains_empty_word!(::Presentation, ::Bool))                                         | Set whether the empty word is allowed.    |
| [`add_generator!`](@ref Semigroups.add_generator!(::Presentation))                                                                     | Append a generator (no-arg or by letter). |
| [`remove_generator!`](@ref Semigroups.remove_generator!(::Presentation, ::Integer))                                                    | Remove a letter from the alphabet.        |
| [`number_of_rules`](@ref Semigroups.number_of_rules(::Presentation))                                                                   | Number of rules in the presentation.      |
| [`rule_lhs`](@ref Semigroups.rule_lhs(::Presentation, ::Integer))                                                                      | Left-hand side of the `i`-th rule.        |
| [`rule_rhs`](@ref Semigroups.rule_rhs(::Presentation, ::Integer))                                                                      | Right-hand side of the `i`-th rule.       |
| [`rules`](@ref Semigroups.rules(::Presentation))                                                                                       | All rules as `(lhs, rhs)` tuples.         |
| [`clear_rules!`](@ref Semigroups.clear_rules!(::Presentation))                                                                         | Remove every rule.                        |
| [`add_rule!`](@ref Semigroups.add_rule!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer}))                     | Append a checked rule.                    |
| [`add_rule_no_checks!`](@ref Semigroups.add_rule_no_checks!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Append a rule without checks.             |

## Full API

```@docs
Semigroups.init!(::Presentation)
Semigroups.alphabet(::Presentation)
Semigroups.set_alphabet!(::Presentation, ::Integer)
Semigroups.set_alphabet!(::Presentation, ::AbstractVector{<:Integer})
Semigroups.alphabet_from_rules!(::Presentation)
Semigroups.letter(::Presentation, ::Integer)
Semigroups.index_of(::Presentation, ::Integer)
Semigroups.in_alphabet(::Presentation, ::Integer)
Semigroups.contains_empty_word(::Presentation)
Semigroups.set_contains_empty_word!(::Presentation, ::Bool)
Semigroups.add_generator!(::Presentation)
Semigroups.remove_generator!(::Presentation, ::Integer)
Semigroups.number_of_rules(::Presentation)
Semigroups.rule_lhs(::Presentation, ::Integer)
Semigroups.rule_rhs(::Presentation, ::Integer)
Semigroups.rules(::Presentation)
Semigroups.clear_rules!(::Presentation)
Semigroups.add_rule!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.add_rule_no_checks!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```
