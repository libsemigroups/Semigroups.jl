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

#include "libsemigroups_julia.hpp"

#include <cstddef>
#include <cstdint>
#include <vector>

namespace libsemigroups_julia {

void define_word_graph(jl::Module & m)
{
  using WG = libsemigroups::WordGraph<uint32_t>;

  auto type = m.add_type<WG>("WordGraph");

  //////////////////////////////////////////////////////////////////////////
  // Constructor
  //////////////////////////////////////////////////////////////////////////

  m.method("WordGraph", [](size_t num_nodes, size_t out_deg) -> WG {
    return WG(num_nodes, out_deg);
  });

  //////////////////////////////////////////////////////////////////////////
  // Size / structure queries
  //////////////////////////////////////////////////////////////////////////

  // number_of_nodes - total number of nodes in the graph
  type.method("number_of_nodes", &WG::number_of_nodes);

  // out_degree - number of edge labels (same for all nodes)
  type.method("out_degree", &WG::out_degree);

  // number_of_edges - total number of defined edges (all nodes)
  type.method("number_of_edges", [](WG const & self) -> size_t {
    return self.number_of_edges();
  });

  // number_of_edges_node - number of defined edges from a specific node
  // Julia passes 1-based node index
  type.method("number_of_edges_node", [](WG const & self, uint32_t s) -> size_t {
    return self.number_of_edges(to_0_based(s));
  });

  //////////////////////////////////////////////////////////////////////////
  // Edge lookup
  //////////////////////////////////////////////////////////////////////////

  // target - get the target of edge (source, label).
  // Julia passes 1-based source and label, returns 1-based target (0 = UNDEFINED)
  type.method("target", [](WG const & self, uint32_t source, uint32_t label) -> uint32_t {
    return to_1_based_undef(self.target(to_0_based(source), to_0_based(label)));
  });

  // next_label_and_target - find next defined edge from node s with label >= a.
  // Returns a 2-element vector [label, target] since CxxWrap can't return std::pair.
  // Julia passes 1-based s and a, returns 1-based label/target (0 = UNDEFINED)
  type.method("next_label_and_target_vec",
      [](WG const & self, uint32_t s, uint32_t a) -> std::vector<uint32_t> {
        auto [label, target] = self.next_label_and_target(to_0_based(s), to_0_based(a));
        return {to_1_based_undef(label), to_1_based_undef(target)};
      });

  //////////////////////////////////////////////////////////////////////////
  // Iteration helpers (collect to vector for CxxWrap)
  //////////////////////////////////////////////////////////////////////////

  // targets_vector - all targets from a given source node as a vector.
  // Julia passes 1-based source, returns 1-based targets (0 = UNDEFINED)
  type.method(
      "targets_vector", [](WG const & self, uint32_t source) -> std::vector<uint32_t> {
        auto src = to_0_based(source);
        std::vector<uint32_t> result;
        result.reserve(self.out_degree());
        for (auto it = self.cbegin_targets(src); it != self.cend_targets(src); ++it)
        {
          result.push_back(to_1_based_undef(*it));
        }
        return result;
      });

  //////////////////////////////////////////////////////////////////////////
  // Comparison
  //////////////////////////////////////////////////////////////////////////

  type.method("is_equal", [](WG const & a, WG const & b) -> bool {
    return a == b;
  });
  type.method("is_not_equal", [](WG const & a, WG const & b) -> bool {
    return a != b;
  });
  type.method("is_less", [](WG const & a, WG const & b) -> bool {
    return a < b;
  });

  //////////////////////////////////////////////////////////////////////////
  // Copy and hash
  //////////////////////////////////////////////////////////////////////////

  // copy - returns a deep copy
  type.method("copy", [](WG const & self) -> WG {
    return WG(self);
  });

  // hash - for use in Julia Base.hash
  type.method("hash", [](WG const & self) -> size_t {
    return self.hash_value();
  });
}

}    // namespace libsemigroups_julia
