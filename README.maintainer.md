# Directions for updating Semigroups.jl

`Semigroups.jl` depends on the [libsemigroups](https://github.com/libsemigroups/libsemigroups) C++ library and some C++ glue code
found in the `deps/src/` directory. Compiled versions of each are distributed to
users as binary artifacts via the Julia "JLL" packages `libsemigroups_jll` and
`libsemigroups_julia_jll` respectively.

The build scripts for these JLL packages can be found here:

- <https://github.com/JuliaPackaging/Yggdrasil/blob/master/L/libsemigroups/build_tarballs.jl>
- <https://github.com/JuliaPackaging/Yggdrasil/blob/master/L/libsemigroups_julia/build_tarballs.jl>

The resulting JLL packages:

- <https://github.com/JuliaBinaryWrappers/libsemigroups_jll.jl>
- <https://github.com/JuliaBinaryWrappers/libsemigroups_julia_jll.jl>

The sources:

- `libsemigroups` sources: <https://github.com/libsemigroups/libsemigroups>
- `libsemigroups_julia` sources: `deps/src/` directory of `Semigroups.jl`

[libsemigroups]: https://github.com/libsemigroups/libsemigroups

## Updating just the C++ wrappers

Suppose just the C++ wrappers need to be updated, without any changes to the
`libsemigroups` kernel itself.

1. Commit changes to the `deps/src/` directory.

2. After the changes are merged (and before the next `Semigroups.jl` release),
   update the `libsemigroups_julia` build script with a new version number and
   using the latest commit SHA for the `main` branch of `Semigroups.jl`.

3. Wait for this to be merged into Yggdrasil, and then wait for the registry
   to pick up the new version of `libsemigroups_julia_jll`.

4. Bump the dependence in `Semigroups.jl` (in `Project.toml`) to whatever
   version number was used in Step 2.

   Version compatibility notation: <https://pkgdocs.julialang.org/v1/compatibility/>

5. Release a new `Semigroups.jl`. This is done by pinging JuliaRegistrator in
   the comments of a commit.

After the new version of `Semigroups.jl` is picked up by the registry, it may
be used in further downstream packages.

## Updating the libsemigroups kernel

Suppose the `libsemigroups` kernel needs an update. This involves updating both
build scripts because `libsemigroups_julia_jll` will need to point to the new
`libsemigroups_jll`.

1. Update the `libsemigroups` build script with the commit SHA of the
   `libsemigroups` sources at <https://github.com/libsemigroups/libsemigroups>.

   Any build issues need to be communicated to
   <https://github.com/libsemigroups/libsemigroups> until you get a commit that
   builds on all targets.

2. Wait for the Yggdrasil merge, and wait for the registry.

3. Update the `libsemigroups_julia` build scripts with a new version and
   `libsemigroups_jll` dependency.

At this point, we have a new `libsemigroups_julia_jll` in the works, and the
steps are essentially Steps 3-5 in the previous section.

4. The usual waiting.

5. Bump the `libsemigroups_julia_jll` and `libsemigroups_jll` dependencies in
   `Semigroups.jl` (in `Project.toml`).

6. Release new `Semigroups.jl` version.

## Updating both `libsemigroups_julia` and the libsemigroups kernel

Since updating the `libsemigroups` kernel requires an update to
`libsemigroups_julia`, the steps here are the same as in the previous section.
Just make sure that in Step 3, the commit SHA used to update the
`libsemigroups_julia` build scripts contains all of the desired changes to
`libsemigroups_julia`.

## Building a custom `libsemigroups_jll` locally

For testing purposes one may wish to try out `libsemigroups_jll` changes locally
before submitting them as a PR to Yggdrasil. This can be done as shown in the
following shell script:

```shell
# Change into a clone of the Yggdrasil repository
git clone https://github.com/JuliaPackaging/Yggdrasil
cd Yggdrasil

# record the base path
BASEPATH=$(pwd)

# ensure building macOS binaries will work (you can omit this if you only
# want to build for Linux)
export BINARYBUILDER_AUTOMATIC_APPLE=true

# change into the directory containing the `build_tarballs.jl` we want to build
cd L/libsemigroups

# Now `build_tarballs.jl` can be modified, e.g. to pull a different set of
# sources, use different versions of dependencies, etc.

# ensure BinaryBuilder etc. is installed in the right version
# (ideally use the same Julia version as specified in `.ci/Manifest.toml`)
julia --project=$BASEPATH/.ci -e 'using Pkg; Pkg.instantiate()'

# get list of platforms etc.
julia --project=$BASEPATH/.ci build_tarballs.jl --help

# build and deploy the JLL locally. If you omit the comma-separated
# list of PLATFORMS then it will build for *all* platforms
julia --project=$BASEPATH/.ci build_tarballs.jl PLATFORMS --deploy=local
```

The same procedure works for `libsemigroups_julia_jll` — substitute
`L/libsemigroups_julia` for `L/libsemigroups` above.
