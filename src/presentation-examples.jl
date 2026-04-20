# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
presentation-examples.jl - v1 bindings for presentation::examples::*

Each binding returns a `Presentation` over `word_type` (Julia `Vector{Int}`
with 1-based letter indices). 

!!! warning "v1 limitation"
    v1 of Semigroups.jl binds `Presentation<word_type>` only. Alphabets and
    rules use `Vector{Int}` with 1-based letter indices.
"""

"""
    symmetric_group(n::Integer) -> Presentation

A presentation for the symmetric group of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 2`.
"""
function symmetric_group(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_symmetric_group(m)
end

"""
    alternating_group(n::Integer) -> Presentation

A presentation for the alternating group of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 4`.
"""
function alternating_group(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_alternating_group(m)
end

"""
    braid_group(n::Integer) -> Presentation

A presentation for the braid group with `n - 1` generators.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function braid_group(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_braid_group(m)
end

"""
    not_symmetric_group(n::Integer) -> Presentation

A presentation that is not a symmetric group but has the same number of
generators and relations as the symmetric group of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 4`.
"""
function not_symmetric_group(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_not_symmetric_group(m)
end

"""
    full_transformation_monoid(n::Integer) -> Presentation

A presentation for the full transformation monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 2`.
"""
function full_transformation_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_full_transformation_monoid(m)
end

"""
    partial_transformation_monoid(n::Integer) -> Presentation

A presentation for the partial transformation monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 2`.
"""
function partial_transformation_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_partial_transformation_monoid(m)
end

"""
    symmetric_inverse_monoid(n::Integer) -> Presentation

A presentation for the symmetric inverse monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 4`.
"""
function symmetric_inverse_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_symmetric_inverse_monoid(m)
end

"""
    cyclic_inverse_monoid(n::Integer) -> Presentation

A presentation for the cyclic inverse monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function cyclic_inverse_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_cyclic_inverse_monoid(m)
end

"""
    order_preserving_monoid(n::Integer) -> Presentation

A presentation for the order-preserving transformation monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function order_preserving_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_order_preserving_monoid(m)
end

"""
    order_preserving_cyclic_inverse_monoid(n::Integer) -> Presentation

A presentation for the order-preserving part of the cyclic inverse monoid of
degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function order_preserving_cyclic_inverse_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_order_preserving_cyclic_inverse_monoid(m)
end

"""
    orientation_preserving_monoid(n::Integer) -> Presentation

A presentation for the orientation-preserving transformation monoid of degree
`n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function orientation_preserving_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_orientation_preserving_monoid(m)
end

"""
    orientation_preserving_reversing_monoid(n::Integer) -> Presentation

A presentation for the orientation-preserving and -reversing transformation
monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function orientation_preserving_reversing_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_orientation_preserving_reversing_monoid(
        m,
    )
end

"""
    partition_monoid(n::Integer) -> Presentation

A presentation for the partition monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 4`.
"""
function partition_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_partition_monoid(m)
end

"""
    partial_brauer_monoid(n::Integer) -> Presentation

A presentation for the partial Brauer monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 1`.
"""
function partial_brauer_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_partial_brauer_monoid(m)
end

"""
    brauer_monoid(n::Integer) -> Presentation

A presentation for the Brauer monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 1`.
"""
function brauer_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_brauer_monoid(m)
end

"""
    singular_brauer_monoid(n::Integer) -> Presentation

A presentation for the singular part of the Brauer monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function singular_brauer_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_singular_brauer_monoid(m)
end

"""
    temperley_lieb_monoid(n::Integer) -> Presentation

A presentation for the Temperley-Lieb monoid with `n - 1` generators.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function temperley_lieb_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_temperley_lieb_monoid(m)
end

"""
    motzkin_monoid(n::Integer) -> Presentation

A presentation for the Motzkin monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 1`.
"""
function motzkin_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_motzkin_monoid(m)
end

"""
    partial_isometries_cycle_graph_monoid(n::Integer) -> Presentation

A presentation for the monoid of partial isometries of an `n`-cycle graph.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function partial_isometries_cycle_graph_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_partial_isometries_cycle_graph_monoid(m)
end

"""
    uniform_block_bijection_monoid(n::Integer) -> Presentation

A presentation for the uniform block bijection monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function uniform_block_bijection_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_uniform_block_bijection_monoid(m)
end

"""
    dual_symmetric_inverse_monoid(n::Integer) -> Presentation

A presentation for the dual symmetric inverse monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 3`.
"""
function dual_symmetric_inverse_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_dual_symmetric_inverse_monoid(m)
end

"""
    stellar_monoid(l::Integer) -> Presentation

A presentation for the stellar monoid with `l` generators.

# Throws
- `LibsemigroupsError`: if `l < 2`.
"""
function stellar_monoid(l::Integer)
    ll = UInt(l)
    @wrap_libsemigroups_call LibSemigroups.example_stellar_monoid(ll)
end

"""
    zero_rook_monoid(n::Integer) -> Presentation

A presentation for the 0-rook monoid of degree `n`.

# Throws
- `LibsemigroupsError`: if `n < 2`.
"""
function zero_rook_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_zero_rook_monoid(m)
end

"""
    abacus_jones_monoid(n::Integer, d::Integer) -> Presentation

A presentation for the abacus Jones monoid of degree `n` with at most `d-1`
beads per arc.

# Throws
- `LibsemigroupsError`: if `n < 3`.
- `LibsemigroupsError`: if `d == 0`.
"""
function abacus_jones_monoid(n::Integer, d::Integer)
    nn = UInt(n)
    dd = UInt(d)
    @wrap_libsemigroups_call LibSemigroups.example_abacus_jones_monoid(nn, dd)
end

# ---- batch C: plactic / misc ----

"""
    plactic_monoid(n::Integer) -> Presentation

A presentation for the plactic monoid with `n` generators.
"""
function plactic_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_plactic_monoid(m)
end

"""
    chinese_monoid(n::Integer) -> Presentation

A presentation for the Chinese monoid with `n` generators.
"""
function chinese_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_chinese_monoid(m)
end

"""
    hypo_plactic_monoid(n::Integer) -> Presentation

A presentation for the hypo-plactic monoid with `n` generators.
"""
function hypo_plactic_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_hypo_plactic_monoid(m)
end

"""
    stylic_monoid(n::Integer) -> Presentation

A presentation for the stylic monoid with `n` generators.
"""
function stylic_monoid(n::Integer)
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_stylic_monoid(m)
end

"""
    special_linear_group_2(q::Integer) -> Presentation

A presentation for the special linear group SL(2, q).
"""
function special_linear_group_2(q::Integer)
    qq = UInt(q)
    @wrap_libsemigroups_call LibSemigroups.example_special_linear_group_2(qq)
end

"""
    fibonacci_semigroup(r::Integer, n::Integer) -> Presentation

A presentation for the Fibonacci semigroup F(r, n).
"""
function fibonacci_semigroup(r::Integer, n::Integer)
    rr = UInt(r)
    nn = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_fibonacci_semigroup(rr, nn)
end

"""
    monogenic_semigroup(m::Integer, r::Integer) -> Presentation

A presentation for the monogenic semigroup with index `m` and period `r`.
"""
function monogenic_semigroup(m::Integer, r::Integer)
    mm = UInt(m)
    rr = UInt(r)
    @wrap_libsemigroups_call LibSemigroups.example_monogenic_semigroup(mm, rr)
end

"""
    rectangular_band(m::Integer, n::Integer) -> Presentation

A presentation for the `m × n` rectangular band.
"""
function rectangular_band(m::Integer, n::Integer)
    mm = UInt(m)
    nn = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.example_rectangular_band(mm, nn)
end

"""
    sigma_plactic_monoid(sigma::AbstractVector{<:Integer}) -> Presentation

Presentation for the σ-plactic monoid with coefficient sequence `sigma`.

!!! note "0-based `sigma`"
    Unlike alphabet letters (which are 1-based in the Julia API), the
    `sigma` argument here is a vector of libsemigroups-native 0-based
    coefficient indices — pass it through verbatim.
"""
function sigma_plactic_monoid(sigma::AbstractVector{<:Integer})
    s = UInt[UInt(x) for x in sigma]
    @wrap_libsemigroups_call LibSemigroups.example_sigma_plactic_monoid(s)
end

"""
    renner_type_B_monoid(l::Integer, q::Integer) -> Presentation

A presentation for the Renner type B monoid of rank `l` over a field of size `q`.
"""
function renner_type_B_monoid(l::Integer, q::Integer)
    ll = UInt(l)
    qq = Int32(q)
    @wrap_libsemigroups_call LibSemigroups.example_renner_type_B_monoid(ll, qq)
end

"""
    renner_type_D_monoid(l::Integer, q::Integer) -> Presentation

A presentation for the Renner type D monoid of rank `l` over a field of size `q`.
"""
function renner_type_D_monoid(l::Integer, q::Integer)
    ll = UInt(l)
    qq = Int32(q)
    @wrap_libsemigroups_call LibSemigroups.example_renner_type_D_monoid(ll, qq)
end

"""
    not_renner_type_B_monoid(l::Integer, q::Integer) -> Presentation

A presentation (not Renner type B) related to the Renner type B monoid of
rank `l` over a field of size `q`.
"""
function not_renner_type_B_monoid(l::Integer, q::Integer)
    ll = UInt(l)
    qq = Int32(q)
    @wrap_libsemigroups_call LibSemigroups.example_not_renner_type_B_monoid(ll, qq)
end

"""
    not_renner_type_D_monoid(l::Integer, q::Integer) -> Presentation

A presentation (not Renner type D) related to the Renner type D monoid of
rank `l` over a field of size `q`.
"""
function not_renner_type_D_monoid(l::Integer, q::Integer)
    ll = UInt(l)
    qq = Int32(q)
    @wrap_libsemigroups_call LibSemigroups.example_not_renner_type_D_monoid(ll, qq)
end
