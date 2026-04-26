# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
setup.jl - Library location and build logic for Semigroups.jl

This module handles locating the compiled C++ wrapper library,
either from a pre-built location or by building it from source.
Uses libsemigroups_jll for the pre-built libsemigroups headers and library.
"""

module Setup

using CxxWrap
using libsemigroups_jll
using libsemigroups_julia_jll
import Pkg

# Get the path to the deps directory
function deps_dir()
    return joinpath(dirname(@__DIR__), "deps")
end

# Get the path to the source directory
function src_dir()
    return joinpath(deps_dir(), "src")
end

# Get the path to the build directory
function build_dir()
    return joinpath(deps_dir(), "build")
end

# Get the expected library path
function library_path()
    if Sys.iswindows()
        return joinpath(build_dir(), "libsemigroups_julia.dll")
    elseif Sys.isapple()
        return joinpath(build_dir(), "libsemigroups_julia.dylib")
    else
        return joinpath(build_dir(), "libsemigroups_julia.so")
    end
end

function local_treehash_path()
    return joinpath(build_dir(), "libsemigroups_julia.treehash")
end

function source_tree_hash()
    return bytes2hex(Pkg.GitTools.tree_hash(src_dir()))
end

function jll_tree_hashes()
    path = joinpath(
        libsemigroups_julia_jll.find_artifact_dir(),
        "lib",
        "libsemigroups_julia.treehash",
    )
    isfile(path) || return String[]
    return split(read(path, String))
end

function package_is_from_registry()
    pkginfo = get(Pkg.dependencies(), Base.PkgId(parentmodule(Setup)).uuid, nothing)
    return pkginfo !== nothing && pkginfo.is_tracking_registry
end

function use_jll_library(src_hash::AbstractString; force_local_build::Bool = false)
    force_local_build && return false
    return src_hash in jll_tree_hashes() || package_is_from_registry()
end

function local_library_is_current(lib_path::AbstractString, src_hash::AbstractString)
    isfile(lib_path) || return false
    try
        return chomp(read(local_treehash_path(), String)) == src_hash
    catch
        return false
    end
end

# Build the C++ library from source
function build_library(src_hash::AbstractString = source_tree_hash())
    @info "Building libsemigroups_julia library..."

    # Create build directory
    mkpath(build_dir())

    # Get JlCxx (CxxWrap C++ library) directory
    jlcxx_dir = CxxWrap.prefix_path()

    # Get libsemigroups paths from JLL
    libsemigroups_incdir = joinpath(libsemigroups_jll.artifact_dir, "include")
    libsemigroups_libdir = joinpath(libsemigroups_jll.artifact_dir, "lib")

    # Configure with CMake
    cmake_args = [
        "-DCMAKE_BUILD_TYPE=Release",
        "-DJlCxx_DIR=$(joinpath(jlcxx_dir, "lib", "cmake", "JlCxx"))",
        "-DLIBSEMIGROUPS_INCLUDE_DIR=$libsemigroups_incdir",
        "-DLIBSEMIGROUPS_LIBRARY_DIR=$libsemigroups_libdir",
    ]

    # Add macOS-specific flags if needed
    if Sys.isapple()
        push!(cmake_args, "-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0")
    end

    # Run CMake configure
    cd(build_dir()) do
        run(`cmake $(cmake_args) $(src_dir())`)
        run(`cmake --build . --config Release`)
    end

    write(local_treehash_path(), src_hash)

    @info "Build complete: $(library_path())"
    return library_path()
end

# Locate the library, building if necessary
function locate_library(; force_local_build::Bool = false)
    src_hash = source_tree_hash()
    if use_jll_library(src_hash; force_local_build)
        path = libsemigroups_julia_jll.libsemigroups_julia
        @debug "Using libsemigroups_julia from JLL" path
        return path
    end

    lib_path = library_path()

    if !local_library_is_current(lib_path, src_hash)
        @info "Local libsemigroups_julia is missing or out of date, building from source..."
        build_library(src_hash)
    end

    if !isfile(lib_path)
        error("Failed to locate or build libsemigroups_julia library at $lib_path")
    end

    return lib_path
end

end # module Setup
