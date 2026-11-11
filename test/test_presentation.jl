using Test
using Semigroups

@testset verbose = true "Presentation" begin
    @testset "scaffolding" begin
        @test isdefined(Semigroups, :Presentation)
        @test hasmethod(Presentation, Tuple{})
    end

    @testset "parametric types and string support" begin
        # Default constructor resolves to Vector{Int}
        p_default = Presentation()
        @test p_default isa Presentation{Vector{Int}}

        p_vec = Presentation([([1, 2], [2, 1])])

        p_str = Presentation([("a", "b")])
        # String constructor inference
        p_str_inferred = Presentation(["a", "b"])
        @test p_str_inferred isa Presentation{String}

        if isdefined(Semigroups, :_cxx_word)
            @test_throws ArgumentError Semigroups._cxx_word(p_str)
            @test Semigroups._cxx_word(p_default) === p_default.cxx_obj
        end
    end

    @testset "string presentation: rules and alphabet" begin
        p = Presentation{String}()
        set_alphabet!(p, "abc")
        @test alphabet(p) == "abc"
        @test letter(p, 1) == 'a'
        @test letter(p, 2) == 'b'
        @test letter(p, 3) == 'c'
        @test index_of(p, 'b') == 2
        @test in_alphabet(p, 'c')
        @test !in_alphabet(p, 'z')

        add_rule_no_checks!(p, "aaa", "a")
        @test rules(p) == [("aaa", "a")]
        @test number_of_rules(p) == 1
        @test rule_lhs(p, 1) == "aaa"
        @test rule_rhs(p, 1) == "a"
        @test is_rule(p, "aaa", "a")
        @test contains_rule(p, "aaa", "a")
        @test index_rule(p, "aaa", "a") == 1

        @test_throws Semigroups.LibsemigroupsError set_alphabet!(p, "aa")
        @test_throws Semigroups.LibsemigroupsError add_rule!(p, "abz", "a")
        @test_throws Semigroups.LibsemigroupsError add_rule!(p, "", "a")

        # std::string is byte-oriented, so the wrapper accepts ASCII only.
        @test_throws ArgumentError set_alphabet!(p, "é")
        @test_throws ArgumentError set_alphabet!(p, ['é'])
        @test_throws ArgumentError add_rule!(p, "é", "a")
        @test_throws ArgumentError add_rule_no_checks!(p, ["é"], ["a"])
        @test_throws ArgumentError add_rule_no_checks!(p, ['é'], ['a'])
        @test_throws ArgumentError index_of(p, 'é')
    end

    @testset "string presentation: alphabet from rules and constructors" begin
        p = Presentation{String}()
        set_alphabet!(p, 4)
        @test alphabet(p) == "abcd"
        add_rule_no_checks!(p, "abca", "aa")
        add_rule_no_checks!(p, "eb", "af")
        add_rule_no_checks!(p, "eb", "abbbbbb")
        alphabet_from_rules!(p)
        @test alphabet(p) == "abcef"
        @test index_of(p, 'a') == 1
        @test index_of(p, 'b') == 2
        @test index_of(p, 'c') == 3
        @test index_of(p, 'e') == 4
        @test index_of(p, 'f') == 5

        add_rule_no_checks!(p, "e", "")
        alphabet_from_rules!(p)
        @test contains_empty_word(p)

        q = Presentation([("ab", "ba")])
        @test q isa Presentation{String}
        @test alphabet(q) == "ab"
        @test deepcopy(q) == q

        q_copy = copy(q)
        @test q_copy == q
        add_rule!(q_copy, "a", "b")
        @test rules(q) == [("ab", "ba")]
        @test rules(q_copy) == [("ab", "ba"), ("a", "b")]

        generated = Presentation{String}()
        set_alphabet!(generated, 31)
        @test length(alphabet(generated)) == 31
        @test letter(generated, 31) == Char(127)
        @test_throws ArgumentError set_alphabet!(Presentation{String}(), 32)
        @test first_unused_letter(generated) == 'A'
        @test add_generator!(generated) == 'A'

        full_ascii = Presentation{String}()
        set_alphabet!(full_ascii, String(Char.(0:127)))
        @test_throws ArgumentError first_unused_letter(full_ascii)
        @test_throws ArgumentError add_generator!(full_ascii)
    end

    @testset "string presentation: identity and zero rules" begin
        p = Presentation{String}()
        add_rule_no_checks!(p, "abcb", "aa")
        @test_throws Semigroups.LibsemigroupsError add_identity_rules!(p, 'a')
        alphabet_from_rules!(p)
        add_identity_rules!(p, 'a')
        @test rules(p) == [
            ("abcb", "aa"),
            ("aa", "a"),
            ("ba", "b"),
            ("ab", "b"),
            ("ca", "c"),
            ("ac", "c"),
        ]

        q = Presentation{String}()
        add_rule_no_checks!(q, "abcb", "aa")
        @test_throws Semigroups.LibsemigroupsError add_zero_rules!(q, '0')
        set_alphabet!(q, "abc0")
        add_zero_rules!(q, '0')
        @test number_of_rules(q) == 8
        @test rule_lhs(q, 2) == "a0"
        @test rule_rhs(q, 2) == "0"
        @test rule_lhs(q, 8) == "00"
        @test rule_rhs(q, 8) == "0"
    end

    @testset "string presentation: word transformations" begin
        p = Presentation{String}()
        set_alphabet!(p, "ab")
        add_rule!(p, "aaa", "a")
        replace_subword!(p, "aa", "b")
        @test rules(p) == [("ba", "a")]

        q = Presentation{String}()
        set_alphabet!(q, "ab")
        add_rule!(q, "aa", "aa")
        add_rule!(q, "ab", "aa")
        replace_word!(q, "aa", "b")
        @test rules(q) == [("b", "b"), ("ab", "b")]
    end

    @testset "string presentation: complete API sweep" begin
        p = Presentation{String}()
        set_alphabet!(p, "ac")
        @test add_generator!(p) == 'b'
        add_generator!(p, 'd')
        @test remove_generator!(p, 'd') === p
        @test alphabet(p) == "acb"
        @test first_unused_letter(p) == 'd'

        add_rule_no_checks!(p, "a", "cba")
        add_rule_no_checks!(p, "a", "cba")
        add_rule_no_checks!(p, "a", "a")
        @test length_of(p) == 10
        @test longest_rule_length(p) == 4
        @test shortest_rule_length(p) == 2
        @test longest_rule_index(p) == 1
        @test shortest_rule_index(p) == 3
        @test !are_rules_sorted(p)
        @test !is_normalized(p)
        remove_duplicate_rules!(p)
        @test rules(p) == [("a", "a"), ("a", "cba")]
        remove_trivial_rules!(p)
        @test rules(p) == [("a", "cba")]
        @test sort_each_rule!(p) == true
        @test rules(p) == [("cba", "a")]
        sort_rules!(p)
        @test rules(p) == [("cba", "a")]
        @test alphabet(p) == "acb"
        normalize_alphabet!(p)
        @test alphabet(p) == "abc"
        @test rules(p) == [("bca", "a")]
        change_alphabet!(p, "cba")
        @test alphabet(p) == "cba"
        @test rules(p) == [("bac", "c")]
        reverse!(p)
        @test rules(p) == [("cab", "c")]
        reverse!(p)
        @test rules(p) == [("bac", "c")]
        @test throw_if_alphabet_has_duplicates(p) === nothing
        @test throw_if_letter_not_in_alphabet(p, 'b') === nothing
        @test throw_if_bad_rules(p) === nothing
        @test throw_if_bad_alphabet_or_rules(p) === nothing
        @test throw_if_odd_number_of_rules(p) === nothing

        q = Presentation{String}()
        set_alphabet!(q, "ba")
        add_rule!(q, "bb", "b")
        @test add_rules!(p, q) === p
        @test number_of_rules(p) == 2
        clear_rules!(p)
        @test isempty(rules(p))

        r = Presentation{String}()
        set_alphabet!(r, "ab")
        set_contains_empty_word!(r, true)
        @test add_inverse_rules!(r, "ba") === r
        @test rules(r) == [("ab", ""), ("ba", "")]

        r_identity = Presentation{String}()
        set_alphabet!(r_identity, "ab")
        set_contains_empty_word!(r_identity, true)
        @test add_inverse_rules!(r_identity, "ab", 'a') === r_identity
        @test rules(r_identity) == [("bb", "a")]
        @test_throws Semigroups.LibsemigroupsError throw_if_bad_inverses(r, "aa")

        s = Presentation{String}()
        set_alphabet!(s, "ab")
        add_rule!(s, "abab", "a")
        @test replace_word_with_new_generator!(s, "ab") == 'c'
        @test rules(s) == [("cc", "a"), ("c", "ab")]
        @test alphabet(s) == "abc"
        @test first_unused_letter(s) == 'd'
        @test to_gap_string(s, "S") isa String
        @test isempty(Presentation{String}())
        @test hash(s) isa UInt
        @test s == deepcopy(s)

        v = Presentation{String}()
        set_alphabet!(v, "ab")
        add_rule!(v, ["a", "b"], ["b"])
        add_rule!(v, ['a', 'b'], ['a'])
        @test rules(v) == [("ab", "b"), ("ab", "a")]
        init!(v)
        @test isempty(v)
    end

    @testset "constructors + init! + deepcopy + alphabet getter" begin
        p = Presentation()
        @test p isa Presentation

        q = Presentation(p)                     # copy constructor
        @test q isa Presentation

        init!(q)
        @test alphabet(q) == Int[]

        r = deepcopy(p)                         # Base.deepcopy via copy ctor
        @test r isa Presentation
        @test r !== p                           # distinct wrapper

        populated = Presentation()
        set_alphabet!(populated, 2)
        add_rule!(populated, [1, 2], [2, 1])
        populated_copy = copy(populated)
        @test populated_copy == populated
        add_rule!(populated_copy, [1], [2])
        @test rules(populated) == [([1, 2], [2, 1])]
        @test rules(populated_copy) == [([1, 2], [2, 1]), ([1], [2])]
    end

    @testset "Alphabet Invariants & Custom Alphabets" begin
        p_char = Presentation(['a', 'b', 'c'])
        @test p_char isa Presentation{String}
        @test alphabet(p_char) == "abc"
        @test letter(p_char, 1) == 'a'
        @test index_of(p_char, 'b') == 2
        @test in_alphabet(p_char, 'c')
        @test !in_alphabet(p_char, 'z')

        p_dup = Presentation()
        @test_throws LibsemigroupsError set_alphabet!(p_dup, [1, 1, 2])
    end
    @testset "Rule Searching and Index Invariants" begin
        p = Presentation()
        set_alphabet!(p, [1, 2])
        add_rule!(p, [1, 2], [2, 1])

        # Verified present rule
        @test is_rule(p, [1, 2], [2, 1])
        @test index_rule(p, [1, 2], [2, 1]) == 1

        # Verified absent rule returns UNDEFINED sentinel
        @test !is_rule(p, [1], [2])
        @test index_rule(p, [1], [2]) == Semigroups.UNDEFINED
        @test !contains_rule(p, [1], [2])
    end

    @testset "Rule Validation Guards" begin
        p = Presentation()
        set_alphabet!(p, [1, 2])

        @test_throws LibsemigroupsError throw_if_letter_not_in_alphabet(p, 3)

        add_rule_no_checks!(p, [1, 3], [2])
        @test_throws LibsemigroupsError throw_if_bad_rules(p)
        @test_throws LibsemigroupsError throw_if_bad_alphabet_or_rules(p)
    end

    @testset "Algorithm Type Guard Constraints" begin
        p_str = Presentation{String}()
        set_alphabet!(p_str, "ab")

        # Assert type guard raises ArgumentError explaining type incompatibility
        @test_throws ArgumentError Semigroups._cxx_word(p_str)
    end
    @testset "alphabet setters" begin
        p = Presentation()
        set_alphabet!(p, 3)
        @test alphabet(p) == [1, 2, 3]

        set_alphabet!(p, [1, 2, 4])
        @test alphabet(p) == [1, 2, 4]

        # Rejection of duplicates
        @test_throws LibsemigroupsError set_alphabet!(p, [1, 1])

        # Negative n must surface as InexactError (not wrapped by @wrap_libsemigroups_call)
        @test_throws InexactError set_alphabet!(p, -1)
    end

    @testset "alphabet queries" begin
        p = Presentation()
        set_alphabet!(p, [3, 1, 4])
        @test letter(p, 1) == 3
        @test letter(p, 2) == 1
        @test letter(p, 3) == 4
        @test_throws LibsemigroupsError letter(p, 4)

        @test index_of(p, 3) == 1
        @test index_of(p, 1) == 2
        @test index_of(p, 4) == 3
        @test_throws LibsemigroupsError index_of(p, 99)

        @test in_alphabet(p, 3)
        @test !in_alphabet(p, 99)
    end

    @testset "contains_empty_word" begin
        p = Presentation()
        @test contains_empty_word(p) == false
        set_contains_empty_word!(p, true)
        @test contains_empty_word(p) == true
        set_contains_empty_word!(p, false)
        @test contains_empty_word(p) == false
    end

    @testset "generator management" begin
        p = Presentation()
        set_alphabet!(p, 2)              # alphabet = [1, 2]
        x = add_generator!(p)            # first letter not in alphabet (1-based)
        @test x == 3
        @test alphabet(p) == [1, 2, 3]

        add_generator!(p, 7)
        @test 7 in alphabet(p)
        @test_throws LibsemigroupsError add_generator!(p, 7)   # duplicate

        remove_generator!(p, 7)
        @test !(7 in alphabet(p))
        @test_throws LibsemigroupsError remove_generator!(p, 99)
    end

    @testset "add_rule! / add_rule_no_checks!" begin
        p = Presentation()
        set_alphabet!(p, 3)

        add_rule_no_checks!(p, [1, 1, 1], [1])
        add_rule!(p, [2, 2], [2])

        # Checked form rejects letter outside alphabet
        @test_throws LibsemigroupsError add_rule!(p, [1, 99], [1])

        # Checked form rejects empty rule when contains_empty_word == false
        @test_throws LibsemigroupsError add_rule!(p, Int[], [1])

        # With contains_empty_word = true, empty sides are accepted
        set_contains_empty_word!(p, true)
        add_rule!(p, Int[], [1])
    end

    @testset "rule access" begin
        p = Presentation()
        set_alphabet!(p, 3)
        @test number_of_rules(p) == 0
        @test isempty(rules(p))

        add_rule_no_checks!(p, [1, 1, 1], [1])
        @test number_of_rules(p) == 1
        @test rule_lhs(p, 1) == [1, 1, 1]
        @test rule_rhs(p, 1) == [1]
        @test rules(p) == [([1, 1, 1], [1])]

        clear_rules!(p)
        @test number_of_rules(p) == 0
    end

    @testset "validation throws" begin
        p = Presentation()
        set_alphabet!(p, [1, 2, 3])
        throw_if_alphabet_has_duplicates(p)         # no throw
        throw_if_letter_not_in_alphabet(p, 2)       # no throw
        @test_throws LibsemigroupsError throw_if_letter_not_in_alphabet(p, 99)
        throw_if_bad_alphabet_or_rules(p)

        q = Presentation()
        set_alphabet!(q, 2)                         # [1, 2]
        add_rule_no_checks!(q, [1, 99], [2])        # illegal letter 99
        @test_throws LibsemigroupsError throw_if_bad_rules(q)
        @test_throws LibsemigroupsError throw_if_bad_alphabet_or_rules(q)
    end

    @testset "helpers: scalar queries" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])       # lens 2 + 1
        add_rule!(p, [2, 2], [2])       # lens 2 + 1

        @test length_of(p) == 6         # 2 + 1 + 2 + 1
        @test longest_rule_length(p) == 3
        @test shortest_rule_length(p) == 3
        @test contains_rule(p, [1, 1], [1])
        @test !contains_rule(p, [1, 2], [1])

        @test are_rules_sorted(p)
        @test is_normalized(p)

        throw_if_odd_number_of_rules(p) # no throw (even)
    end

    @testset "helpers: shape mutators" begin
        # normalize_alphabet!
        p = Presentation()
        set_alphabet!(p, [7, 3])
        add_rule!(p, [7, 3], [7])
        normalize_alphabet!(p)
        @test alphabet(p) == [1, 2]

        # change_alphabet!
        q = Presentation()
        set_alphabet!(q, [1, 2])
        add_rule!(q, [1, 2], [1])
        change_alphabet!(q, [5, 6])
        @test alphabet(q) == [5, 6]
        @test rule_lhs(q, 1) == [5, 6]

        # Base.reverse! (not exported; dispatches on ::Presentation)
        r = Presentation()
        set_alphabet!(r, 2)
        add_rule!(r, [1, 2, 1], [2])
        reverse!(r)
        @test rule_lhs(r, 1) == [1, 2, 1]           # palindrome reverses to itself
        # adjacent rule with distinct reverse:
        add_rule!(r, [1, 2], [2, 1])
        reverse!(r)
        reverse!(r)                    # double-reverse is identity
        @test rule_lhs(r, 2) == [1, 2]

        # sort_rules!, sort_each_rule!
        s = Presentation()
        set_alphabet!(s, 2)
        add_rule!(s, [2, 2], [2])
        add_rule!(s, [1, 1], [1])
        sort_rules!(s)
        @test rule_lhs(s, 1) == [1, 1]              # shortlex: smaller lhs first

        t = Presentation()
        set_alphabet!(t, 2)
        add_rule!(t, [2], [1, 1, 1])                # lhs < rhs by shortlex
        sort_each_rule!(t)
        # After sort_each_rule!: lhs > rhs under shortlex (larger side first).
        # [1,1,1] has length 3 > [2] length 1, so [1,1,1] becomes lhs.
        @test rule_lhs(t, 1) == [1, 1, 1]
        @test rule_rhs(t, 1) == [2]
    end

    @testset "helpers: rule-set mutators" begin
        # add_identity_rules!
        t = Presentation()
        set_alphabet!(t, 2)
        set_contains_empty_word!(t, true)
        add_identity_rules!(t, 1)       # make 1 the identity -> 1*a = a*1 = a
        # 2-letter alphabet: rules are {0,0}={0}, {1,0}={1}, {0,1}={1} (0-indexed)
        # i.e., 3 rules for 2 letters (2n-1 where n=2)
        @test number_of_rules(t) == 3

        # add_zero_rules!
        z = Presentation()
        set_alphabet!(z, 2)
        set_contains_empty_word!(z, true)
        add_zero_rules!(z, 1)           # make 1 a zero -> 1*a = a*1 = 1
        @test number_of_rules(z) == 3

        # remove_duplicate_rules!
        u = Presentation()
        set_alphabet!(u, 2)
        add_rule!(u, [1, 1], [1])
        add_rule!(u, [1, 1], [1])       # duplicate
        remove_duplicate_rules!(u)
        @test number_of_rules(u) == 1

        # remove_trivial_rules!
        v = Presentation()
        set_alphabet!(v, 1)
        add_rule!(v, [1], [1])          # trivial
        remove_trivial_rules!(v)
        @test number_of_rules(v) == 0
    end

    @testset "equality + show" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])

        q = Presentation()
        set_alphabet!(q, 2)
        add_rule!(q, [1, 1], [1])

        @test p == q
        add_rule!(q, [2], [2])
        @test p != q

        s = sprint(show, p)
        @test occursin("presentation", s)
    end

    @testset "InversePresentation" begin
        p = Presentation()
        set_alphabet!(p, [1, 2])
        ip = InversePresentation(p)
        @test ip isa InversePresentation
        @test ip isa Semigroups.LibSemigroups.PresentationWord   # CxxWrap inheritance chain
        @test alphabet(ip) == [1, 2]

        # Copy ctor
        jp = InversePresentation(ip)
        @test jp isa InversePresentation

        set_inverses!(ip, [2, 1])
        @test inverses(ip) == [2, 1]
        @test inverse_of(ip, 1) == 2
        @test inverse_of(ip, 2) == 1

        equal_copy = InversePresentation(ip)
        @test equal_copy == ip
        @test hash(equal_copy) == hash(ip)

        dict = Dict(ip => :present)
        @test dict[equal_copy] == :present
        set = Set([ip])
        push!(set, equal_copy)
        @test length(set) == 1
        @test equal_copy in set

        # Bad inverses rejected
        @test_throws LibsemigroupsError set_inverses!(ip, [1, 1])

        throw_if_bad_alphabet_rules_or_inverses(ip)

        # == takes inverses into account
        kp = InversePresentation(p)
        set_inverses!(kp, [2, 1])
        @test ip == kp
        set_inverses!(kp, [1, 2])                   # different inverse map
        @test ip != kp

        # show produces something containing "presentation" (case-insensitive match)
        s = sprint(show, ip)
        @test occursin("presentation", lowercase(s))
    end

    @testset "end-to-end: construct, validate, render, compare" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1, 1], [1])
        add_rule!(p, [2, 2], [2])
        add_rule!(p, [1, 2, 1], [2, 1, 2])

        throw_if_bad_alphabet_or_rules(p)
        @test number_of_rules(p) == 3
        @test rules(p) == [([1, 1, 1], [1]), ([2, 2], [2]), ([1, 2, 1], [2, 1, 2])]

        # Round-trip through Base.reverse! and back
        reverse!(p)
        reverse!(p)
        @test rules(p) == [([1, 1, 1], [1]), ([2, 2], [2]), ([1, 2, 1], [2, 1, 2])]

        # Equality against a freshly constructed twin
        q = Presentation()
        set_alphabet!(q, 2)
        add_rule!(q, [1, 1, 1], [1])
        add_rule!(q, [2, 2], [2])
        add_rule!(q, [1, 2, 1], [2, 1, 2])
        @test p == q

        # Promote to InversePresentation
        ip = InversePresentation(p)
        set_inverses!(ip, [2, 1])
        @test inverse_of(ip, 1) == 2
        throw_if_bad_alphabet_rules_or_inverses(ip)
    end

    @testset "add_rules!" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])

        q = Presentation()
        set_alphabet!(q, 2)
        add_rule!(q, [2, 2], [2])
        add_rule!(q, [1, 2], [2, 1])

        @test add_rules!(p, q) === p                       # chainable
        @test rules(p) == [([1, 1], [1]), ([2, 2], [2]), ([1, 2], [2, 1])]

        # Bad letter in q's rules -> throws
        bad = Presentation()
        set_alphabet!(bad, 1)
        add_rule_no_checks!(bad, [1, 99], [1])             # 99 not in p's alphabet
        @test_throws LibsemigroupsError add_rules!(p, bad)
    end

    @testset "add_inverse_rules!" begin
        # 2-arg form (no identity): inverses of [1,2] are [2,1]
        p = Presentation()
        set_alphabet!(p, [1, 2])
        set_contains_empty_word!(p, true)                  # empty identity allowed
        @test add_inverse_rules!(p, [2, 1]) === p          # chainable
        # The resulting rules should encode a*a^(-1) = empty for each letter.
        @test number_of_rules(p) >= 2

        # 3-arg form with explicit identity letter.
        q = Presentation()
        set_alphabet!(q, [1, 2, 3])
        @test add_inverse_rules!(q, [2, 1, 3], 3) === q    # identity = letter 3
        @test number_of_rules(q) >= 1

        # Invalid inverses rejected
        r = Presentation()
        set_alphabet!(r, [1, 2])
        @test_throws LibsemigroupsError add_inverse_rules!(r, [1, 1])
    end

    @testset "replace_subword!" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1, 1], [1])                       # a^3 = a

        @test replace_subword!(p, [1, 1], [2]) === p
        # Every non-overlapping "aa" in the rule "aaa = a" is replaced by "b":
        # "aaa" -> "ba" (one a leftover); rhs "a" unchanged.
        @test rules(p) == [([2, 1], [1])]

        @test_throws LibsemigroupsError replace_subword!(p, Int[], [1])
    end

    @testset "replace_word!" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1, 1])                       # a^2 = a^2  (trivial)
        add_rule!(p, [1, 2], [1, 1])                       # ab = a^2
        # Replace the full-side word [1,1] wherever it appears as a complete side.
        replace_word!(p, [1, 1], [2])
        # After: [1,1] fully replaced on matching sides; [1,2]=[1,1] -> [1,2]=[2].
        @test rules(p) == [([2], [2]), ([1, 2], [2])]
    end

    @testset "replace_word_with_new_generator!" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 2, 1, 2], [1])

        z = replace_word_with_new_generator!(p, [1, 2])
        @test z isa Int
        @test z in alphabet(p)                             # new generator present
        # The rule for the new generator (w = z) should be present:
        @test contains_rule(p, [1, 2], [z])

        @test_throws LibsemigroupsError replace_word_with_new_generator!(p, Int[])
    end

    @testset "first_unused_letter" begin
        p = Presentation()
        set_alphabet!(p, 3)
        @test first_unused_letter(p) == 4                  # 1-based

        q = Presentation()
        set_alphabet!(q, [1, 3, 5])
        @test first_unused_letter(q) == 2                  # first gap
    end

    @testset "index_rule + is_rule + UNDEFINED" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])
        add_rule!(p, [2, 2], [2])
        add_rule!(p, [1, 2], [2, 1])

        @test index_rule(p, [1, 1], [1]) == 1
        @test index_rule(p, [2, 2], [2]) == 2
        @test index_rule(p, [1, 2], [2, 1]) == 3

        missing_idx = index_rule(p, [1], [2])
        @test missing_idx === UNDEFINED                    # singleton, not nothing
        @test is_undefined(missing_idx)

        @test is_rule(p, [1, 1], [1])
        @test is_rule(p, [2, 2], [2])
        @test !is_rule(p, [1], [2])
    end

    @testset "longest_rule_index + shortest_rule_index" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1], [1])                             # len 2
        add_rule!(p, [1, 1, 1], [2, 2])                    # len 5
        add_rule!(p, [1, 2], [2])                          # len 3

        @test longest_rule_index(p) == 2
        @test shortest_rule_index(p) == 1
    end

    @testset "throw_if_bad_inverses" begin
        p = Presentation()
        set_alphabet!(p, [1, 2])
        @test throw_if_bad_inverses(p, [2, 1]) === nothing  # valid

        # Duplicate inverses -> throws
        @test_throws LibsemigroupsError throw_if_bad_inverses(p, [1, 1])

        # Wrong length -> throws
        @test_throws LibsemigroupsError throw_if_bad_inverses(p, [2])
    end

    @testset "to_gap_string" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])

        s = to_gap_string(p)                               # default var_name "p"
        @test s isa String
        @test !isempty(s)
        @test occursin("p", s)

        s2 = to_gap_string(p, "S")
        @test occursin("S", s2)
    end

    @testset "rule(p, i) accessor" begin
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule!(p, [1, 1], [1])
        add_rule!(p, [2, 2], [2])
        add_rule!(p, [1, 2], [2, 1])

        for i = 1:3
            @test rule(p, i) == (rule_lhs(p, i), rule_rhs(p, i))
        end
    end

    @testset "rules(p) via rules_vector binding" begin
        p = Presentation()
        set_alphabet!(p, 2)
        @test rules(p) == Tuple{Vector{Int},Vector{Int}}[]   # empty

        add_rule!(p, [1, 1], [1])
        add_rule!(p, [2, 2], [2])
        @test rules(p) == [([1, 1], [1]), ([2, 2], [2])]

        # Binding-surface: rules_vector is a callable C++ method on Presentation.
        flat = Semigroups.LibSemigroups.rules_vector(p.cxx_obj)
        @test length(flat) == 2 * number_of_rules(p)
    end

    @testset "Base.isempty + Base.hash" begin
        p = Presentation()
        @test isempty(p)                                   # just constructed

        set_alphabet!(p, 2)
        @test !isempty(p)                                  # has alphabet

        q = Presentation()
        set_alphabet!(q, 2)
        add_rule!(q, [1, 1], [1])
        @test !isempty(q)                                  # has rules

        init!(q)
        @test isempty(q)                                   # cleared back

        # hash stability + equality
        a = Presentation()
        set_alphabet!(a, 2)
        add_rule!(a, [1, 1], [1])

        b = deepcopy(a)
        @test hash(a) isa UInt
        @test hash(a) == hash(b)

        # Two equal-but-separately-built presentations
        c = Presentation()
        set_alphabet!(c, 2)
        add_rule!(c, [1, 1], [1])
        @test a == c
        @test hash(a) == hash(c)

        # Differing presentations hash differently (overwhelmingly likely)
        add_rule!(c, [2, 2], [2])
        @test a != c
        @test hash(a) != hash(c)
    end

    @testset "binding surface" begin
        LS = Semigroups.LibSemigroups
        # Scalar / reference signatures - hasmethod with concrete types works.
        @test hasmethod(LS.first_unused_letter, Tuple{LS.PresentationWord})
        @test hasmethod(LS.longest_rule_index, Tuple{LS.PresentationWord})
        @test hasmethod(LS.shortest_rule_index, Tuple{LS.PresentationWord})
        @test hasmethod(LS.rules_vector, Tuple{LS.PresentationWord})

        # Vector-input methods: CxxWrap's ArrayRef<size_t> maps to a concrete
        # Julia method signature that is tricky to spell as a `Tuple{...}`, so
        # use `isdefined` to check the binding name is registered - enough to
        # catch silent omissions. Call-through correctness is covered above.
        for name in (
            :add_rules!,
            :add_inverse_rules!,
            :add_inverse_rules_with_identity!,
            :replace_subword!,
            :replace_word!,
            :replace_word_with_new_generator!,
            :index_rule,
            :is_rule,
            :throw_if_bad_inverses,
            :to_gap_string,
        )
            @test isdefined(LS, name)
        end
    end
end
