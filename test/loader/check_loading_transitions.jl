# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

# Run separately: this check builds a real native wrapper in an isolated copy.
include("loading_helpers.jl")

@testset "Native source changes invalidate bindings" begin
    mktempdir() do directory
        fixture = local_fixture(directory)
        run_child(
            fixture.project,
            check_local(fixture.library) * """
                @test !isdefined(Semigroups.LibSemigroups, :loading_source_probe)
                """;
            timeout = 900,
        )

        # Add a real wrapped method after the first process has warmed its cache.
        # No compilecache call is made: source tracking must invalidate it.
        path = joinpath(fixture.source, "deps", "src", "libsemigroups_julia.cpp")
        source = read(path, String)
        marker = "    mod.method(\"libsemigroups_version\","
        @assert occursin(marker, source)
        write(
            path,
            replace(
                source,
                marker =>
                    "    mod.method(\"loading_source_probe\", []() -> int { return 122; });\n" *
                    marker;
                count = 1,
            ),
        )
        run_child(
            fixture.project,
            check_local(fixture.library) * """
                @test isdefined(Semigroups.LibSemigroups, :loading_source_probe)
                if isdefined(Semigroups.LibSemigroups, :loading_source_probe)
                    @test Semigroups.LibSemigroups.loading_source_probe() == 122
                end
                """,
        )

        # Keep an explicit no-precompilation smoke without paying this cost in
        # every routine override case on every CI matrix entry.
        run_child(
            fixture.project,
            check_local(fixture.library) * """
                @test Semigroups.LibSemigroups.loading_source_probe() == 122
                """;
            compiled_modules = "no",
        )
    end
end
