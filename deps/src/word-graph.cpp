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

#include <libsemigroups/word-graph.hpp>

#include <cstddef>
#include <cstdint>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::WordGraph<uint32_t>> : std::false_type {
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_word_graph(jl::Module& m) {
    using WordGraph_ = libsemigroups::WordGraph<uint32_t>;

    auto type = m.add_type<WordGraph_>("WordGraph");

    // Constructor: (num_nodes, out_degree)
    type.constructor<std::size_t, std::size_t>();

    // --- Read queries ---

    type.method("number_of_nodes", [](WordGraph_ const& g) -> std::size_t {
      return g.number_of_nodes();
    });

    type.method("out_degree", [](WordGraph_ const& g) -> std::size_t {
      return g.out_degree();
    });

    type.method("target",
                [](WordGraph_ const& g, uint32_t s, uint32_t a) -> uint32_t {
                  return g.target(s, a);
                });

    // --- Mutators ---
    // Getter `target(s, a)` and setter `target(s, a, t)` are same-name
    // different-arity in C++; CxxWrap cannot reliably dispatch these, so the
    // setter is bound under a distinct `target!` name. Returns void -- Julia
    // does not need the *this chaining idiom.

    type.method("target!",
                [](WordGraph_& g, uint32_t s, uint32_t a, uint32_t t) {
                  g.target(s, a, t);
                });

    // libsemigroups' target(s, a, t) rejects t = UNDEFINED (typemax) as
    // out-of-range; clearing an edge requires the distinct `remove_target`
    // entry point. Julia's `target!(g, s, a, UNDEFINED)` dispatches here.
    type.method("remove_target!", [](WordGraph_& g, uint32_t s, uint32_t a) {
      g.remove_target(s, a);
    });

    type.method("add_nodes!",
                [](WordGraph_& g, std::size_t n) { g.add_nodes(n); });
  }

}  // namespace libsemigroups_julia
