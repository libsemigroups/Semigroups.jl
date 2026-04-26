# The Paths type

This page documents the type [`Paths`](@ref Semigroups.Paths), a stateful
range over paths in a [`WordGraph`](@ref Semigroups.WordGraph). A `Paths`
object pins its source word graph for garbage collection and yields paths
as `Vector{Int}` of 1-based edge labels via the standard Julia iteration
protocol or the manual `get` / [`next!`](@ref Semigroups.next!) /
[`at_end`](@ref Semigroups.at_end) interface.

!!! warning "v1 limitation"
    Paths is bound for `WordGraph<uint32_t>` only; other Node types follow
    when consumers need them.

```@docs
Semigroups.Paths
```

## Contents

| Function                                                                                          | Description                                                          |
| ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [`Paths`](@ref Semigroups.Paths(::WordGraph))                                                     | Construct a [`Paths`](@ref Semigroups.Paths) over a word graph.      |
| [`paths`](@ref Semigroups.paths(::WordGraph))                                                     | Keyword-argument factory for a [`Paths`](@ref Semigroups.Paths).     |
| [`source`](@ref Semigroups.source(::Paths))                                                       | Get the current source node.                                         |
| [`source!`](@ref Semigroups.source!(::Paths, ::Integer))                                          | Set the source node.                                                 |
| [`target`](@ref Semigroups.target(::Paths))                                                       | Get the current target node (or [`UNDEFINED`](@ref Semigroups.UNDEFINED)). |
| [`target!`](@ref Semigroups.target!(::Paths, ::Integer))                                          | Set the target node, or clear it with [`UNDEFINED`](@ref Semigroups.UNDEFINED). |
| [`min!`](@ref Semigroups.min!(::Paths, ::Integer))                                                | Set the minimum path length.                                         |
| [`max!`](@ref Semigroups.max!(::Paths, ::Integer))                                                | Set the maximum path length, or remove the bound with [`POSITIVE_INFINITY`](@ref Semigroups.POSITIVE_INFINITY). |
| [`order`](@ref Semigroups.order(::Paths))                                                         | Get the current word [`Order`](@ref Semigroups.Order).               |
| [`order!`](@ref Semigroups.order!(::Paths, ::Order))                                              | Set the word [`Order`](@ref Semigroups.Order).                       |
| [`current_target`](@ref Semigroups.current_target(::Paths))                                       | Target node of the path currently labelled by [`Base.get`](@ref Base.get(::Paths)). |
| [`word_graph`](@ref Semigroups.word_graph(::Paths))                                               | Return the underlying [`WordGraph`](@ref Semigroups.WordGraph).      |
| [`next!`](@ref Semigroups.next!(::Paths))                                                         | Advance the range to the next path.                                  |
| [`at_end`](@ref Semigroups.at_end(::Paths))                                                       | Test whether the range is exhausted.                                 |
| [`throw_if_source_undefined`](@ref Semigroups.throw_if_source_undefined(::Paths))                 | Throw if [`source`](@ref Semigroups.source(::Paths)) is undefined.   |
| [`Base.min`](@ref Base.min(::Paths))                                                              | Get the current minimum path length (qualified-only).                |
| [`Base.max`](@ref Base.max(::Paths))                                                              | Get the current maximum path length (qualified-only).                |
| [`Base.get`](@ref Base.get(::Paths))                                                              | Get the current path as a `Vector{Int}` (qualified-only).            |
| [`Base.count`](@ref Base.count(::Paths))                                                          | Get the number of paths in the range (qualified-only).               |
| `Base.iterate(p::Paths)`                                                                          | Julia iteration protocol (destructive — consumes the range).         |
| `Base.show(io::IO, p::Paths)`                                                                     | Human-readable representation.                                       |

## Full API

```@docs
Semigroups.Paths(::WordGraph)
Semigroups.paths(::WordGraph)
Semigroups.source(::Paths)
Semigroups.source!(::Paths, ::Integer)
Semigroups.target(::Paths)
Semigroups.target!(::Paths, ::Integer)
Semigroups.min!(::Paths, ::Integer)
Semigroups.max!(::Paths, ::Integer)
Semigroups.order(::Paths)
Semigroups.order!(::Paths, ::Order)
Semigroups.current_target(::Paths)
Semigroups.word_graph(::Paths)
Semigroups.next!(::Paths)
Semigroups.at_end(::Paths)
Semigroups.throw_if_source_undefined(::Paths)
Base.min(::Paths)
Base.max(::Paths)
Base.get(::Paths)
Base.count(::Paths)
```
