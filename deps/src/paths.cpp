//
// Semigroups.jl
// Copyright (C) 2026, James W. Swent
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#include "libsemigroups_julia.hpp"

#include <libsemigroups/order.hpp>
#include <libsemigroups/paths.hpp>
#include <libsemigroups/types.hpp>
#include <libsemigroups/word-graph.hpp>

#include <cstddef>
#include <cstdint>
#include <string>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Paths<uint32_t>> : std::false_type {};
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_paths(jl::Module& m) {
    using Paths_     = libsemigroups::Paths<uint32_t>;
    using WordGraph_ = libsemigroups::WordGraph<uint32_t>;
    using libsemigroups::Order;

    // Registered as "PathsCxx" so the public Julia name `Paths` is free for
    // the high-level wrapper struct in `src/paths.jl`.
    auto type = m.add_type<Paths_>("PathsCxx");

    // Constructor: Paths(WordGraph const&). The C++ object holds only a raw
    // pointer to the WordGraph; lifetime is the Julia wrapper's responsibility
    // (the wrapper struct holds a `g::WordGraph` field that pins it for GC).
    type.constructor<WordGraph_ const&>();

    // --- Validation ---

    type.method("throw_if_source_undefined", [](Paths_ const& self) {
      self.throw_if_source_undefined();
    });

    // --- Range / iteration interface ---

    // `get` returns `word_type const&` in C++ (reference to internal iterator
    // storage that is invalidated by `next`). Copy at the boundary.
    type.method("get", [](Paths_ const& self) -> libsemigroups::word_type {
      return self.get();
    });

    type.method("next!", [](Paths_& self) { self.next(); });

    type.method("at_end",
                [](Paths_ const& self) -> bool { return self.at_end(); });

    type.method("count",
                [](Paths_ const& self) -> uint64_t { return self.count(); });

    // --- Settings: getter / setter pairs ---
    // Same-name different-arity overloads are unreliable in CxxWrap; split
    // setters to use the `!` suffix per Julia convention.

    // source
    type.method("source", [](Paths_ const& self) -> uint32_t {
      return self.source();
    });
    type.method("source!", [](Paths_& self, uint32_t n) { self.source(n); });

    // target — single setter handles both regular and UNDEFINED cases. The
    // underlying libsemigroups `target(n)` short-circuits on `n == UNDEFINED`
    // (paths.hpp:968-973), accepting it as "any reachable target". The Julia
    // wrapper's `target!(p, ::UndefinedType)` arm dispatches into this same
    // call after converting UNDEFINED to typemax(uint32_t).
    type.method("target", [](Paths_ const& self) -> uint32_t {
      return self.target();
    });
    type.method("target!", [](Paths_& self, uint32_t n) { self.target(n); });

    // min
    type.method("min", [](Paths_ const& self) -> std::size_t {
      return self.min();
    });
    type.method("min!",
                [](Paths_& self, std::size_t val) { self.min(val); });

    // max
    type.method("max", [](Paths_ const& self) -> std::size_t {
      return self.max();
    });
    type.method("max!",
                [](Paths_& self, std::size_t val) { self.max(val); });

    // order
    type.method("order",
                [](Paths_ const& self) -> Order { return self.order(); });
    type.method("order!", [](Paths_& self, Order val) { self.order(val); });

    // --- Read-only queries ---

    type.method("current_target", [](Paths_ const& self) -> uint32_t {
      return self.current_target();
    });

    // word_graph returns `WordGraph const&`; the Julia wrapper holds the
    // original WordGraph in its `g` field, so this is rarely needed from
    // Julia. Bound for parity / completeness. Returned as a reference (the
    // caller gets a `CxxBaseRef{WordGraph}`).
    type.method(
        "word_graph",
        [](Paths_ const& self) -> WordGraph_ const& { return self.word_graph(); });

    // --- Display ---
    // `to_human_readable_repr` is a free function template in libsemigroups,
    // bound at module level (not as `type.method`).
    m.method("to_human_readable_repr",
             [](Paths_ const& p) -> std::string {
               return libsemigroups::to_human_readable_repr(p);
             });
  }

}  // namespace libsemigroups_julia
