# The WordGraph type

This page contains the documentation of the type [`WordGraph`](@ref
Semigroups.WordGraph), a representation of a word graph over an alphabet
of fixed out-degree.

```@docs
Semigroups.WordGraph
```

## Contents

| Function                                                                                                   | Description                                                          |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [`WordGraph`](@ref Semigroups.WordGraph(::Integer, ::Integer))                                             | Construct from number of nodes and out degree.                       |
| [`number_of_nodes`](@ref Semigroups.number_of_nodes(::WordGraph))                                          | Returns the number of nodes.                                         |
| [`out_degree`](@ref Semigroups.out_degree(::WordGraph))                                                    | Returns the out-degree.                                              |
| [`target`](@ref Semigroups.target(::WordGraph, ::Integer, ::Integer))                                      | Get the target of the edge with given source node and label.         |
| [`target!`](@ref Semigroups.target!(::WordGraph, ::Integer, ::Integer, ::Integer))                         | Set the target of the edge with given source node and label.         |
| [`add_nodes!`](@ref Semigroups.add_nodes!(::WordGraph, ::Integer))                                         | Add a number of new nodes.                                           |

## Full API

```@docs
Semigroups.WordGraph(::Integer, ::Integer)
Semigroups.number_of_nodes(::WordGraph)
Semigroups.out_degree(::WordGraph)
Semigroups.target(::WordGraph, ::Integer, ::Integer)
Semigroups.target!(::WordGraph, ::Integer, ::Integer, ::Integer)
Semigroups.add_nodes!(::WordGraph, ::Integer)
```
