# Copyright (c) 2026, James W. Swent, J. D. Mitchell
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
froidure-pin.jl - FroidurePin{E} high-level Julia wrapper

Provides a parametric `FroidurePin{E}` type wrapping the CxxWrap-bound
C++ `FroidurePin<E>` template instantiations. Follows the same three-layer
pattern as `transf.jl`: CxxWrap type aliases, union type, private helpers,
mutable struct, constructors, and method wrappers.
"""

# ============================================================================
# CxxWrap type aliases — concrete FroidurePin<E> instantiations
# ============================================================================

const FroidurePinBase = LibSemigroups.FroidurePinBase

const FroidurePinTransf1 = LibSemigroups.FroidurePinTransf1
const FroidurePinTransf2 = LibSemigroups.FroidurePinTransf2
const FroidurePinTransf4 = LibSemigroups.FroidurePinTransf4

const FroidurePinPPerm1 = LibSemigroups.FroidurePinPPerm1
const FroidurePinPPerm2 = LibSemigroups.FroidurePinPPerm2
const FroidurePinPPerm4 = LibSemigroups.FroidurePinPPerm4

const FroidurePinPerm1 = LibSemigroups.FroidurePinPerm1
const FroidurePinPerm2 = LibSemigroups.FroidurePinPerm2
const FroidurePinPerm4 = LibSemigroups.FroidurePinPerm4

const FroidurePinBMat8 = LibSemigroups.FroidurePinBMat8

# ============================================================================
# Union type for cxx_obj field
# ============================================================================

const _FroidurePinCxx = Union{
    FroidurePinTransf1,
    FroidurePinTransf2,
    FroidurePinTransf4,
    FroidurePinPPerm1,
    FroidurePinPPerm2,
    FroidurePinPPerm4,
    FroidurePinPerm1,
    FroidurePinPerm2,
    FroidurePinPerm4,
    FroidurePinBMat8,
}

# ============================================================================
# Private helpers
# ============================================================================
# Index/word conversion helpers (_to_cpp, _from_cpp, _word_to_cpp,
# _word_from_cpp) are defined in word-graph.jl, transf.jl, and order.jl
# respectively. We reuse them here without redefinition.

# ============================================================================
# Type dispatch helpers
# ============================================================================

"""
    _cxx_fp_type(::Type{E}) -> Type

Map a high-level Julia element type to its CxxWrap FroidurePin constructor type.
"""
_cxx_fp_type(::Type{Transf{UInt8}}) = FroidurePinTransf1
_cxx_fp_type(::Type{Transf{UInt16}}) = FroidurePinTransf2
_cxx_fp_type(::Type{Transf{UInt32}}) = FroidurePinTransf4

_cxx_fp_type(::Type{PPerm{UInt8}}) = FroidurePinPPerm1
_cxx_fp_type(::Type{PPerm{UInt16}}) = FroidurePinPPerm2
_cxx_fp_type(::Type{PPerm{UInt32}}) = FroidurePinPPerm4

_cxx_fp_type(::Type{Perm{UInt8}}) = FroidurePinPerm1
_cxx_fp_type(::Type{Perm{UInt16}}) = FroidurePinPerm2
_cxx_fp_type(::Type{Perm{UInt32}}) = FroidurePinPerm4

_cxx_fp_type(::Type{T}) where {T<:BMat8} = FroidurePinBMat8

"""
    _wrap_element(::Type{E}, raw) -> E

Wrap a raw CxxWrap element back into the high-level Julia type.
"""
_wrap_element(::Type{Transf{T}}, raw) where {T} = Transf{T}(raw)
_wrap_element(::Type{PPerm{T}}, raw) where {T} = PPerm{T}(raw)
_wrap_element(::Type{Perm{T}}, raw) where {T} = Perm{T}(raw)
_wrap_element(::Type{T}, raw) where {T<:BMat8} = raw  # BMat8 is a direct alias

"""
    _cxx_element(x) -> CxxWrap object

Extract the CxxWrap object from a high-level Julia element.
"""
_cxx_element(x::Transf) = x.cxx_obj
_cxx_element(x::PPerm) = x.cxx_obj
_cxx_element(x::Perm) = x.cxx_obj
_cxx_element(x::BMat8) = x  # BMat8 is a direct alias

"""
    _fp_element_type(::Type{E}) -> Type

Normalize element type for the FroidurePin{E} type parameter.
CxxWrap creates BMat8Allocated as a subtype of BMat8; we normalize
to BMat8 so that FroidurePin{BMat8} is the canonical type.
"""
_fp_element_type(::Type{E}) where {E} = E
_fp_element_type(::Type{T}) where {T<:BMat8} = BMat8

# ============================================================================
# FroidurePin{E} mutable struct
# ============================================================================

"""
    FroidurePin{E}

A Froidure-Pin semigroup over elements of type `E`.

The Froidure-Pin algorithm is used to enumerate all elements of a finitely
generated semigroup. This type wraps the C++ `FroidurePin<E>` class from
libsemigroups.

Supported element types:
- `Transf{UInt8}`, `Transf{UInt16}`, `Transf{UInt32}` (transformations)
- `PPerm{UInt8}`, `PPerm{UInt16}`, `PPerm{UInt32}` (partial permutations)
- `Perm{UInt8}`, `Perm{UInt16}`, `Perm{UInt32}` (permutations)
- `BMat8` (boolean matrices up to 8x8)

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6 (S_3)
```
"""
mutable struct FroidurePin{E}
    cxx_obj::_FroidurePinCxx
end

# ============================================================================
# Constructors
# ============================================================================

"""
    FroidurePin(gens::Vector{E}) where {E}

Construct a `FroidurePin{E}` from a vector of generators.

# Example
```julia
using Semigroups

S = FroidurePin([Transf([2, 1, 3]), Transf([2, 3, 1])])
length(S)  # 6
```
"""
function FroidurePin(gens::Vector{E}) where {E}
    isempty(gens) && error("At least one generator is required")

    # Normalize element type (BMat8Allocated -> BMat8)
    NE = _fp_element_type(E)

    FPType = _cxx_fp_type(NE)
    cxx_gens = [_cxx_element(g) for g in gens]

    n = length(cxx_gens)
    if n == 1
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1])
    elseif n == 2
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1], cxx_gens[2])
    elseif n == 3
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1], cxx_gens[2], cxx_gens[3])
    elseif n == 4
        cxx_obj = @wrap_libsemigroups_call FPType(
            cxx_gens[1],
            cxx_gens[2],
            cxx_gens[3],
            cxx_gens[4],
        )
    else
        # >4 generators: construct with first, then add the rest
        cxx_obj = @wrap_libsemigroups_call FPType(cxx_gens[1])
        for i in 2:n
            @wrap_libsemigroups_call LibSemigroups.add_generator!(cxx_obj, cxx_gens[i])
        end
    end

    return FroidurePin{NE}(cxx_obj)
end

"""
    FroidurePin(x::E, xs::E...) where {E}

Construct a `FroidurePin{E}` from one or more generators (variadic).

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6
```
"""
function FroidurePin(x::E, xs::E...) where {E}
    return FroidurePin(E[x, xs...])
end

# ============================================================================
# Size queries
# ============================================================================

"""
    Base.length(fp::FroidurePin) -> Int

Return the total number of elements in the semigroup.

Triggers full enumeration if not already complete.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
length(S)  # 6
```
"""
Base.length(fp::FroidurePin) = Int(LibSemigroups.size(fp.cxx_obj))

"""
    current_size(fp::FroidurePin) -> Int

Return the number of elements enumerated so far (without triggering
further enumeration).

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
current_size(S)  # 2 (only generators known)
```
"""
current_size(fp::FroidurePin) = Int(LibSemigroups.current_size(fp.cxx_obj))

"""
    degree(fp::FroidurePin) -> Int

Return the degree of the elements in the semigroup.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
degree(S)  # 3
```
"""
degree(fp::FroidurePin) = Int(LibSemigroups.degree(fp.cxx_obj))

"""
    number_of_generators(fp::FroidurePin) -> Int

Return the number of generators of the semigroup.

# Example
```julia
using Semigroups

S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
number_of_generators(S)  # 2
```
"""
number_of_generators(fp::FroidurePin) = Int(LibSemigroups.number_of_generators(fp.cxx_obj))

"""
    enumerate!(fp::FroidurePin, limit::Integer)

Enumerate elements until at least `limit` elements have been found.

This partially enumerates the semigroup. After calling this, `current_size`
will be at least `min(limit, length(fp))`.
"""
function enumerate!(fp::FroidurePin, limit::Integer)
    @wrap_libsemigroups_call LibSemigroups.enumerate!(fp.cxx_obj, UInt(limit))
    return fp
end

# ============================================================================
# Runner delegation
# ============================================================================
# Every public Runner method is delegated through fp.cxx_obj.
# Mutating methods return fp for chaining; query methods return the result.

"""
    run!(fp::FroidurePin) -> FroidurePin

Run the Froidure-Pin algorithm until [`finished`](@ref).

Returns `fp` for method chaining.
"""
function run!(fp::FroidurePin)
    LibSemigroups.run!(fp.cxx_obj)
    return fp
end

"""
    run_for!(fp::FroidurePin, t::TimePeriod) -> FroidurePin

Run the Froidure-Pin algorithm for a specified amount of time.

Returns `fp` for method chaining.

# Examples
```julia
run_for!(S, Second(1))
run_for!(S, Millisecond(500))
```
"""
function run_for!(fp::FroidurePin, t::TimePeriod)
    ns = convert(Nanosecond, t)
    Dates.value(ns) >= 0 ||
        throw(ArgumentError("run_for! requires a non-negative duration, got $t"))
    LibSemigroups.run_for!(fp.cxx_obj, Int64(Dates.value(ns)))
    return fp
end

function run_until!(f::Function, fp::FroidurePin)
    sf = @safe_cfunction($f, Cuchar, ())
    GC.@preserve sf LibSemigroups.run_until!(fp.cxx_obj, sf)
    return fp
end

"""
    run_until!(fp::FroidurePin, f::Function) -> FroidurePin

Run the Froidure-Pin algorithm until a nullary predicate returns `true`
or [`finished`](@ref).

Returns `fp` for method chaining.

Supports do-block syntax:

```julia
run_until!(S) do
    some_condition(S)
end
```
"""
run_until!(fp::FroidurePin, f::Function) = run_until!(f, fp)

"""
    init!(fp::FroidurePin) -> FroidurePin

Initialize an existing FroidurePin object, resetting it to its default state.

Returns `fp` for method chaining.
"""
function init!(fp::FroidurePin)
    LibSemigroups.init!(fp.cxx_obj)
    return fp
end

"""
    kill!(fp::FroidurePin)

Stop the Froidure-Pin algorithm from running (thread-safe).
"""
kill!(fp::FroidurePin) = LibSemigroups.kill!(fp.cxx_obj)

"""
    finished(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm has been run to completion.
"""
finished(fp::FroidurePin) = LibSemigroups.finished(fp.cxx_obj)

"""
    Base.success(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm has been run to completion successfully.
"""
Base.success(fp::FroidurePin) = LibSemigroups.success(fp.cxx_obj)

"""
    started(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm has been started.
"""
started(fp::FroidurePin) = LibSemigroups.started(fp.cxx_obj)

"""
    running(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm is currently running.
"""
running(fp::FroidurePin) = LibSemigroups.running(fp.cxx_obj)

"""
    timed_out(fp::FroidurePin) -> Bool

Check if the last `run_for!` call timed out.
"""
timed_out(fp::FroidurePin) = LibSemigroups.timed_out(fp.cxx_obj)

"""
    stopped(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm is stopped for any reason.
"""
stopped(fp::FroidurePin) = LibSemigroups.stopped(fp.cxx_obj)

"""
    dead(fp::FroidurePin) -> Bool

Check if the Froidure-Pin algorithm has been killed by another thread.
"""
dead(fp::FroidurePin) = LibSemigroups.dead(fp.cxx_obj)

"""
    stopped_by_predicate(fp::FroidurePin) -> Bool

Check if the algorithm was stopped by the predicate passed to `run_until!`.
"""
stopped_by_predicate(fp::FroidurePin) = LibSemigroups.stopped_by_predicate(fp.cxx_obj)

"""
    running_for(fp::FroidurePin) -> Bool

Check if the algorithm is currently running for a particular length of time.
"""
running_for(fp::FroidurePin) = LibSemigroups.running_for(fp.cxx_obj)

"""
    running_for_how_long(fp::FroidurePin) -> Nanosecond

Return the duration of the most recent `run_for!` call as a `Dates.Nanosecond`.
"""
running_for_how_long(fp::FroidurePin) = Nanosecond(LibSemigroups.running_for_how_long(fp.cxx_obj))

"""
    running_until(fp::FroidurePin) -> Bool

Check if the algorithm is currently running until a predicate returns `true`.
"""
running_until(fp::FroidurePin) = LibSemigroups.running_until(fp.cxx_obj)

"""
    current_state(fp::FroidurePin) -> RunnerState

Return the current state of the Froidure-Pin algorithm.
"""
current_state(fp::FroidurePin) = LibSemigroups.current_state(fp.cxx_obj)

"""
    report_why_we_stopped(fp::FroidurePin)

Report why the Froidure-Pin algorithm stopped.
"""
report_why_we_stopped(fp::FroidurePin) = LibSemigroups.report_why_we_stopped(fp.cxx_obj)

"""
    string_why_we_stopped(fp::FroidurePin) -> String

Return a human-readable string describing why the algorithm stopped.
"""
string_why_we_stopped(fp::FroidurePin) = LibSemigroups.string_why_we_stopped(fp.cxx_obj)

# ============================================================================
# Element access
# ============================================================================

"""
    Base.getindex(fp::FroidurePin{E}, i::Integer) -> E

Return the `i`-th element of the semigroup (1-based indexing).

Triggers full enumeration if not already complete.

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
S[1]  # first element
```

# Throws
- `BoundsError` if `i` is out of range.
"""
function Base.getindex(fp::FroidurePin{E}, i::Integer) where {E}
    if i < 1 || i > length(fp)
        throw(BoundsError(fp, i))
    end
    idx = _to_cpp(i, UInt)
    raw = @wrap_libsemigroups_call LibSemigroups.at(fp.cxx_obj, idx)
    return _wrap_element(E, raw)
end

"""
    generator(fp::FroidurePin{E}, i::Integer) -> E

Return the `i`-th generator of the semigroup (1-based indexing).

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
generator(S, 1)  # first generator
```
"""
function generator(fp::FroidurePin{E}, i::Integer) where {E}
    idx = _to_cpp(i, UInt)
    raw = @wrap_libsemigroups_call LibSemigroups.generator(fp.cxx_obj, idx)
    return _wrap_element(E, raw)
end

"""
    sorted_at(fp::FroidurePin{E}, i::Integer) -> E

Return the `i`-th element in sorted order (1-based indexing).

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
sorted_at(S, 1)  # first element in sorted order
```
"""
function sorted_at(fp::FroidurePin{E}, i::Integer) where {E}
    idx = _to_cpp(i, UInt)
    raw = @wrap_libsemigroups_call LibSemigroups.sorted_at(fp.cxx_obj, idx)
    return _wrap_element(E, raw)
end

# ============================================================================
# Iteration
# ============================================================================

"""
    Base.iterate(fp::FroidurePin, state=1)

Iterate over all elements of the semigroup.

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
for x in S
    println(x)
end
elts = collect(S)  # Vector{Transf{UInt8}} of length 6
```
"""
function Base.iterate(fp::FroidurePin, state::Int = 1)
    if state > length(fp)
        return nothing
    end
    return (fp[state], state + 1)
end

"""
    Base.eltype(::Type{FroidurePin{E}}) where E

Return the element type `E` of a `FroidurePin{E}`.
"""
Base.eltype(::Type{FroidurePin{E}}) where {E} = E

Base.IteratorSize(::Type{<:FroidurePin}) = Base.HasLength()

# ============================================================================
# Copy
# ============================================================================

"""
    Base.copy(fp::FroidurePin{E}) -> FroidurePin{E}

Create an independent copy of the semigroup by reconstructing it from
its generators.
"""
function Base.copy(fp::FroidurePin{E}) where {E}
    gens = [generator(fp, i) for i in 1:number_of_generators(fp)]
    return FroidurePin(gens)
end

# ============================================================================
# Display
# ============================================================================

"""
    Base.show(io::IO, fp::FroidurePin)

Display a human-readable representation of the semigroup.
"""
function Base.show(io::IO, fp::FroidurePin)
    print(io, @wrap_libsemigroups_call LibSemigroups.to_human_readable_repr(fp.cxx_obj))
end

# ============================================================================
# Containment
# ============================================================================

"""
    Base.in(x::E, fp::FroidurePin{E}) where E -> Bool

Check whether the element `x` belongs to the semigroup `fp`.

Triggers full enumeration if not already complete.

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
Transf([2, 1, 3]) in S   # true
Transf([1, 1, 1]) in S   # false
```
"""
function Base.in(x::E, fp::FroidurePin{E}) where {E}
    cxx_x = _cxx_element(x)
    return @wrap_libsemigroups_call LibSemigroups.contains(fp.cxx_obj, cxx_x)
end

# BMat8 dispatch: BMat8Allocated <: BMat8, so we need a fallback
function Base.in(x::BMat8, fp::FroidurePin{BMat8})
    cxx_x = _cxx_element(x)
    return @wrap_libsemigroups_call LibSemigroups.contains(fp.cxx_obj, cxx_x)
end

"""
    position(fp::FroidurePin{E}, x::E) where E -> Int

Return the 1-based position of element `x` in the semigroup `fp`.

Triggers full enumeration if not already complete.

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]), Transf([2, 3, 1]))
position(S, Transf([2, 1, 3]))  # 1-based index
```
"""
function position(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    raw = @wrap_libsemigroups_call LibSemigroups.position(fp.cxx_obj, cxx_x)
    return _from_cpp(raw)
end

function position(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    raw = @wrap_libsemigroups_call LibSemigroups.position(fp.cxx_obj, cxx_x)
    return _from_cpp(raw)
end

"""
    sorted_position(fp::FroidurePin{E}, x::E) where E -> Int

Return the 1-based sorted position of element `x` in the semigroup `fp`.

Triggers full enumeration if not already complete.
"""
function sorted_position(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    raw = @wrap_libsemigroups_call LibSemigroups.sorted_position(fp.cxx_obj, cxx_x)
    return _from_cpp(raw)
end

function sorted_position(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    raw = @wrap_libsemigroups_call LibSemigroups.sorted_position(fp.cxx_obj, cxx_x)
    return _from_cpp(raw)
end

"""
    to_sorted_position(fp::FroidurePin, i::Integer) -> Int

Convert a 1-based element position to its 1-based sorted position.

Triggers full enumeration if not already complete.
"""
function to_sorted_position(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt)
    raw = @wrap_libsemigroups_call LibSemigroups.to_sorted_position(fp.cxx_obj, idx)
    return _from_cpp(raw)
end

# ============================================================================
# Modification
# ============================================================================

"""
    Base.push!(fp::FroidurePin{E}, x::E) where E -> FroidurePin{E}

Add a new generator `x` to the semigroup `fp`.

Returns `fp` for method chaining.

# Example
```julia
S = FroidurePin(Transf([2, 1, 3]))
push!(S, Transf([2, 3, 1]))
length(S)  # 6
```
"""
function Base.push!(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    @wrap_libsemigroups_call LibSemigroups.add_generator!(fp.cxx_obj, cxx_x)
    return fp
end

function Base.push!(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    @wrap_libsemigroups_call LibSemigroups.add_generator!(fp.cxx_obj, cxx_x)
    return fp
end

"""
    closure!(fp::FroidurePin{E}, x::E) where E -> FroidurePin{E}

Add element `x` to the semigroup `fp` if it is not already contained,
and re-enumerate.

Returns `fp` for method chaining.
"""
function closure!(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    @wrap_libsemigroups_call LibSemigroups.closure!(fp.cxx_obj, cxx_x)
    return fp
end

function closure!(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    @wrap_libsemigroups_call LibSemigroups.closure!(fp.cxx_obj, cxx_x)
    return fp
end

"""
    copy_closure(fp::FroidurePin{E}, x::E) where E -> FroidurePin{E}

Return a new `FroidurePin{E}` that is a copy of `fp` with element `x`
added as a generator (if not already contained), and re-enumerated.
"""
function copy_closure(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    new_cxx = @wrap_libsemigroups_call LibSemigroups.copy_closure(fp.cxx_obj, cxx_x)
    return FroidurePin{E}(new_cxx)
end

function copy_closure(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    new_cxx = @wrap_libsemigroups_call LibSemigroups.copy_closure(fp.cxx_obj, cxx_x)
    return FroidurePin{BMat8}(new_cxx)
end

"""
    copy_add_generators(fp::FroidurePin{E}, x::E) where E -> FroidurePin{E}

Return a new `FroidurePin{E}` that is a copy of `fp` with element `x`
added as a generator (without checking containment).
"""
function copy_add_generators(fp::FroidurePin{E}, x::E) where {E}
    cxx_x = _cxx_element(x)
    new_cxx = @wrap_libsemigroups_call LibSemigroups.copy_add_generators(fp.cxx_obj, cxx_x)
    return FroidurePin{E}(new_cxx)
end

function copy_add_generators(fp::FroidurePin{BMat8}, x::BMat8)
    cxx_x = _cxx_element(x)
    new_cxx = @wrap_libsemigroups_call LibSemigroups.copy_add_generators(fp.cxx_obj, cxx_x)
    return FroidurePin{BMat8}(new_cxx)
end

# ============================================================================
# Settings
# ============================================================================

"""
    batch_size(fp::FroidurePin) -> Int

Return the current batch size used for partial enumeration.
"""
batch_size(fp::FroidurePin) = Int(LibSemigroups.batch_size(fp.cxx_obj))

"""
    set_batch_size!(fp::FroidurePin, n::Integer) -> FroidurePin

Set the batch size for partial enumeration.

Returns `fp` for method chaining.
"""
function set_batch_size!(fp::FroidurePin, n::Integer)
    LibSemigroups.set_batch_size!(fp.cxx_obj, UInt(n))
    return fp
end

# ============================================================================
# Predicates
# ============================================================================

"""
    contains_one(fp::FroidurePin) -> Bool

Check whether the semigroup contains the identity element.

Triggers full enumeration if not already complete.
"""
contains_one(fp::FroidurePin) = LibSemigroups.contains_one(fp.cxx_obj)

"""
    is_idempotent(fp::FroidurePin, i::Integer) -> Bool

Check whether the element at 1-based position `i` is an idempotent
(i.e., `x * x == x`).

Triggers full enumeration if not already complete.
"""
function is_idempotent(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt)
    return @wrap_libsemigroups_call LibSemigroups.is_idempotent(fp.cxx_obj, idx)
end

# ============================================================================
# Index queries (FroidurePinBase methods — uint32_t positions)
# ============================================================================

"""
    prefix(fp::FroidurePin, i::Integer) -> Int

Return the 1-based position of the prefix of the element at 1-based
position `i`. The prefix is the element obtained by removing the last
letter of the factorisation.
"""
function prefix(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt32)
    raw = @wrap_libsemigroups_call LibSemigroups.prefix(fp.cxx_obj, idx)
    return _from_cpp(raw)
end

"""
    suffix(fp::FroidurePin, i::Integer) -> Int

Return the 1-based position of the suffix of the element at 1-based
position `i`. The suffix is the element obtained by removing the first
letter of the factorisation.
"""
function suffix(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt32)
    raw = @wrap_libsemigroups_call LibSemigroups.suffix(fp.cxx_obj, idx)
    return _from_cpp(raw)
end

"""
    first_letter(fp::FroidurePin, i::Integer) -> Int

Return the 1-based position of the first letter (generator) in the
factorisation of the element at 1-based position `i`.
"""
function first_letter(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt32)
    raw = @wrap_libsemigroups_call LibSemigroups.first_letter(fp.cxx_obj, idx)
    return _from_cpp(raw)
end

"""
    final_letter(fp::FroidurePin, i::Integer) -> Int

Return the 1-based position of the final letter (generator) in the
factorisation of the element at 1-based position `i`.
"""
function final_letter(fp::FroidurePin, i::Integer)
    idx = _to_cpp(i, UInt32)
    raw = @wrap_libsemigroups_call LibSemigroups.final_letter(fp.cxx_obj, idx)
    return _from_cpp(raw)
end

"""
    fast_product(fp::FroidurePin, i::Integer, j::Integer) -> Int

Return the 1-based position of the product of the elements at 1-based
positions `i` and `j`.

The semigroup must be fully enumerated before calling this method.
"""
function fast_product(fp::FroidurePin, i::Integer, j::Integer)
    ci = _to_cpp(i, UInt)
    cj = _to_cpp(j, UInt)
    raw = @wrap_libsemigroups_call LibSemigroups.fast_product(fp.cxx_obj, ci, cj)
    return _from_cpp(raw)
end

"""
    number_of_rules(fp::FroidurePin) -> Int

Return the total number of rules (relations) in the semigroup.

Triggers full enumeration if not already complete.
"""
number_of_rules(fp::FroidurePin) = Int(LibSemigroups.number_of_rules(fp.cxx_obj))

"""
    number_of_idempotents(fp::FroidurePin) -> Int

Return the total number of idempotent elements in the semigroup.

Triggers full enumeration if not already complete.
"""
number_of_idempotents(fp::FroidurePin) = Int(LibSemigroups.number_of_idempotents(fp.cxx_obj))
