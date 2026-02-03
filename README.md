<h1>
<p align="center">
<img src="docs/pictures/banner.png" height="128" alt="Semigroups.jl">
</p>
</h1>
<p align="center">
Julia bindings for the <a href="https://libsemigroups.readthedocs.io/">libsemigroups</a> C++ library.
<br />

## Installation

### Prerequisites

- **Julia** >= 1.9
- **libsemigroups** installed system-wide (tested with version >= 3.2.0)
- **CMake** >= 3.15
- **C++17 compiler**

### Installing Semigroups.jl

Currently under development. To install from the local repository:

```julia
using Pkg
Pkg.develop(path="/path/to/Semigroups.jl")
```

The C++ glue library will be automatically built during package precompilation.

## Development

A Makefile is provided for common tasks:

| Command | Description |
|---------|-------------|
| `make test` | Run the test suite |
| `make docs` | Build documentation |
| `make docs-serve` | Build and serve docs locally |
| `make build` | Build C++ bindings |
| `make clean` | Clean build artifacts |
| `make format` | Format Julia and C++ code |

## Documentation

Build and serve the documentation locally:

```bash
make docs-serve
```

Then open http://localhost:8000 in your browser.
