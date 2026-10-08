using Test
using Semigroups

@testset verbose = true "to InversePresentation" begin
    @testset "scaffolding" begin
        # Check conversion from Presentation and copying an inverse presentation.
        @test hasmethod(Semigroups.to, Tuple{Type{InversePresentation},Presentation})
        @test hasmethod(Semigroups.to, Tuple{Type{InversePresentation},InversePresentation})
    end

    @testset "from Presentation" begin
        # Conversion adds inverse generators and preserves the original rules.
        p = Presentation()
        set_alphabet!(p, 2)
        add_rule_no_checks!(p, [1, 2], [2, 1])

        ip = Semigroups.to(InversePresentation, p)

        @test ip isa InversePresentation
        @test alphabet(ip) == [1, 2, 3, 4]
        @test rules(ip) == rules(p)
        @test inverses(ip) == [3, 4, 1, 2]
        throw_if_bad_alphabet_rules_or_inverses(ip)
    end

    @testset "copy" begin
        # Copy conversion must produce an equal but distinct wrapper.
        p = Presentation()
        set_alphabet!(p, 1)
        ip = InversePresentation(p)
        set_inverses!(ip, [1])

        copy = Semigroups.to(InversePresentation, ip)

        @test copy isa InversePresentation
        @test copy !== ip
        @test copy == ip
        @test inverses(copy) == [1]
    end
end
