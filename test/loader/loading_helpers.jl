# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

# Shared by the fresh-process loading and native-source transition checks.
using Test, Semigroups, Libdl, Pkg, TOML

const root = dirname(dirname(@__DIR__))
const wrapper_uuid = string(Semigroups.Setup.WRAPPER_ID.uuid)
const selected = realpath(Semigroups.libsemigroups_julia())
const artifact = Semigroups.Setup.jll_artifact().directory
const published = joinpath(artifact, "lib", Semigroups.Setup.library_name())

function fixture_project(directory, source = root)
    mkpath(directory)
    package = TOML.parsefile(joinpath(source, "Project.toml"))
    project = Dict("deps" => merge(package["deps"], Dict("Semigroups" => package["uuid"])))
    open(joinpath(directory, "Project.toml"), "w") do io
        TOML.print(io, project)
    end
    manifest = TOML.parsefile(joinpath(dirname(Base.active_project()), "Manifest.toml"))
    entries = get!(manifest["deps"], "Semigroups", [Dict{String,Any}()])
    entry = only(entries)
    empty!(entry)
    merge!(
        entry,
        Dict(
            "uuid" => package["uuid"],
            "version" => package["version"],
            "path" => source,
            "deps" => collect(keys(package["deps"])),
        ),
    )
    open(joinpath(directory, "Manifest.toml"), "w") do io
        TOML.print(io, manifest)
    end
end

function library_preference(directory, path)
    open(joinpath(directory, "LocalPreferences.toml"), "w") do io
        TOML.print(
            io,
            Dict("libsemigroups_julia_jll" => Dict("libsemigroups_julia_path" => path)),
        )
    end
end

function run_child(
    project,
    code;
    compiled_modules = "yes",
    depot = nothing,
    recompile = false,
    timeout = 300,
)
    if recompile
        code = "Base.compilecache(Base.identify_package(\"Semigroups\"));\n" * code
    end
    cmd = `$(Base.julia_cmd()) --startup-file=no --compiled-modules=$compiled_modules --project=$project -e $code`
    if depot !== nothing
        separator = Sys.iswindows() ? ';' : ':'
        cmd = addenv(cmd, "JULIA_DEPOT_PATH" => join([depot; DEPOT_PATH], separator))
    end
    mktemp() do _, io
        process = run(pipeline(cmd; stdout = io, stderr = io); wait = false)
        status = timedwait(() -> process_exited(process), timeout)
        status == :timed_out && kill(process, Base.SIGKILL)
        wait(process)
        seekstart(io)
        output = read(io, String)
        success(process) || print(output)
        @test status != :timed_out
        @test success(process)
    end
end

function check_selected(path)
    return """
        using Semigroups, Libdl, Test
        expected = realpath($(repr(abspath(path))))
        @test realpath(Semigroups.libsemigroups_julia()) == expected
        @test Semigroups.Setup.loaded_wrappers() == [expected]
        if Semigroups._libsemigroups_julia_source() == "dev/local"
            @test !haskey(Base.loaded_modules, Semigroups.Setup.WRAPPER_ID)
        end
        @test length(FroidurePin(Transf([2, 1]))) == 2
        sprint(Semigroups.versioninfo)
        @test Semigroups.Setup.loaded_wrappers() == [expected]
        """
end

function local_fixture(directory; seed_library = false)
    source = joinpath(directory, "Semigroups")
    mkpath(joinpath(source, "deps"))
    cp(joinpath(root, "Project.toml"), joinpath(source, "Project.toml"))
    cp(joinpath(root, "src"), joinpath(source, "src"))
    cp(joinpath(root, "deps", "src"), joinpath(source, "deps", "src"))
    # A comment changes the tree hash without changing the native code's meaning.
    # This must select a local build even when the published JLL matches root.
    open(joinpath(source, "deps", "src", "libsemigroups_julia.cpp"), "a") do io
        println(io, "\n// Fresh-process loading fixture: select the local source tree.")
    end
    project = joinpath(directory, "environment")
    fixture_project(project, source)
    build = joinpath(source, "deps", basename(Semigroups.Setup.build_dir()))
    library = joinpath(build, Semigroups.Setup.library_name())
    if seed_library
        # Selection-only fixture: reuse the matching binary before the harmless
        # comment edit. The separate transition check performs real CMake builds.
        mkpath(build)
        cp(selected, library)
        hash = bytes2hex(Pkg.GitTools.tree_hash(joinpath(source, "deps", "src")))
        open(joinpath(build, basename(Semigroups.Setup.local_state_path())), "w") do io
            TOML.print(
                io,
                Dict(
                    "source_hash" => hash,
                    "configuration" => Semigroups.Setup.build_configuration(),
                ),
            )
        end
    end
    return (; source, project, library)
end

function check_local(library)
    return check_selected(library) * """
        @test Semigroups._libsemigroups_julia_source() == "dev/local"
        """
end
