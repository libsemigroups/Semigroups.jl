# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

# Run in its own process: native libraries cannot safely be switched in-place.
include("loading_helpers.jl")

@testset "Fresh-process wrapper loading" begin
    mktempdir() do directory
        fixture_project(directory)
        # Exercise normal loading twice, including reuse of precompiled code.
        run_child(directory, check_selected(selected))
        run_child(directory, check_selected(selected))

        @testset "Published library preference" begin
            library_preference(directory, published)
            run_child(directory, check_selected(published); recompile = true)
            run_child(directory, check_selected(published))
        end

        @testset "Local library preference and existing-library guard" begin
            local_lib = joinpath(directory, Semigroups.Setup.library_name())
            cp(selected, local_lib)
            library_preference(directory, local_lib)
            run_child(directory, check_selected(local_lib); recompile = true)
            run_child(directory, check_selected(local_lib))
            run_child(
                directory,
                """
using CxxWrap, libsemigroups_jll, Libdl, Test
Libdl.dlopen($(repr(published)))
failure = try
    @eval using Semigroups
    nothing
catch error
    error
end
@test failure !== nothing
@test occursin("different libsemigroups_julia wrapper is already loaded", sprint(showerror, failure))
""",
            )
        end

        @testset "Artifact override" begin
            rm(joinpath(directory, "LocalPreferences.toml"))
            prefix = joinpath(directory, "override")
            mkpath(joinpath(prefix, "lib"))
            override_lib = joinpath(prefix, "lib", Semigroups.Setup.library_name())
            cp(selected, override_lib)
            depot = joinpath(directory, "depot")
            mkpath(joinpath(depot, "artifacts"))
            open(joinpath(depot, "artifacts", "Overrides.toml"), "w") do io
                TOML.print(io, Dict(wrapper_uuid => Dict("libsemigroups_julia" => prefix)))
            end
            # Regenerate bindings after changing an artifact override, then
            # check that another process can reuse that cache.
            run_child(directory, check_selected(override_lib); recompile = true, depot)
            run_child(directory, check_selected(override_lib); depot)
        end
    end
end

@testset "Automatic local selection" begin
    mktempdir() do directory
        fixture = local_fixture(directory; seed_library = true)
        run_child(fixture.project, check_local(fixture.library))
        run_child(
            fixture.project,
            """
            using libsemigroups_julia_jll, Libdl, Test
            failure = try
                @eval using Semigroups
                nothing
            catch error
                error
            end
            @test failure !== nothing
            @test occursin("different libsemigroups_julia wrapper is already loaded", sprint(showerror, failure))
            loaded = unique(realpath(p) for p in Libdl.dllist() if basename(p) == $(repr(Semigroups.Setup.library_name())))
            @test loaded == [$(repr(realpath(published)))]
            """,
        )
    end
end
