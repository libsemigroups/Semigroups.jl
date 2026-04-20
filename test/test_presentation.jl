using Test
using Semigroups

@testset verbose = true "Presentation" begin
    @testset "scaffolding" begin
        @test isdefined(Semigroups, :Presentation)
        @test hasmethod(Presentation, Tuple{})
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
        reverse!(r);
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
        add_identity_rules!(t, 1)       # make 1 the identity → 1·a = a·1 = a
        # 2-letter alphabet: rules are {0,0}={0}, {1,0}={1}, {0,1}={1} (0-indexed)
        # i.e., 3 rules for 2 letters (2n-1 where n=2)
        @test number_of_rules(t) == 3

        # add_zero_rules!
        z = Presentation()
        set_alphabet!(z, 2)
        set_contains_empty_word!(z, true)
        add_zero_rules!(z, 1)           # make 1 a zero → 1·a = a·1 = 1
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
        @test ip isa Presentation                   # CxxWrap inheritance chain
        @test alphabet(ip) == [1, 2]

        # Copy ctor
        jp = InversePresentation(ip)
        @test jp isa InversePresentation

        set_inverses!(ip, [2, 1])
        @test inverses(ip) == [2, 1]
        @test inverse_of(ip, 1) == 2
        @test inverse_of(ip, 2) == 1

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
        reverse!(p);
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
end
