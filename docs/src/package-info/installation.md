# Installation

## Requirements

- Julia 1.9 or later
- CMake 3.15 or later (for building C++ bindings)
- A C++17 compatible compiler

## Installing from Source

Currently, Semigroups.jl must be installed from source:

```julia
using Pkg
Pkg.add(url="https://github.com/jswent/Semigroups.jl")
```

## Building the C++ Bindings

The package automatically builds the required C++ bindings during installation. If you need to rebuild manually:

```julia
using Pkg
Pkg.build("Semigroups")
```

## Verifying Installation

```julia
using Semigroups

# Test basic functionality
t = Transf([2, 1])
println(degree(t))  # Should print 2
```

## Troubleshooting

### Library Loading Errors

If you encounter errors loading the shared library, ensure:
1. CMake is installed and available in your PATH
2. You have a C++17 compatible compiler (GCC 7+, Clang 5+, or MSVC 2017+)
3. The libsemigroups library is accessible

### Build Failures

For build issues, try:

```julia
using Pkg
Pkg.build("Semigroups"; verbose=true)
```

This will show detailed build output to help diagnose problems.
