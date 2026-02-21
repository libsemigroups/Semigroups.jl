# Exceptions

Semigroups.jl provides error handling utilities for managing errors that may occur in the underlying C++ library.

## Error Handling Functions

```@docs
Semigroups.have_error
Semigroups.check_error!
Semigroups.clear_errors!
Semigroups.get_and_clear_errors
```

## Usage

The C++ library may set error flags during computation. Use these functions to check for and handle errors:

```julia
using Semigroups

# Check if any errors occurred
if have_error()
    # Get error messages and clear the error state
    errors = get_and_clear_errors()
    for err in errors
        println("Error: ", err)
    end
end

# Or automatically throw if errors exist
check_error!()  # Throws if there are pending errors
```

## Exception Types

Errors from the C++ library are converted to Julia exceptions. The main exception types are:

- `ErrorException` - General errors from libsemigroups operations
- `ArgumentError` - Invalid arguments passed to functions
- `BoundsError` - Index out of bounds (e.g., accessing transformation images)
