# Constants

This page describes the constants used in Semigroups.jl.

## Constant Values

```@docs
Semigroups.UNDEFINED
Semigroups.POSITIVE_INFINITY
Semigroups.NEGATIVE_INFINITY
Semigroups.LIMIT_MAX
```

`UNDEFINED` is used to indicate that a value is undefined. It is comparable with other constants via `==` and `!=`, and with integers.

`POSITIVE_INFINITY` represents ``+\infty`` and is comparable via `==`, `!=`, `<`, `>` with any integer and with `NEGATIVE_INFINITY`.

`NEGATIVE_INFINITY` represents ``-\infty`` and is comparable via `==`, `!=`, `<`, `>` with any signed integer and with `POSITIVE_INFINITY`.

`LIMIT_MAX` represents the maximum limit value. It is comparable with integers via `==`, `!=`, `<`, `>`.

## Predicate Functions

```@docs
Semigroups.is_undefined
Semigroups.is_positive_infinity
Semigroups.is_negative_infinity
Semigroups.is_limit_max
```

## Ternary Logic (tril)

The `tril` type represents a ternary logic value that can be true, false, or unknown.

- `tril_TRUE` - Represents a true value
- `tril_FALSE` - Represents a false value
- `tril_unknown` - Represents an unknown/undetermined value

```@docs
Semigroups.tril_to_bool
```
