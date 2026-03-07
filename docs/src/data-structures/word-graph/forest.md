# The Forest type

This page contains the documentation of the type [`Forest`](@ref Semigroups.Forest).

## Contents

| Function                                                                                                                 | Description                                              |
| ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------- |
| [`Forest`](@ref Semigroups.Forest(::Int64))                                                                              | Construct a forest with `n` nodes.                       |
| [`Forest`](@ref Semigroups.Forest(::Vector{Any},::Vector{Any}))                                                          | Construct a forest from parents and labels.              |
| [`add_nodes!`](@ref Semigroups.add_nodes!(::Forest, ::Int64))                                                            | Add nodes to the [`Forest`](@ref).                       |
| [`empty`](@ref Base.empty(::Forest))                                                                                     | Check if there are any nodes in the forest.              |
| [`init!`](@ref Semigroups.init!(::Forest,::Int64))                                                                       | Reinitialize an existing [`Forest`](@ref) object.        |
| [`label`](@ref Semigroups.label(::Forest, ::Int64))                                                                      | Returns the label of the edge from a node to its parent. |
| [`labels`](@ref Semigroups.labels(::Forest))                                                                             | Returns the `Vector` of edge labels.                     |
| [`number_of_nodes`](@ref Semigroups.number_of_nodes(::Forest))                                                           | Returns the number of nodes in the forest.               |
| [`parent_node`](@ref Semigroups.parent_node(::Forest,::Int64))                                                           | Returns the parent of a node.                            |
| [`parents`](@ref Semigroups.parents(::Forest))                                                                           | Returns the `Vector` of parents.                         |
| [`set_parent_and_label!`](@ref Semigroups.set_parent_and_label!(::Forest,::Int64,::Int64OrUndefined,::Int64OrUndefined)) | Set the parent and edge label for a node.                |

## Full API

```@docs
Semigroups.Forest(::Int64)
Semigroups.Forest(::Vector{Any},::Vector{Any})
Semigroups.add_nodes!(::Forest,::Int64)
Base.empty(::Forest)
Semigroups.init!(::Forest,::Int64)
Semigroups.label(::Forest,::Int64)
Semigroups.labels(::Forest)
Semigroups.number_of_nodes(::Forest)
Semigroups.parent_node(::Forest, ::Int64)
Semigroups.parents(::Forest)
Semigroups.set_parent_and_label!(::Forest,::Int64,::Int64OrUndefined,::Int64OrUndefined)
```
