# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.

"""
presentation.jl - Presentation{W} + InversePresentation wrappers

Provides a parametric `Presentation{W}` type wrapping the CxxWrap-bound
C++ `Presentation<W>` template instantiations (`Vector{Int}` or `String`).
Follows the same three-layer pattern as `froidure-pin.jl`: CxxWrap type aliases,
union type, private helpers, mutable struct, constructors, and method wrappers.
"""

# ============================================================================
# CxxWrap type aliases — concrete Presentation<W> instantiations
# ============================================================================

const PresentationWord = LibSemigroups.PresentationWord
const PresentationString = LibSemigroups.PresentationString

# ============================================================================
# Union type for cxx_obj field
# ============================================================================

const _PresentationCxx = Union{PresentationWord,PresentationString}

# ============================================================================
# Presentation{W} mutable struct
# ============================================================================

"""
    Presentation{W}

Type for semigroup or monoid presentations.

This type provides a shallow wrapper around a vector of words (the *rules*
of the presentation), together with an *alphabet*. It is intended to be
used as the input to other algorithms in `libsemigroups` (such as
the Knuth-Bendix, Todd-Coxeter, and Kambites algorithms).

In a valid presentation, rules only consist of letters from within the
alphabet; however, for performance reasons, it is possible to update both
the rules and the alphabet independently of each other. For this reason,
it is possible for the alphabet and the rules to become out of sync.
[`Presentation`](@ref Semigroups.Presentation) provides some checks that
the rules define a valid presentation, and some related helper functions
live as module-level functions in `Semigroups`.

The zero-argument form constructs an empty presentation with no rules and
no alphabet; the one-argument form copies `other`.
"""
mutable struct Presentation{W}
    cxx_obj::_PresentationCxx
end

# ============================================================================
# Private helpers
# ============================================================================

"""
    _cxx_presentation_type(::Type{W}) -> Type

Map a high-level Julia word type to its CxxWrap Presentation constructor type.
"""
_cxx_presentation_type(::Type{Vector{Int}}) = PresentationWord
_cxx_presentation_type(::Type{String}) = PresentationString

_presentation_word_to_cpp(::Type{Vector{Int}}, w::AbstractVector{<:Integer}) =
    _word_to_cpp(w)
_presentation_word_to_cpp(::Type{String}, w::AbstractString) = String(w)
_presentation_word_to_cpp(::Type{String}, w::AbstractVector{<:AbstractString}) = join(w)
_presentation_word_to_cpp(::Type{String}, w::AbstractVector{Char}) = String(w)

_presentation_word_from_cpp(::Type{Vector{Int}}, w) = _word_from_cpp(w)
_presentation_word_from_cpp(::Type{String}, w) = String(w)

_presentation_letter_to_cpp(::Type{Vector{Int}}, x::Integer) = _letter_to_cpp(x)
# In src/presentation.jl:
_presentation_letter_to_cpp(::Type{String}, x::Char) = UInt(x)
_presentation_letter_from_cpp(::Type{Vector{Int}}, x) = _letter_from_cpp(x)
_presentation_letter_from_cpp(::Type{String}, x) = Char(x)

# ============================================================================
# Wrap / unwrap helpers
# ============================================================================

const _CxxRefs{T} =
    Union{T,CxxWrap.CxxWrapCore.ConstCxxRef{<:T},CxxWrap.CxxWrapCore.CxxRef{<:T}}

# Always copy via the C++ copy constructor: presentation(kb) and friends
# return a reference into kb, which must not be aliased by a Julia object.
_wrap_presentation(x::PresentationWord) = Presentation{Vector{Int}}(x)
_wrap_presentation(x::PresentationString) = Presentation{String}(x)
_wrap_presentation(x::Presentation) = x

_cxx(p::Presentation) = p.cxx_obj

# Presentations accepted by algorithms that are only bound for word_type.
function _cxx_word(p::Presentation{W}) where {W}
    W === Vector{Int} || throw(
        ArgumentError(
            "this algorithm is only available for Presentation{Vector{Int}}; " *
            "got Presentation{$W}.",
        ),
    )
    return p.cxx_obj
end

# ============================================================================
# Constructors
# ============================================================================

function Presentation{W}() where {W}
    T = _cxx_presentation_type(W)
    return Presentation{W}(@wrap_libsemigroups_call T())
end

Presentation() = Presentation{Vector{Int}}()

function Presentation(p::Presentation{W}) where {W}
    T = _cxx_presentation_type(W)
    return Presentation{W}(@wrap_libsemigroups_call T(p.cxx_obj))
end

"""
    Presentation(rules::AbstractVector{<:Union{Tuple{W,W}, Pair{W,W}}}) where {W<:Union{Vector{Int}, String}}

Construct a [`Presentation{W}`](@ref Semigroups.Presentation) from a vector
of rules (given as `(lhs, rhs)` tuples or `lhs => rhs` pairs), inferring the alphabet
from the letters present in the rules.
"""
function Presentation(
    rules::AbstractVector{<:Union{Tuple{W,W},Pair{W,W}}},
) where {W<:Union{Vector{Int},String}}
    p = Presentation{W}()
    for (lhs, rhs) in rules
        add_rule_no_checks!(p, lhs, rhs)
    end
    alphabet_from_rules!(p)
    return p
end

"""
    Presentation(alphabet)

Construct an empty [`Presentation{W}`](@ref Semigroups.Presentation) with an initial
alphabet defined by `alphabet`.
"""
function Presentation(alphabet::Union{Vector{Int},String,Vector{String},Vector{Char}})
    if alphabet isa Vector{String}
        p = Presentation{String}()
        set_alphabet!(p, join(alphabet))
        return p
    end
    W = (alphabet isa String || eltype(alphabet) === Char) ? String : Vector{Int}
    p = Presentation{W}()
    set_alphabet!(p, alphabet)
    return p
end

# ============================================================================
# Core presentation methods
# ============================================================================

"""
    init!(p::Presentation{W}) -> Presentation

Remove the alphabet and all rules from `p`.

This function clears the alphabet and all rules of `p`, putting it back
into the state it would be in if it was newly constructed.
"""
init!(p::Presentation{W}) where {W} = (LibSemigroups.init!(p.cxx_obj); p)

"""
    alphabet(p::Presentation{W}) -> Vector{Int}

Return the alphabet of `p`.

# Complexity
Constant.
"""
alphabet(p::Presentation{W}) where {W} =
    _presentation_word_from_cpp(W, LibSemigroups.alphabet(p.cxx_obj))

Base.deepcopy_internal(p::Presentation{W}, ::IdDict) where {W} = Presentation(p)

"""
    set_alphabet!(p::Presentation{W}, n::Integer) -> Presentation

Set the alphabet of `p` by size.
"""
function set_alphabet!(p::Presentation{W}, n::Integer) where {W}
    m = UInt(n)
    @wrap_libsemigroups_call LibSemigroups.set_alphabet_size!(p.cxx_obj, m)
    return p
end

"""
    set_alphabet!(p::Presentation{W}, a) -> Presentation

Set the alphabet of `p` to the letters in `a`.
"""
function set_alphabet!(p::Presentation{W}, a) where {W}
    w = _presentation_word_to_cpp(W, a)
    @wrap_libsemigroups_call LibSemigroups.set_alphabet!(p.cxx_obj, w)
    return p
end

"""
    alphabet_from_rules!(p::Presentation{W}) -> Presentation

Set the alphabet of `p` to be the letters that appear in its rules.
"""
alphabet_from_rules!(p::Presentation{W}) where {W} =
    (LibSemigroups.alphabet_from_rules!(p.cxx_obj); p)

"""
    letter(p::Presentation{W}, i::Integer)

Return a letter in the alphabet of `p` by index.
"""
function letter(p::Presentation{W}, i::Integer) where {W}
    idx = UInt(i - 1)
    _presentation_letter_from_cpp(
        W,
        @wrap_libsemigroups_call LibSemigroups.letter(p.cxx_obj, idx)
    )
end

"""
    index_of(p::Presentation{W}, x) -> Int

Return the 1-based index of a letter in the alphabet of `p`.
"""
function index_of(p::Presentation{W}, x) where {W}
    y = _presentation_letter_to_cpp(W, x)
    Int(@wrap_libsemigroups_call LibSemigroups.index_of(p.cxx_obj, y)) + 1
end

"""
    in_alphabet(p::Presentation{W}, x) -> Bool

Check if a letter belongs to the alphabet of `p`.
"""
in_alphabet(p::Presentation{W}, x) where {W} =
    LibSemigroups.in_alphabet(p.cxx_obj, _presentation_letter_to_cpp(W, x))

"""
    contains_empty_word(p::Presentation{W}) -> Bool

Return whether the empty word is a valid relation word in `p`.
"""
contains_empty_word(p::Presentation{W}) where {W} =
    LibSemigroups.contains_empty_word(p.cxx_obj)

"""
    set_contains_empty_word!(p::Presentation{W}, val::Bool) -> Presentation

Set whether the empty word is a valid relation word in `p`.
"""
set_contains_empty_word!(p::Presentation{W}, val::Bool) where {W} =
    (LibSemigroups.set_contains_empty_word!(p.cxx_obj, val); p)

"""
    add_generator!(p::Presentation{W})
    add_generator!(p::Presentation{W}, x) -> Presentation

Add a generator to `p`.
"""
function add_generator!(p::Presentation{W}) where {W}
    x = @wrap_libsemigroups_call LibSemigroups.add_generator_no_arg!(p.cxx_obj)
    return _presentation_letter_from_cpp(W, x)
end

function add_generator!(p::Presentation{W}, x) where {W}
    y = _presentation_letter_to_cpp(W, x)
    @wrap_libsemigroups_call LibSemigroups.add_generator!(p.cxx_obj, y)
    return p
end

"""
    remove_generator!(p::Presentation{W}, x) -> Presentation

Remove the letter `x` as a generator of `p`.
"""
function remove_generator!(p::Presentation{W}, x) where {W}
    y = _presentation_letter_to_cpp(W, x)
    @wrap_libsemigroups_call LibSemigroups.remove_generator!(p.cxx_obj, y)
    return p
end

"""
    add_rule!(p::Presentation{W}, lhs, rhs) -> Presentation

Add the rule `lhs = rhs` to `p`, after validation checks.
"""
function add_rule!(p::Presentation{W}, lhs, rhs) where {W}
    l = _presentation_word_to_cpp(W, lhs)
    r = _presentation_word_to_cpp(W, rhs)
    @wrap_libsemigroups_call LibSemigroups.add_rule!(p.cxx_obj, l, r)
    return p
end

"""
    add_rule_no_checks!(p::Presentation{W}, lhs, rhs) -> Presentation

Add the rule `lhs = rhs` to `p` without checking the arguments.
"""
function add_rule_no_checks!(p::Presentation{W}, lhs, rhs) where {W}
    l = _presentation_word_to_cpp(W, lhs)
    r = _presentation_word_to_cpp(W, rhs)
    LibSemigroups.add_rule_no_checks!(p.cxx_obj, l, r)
    return p
end

"""
    number_of_rules(p::Presentation{W}) -> Int

Return the number of rules in `p`.
"""
number_of_rules(p::Presentation{W}) where {W} =
    Int(LibSemigroups.number_of_rules(p.cxx_obj))

"""
    rule_lhs(p::Presentation{W}, i::Integer)

Return the left-hand side of the `i`-th rule of `p` (1-based rule index).
"""
function rule_lhs(p::Presentation{W}, i::Integer) where {W}
    idx = UInt(i - 1)
    _presentation_word_from_cpp(
        W,
        @wrap_libsemigroups_call LibSemigroups.rule_lhs(p.cxx_obj, idx)
    )
end

"""
    rule_rhs(p::Presentation{W}, i::Integer)

Return the right-hand side of the `i`-th rule of `p` (1-based rule index).
"""
function rule_rhs(p::Presentation{W}, i::Integer) where {W}
    idx = UInt(i - 1)
    _presentation_word_from_cpp(
        W,
        @wrap_libsemigroups_call LibSemigroups.rule_rhs(p.cxx_obj, idx)
    )
end

"""
    rule(p::Presentation{W}, i::Integer)

Return the `i`-th rule of `p` as a `(lhs, rhs)` tuple (1-based rule index).
"""
rule(p::Presentation{W}, i::Integer) where {W} = (rule_lhs(p, i), rule_rhs(p, i))

"""
    rules(p::Presentation{W})

Return all rules of `p` as a vector of `(lhs, rhs)` tuples.
"""
function rules(p::Presentation{W}) where {W}
    flat = LibSemigroups.rules_vector(p.cxx_obj)
    n = length(flat)
    return [
        (
            _presentation_word_from_cpp(W, flat[i]),
            _presentation_word_from_cpp(W, flat[i+1]),
        ) for i = 1:2:n
    ]
end

"""
    clear_rules!(p::Presentation{W}) -> Presentation

Remove all rules from `p`.
"""
clear_rules!(p::Presentation{W}) where {W} = (LibSemigroups.clear_rules!(p.cxx_obj); p)

# ============================================================================
# Validation guards
# ============================================================================

"""
    throw_if_alphabet_has_duplicates(p::Presentation{W})

Check if the alphabet of `p` is valid.
"""
throw_if_alphabet_has_duplicates(p::Presentation{W}) where {W} = (
    @wrap_libsemigroups_call LibSemigroups.throw_if_alphabet_has_duplicates(p.cxx_obj);
    nothing
)

"""
    throw_if_letter_not_in_alphabet(p::Presentation{W}, x)

Check if a letter belongs to the alphabet of `p`.
"""
function throw_if_letter_not_in_alphabet(p::Presentation{W}, x) where {W}
    y = _presentation_letter_to_cpp(W, x)
    @wrap_libsemigroups_call LibSemigroups.throw_if_letter_not_in_alphabet(p.cxx_obj, y)
    return nothing
end

"""
    throw_if_bad_rules(p::Presentation{W})

Check if every word in every rule of `p` consists only of letters belonging to the alphabet.
"""
throw_if_bad_rules(p::Presentation{W}) where {W} =
    (@wrap_libsemigroups_call LibSemigroups.throw_if_bad_rules(p.cxx_obj); nothing)

"""
    throw_if_bad_alphabet_or_rules(p::Presentation{W})

Check if the alphabet and rules of `p` are valid.
"""
throw_if_bad_alphabet_or_rules(p::Presentation{W}) where {W} = (
    @wrap_libsemigroups_call LibSemigroups.throw_if_bad_alphabet_or_rules(p.cxx_obj);
    nothing
)

# ============================================================================
# Algorithms & standalone helpers
# ============================================================================

"""
    length_of(p::Presentation{W}) -> Int

Return the sum of the lengths of all rule words in `p`.
"""
length_of(p::Presentation{W}) where {W} = Int(LibSemigroups.length_of(p.cxx_obj))

"""
    longest_rule_length(p::Presentation{W}) -> Int

Return the maximum length of a rule in `p`.
"""
longest_rule_length(p::Presentation{W}) where {W} =
    Int(LibSemigroups.longest_rule_length(p.cxx_obj))

"""
    shortest_rule_length(p::Presentation{W}) -> Int

Return the minimum length of a rule in `p`.
"""
shortest_rule_length(p::Presentation{W}) where {W} =
    Int(LibSemigroups.shortest_rule_length(p.cxx_obj))

"""
    is_normalized(p::Presentation{W}) -> Bool

Check if the presentation `p` is normalized.
"""
is_normalized(p::Presentation{W}) where {W} = LibSemigroups.is_normalized(p.cxx_obj)

"""
    are_rules_sorted(p::Presentation{W}) -> Bool

Check if the rules of `p` are sorted in short-lex order.
"""
are_rules_sorted(p::Presentation{W}) where {W} = LibSemigroups.are_rules_sorted(p.cxx_obj)

"""
    contains_rule(p::Presentation{W}, lhs, rhs) -> Bool

Check if `p` contains the rule `lhs = rhs`.
"""
function contains_rule(p::Presentation{W}, lhs, rhs) where {W}
    l = _presentation_word_to_cpp(W, lhs)
    r = _presentation_word_to_cpp(W, rhs)
    LibSemigroups.contains_rule(p.cxx_obj, l, r)
end

"""
    throw_if_odd_number_of_rules(p::Presentation{W})

Throw if the number of words in the rule list of `p` is odd.
"""
throw_if_odd_number_of_rules(p::Presentation{W}) where {W} = (
    @wrap_libsemigroups_call LibSemigroups.throw_if_odd_number_of_rules(p.cxx_obj);
    nothing
)

"""
    normalize_alphabet!(p::Presentation{W}) -> Presentation

Normalize the alphabet of `p`.
"""
normalize_alphabet!(p::Presentation{W}) where {W} =
    (@wrap_libsemigroups_call LibSemigroups.normalize_alphabet!(p.cxx_obj); p)

"""
    change_alphabet!(p::Presentation{W}, new_alphabet) -> Presentation

Change or re-order the alphabet of `p`.
"""
function change_alphabet!(p::Presentation{W}, new_alphabet) where {W}
    w = _presentation_word_to_cpp(W, new_alphabet)
    @wrap_libsemigroups_call LibSemigroups.change_alphabet!(p.cxx_obj, w)
    return p
end

Base.reverse!(p::Presentation{W}) where {W} = (LibSemigroups.reverse_rules!(p.cxx_obj); p)

"""
    sort_rules!(p::Presentation{W}) -> Presentation

Sort the rules of `p` in short-lex order.
"""
sort_rules!(p::Presentation{W}) where {W} = (LibSemigroups.sort_rules!(p.cxx_obj); p)

"""
    sort_each_rule!(p::Presentation{W}) -> Bool

Sort the two sides of each rule in short-lex order.
"""
sort_each_rule!(p::Presentation{W}) where {W} = LibSemigroups.sort_each_rule!(p.cxx_obj)

"""
    add_identity_rules!(p::Presentation{W}, e) -> Presentation

Add rules for an identity element.
"""
function add_identity_rules!(p::Presentation{W}, e) where {W}
    y = _presentation_letter_to_cpp(W, e)
    @wrap_libsemigroups_call LibSemigroups.add_identity_rules!(p.cxx_obj, y)
    return p
end

"""
    add_zero_rules!(p::Presentation{W}, z) -> Presentation

Add rules for a zero element.
"""
function add_zero_rules!(p::Presentation{W}, z) where {W}
    y = _presentation_letter_to_cpp(W, z)
    @wrap_libsemigroups_call LibSemigroups.add_zero_rules!(p.cxx_obj, y)
    return p
end

"""
    remove_duplicate_rules!(p::Presentation{W}) -> Presentation

Remove duplicate rules from `p`.
"""
remove_duplicate_rules!(p::Presentation{W}) where {W} =
    (LibSemigroups.remove_duplicate_rules!(p.cxx_obj); p)

"""
    remove_trivial_rules!(p::Presentation{W}) -> Presentation

Remove rules consisting of identical words.
"""
remove_trivial_rules!(p::Presentation{W}) where {W} =
    (LibSemigroups.remove_trivial_rules!(p.cxx_obj); p)

"""
    add_rules!(p::Presentation{W}, q::Presentation{W}) -> Presentation

Add the rules of `q` to `p`.
"""
function add_rules!(p::Presentation{W}, q::Presentation{W}) where {W}
    @wrap_libsemigroups_call LibSemigroups.add_rules!(p.cxx_obj, q.cxx_obj)
    return p
end

"""
    add_inverse_rules!(p::Presentation{W}, inverses) -> Presentation
    add_inverse_rules!(p::Presentation{W}, inverses, e) -> Presentation

Add rules for inverses.
"""
function add_inverse_rules!(p::Presentation{W}, inverses) where {W}
    v = _presentation_word_to_cpp(W, inverses)
    @wrap_libsemigroups_call LibSemigroups.add_inverse_rules!(p.cxx_obj, v)
    return p
end

function add_inverse_rules!(p::Presentation{W}, inverses, e) where {W}
    v = _presentation_word_to_cpp(W, inverses)
    y = _presentation_letter_to_cpp(W, e)
    @wrap_libsemigroups_call LibSemigroups.add_inverse_rules_with_identity!(p.cxx_obj, v, y)
    return p
end

"""
    replace_subword!(p::Presentation{W}, existing, replacement) -> Presentation

Replace every non-overlapping occurrence of `existing` with `replacement`.
"""
function replace_subword!(p::Presentation{W}, existing, replacement) where {W}
    e = _presentation_word_to_cpp(W, existing)
    r = _presentation_word_to_cpp(W, replacement)
    @wrap_libsemigroups_call LibSemigroups.replace_subword!(p.cxx_obj, e, r)
    return p
end

"""
    replace_word!(p::Presentation{W}, existing, replacement) -> Presentation

Replace full-side instances of `existing` with `replacement`.
"""
function replace_word!(p::Presentation{W}, existing, replacement) where {W}
    e = _presentation_word_to_cpp(W, existing)
    r = _presentation_word_to_cpp(W, replacement)
    @wrap_libsemigroups_call LibSemigroups.replace_word!(p.cxx_obj, e, r)
    return p
end

"""
    replace_word_with_new_generator!(p::Presentation{W}, w)

Replace occurrences of `w` with a new generator `z` and add rule `w = z`.
"""
function replace_word_with_new_generator!(p::Presentation{W}, w) where {W}
    v = _presentation_word_to_cpp(W, w)
    z = @wrap_libsemigroups_call LibSemigroups.replace_word_with_new_generator!(
        p.cxx_obj,
        v,
    )
    return _presentation_letter_from_cpp(W, z)
end

"""
    first_unused_letter(p::Presentation{W})

Return the smallest letter not already in the alphabet of `p`.
"""
function first_unused_letter(p::Presentation{W}) where {W}
    return _presentation_letter_from_cpp(
        W,
        @wrap_libsemigroups_call LibSemigroups.first_unused_letter(p.cxx_obj)
    )
end

"""
    index_rule(p::Presentation{W}, lhs, rhs) -> Union{Int, UndefinedType}

Return the 1-based index of the first rule equal to `lhs = rhs`.
"""
function index_rule(p::Presentation{W}, lhs, rhs) where {W}
    l = _presentation_word_to_cpp(W, lhs)
    r = _presentation_word_to_cpp(W, rhs)
    i = UInt(@wrap_libsemigroups_call LibSemigroups.index_rule(p.cxx_obj, l, r))
    i == typemax(UInt) && return UNDEFINED
    return div(Int(i), 2) + 1
end

"""
    is_rule(p::Presentation{W}, lhs, rhs) -> Bool

Return `true` if `lhs = rhs` is a rule of `p`.
"""
function is_rule(p::Presentation{W}, lhs, rhs) where {W}
    l = _presentation_word_to_cpp(W, lhs)
    r = _presentation_word_to_cpp(W, rhs)
    return @wrap_libsemigroups_call LibSemigroups.is_rule(p.cxx_obj, l, r)
end

"""
    longest_rule_index(p::Presentation{W}) -> Int

Return the 1-based index of the first rule of maximal length.
"""
function longest_rule_index(p::Presentation{W}) where {W}
    flat = UInt(@wrap_libsemigroups_call LibSemigroups.longest_rule_index(p.cxx_obj))
    return div(Int(flat), 2) + 1
end

"""
    shortest_rule_index(p::Presentation{W}) -> Int

Return the 1-based index of the first rule of minimal length.
"""
function shortest_rule_index(p::Presentation{W}) where {W}
    flat = UInt(@wrap_libsemigroups_call LibSemigroups.shortest_rule_index(p.cxx_obj))
    return div(Int(flat), 2) + 1
end

"""
    throw_if_bad_inverses(p::Presentation{W}, inverses)

Throw if `inverses` does not define a valid list of semigroup inverses.
"""
function throw_if_bad_inverses(p::Presentation{W}, inverses) where {W}
    v = _presentation_word_to_cpp(W, inverses)
    @wrap_libsemigroups_call LibSemigroups.throw_if_bad_inverses(p.cxx_obj, v)
    return nothing
end

"""
    to_gap_string(p::Presentation{W}, var_name::AbstractString = "p") -> String

Return GAP source code that constructs `p`.
"""
function to_gap_string(p::Presentation{W}, var_name::AbstractString = "p") where {W}
    s = @wrap_libsemigroups_call LibSemigroups.to_gap_string(p.cxx_obj, String(var_name))
    return String(s)
end

Base.:(==)(a::Presentation{W}, b::Presentation{W}) where {W} =
    LibSemigroups.is_equal(a.cxx_obj, b.cxx_obj)

Base.isempty(p::Presentation{W}) where {W} = isempty(alphabet(p)) && number_of_rules(p) == 0

function Base.hash(p::Presentation{W}, h::UInt) where {W}
    return hash(
        (
            alphabet(p),
            [
                _presentation_word_from_cpp(W, w) for
                w in LibSemigroups.rules_vector(p.cxx_obj)
            ],
            contains_empty_word(p),
        ),
        h,
    )
end

function Base.show(io::IO, p::Presentation{W}) where {W}
    print(io, LibSemigroups.to_human_readable_repr(p.cxx_obj))
end

# ============================================================================
# InversePresentation
# ============================================================================

"""
    InversePresentation(p::Presentation) -> InversePresentation
    InversePresentation(ip::InversePresentation) -> InversePresentation

Type for inverse-semigroup or inverse-monoid presentations.
"""
const InversePresentation = LibSemigroups.InversePresentation

InversePresentation(p::Presentation{Vector{Int}}) =
    LibSemigroups.InversePresentation(p.cxx_obj)

"""
    set_inverses!(ip::InversePresentation, w::AbstractVector{<:Integer}) -> InversePresentation

Set the inverse of each letter in the alphabet of `ip`.
"""
function set_inverses!(ip::InversePresentation, w::AbstractVector{<:Integer})
    v = _word_to_cpp(w)
    @wrap_libsemigroups_call LibSemigroups.set_inverses!(ip, v)
    return ip
end

"""
    inverses(ip::InversePresentation) -> Vector{Int}

Return the inverse of each letter in the alphabet of `ip`.
"""
inverses(ip::InversePresentation) = _word_from_cpp(LibSemigroups.inverses(ip))

"""
    inverse_of(ip::InversePresentation, x::Integer) -> Int

Return the inverse of the letter `x` in `ip`.
"""
function inverse_of(ip::InversePresentation, x::Integer)
    y = _letter_to_cpp(x)
    _letter_from_cpp(@wrap_libsemigroups_call LibSemigroups.inverse_of(ip, y))
end

"""
    throw_if_bad_alphabet_rules_or_inverses(ip::InversePresentation)

Check if `ip` is a valid inverse presentation.
"""
throw_if_bad_alphabet_rules_or_inverses(ip::InversePresentation) = (
    @wrap_libsemigroups_call LibSemigroups.throw_if_bad_alphabet_rules_or_inverses(ip);
    nothing
)

Base.:(==)(a::InversePresentation, b::InversePresentation) =
    LibSemigroups.is_equal_inv(a, b)

function Base.show(io::IO, ip::InversePresentation)
    print(io, LibSemigroups.to_human_readable_repr(ip))
end

Base.deepcopy_internal(ip::InversePresentation, ::IdDict) = InversePresentation(ip)

# ============================================================================
# InversePresentation Delegation
# ============================================================================

_presentation_view(ip::InversePresentation) = Presentation{Vector{Int}}(ip)

function _forward_to_presentation(f, ip::InversePresentation, args...)
    v = _presentation_view(ip)
    r = f(v, args...)
    return r === v ? ip : r
end

for _f in (
    :add_generator!,
    :add_identity_rules!,
    :add_inverse_rules!,
    :add_rule!,
    :add_rule_no_checks!,
    :add_rules!,
    :add_zero_rules!,
    :alphabet,
    :alphabet_from_rules!,
    :are_rules_sorted,
    :change_alphabet!,
    :clear_rules!,
    :contains_empty_word,
    :contains_rule,
    :first_unused_letter,
    :in_alphabet,
    :index_of,
    :index_rule,
    :init!,
    :is_normalized,
    :is_rule,
    :length_of,
    :letter,
    :longest_rule_index,
    :longest_rule_length,
    :normalize_alphabet!,
    :number_of_rules,
    :remove_duplicate_rules!,
    :remove_generator!,
    :remove_trivial_rules!,
    :replace_subword!,
    :replace_word!,
    :replace_word_with_new_generator!,
    :rule,
    :rule_lhs,
    :rule_rhs,
    :rules,
    :set_alphabet!,
    :set_contains_empty_word!,
    :shortest_rule_index,
    :shortest_rule_length,
    :sort_each_rule!,
    :sort_rules!,
    :throw_if_alphabet_has_duplicates,
    :throw_if_bad_alphabet_or_rules,
    :throw_if_bad_inverses,
    :throw_if_bad_rules,
    :throw_if_letter_not_in_alphabet,
    :throw_if_odd_number_of_rules,
    :to_gap_string,
)
    @eval $_f(ip::InversePresentation, args...) = _forward_to_presentation($_f, ip, args...)
end

Base.isempty(ip::InversePresentation) = isempty(_presentation_view(ip))
Base.reverse!(ip::InversePresentation) = (reverse!(_presentation_view(ip)); ip)
