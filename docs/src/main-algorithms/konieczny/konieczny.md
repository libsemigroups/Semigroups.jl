# The Konieczny type

This page documents the parametric type
[`Konieczny{E}`](@ref Semigroups.Konieczny), which implements Konieczny's
algorithm for computing the Green's structure of a finitely generated
semigroup, and [`KoniecznyDClass{E}`](@ref Semigroups.KoniecznyDClass),
the handle through which its D-classes are accessed.

`Konieczny{E}` is a subtype of [`Runner`](@ref Semigroups.Runner), so all
runner methods ([`run!`](@ref), [`run_for!`](@ref), [`finished`](@ref),
etc.) are available.

```@docs
Semigroups.Konieczny
Semigroups.KoniecznyDClass
```

## Construction

```@docs
Konieczny(::Vector{E}) where {E}
Konieczny(::E, ::E...) where {E}
add_generator!(::Konieczny{E}, ::E) where {E}
```

## Size and generators

```@docs
Base.length(::Konieczny)
current_size(::Konieczny)
degree(::Konieczny)
number_of_generators(::Konieczny)
generator(::Konieczny{E}, ::Integer) where {E}
```

## Counting Green's classes

Each of these triggers a full run of the algorithm. The `current_` variant
returns the count over the D-classes found so far and does not trigger a
run.

```@docs
number_of_D_classes
current_number_of_D_classes
number_of_regular_D_classes
current_number_of_regular_D_classes
number_of_L_classes(::Konieczny)
current_number_of_L_classes
number_of_regular_L_classes
current_number_of_regular_L_classes
number_of_R_classes(::Konieczny)
current_number_of_R_classes
number_of_regular_R_classes
current_number_of_regular_R_classes
number_of_H_classes
current_number_of_H_classes
number_of_idempotents(::Konieczny)
current_number_of_idempotents
number_of_regular_elements
current_number_of_regular_elements
```


## D-classes

```@docs
D_class_of_element
D_class
regular_D_class
D_classes
regular_D_classes
rep
Base.length(::KoniecznyDClass)
number_of_L_classes(::KoniecznyDClass)
number_of_R_classes(::KoniecznyDClass)
size_H_class
is_regular_D_class
number_of_idempotents(::KoniecznyDClass)
Base.in(::E, ::KoniecznyDClass{E}) where {E}
```
