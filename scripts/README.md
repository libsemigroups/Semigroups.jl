# Scripts

This directory contains development scripts for Semigroups.jl.

## Setup

Create and activate a Python virtual environment:

```bash
python3 -m venv scripts/.venv
source scripts/.venv/bin/activate
pip install -r scripts/requirements.txt
```

## generate_jlcxx.py

Generates JlCxx (CxxWrap.jl) C++ binding stubs from Doxygen XML output. This script parses libsemigroups Doxygen documentation and produces starter code matching the patterns in `deps/src/`.

### Usage

```bash
# Direct invocation
source scripts/.venv/bin/activate
python3 scripts/generate_jlcxx.py \
  --doxy-dir ../libsemigroups/docs/xml \
  libsemigroups::BMat8 > deps/src/bmat8_generated.cpp

# Multiple things
python3 scripts/generate_jlcxx.py \
  --doxy-dir ../libsemigroups/docs/xml \
  libsemigroups::BMat8 libsemigroups::bmat8
```

### Options

| Flag                 | Description                                         |
| -------------------- | --------------------------------------------------- |
| `--doxy-dir DIR`     | Path to Doxygen XML output (default: `docs/xml`)    |
| `--no-header-footer` | Suppress copyright, includes, and namespace wrapper |
| `--no-advice`        | Suppress the "things to do" checklist at the end    |

### Output Structure

For **non-template classes** (e.g., `BMat8`):

```cpp
// IsMirroredType specialization
namespace jlcxx {
template <> struct IsMirroredType<libsemigroups::BMat8> : std::false_type {};
}

namespace libsemigroups_julia {

void define_TODO(jl::Module & m)
{
  using namespace libsemigroups;

  auto type = m.add_type<BMat8>("BMat8");

  // Constructors
  type.constructor<>();
  m.method("BMat8", [](uint64_t mat) -> BMat8 { return BMat8(mat); });

  // Methods
  type.method("degree", &BMat8::degree);
  type.method("is_equal", [](BMat8 const & a, BMat8 const & b) -> bool { ... });
  // ...
}

}
```

For **template classes** (e.g., `Transf`, `PTransfBase`):

```cpp
namespace libsemigroups_julia {

namespace {

template <typename TType>
void bind_TODO_common(jl::Module & m,
                      jlcxx::TypeWrapper<TType> & type,
                      std::string const & type_name)
{
  using Scalar = typename TType::point_type; // TODO: adjust alias

  // Method bindings using TType
  type.method("degree", &TType::degree);
  // ...
}

template <typename TType>
void bind_TODO_type(jl::Module & m, std::string const & name)
{
  auto type = m.add_type<TType>(name);
  bind_TODO_common(m, type, name);
}

}

void define_TODO(jl::Module & m)
{
  using namespace libsemigroups;
  // TODO: add instantiations
  // bind_TODO_type<Transf<0, uint8_t>>(m, "Transf1");
}

}
```

### What Gets Generated

| C++ Feature                      | JlCxx Pattern                                                                        |
| -------------------------------- | ------------------------------------------------------------------------------------ |
| Default constructor              | `type.constructor<>();`                                                              |
| Parameterized constructor        | `m.method("ClassName", [](params) -> T { return T(params); });`                      |
| Instance method (non-overloaded) | `type.method("name", &T::name);`                                                     |
| Instance method (overloaded)     | `type.method("name", [](T const& self, params) { return self.name(params); });`      |
| Static method                    | `m.method("name", [](jlcxx::SingletonType<T>, params) { return T::name(params); });` |
| `operator==`, `!=`, `<`, etc.    | `type.method("is_equal", [](T const& a, T const& b) -> bool { return a == b; });`    |
| `operator*`, `+`                 | `type.method("multiply", [](T const& a, T const& b) { return a * b; });`             |
| `operator*=`, `+=`               | `type.method("multiply!", [](T& self, T const& other) { self *= other; });`          |
| `at` (element access)            | `type.method("at", [](T const& self, size_t i) { return self.at(i); });`             |
| `hash_value`                     | `type.method("hash", &T::hash_value);`                                               |
| Iterators (`cbegin`/`cend`)      | `type.method("images_vector", [](T const& self) { ... collect to vector ... });`     |
| Enums                            | `m.add_bits<E>("name", jl::julia_type("CppEnum"));` + `m.set_const(...)`             |
| Free functions                   | `m.method("name", [](params) { return name(params); });`                             |

### What Gets Skipped

- `_no_checks` suffixed functions
- `initializer_list` parameters
- Move semantics (`&&` parameters)
- Raw pointer parameters/returns
- `operator=`, `operator[]`, `operator<<`, `operator()`
- `end`/`cend` iterators (uses `cbegin` for `images_vector`)
- Typedefs
- Deleted members
- Non-public members

### Limitations

#### 1. Template Parameter Names Are Not Resolved

The Doxygen XML contains literal template parameter names that need manual replacement:

```cpp
// Generated (problematic):
m.method(type_name, [](Container const & cont) -> TType { ... });
type.method("multiply", [](TType const & self, Subclass const & that) { ... });

// Should be:
m.method(type_name, [](std::vector<Scalar> const & imgs) -> TType { ... });
type.method("multiply", [](TType const & a, TType const & b) { ... });
```

#### 2. Inherited Methods Not Automatically Included

For class hierarchies like `Transf` -> `StaticPTransf` -> `PTransfBase`, methods from base classes appear in separate Doxygen files. You need to generate bindings for each class and merge manually.

Example: `increase_degree_by` is in `StaticPTransf`, not `PTransfBase` or `Transf`.

#### 3. Constructor Validation Pattern Differs

Hand-written code often uses `make<T>()` for input validation:

```cpp
// Hand-written (preferred):
m.method(type_name, [](std::vector<Scalar> const & imgs) -> PTransfType {
  return libsemigroups::make<PTransfType>(imgs);  // validates input
});

// Generated:
m.method(type_name, [](std::vector<Scalar> const & imgs) -> TType {
  return TType(imgs);  // no validation
});
```

#### 4. Julia Naming Conventions Need Manual Adjustment

| Generated            | Julia Convention      | Action  |
| -------------------- | --------------------- | ------- |
| `at`                 | `getindex`            | rename  |
| `multiply!`          | correct               | keep    |
| `product_inplace`    | `product_inplace!`    | add `!` |
| `increase_degree_by` | `increase_degree_by!` | add `!` |

#### 5. Method Placement Decisions

Some methods work better as module-level functions than type methods:

```cpp
// Generated as type method:
type.method("product_inplace", &TType::product_inplace);

// Hand-written as module method (allows 3-arg form):
m.method("product_inplace!", [](TType & xy, TType const & x, TType const & y) {
  xy.product_inplace(x, y);
});
```

#### 6. swap Should Use Lambda

To avoid exposing base class types in the signature:

```cpp
// Generated (may expose base class):
type.method("swap", &TType::swap);

// Hand-written (cleaner):
type.method("swap", [](TType & self, TType & other) { self.swap(other); });
```

### Comparison: BMat8 (Non-Template)

For non-template classes, generated output closely matches hand-written code (~95% match):

| Feature              | Generated                | Hand-written | Match |
| -------------------- | ------------------------ | ------------ | ----- |
| Type declaration     | ✓                        | ✓            | ✓     |
| IsMirroredType       | ✓                        | ✓            | ✓     |
| Default constructor  | ✓                        | ✓            | ✓     |
| Param constructors   | ✓                        | ✓            | ✓     |
| Comparison operators | ✓ all 6                  | ✓ all 6      | ✓     |
| Arithmetic operators | ✓ with correct overloads | ✓            | ✓     |
| Instance methods     | ✓                        | ✓            | ✓     |
| Free functions       | ✓ (separate namespace)   | ✓            | ✓     |

### Comparison: Transf (Template Hierarchy)

For template class hierarchies, generated output is ~70-80% complete:

| Feature                  | Generated            | Hand-written    | Status       |
| ------------------------ | -------------------- | --------------- | ------------ |
| Template structure       | ✓                    | ✓               | ✓            |
| Static `one()`           | ✓                    | ✓               | ✓            |
| Comparison operators     | ✓                    | ✓               | ✓            |
| `degree`, `rank`         | ✓                    | ✓               | ✓            |
| `hash`                   | ✓                    | ✓               | ✓            |
| `images_vector`          | ✓                    | ✓               | ✓            |
| Constructor              | ✗ unresolved types   | ✓ uses `make<>` | needs fix    |
| `multiply`               | ✗ `Subclass` literal | ✓ same type     | needs fix    |
| `copy`                   | ✗ missing            | ✓               | add manually |
| `increase_degree_by!`    | ✗ in different class | ✓               | add manually |
| Naming (`getindex`, `!`) | ✗                    | ✓               | rename       |

### Post-Generation Checklist

After generating bindings:

1. Save output to `deps/src/<name>.cpp`
2. Rename `define_TODO` / `bind_TODO` to `define_<name>` / `bind_<name>`
3. Replace unresolved template params (`Container`, `Iterator`, `Subclass`)
4. Add `make<>` wrapper for constructors if validation needed
5. Rename methods to Julia conventions (`at` -> `getindex`, add `!` suffix)
6. Add missing methods from base classes
7. Add `copy` method if needed
8. Forward-declare in `deps/src/libsemigroups_julia.hpp`
9. Call from `deps/src/libsemigroups_julia.cpp`
10. Add to `CMakeLists.txt`
11. Create Julia wrappers in `src/`
12. Add tests in `test/`

### Architecture

The script reuses Doxygen XML parsing from `libsemigroups/etc/generate_pybind11.py` and rewrites code generation for JlCxx:

```
[1] CLI parsing, globals
[2] Doxygen XML parsing (from generate_pybind11.py)
    - doxygen_filename(), get_xml(), is_public(), is_typedef(), etc.
[3] JlCxx code generation (new)
    - jlcxx_constructor(), jlcxx_operator(), jlcxx_iterator(), etc.
[4] Skip logic (adapted from pybind11)
[5] Template structure generation
[6] main()
```

### Dependencies

- `beautifulsoup4` - XML parsing
- `lxml` - XML backend
- `accepts` - Type checking decorators
