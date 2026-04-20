# The WordRange type

This page contains the documentation of the type [`WordRange`](@ref
Semigroups.WordRange), an iterable range over words in an alphabet in a
user-selected [`Order`](@ref Semigroups.Order).

```@docs
Semigroups.WordRange
```

## Contents

| Function                                                                                                                 | Description                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| [`alphabet_size`](@ref Semigroups.alphabet_size(::WordRange))                                                            | The current number of letters in the alphabet.                                               |
| [`set_alphabet_size!`](@ref Semigroups.set_alphabet_size!(::WordRange, ::Integer))                                       | Set the number of letters in the alphabet.                                                   |
| [`at_end`](@ref Semigroups.at_end(::WordRange))                                                                          | Check if the range is exhausted.                                                             |
| [`count`](@ref Base.count(::WordRange))                                                                                  | The actual size of the range.                                                                |
| [`first_word`](@ref Semigroups.first_word(::WordRange))                                                                  | The current first word (lower bookend) of the range.                                         |
| [`set_first!`](@ref Semigroups.set_first!(::WordRange, ::AbstractVector{<:Integer}))                                     | Set the first word (lower bookend) of the range.                                             |
| [`get`](@ref Base.get(::WordRange))                                                                                      | Get the current word from the range.                                                         |
| [`init!`](@ref Semigroups.init!(::WordRange))                                                                            | Re-initialize an existing [`WordRange`](@ref Semigroups.WordRange) object.                   |
| [`last_word`](@ref Semigroups.last_word(::WordRange))                                                                    | The current one-past-the-last word (upper bookend) of the range.                             |
| [`set_last!`](@ref Semigroups.set_last!(::WordRange, ::AbstractVector{<:Integer}))                                       | Set the one-past-the-last word (upper bookend) of the range.                                 |
| [`set_max!`](@ref Semigroups.set_max!(::WordRange, ::Integer))                                                           | Set one past the maximum word length.                                                        |
| [`set_min!`](@ref Semigroups.set_min!(::WordRange, ::Integer))                                                           | Set the minimum word length.                                                                 |
| [`next!`](@ref Semigroups.next!(::WordRange))                                                                            | Advance the range to the next word.                                                          |
| [`order`](@ref Semigroups.order(::WordRange))                                                                            | The current order of the words in the range.                                                 |
| [`set_order!`](@ref Semigroups.set_order!(::WordRange, ::Order))                                                         | Set the order of the words in the range.                                                     |
| [`size_hint`](@ref Semigroups.size_hint(::WordRange))                                                                    | The possible size of the range.                                                              |
| [`upper_bound`](@ref Semigroups.upper_bound(::WordRange))                                                                | The current upper bound on the length of a word in the range.                                |
| [`set_upper_bound!`](@ref Semigroups.set_upper_bound!(::WordRange, ::Integer))                                           | Set an upper bound on the length of a word in the range.                                     |
| [`valid`](@ref Semigroups.valid(::WordRange))                                                                            | Whether settings have been changed since the last [`next!`](@ref Semigroups.next!) / [`get`](@ref Base.get(::WordRange)) call. |

## Free functions

| Function                                                                                   | Description                                                                             |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| [`number_of_words`](@ref Semigroups.number_of_words(::Integer, ::Integer, ::Integer))      | Count the words over an alphabet of size `n` with length in `[min, max)`.               |
| [`random_word`](@ref Semigroups.random_word(::Integer, ::Integer))                         | Return a uniformly random word of the given length over an alphabet of a given size.    |

## Full API

```@docs
Semigroups.alphabet_size(::WordRange)
Semigroups.set_alphabet_size!(::WordRange, ::Integer)
Semigroups.at_end(::WordRange)
Base.count(::WordRange)
Semigroups.first_word(::WordRange)
Semigroups.set_first!(::WordRange, ::AbstractVector{<:Integer})
Base.get(::WordRange)
Semigroups.init!(::WordRange)
Semigroups.last_word(::WordRange)
Semigroups.set_last!(::WordRange, ::AbstractVector{<:Integer})
Semigroups.set_max!(::WordRange, ::Integer)
Semigroups.set_min!(::WordRange, ::Integer)
Semigroups.next!(::WordRange)
Semigroups.order(::WordRange)
Semigroups.set_order!(::WordRange, ::Order)
Semigroups.size_hint(::WordRange)
Semigroups.upper_bound(::WordRange)
Semigroups.set_upper_bound!(::WordRange, ::Integer)
Semigroups.valid(::WordRange)
Semigroups.number_of_words(::Integer, ::Integer, ::Integer)
Semigroups.random_word(::Integer, ::Integer)
```
