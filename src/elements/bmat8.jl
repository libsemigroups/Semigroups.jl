# Copyright (c) 2026, James W. Swent, J. D. Mitchell
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
bmat8.jl - High-level Julia API for BMat8

This file provides user-facing BMat8 functionality with idiomatic Julia
interfaces: 1-based indexing, and standard Julia operators.
"""

########################################################################
# BMat8
########################################################################

"""
Fast boolean matrices of dimension up to 8 x 8.


This class represents 8 x 8 matrices over the boolean semiring. The functions
for these small matrices over the boolean semiring are more optimised than the
generic functions for boolean matrices. Note that all [`BMat8`](@ref) are
represented internally as an 8 x 8 matrix; any entries not defined by the user
are taken to be `0`. This does not affect the results of any calculations.

# Example
```jldoctest
julia> using Semigroups

julia> x = BMat8([[0, 1], [1, 0]])
BMat8([[0, 1],
       [1, 0]])

julia> x[1, 1] = 1
1

julia> x
BMat8([[1, 1],
       [1, 0]])

julia> x[1, 2]
true

julia> x[2, 2]
false

julia> x * x
BMat8([[1, 1],
       [1, 1]])

julia> x < x * x
true

julia> x *= x
BMat8([[1, 1],
       [1, 1]])

julia> x
BMat8([[1, 1],
       [1, 1]])

julia> to_int(x)
0xc0c0000000000000

julia> string(to_int(x), base=2)
"1100000011000000000000000000000000000000000000000000000000000000"

julia> x == BMat8([[1, 1, 0], [1, 1, 0], [0, 0, 0]]) # All BMat8's are really 8x8!
true

julia> y = BMat8([[1, 0, 1], [0, 1, 0], [0, 0, 0]])
BMat8([[1, 0, 1],
       [0, 1, 0],
       [0, 0, 0]])

julia> y[1]  # The first row
8-element Vector{Bool}:
 1
 0
 1
 0
 0
 0
 0
 0

julia> x + y
BMat8([[1, 1, 1],
       [1, 1, 0],
       [0, 0, 0]])

julia> x += y
BMat8([[1, 1, 1],
       [1, 1, 0],
       [0, 0, 0]])

julia> 1 * x == x
true

julia> x * 0
BMat8(0)

julia> Dict(BMat8(0) => 1)
Dict{Semigroups.LibSemigroups.BMat8Allocated, Int64} with 1 entry:
  BMat8(0) => 1
```

[`BMat8`](@ref) objects can be used with the following algorithms in
Semigroups.jl

* [`Action`](@ref)
* [`FroidurePin`](@ref)
* [`Konieczny`](@ref)
"""
const BMat8 = LibSemigroups.BMat8

########################################################################
# Base overloads
########################################################################


function Base.show(io::IO, x::BMat8)
    # TODO when is @wrap_libsemigroups_call required?
    print(io, @wrap_libsemigroups_call LibSemigroups.to_human_readable_repr(x))
end

function Base.getindex(x::BMat8, r::Integer, c::Integer)::Bool
    return LibSemigroups.at(x, UInt(r - 1), UInt(c - 1))
end

function Base.getindex(x::BMat8, r::Integer)::Vector{Bool}
    return LibSemigroups.at(x, UInt(r - 1))
end

function Base.setindex!(
    x::BMat8,
    val::T,
    r::Integer,
    c::Integer,
) where {T<:Union{Bool,Int64}}
    LibSemigroups.setitem(x, UInt(r - 1), UInt(c - 1), Bool(val))
end

function Base.setindex!(x::BMat8, row::Vector{UInt8}, r::Integer)
    LibSemigroups.setrow(x, UInt(r - 1), row)
end

function Base.setindex!(x::BMat8, row::Vector{T}, r::Integer) where {T<:Union{Bool,Int64}}
    setindex!(x, Vector{UInt8}(row), r)
end

Base.:(==)(x::BMat8, y::BMat8) = LibSemigroups.is_equal(x, y)
Base.:(<)(x::BMat8, y::BMat8) = LibSemigroups.is_less(x, y)
Base.:(<=)(x::BMat8, y::BMat8) = LibSemigroups.is_less_equal(x, y)
Base.:(>)(x::BMat8, y::BMat8) = LibSemigroups.is_greater(x, y)
Base.:(>=)(x::BMat8, y::BMat8) = LibSemigroups.is_greater_equal(x, y)
Base.:(*)(x::BMat8, y::BMat8) = LibSemigroups.multiply(x, y)
Base.:(*)(x::BMat8, y::T) where {T<:Union{Bool,Int64}} = LibSemigroups.multiply(x, Bool(y))
Base.:(*)(x::T, y::BMat8) where {T<:Union{Bool,Int64}} = LibSemigroups.multiply(Bool(x), y)
Base.:(+)(x::BMat8, y::BMat8) = LibSemigroups.add(x, y)

Base.copy(x::BMat8) = LibSemigroups.copy(x)
Base.hash(x::BMat8, h::UInt) = hash(LibSemigroups.hash_value(x), h)
Base.transpose(x::BMat8)::BMat8 = LibSemigroups.bmat8_transpose(x)

########################################################################
# Semigroups.jl functions
########################################################################

# TODO document the 0-arg constructor

"""
    BMat8(rows::Vector{Vector{T}})::BMat8 where {T<:Union{Bool,Int64}} -> BMat8

Construct from Vector of rows.

This constructor initializes a matrix where the rows of the matrix are the
lists in *rows*.

# Arguments
- `rows::Vector{Vector{T}} where {T<:Union{Bool,Int64}}`: the rows of the matrix.

# Throws
- `MethodError`: if `rows` has `0` rows.
- `LibsemigroupsError`: if `rows` has more than `8` rows.
- `LibsemigroupsError`: if the items in `rows` are not all of the same length.

# Complexity
- Constant.
"""
function BMat8(rows::Vector{Vector{T}})::BMat8 where {T<:Union{Bool,Int64}}
    result = BMat8(0)
    n = length(rows[1])
    for (i, row) in enumerate(rows)
        if length(row) != n
            throw(
                LibsemigroupsError(
                    "the entries of the argument (rows) must all be the same length $n, found length $(length(row)) for row with index $i",
                ),
            )
        end
        result[i] = row
    end
    return result
end

########################################################################
# Mem fns
########################################################################

"""
    degree(x::BMat8) -> Integer

Returns the degree of a [`BMat8`](@ref).

This function returns the degree of `x` which is always returns `8`.

# Arguments
- `x::BMat8`: the matrix. 
"""
degree(x::BMat8)::Integer = LibSemigroups.degree(x)

"""
    swap!(x::BMat8, y::BMat8) -> nothing

Swaps two [`BMat8`](@ref) objects.

This function swaps the values of `x` and `y`.

# Arguments
- `x::BMat8`: the first matrix to swap.
- `y::BMat8`: the second matrix to swap.

# Complexity
- Constant.

# Example
```jldoctest
julia> using Semigroups

julia> x = BMat8([[0, 1], [1, 0]])
BMat8([[0, 1],
       [1, 0]])

julia> y = BMat8([[1, 1], [0, 0]])
BMat8([[1, 1],
       [0, 0]])

julia> swap!(x, y)

julia> x
BMat8([[1, 1],
       [0, 0]])

julia> y
BMat8([[0, 1],
       [1, 0]])
```
"""
swap!(x::BMat8, y::BMat8)::Nothing = LibSemigroups.swap(x, y)

"""
    to_int(x::BMat8) -> Integer

Returns the integer representation of a [`BMat8`](@ref).

This function returns a non-negative integer obtained by interpreting an 8 x 8
[`BMat8`](@ref) as a sequence of `64` bits (reading rows left to right, from top
to bottom) and then realising this sequence as an integer.

# Arguments
- `x::BMat8`: the matrix. 

# Complexity
- Constant.

# Example
```jldoctest
julia> using Semigroups

julia> x = BMat8([[0, 1], [1, 0]])
BMat8([[0, 1],
       [1, 0]])

julia> to_int(x)
0x4080000000000000

julia> string(to_int(x), base=2)
"100000010000000000000000000000000000000000000000000000000000000"
```
"""
to_int(x::BMat8)::Integer = LibSemigroups.to_int(x)

########################################################################
# Helpers
########################################################################

col_space_basis(x::BMat8)::BMat8 = LibSemigroups.bmat8_col_space_basis(x)
col_space_size(x::BMat8)::Integer = LibSemigroups.bmat8_col_space_size(x)
is_regular_element(x::BMat8)::Bool = LibSemigroups.bmat8_is_regular_element(x)
minimum_dim(x::BMat8)::Integer = LibSemigroups.bmat8_minimum_dim(x)
number_of_cols(x::BMat8)::Integer = LibSemigroups.bmat8_number_of_cols(x)
number_of_rows(x::BMat8)::Integer = LibSemigroups.bmat8_number_of_rows(x)
one(::Type{BMat8}, n::Integer)::BMat8 = LibSemigroups.bmat8_one(n)
one(::BMat8, n::Integer)::BMat8 = LibSemigroups.bmat8_one(n)
random(::Type{BMat8}, n::Integer)::BMat8 = LibSemigroups.bmat8_random(n)
random(::BMat8, n::Integer)::BMat8 = LibSemigroups.bmat8_random(n)
row_space_size(x::BMat8)::Integer = LibSemigroups.bmat8_row_space_size(x)
rows(x::BMat8)::Vector{Vector{Bool}} = LibSemigroups.bmat8_rows(x)
