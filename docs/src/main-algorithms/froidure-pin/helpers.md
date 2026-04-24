# Helper functions

This page collects the free functions that operate on a
[`FroidurePin`](@ref Semigroups.FroidurePin) instance. They mirror the
`libsemigroups::froidure_pin::*` namespace and are organised into three
groups: factorisations, collections, and word-element conversion.

## Factorisations

These functions return or query words (as `Vector{Int}` with 1-based
generator indices) representing elements of the semigroup.

### Contents

| Function | Description |
| -------- | ----------- |
| [`minimal_factorisation`](@ref Semigroups.minimal_factorisation(::FroidurePin, ::Integer)) | Minimal factorisation of the element at a given position. |
| [`current_minimal_factorisation`](@ref Semigroups.current_minimal_factorisation(::FroidurePin, ::Integer)) | Minimal factorisation without triggering enumeration. |
| [`factorisation`](@ref Semigroups.factorisation(::FroidurePin, ::Integer)) | A (not necessarily minimal) factorisation. |

### Full API

```@docs
Semigroups.minimal_factorisation(::FroidurePin, ::Integer)
Semigroups.current_minimal_factorisation(::FroidurePin, ::Integer)
Semigroups.factorisation(::FroidurePin, ::Integer)
```

## Collections

These functions return materialized collections of elements, rules, or
normal forms.

### Contents

| Function | Description |
| -------- | ----------- |
| [`rules`](@ref Semigroups.rules(::FroidurePin)) | All rules as `lhs => rhs` pairs with 1-based generator indices. |
| [`current_rules`](@ref Semigroups.current_rules(::FroidurePin)) | Rules discovered so far. |
| [`normal_forms`](@ref Semigroups.normal_forms(::FroidurePin)) | Normal forms for all elements. |
| [`current_normal_forms`](@ref Semigroups.current_normal_forms(::FroidurePin)) | Normal forms discovered so far. |
| [`idempotents`](@ref Semigroups.idempotents(::FroidurePin{E}) where E) | All idempotent elements. |
| [`sorted_elements`](@ref Semigroups.sorted_elements(::FroidurePin{E}) where E) | All elements in sorted order. |

### Full API

```@docs
Semigroups.rules(::FroidurePin)
Semigroups.current_rules(::FroidurePin)
Semigroups.normal_forms(::FroidurePin)
Semigroups.current_normal_forms(::FroidurePin)
Semigroups.idempotents(::FroidurePin{E}) where E
Semigroups.sorted_elements(::FroidurePin{E}) where E
```

## Word-element conversion

These functions convert between generator-index words (`Vector{Int}`
with 1-based indices) and semigroup elements.

### Contents

| Function | Description |
| -------- | ----------- |
| [`to_element`](@ref Semigroups.to_element(::FroidurePin{E}, ::AbstractVector{<:Integer}) where E) | Convert a word to the corresponding element. |
| [`equal_to`](@ref Semigroups.equal_to(::FroidurePin, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})) | Check if two words represent the same element. |
| [`position`](@ref Semigroups.position(::FroidurePin, ::AbstractVector{<:Integer})) | Position of the element represented by a word. |

### Full API

```@docs
Semigroups.to_element(::FroidurePin{E}, ::AbstractVector{<:Integer}) where E
Semigroups.equal_to(::FroidurePin, ::AbstractVector{<:Integer}, ::AbstractVector{<:Integer})
Semigroups.position(::FroidurePin, ::AbstractVector{<:Integer})
```

## Cayley graphs

The left and right Cayley graphs of a `FroidurePin` instance are
returned as [`WordGraph`](@ref Semigroups.WordGraph) objects. The
`current_*` variants return the graph for elements enumerated so far
without triggering further enumeration.

### Contents

| Function | Description |
| -------- | ----------- |
| [`right_cayley_graph`](@ref Semigroups.right_cayley_graph(::FroidurePin)) | Right Cayley graph (triggers full enumeration). |
| [`current_right_cayley_graph`](@ref Semigroups.current_right_cayley_graph(::FroidurePin)) | Right Cayley graph for elements enumerated so far. |
| [`left_cayley_graph`](@ref Semigroups.left_cayley_graph(::FroidurePin)) | Left Cayley graph (triggers full enumeration). |
| [`current_left_cayley_graph`](@ref Semigroups.current_left_cayley_graph(::FroidurePin)) | Left Cayley graph for elements enumerated so far. |

### Full API

```@docs
Semigroups.right_cayley_graph(::FroidurePin)
Semigroups.current_right_cayley_graph(::FroidurePin)
Semigroups.left_cayley_graph(::FroidurePin)
Semigroups.current_left_cayley_graph(::FroidurePin)
```
