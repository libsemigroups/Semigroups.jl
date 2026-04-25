# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
cong-common.jl - shared CongruenceCommon helper wrappers
"""

const CongruenceCommon = LibSemigroups.CongruenceCommon

# ============================================================================
# Private helpers
# ============================================================================

_words_to_cpp(words::AbstractVector{<:AbstractVector{<:Integer}}) =
    Any[_word_to_cpp(word) for word in words]

# ============================================================================
# Word operations - 1-based boundary
# ============================================================================

"""
    reduce(cong::CongruenceCommon, w::AbstractVector{<:Integer}) -> Vector{Int}

Reduce a word using the congruence. This may trigger a full run.

Words are given as 1-based `Vector{Int}` letter indices. The returned
word is also 1-based.
"""
function reduce(cong::CongruenceCommon, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    result = @wrap_libsemigroups_call LibSemigroups.cong_common_reduce(cong, cpp_w)
    return _word_from_cpp(result)
end

"""
    reduce_no_run(cong::CongruenceCommon, w::AbstractVector{<:Integer}) -> Vector{Int}

Reduce a word using only the current congruence data, without forcing a full run.

Words are given as 1-based `Vector{Int}` letter indices.
"""
function reduce_no_run(cong::CongruenceCommon, w::AbstractVector{<:Integer})
    cpp_w = _word_to_cpp(w)
    result = @wrap_libsemigroups_call LibSemigroups.cong_common_reduce_no_run(cong, cpp_w)
    return _word_from_cpp(result)
end

"""
    contains(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> Bool

Check if two words are equivalent under the congruence. This may trigger a full run.

Words are given as 1-based `Vector{Int}` letter indices.
"""
function contains(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    cpp_u = _word_to_cpp(u)
    cpp_v = _word_to_cpp(v)
    return @wrap_libsemigroups_call LibSemigroups.cong_common_contains(cong, cpp_u, cpp_v)
end

"""
    currently_contains(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> tril

Check if two words are known to be equivalent without forcing a full run.

Returns a [`tril`](@ref) value: `tril_TRUE`, `tril_FALSE`, or `tril_unknown`.
Words are given as 1-based `Vector{Int}` letter indices.
"""
function currently_contains(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    cpp_u = _word_to_cpp(u)
    cpp_v = _word_to_cpp(v)
    return @wrap_libsemigroups_call LibSemigroups.cong_common_currently_contains(
        cong,
        cpp_u,
        cpp_v,
    )
end

"""
    add_generating_pair!(cong::CongruenceCommon, u::AbstractVector{<:Integer}, v::AbstractVector{<:Integer}) -> CongruenceCommon

Add a generating pair to the congruence.

Words are given as 1-based `Vector{Int}` letter indices.
"""
function add_generating_pair!(
    cong::CongruenceCommon,
    u::AbstractVector{<:Integer},
    v::AbstractVector{<:Integer},
)
    cpp_u = _word_to_cpp(u)
    cpp_v = _word_to_cpp(v)
    @wrap_libsemigroups_call LibSemigroups.cong_common_add_generating_pair!(
        cong,
        cpp_u,
        cpp_v,
    )
    return cong
end

"""
    normal_forms(cong::CongruenceCommon) -> Vector{Vector{Int}}

Return all normal forms as 1-based words.
"""
function normal_forms(cong::CongruenceCommon)
    nf = @wrap_libsemigroups_call LibSemigroups.cong_common_normal_forms(cong)
    return [_word_from_cpp(w) for w in nf]
end

"""
    partition(cong::CongruenceCommon, words::AbstractVector{<:AbstractVector{<:Integer}}) -> Vector{Vector{Vector{Int}}}

Partition `words` into congruence classes.

This function returns the partition of the input words induced by `cong`.
Words are given and returned as 1-based `Vector{Int}` letter indices.
Calling this function may trigger a full run of `cong`.
"""
function partition(cong::CongruenceCommon, words::AbstractVector{<:AbstractVector{<:Integer}})
    classes = @wrap_libsemigroups_call LibSemigroups.cong_common_partition(
        cong,
        _words_to_cpp(words),
    )
    return [[_word_from_cpp(word) for word in cls] for cls in classes]
end

"""
    non_trivial_classes(x::CongruenceCommon, y::CongruenceCommon) -> Vector{Vector{Vector{Int}}}

Return the non-trivial classes as nested vectors of 1-based words.
"""
function non_trivial_classes(x::CongruenceCommon, y::CongruenceCommon)
    classes = @wrap_libsemigroups_call LibSemigroups.cong_common_non_trivial_classes(x, y)
    return [[_word_from_cpp(w) for w in cls] for cls in classes]
end
