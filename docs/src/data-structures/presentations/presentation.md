# The Presentation type

This page documents the type [`Presentation`](@ref Semigroups.Presentation),
a finite semigroup or monoid presentation over `Presentation{W}`, where `W`
is either `Vector{Int}` or `String`.

`Presentation{String}` uses the byte-oriented native `std::string` API and
therefore accepts ASCII characters only. Its generated alphabet-by-size form
is limited to 31 letters because libsemigroups starts that alphabet at `'a'`.

Algorithms such as Knuth-Bendix and Todd-Coxeter currently accept only
`Presentation{Vector{Int}}`; `Presentation{String}` is supported for the
presentation data structure and its helpers.

```@docs
Semigroups.Presentation
```

## Contents

| Function                                                                                                                               | Description                               |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| [`init!`](@ref Semigroups.init!(::Presentation))                                                                                       | Reset a presentation to the empty state.  |
| [`alphabet`](@ref Semigroups.alphabet(::Presentation))                                                                                 | Return the alphabet as `W`.              |
| [`set_alphabet!`](@ref Semigroups.set_alphabet!(::Presentation, ::Integer))                                                            | Set the alphabet to `[1, ..., n]`.          |
| [`set_alphabet!`](@ref Semigroups.set_alphabet!(::Presentation, ::AbstractVector{<:Integer}))                                          | Set the alphabet to the given `W` value.  |
| [`alphabet_from_rules!`](@ref Semigroups.alphabet_from_rules!(::Presentation))                                                         | Infer the alphabet from the rules.        |
| [`letter`](@ref Semigroups.letter(::Presentation, ::Integer))                                                                          | Return the `i`-th alphabet letter.        |
| [`index_of`](@ref Semigroups.index_of(::Presentation, ::Integer))                                                                      | Return the 1-based letter index.         |
| [`in_alphabet`](@ref Semigroups.in_alphabet(::Presentation, ::Integer))                                                                | Test alphabet membership.                |
| [`contains_empty_word`](@ref Semigroups.contains_empty_word(::Presentation))                                                           | Query whether the empty word is allowed.  |
| [`set_contains_empty_word!`](@ref Semigroups.set_contains_empty_word!(::Presentation, ::Bool))                                         | Set whether the empty word is allowed.    |
| [`add_generator!`](@ref Semigroups.add_generator!(::Presentation))                                                                     | Append a generator (no-arg or by letter). |
| [`remove_generator!`](@ref Semigroups.remove_generator!(::Presentation, ::Integer))                                                    | Remove a letter from the alphabet.        |
| [`number_of_rules`](@ref Semigroups.number_of_rules(::Presentation))                                                                   | Number of rules in the presentation.      |
| [`rule_lhs`](@ref Semigroups.rule_lhs(::Presentation, ::Integer))                                                                      | Left-hand side of the `i`-th rule.        |
| [`rule_rhs`](@ref Semigroups.rule_rhs(::Presentation, ::Integer))                                                                      | Right-hand side of the `i`-th rule.       |
| [`rule`](@ref Semigroups.rule(::Presentation, ::Integer))                                                                              | `(lhs, rhs)` tuple for the `i`-th rule.   |
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
Semigroups.rule(::Presentation, ::Integer)
Semigroups.rules(::Presentation)
Semigroups.clear_rules!(::Presentation)
Semigroups.add_rule!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.add_rule_no_checks!(::Presentation, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
```

## `Base` interface

A [`Presentation`](@ref Semigroups.Presentation) extends the standard
value-semantics predicates from `Base`, making it usable as a dictionary
key and interoperable with generic Julia code.

```@docs
Base.isempty
Base.hash
```
