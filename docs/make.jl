# Copyright (c) 2026, James W. Swent
#
# Distributed under the terms of the GPL license version 3.
#
# The full license is in the file LICENSE, distributed with this software.

"""
make.jl - Documentation build script for Semigroups.jl
"""

using Documenter
using Semigroups
using Revise;
Revise.revise()
using Dates

DocMeta.setdocmeta!(Semigroups, :DocTestSetup, :(using Semigroups); recursive = true)

makedocs(;
    modules = [Semigroups],
    sitename = "Semigroups.jl",
    format = Documenter.HTML(;
        canonical = "https://github.com/libsemigroups/Semigroups.jl",
        edit_link = "main",
        assets = String[],
        collapselevel = 1,
        sidebar_sitename = false,
    ),
    pages = [
        "Home" => "index.md",
        "Package Info" => [
            "Installation" => "package-info/installation.md",
            "Authors" => "package-info/authors.md",
            #= "Bibliography" => "package-info/bibliography.md", =#
            "Exceptions" => "package-info/exceptions.md",
        ],
        "Data Structures" => [
            "Constants" => "data-structures/constants/index.md",
            "Elements" => [
                "Overview" => "data-structures/elements/index.md",
                "Transformations" => [
                    "Overview" => "data-structures/elements/transformations/index.md",
                    "Transf" => "data-structures/elements/transformations/transf.md",
                    "PPerm" => "data-structures/elements/transformations/pperm.md",
                    "Perm" => "data-structures/elements/transformations/perm.md",
                ],
            ],
        ],
        "Main Algorithms" => [
            "Overview" => "main-algorithms/index.md",
            "Core classes" => [
                "main-algorithms/core-classes/index.md",
                "main-algorithms/core-classes/runner.md",
            ],
        ],
    ],
    warnonly = [:missing_docs, :linkcheck, :cross_references],
)

deploydocs(repo = "github.com/libsemigroups/Semigroups.jl.git", devbranch = "main")
