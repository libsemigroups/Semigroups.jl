# The FroidurePin type

This page documents the parametric type
[`FroidurePin{E}`](@ref Semigroups.FroidurePin), which implements the
Froidure-Pin algorithm for enumerating the elements of a finitely
generated semigroup.

`FroidurePin{E}` is a subtype of [`Runner`](@ref Semigroups.Runner)
(via the internal `FroidurePinBase`), so all runner methods
([`run!`](@ref), [`run_for!`](@ref), [`finished`](@ref), etc.) are
available.

!!! warning "v1 limitation"
    Semigroups.jl v1 binds `FroidurePin{E}` for the element types
    [`Transf`](@ref Semigroups.Transf),
    [`PPerm`](@ref Semigroups.PPerm),
    [`Perm`](@ref Semigroups.Perm), and
    [`BMat8`](@ref Semigroups.BMat8) only.

## Table of contents

| Section | Description |
| ------- | ----------- |
| [Construction](@ref) | Constructors from vectors or variadic generators. |
| [Size and enumeration](@ref) | Element count, degree, generator count, partial enumeration. |
| [Element access](@ref) | Access elements by index, generator index, or sorted index. |
| [Containment and position](@ref) | Membership testing and element position queries. |
| [Modification](@ref) | Adding generators, closure, copy-and-extend operations. |
| [Settings](@ref) | Batch size for partial enumeration. |
| [Predicates](@ref) | Identity containment, idempotent checks. |
| [Index queries](@ref) | Prefix/suffix, first/final letter, products, word lengths, rule counts. |
| [Iteration and display](@ref) | `for` loop iteration, `copy`, `show`. |
| [Runner interface](@ref) | Inherited `run!`, `run_for!`, `finished`, etc. |

```@docs
Semigroups.FroidurePin
```

## Construction

| Function | Description |
| -------- | ----------- |
| [`FroidurePin(gens::Vector{E})`](@ref Semigroups.FroidurePin(::Vector{E}) where E) | Construct from a vector of generators. |
| [`FroidurePin(x, xs...)`](@ref Semigroups.FroidurePin(::E, ::Vararg{E}) where E) | Construct from one or more generators (variadic). |

```@docs
Semigroups.FroidurePin(::Vector{E}) where E
Semigroups.FroidurePin(::E, ::Vararg{E}) where E
```

## Size and enumeration

| Function | Description |
| -------- | ----------- |
| [`length`](@ref Base.length(::FroidurePin)) | Total number of elements (triggers full enumeration). |
| [`current_size`](@ref Semigroups.current_size(::FroidurePin)) | Number of elements enumerated so far. |
| [`degree`](@ref Semigroups.degree(::FroidurePin)) | Degree of the elements. |
| [`number_of_generators`](@ref Semigroups.number_of_generators(::FroidurePin)) | Number of generators. |
| [`enumerate!`](@ref Semigroups.enumerate!(::FroidurePin, ::Integer)) | Enumerate until at least a given number of elements are found. |

```@docs
Base.length(::FroidurePin)
Semigroups.current_size(::FroidurePin)
Semigroups.degree(::FroidurePin)
Semigroups.number_of_generators(::FroidurePin)
Semigroups.enumerate!(::FroidurePin, ::Integer)
```

## Element access

| Function | Description |
| -------- | ----------- |
| [`getindex`](@ref Base.getindex(::FroidurePin{E}, ::Integer) where E) | Access element by 1-based index (triggers enumeration). |
| [`generator`](@ref Semigroups.generator(::FroidurePin{E}, ::Integer) where E) | Return the `i`-th generator. |
| [`sorted_at`](@ref Semigroups.sorted_at(::FroidurePin{E}, ::Integer) where E) | Access element by sorted index. |

```@docs
Base.getindex(::FroidurePin{E}, ::Integer) where E
Semigroups.generator(::FroidurePin{E}, ::Integer) where E
Semigroups.sorted_at(::FroidurePin{E}, ::Integer) where E
```

## Containment and position

| Function | Description |
| -------- | ----------- |
| [`in`](@ref Base.in(::E, ::FroidurePin{E}) where E) | Test membership of an element. |
| [`position`](@ref Semigroups.position(::FroidurePin{E}, ::E) where E) | Position of an element (triggers full enumeration). |
| [`sorted_position`](@ref Semigroups.sorted_position(::FroidurePin{E}, ::E) where E) | Sorted position of an element. |
| [`to_sorted_position`](@ref Semigroups.to_sorted_position(::FroidurePin, ::Integer)) | Convert element index to sorted index. |
| [`current_position`](@ref Semigroups.current_position(::FroidurePin{E}, ::E) where E) | Position among elements enumerated so far. |
| [`current_position`](@ref Semigroups.current_position(::FroidurePin, ::AbstractVector{<:Integer})) | Position of a word among elements enumerated so far. |

```@docs
Base.in(::E, ::FroidurePin{E}) where E
Semigroups.position(::FroidurePin{E}, ::E) where E
Semigroups.sorted_position(::FroidurePin{E}, ::E) where E
Semigroups.to_sorted_position(::FroidurePin, ::Integer)
Semigroups.current_position(::FroidurePin{E}, ::E) where E
Semigroups.current_position(::FroidurePin, ::AbstractVector{<:Integer})
```

## Modification

| Function | Description |
| -------- | ----------- |
| [`push!`](@ref Base.push!(::FroidurePin{E}, ::E) where E) | Add a new generator. |
| [`closure!`](@ref Semigroups.closure!(::FroidurePin{E}, ::E) where E) | Add a non-redundant generator and re-enumerate. |
| [`copy_closure`](@ref Semigroups.copy_closure(::FroidurePin{E}, ::E) where E) | Copy and add a non-redundant generator. |
| [`copy_add_generators`](@ref Semigroups.copy_add_generators(::FroidurePin{E}, ::E) where E) | Copy and add a generator. |
| [`reserve!`](@ref Semigroups.reserve!(::FroidurePin, ::Integer)) | Pre-allocate storage for elements. |

```@docs
Base.push!(::FroidurePin{E}, ::E) where E
Semigroups.closure!(::FroidurePin{E}, ::E) where E
Semigroups.copy_closure(::FroidurePin{E}, ::E) where E
Semigroups.copy_add_generators(::FroidurePin{E}, ::E) where E
Semigroups.reserve!(::FroidurePin, ::Integer)
```

## Settings

| Function | Description |
| -------- | ----------- |
| [`batch_size`](@ref Semigroups.batch_size(::FroidurePin)) | Return the current batch size. |
| [`set_batch_size!`](@ref Semigroups.set_batch_size!(::FroidurePin, ::Integer)) | Set the batch size for partial enumeration. |

```@docs
Semigroups.batch_size(::FroidurePin)
Semigroups.set_batch_size!(::FroidurePin, ::Integer)
```

## Predicates

| Function | Description |
| -------- | ----------- |
| [`contains_one`](@ref Semigroups.contains_one(::FroidurePin)) | Check if the identity is an element. |
| [`currently_contains_one`](@ref Semigroups.currently_contains_one(::FroidurePin)) | Check if the identity is known to be an element so far. |
| [`is_idempotent`](@ref Semigroups.is_idempotent(::FroidurePin, ::Integer)) | Check if an element is an idempotent via its index. |

```@docs
Semigroups.contains_one(::FroidurePin)
Semigroups.currently_contains_one(::FroidurePin)
Semigroups.is_idempotent(::FroidurePin, ::Integer)
```

## Index queries

| Function | Description |
| -------- | ----------- |
| [`prefix`](@ref Semigroups.prefix(::FroidurePin, ::Integer)) | Position of the longest proper prefix. |
| [`suffix`](@ref Semigroups.suffix(::FroidurePin, ::Integer)) | Position of the longest proper suffix. |
| [`first_letter`](@ref Semigroups.first_letter(::FroidurePin, ::Integer)) | Index of the first generator in the factorisation. |
| [`final_letter`](@ref Semigroups.final_letter(::FroidurePin, ::Integer)) | Index of the last generator in the factorisation. |
| [`fast_product`](@ref Semigroups.fast_product(::FroidurePin, ::Integer, ::Integer)) | Position of the product of two elements by index. |
| [`product_by_reduction`](@ref Semigroups.product_by_reduction(::FroidurePin, ::Integer, ::Integer)) | Product using the Cayley graph. |
| [`position_of_generator`](@ref Semigroups.position_of_generator(::FroidurePin, ::Integer)) | Position of the `i`-th generator in the enumerated elements. |
| [`current_length`](@ref Semigroups.current_length(::FroidurePin, ::Integer)) | Length of the minimal factorisation (no enumeration). |
| [`word_length`](@ref Semigroups.word_length(::FroidurePin, ::Integer)) | Length of the minimal factorisation (with enumeration). |
| [`number_of_rules`](@ref Semigroups.number_of_rules(::FroidurePin)) | Total number of rules. |
| [`current_number_of_rules`](@ref Semigroups.current_number_of_rules(::FroidurePin)) | Number of rules found so far. |
| [`number_of_idempotents`](@ref Semigroups.number_of_idempotents(::FroidurePin)) | Total number of idempotent elements. |
| [`current_max_word_length`](@ref Semigroups.current_max_word_length(::FroidurePin)) | Maximum word length among elements enumerated so far. |
| [`number_of_elements_of_length`](@ref Semigroups.number_of_elements_of_length(::FroidurePin, ::Integer)) | Number of elements with a given factorisation length. |

```@docs
Semigroups.prefix(::FroidurePin, ::Integer)
Semigroups.suffix(::FroidurePin, ::Integer)
Semigroups.first_letter(::FroidurePin, ::Integer)
Semigroups.final_letter(::FroidurePin, ::Integer)
Semigroups.fast_product(::FroidurePin, ::Integer, ::Integer)
Semigroups.product_by_reduction(::FroidurePin, ::Integer, ::Integer)
Semigroups.position_of_generator(::FroidurePin, ::Integer)
Semigroups.current_length(::FroidurePin, ::Integer)
Semigroups.word_length(::FroidurePin, ::Integer)
Semigroups.number_of_rules(::FroidurePin)
Semigroups.current_number_of_rules(::FroidurePin)
Semigroups.number_of_idempotents(::FroidurePin)
Semigroups.current_max_word_length(::FroidurePin)
Semigroups.number_of_elements_of_length(::FroidurePin, ::Integer)
```

## Iteration and display

| Function | Description |
| -------- | ----------- |
| [`iterate`](@ref Base.iterate(::FroidurePin, ::Int)) | Iterate over all elements. |
| [`eltype`](@ref Base.eltype(::Type{FroidurePin{E}}) where E) | Return the element type `E`. |
| [`copy`](@ref Base.copy(::FroidurePin{E}) where E) | Create an independent copy. |
| [`show`](@ref Base.show(::IO, ::FroidurePin)) | Display a human-readable representation. |

```@docs
Base.iterate(::FroidurePin, ::Int)
Base.eltype(::Type{FroidurePin{E}}) where E
Base.copy(::FroidurePin{E}) where E
Base.show(::IO, ::FroidurePin)
```

## Runner interface

`FroidurePin{E}` inherits the full [`Runner`](@ref Semigroups.Runner)
interface. See the [Runner documentation](../core-classes/runner.md) for
the complete list of methods (`run!`, `run_for!`, `run_until!`,
`finished`, `started`, `timed_out`, `dead`, etc.).
