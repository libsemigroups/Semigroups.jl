//
// Semigroups.jl
// Copyright (C) 2026 James D. Mitchell
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

#include <libsemigroups/forest.hpp>

// Disable CxxWrap mirroring for Forest
namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Forest> : std::false_type {};
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_forest(jl::Module& m) {
    using namespace libsemigroups;
    using node_type = Forest::node_type;

    auto type = m.add_type<Forest>("Forest");

    m.method("Forest", [](size_t n) -> Forest { return Forest(n); });
    m.method("forest_make",
             [](std::vector<uint32_t> const& parents,
                std::vector<uint32_t> const& labels) -> Forest {
               // TODO avoid copies here, i.e. the copying of Julia Vector into
               // std::vector
               return make<Forest>(parents, labels);
             });
    type.method("forest_add_nodes", &Forest::add_nodes);
    type.method("forest_empty", &Forest::empty);
    type.method("forest_init", &Forest::init);
    type.method("forest_label", &Forest::label);
    type.method("forest_labels", &Forest::labels);
    type.method("forest_number_of_nodes", &Forest::number_of_nodes);
    type.method(
        "forest_is_not_equal",
        [](Forest const& a, Forest const& b) -> bool { return a != b; });
    type.method(
        "forest_is_equal",
        [](Forest const& a, Forest const& b) -> bool { return a == b; });
    type.method("forest_parent", &Forest::parent);
    type.method("forest_parents", &Forest::parents);
    type.method("forest_set_parent_and_label", &Forest::set_parent_and_label);
    type.method("forest_to_human_readable_repr",
                [](Forest const& f) { return to_human_readable_repr(f); });

    m.method("forest_depth", [](Forest const& f, Forest::node_type n) {
      return forest::depth(f, n);
    });
    // TODO  uncomment when Dot is implemented
    // m.method("dot", [](Forest const& f) { return forest::dot(f); });
    // m.method("dot",
    //          [](Forest const& f, std::vector<std::string> const& labels) {
    //            return forest::dot(f, labels);
    //          });
    m.method("forest_is_forest",
             [](Forest const& f) { return forest::is_forest(f); });
    m.method("forest_is_root", [](Forest const& f, Forest::node_type n) {
      return forest::is_root(f, n);
    });
    m.method("forest_max_label",
             [](Forest const& f) { return forest::max_label(f); });
    m.method("forest_path_from_root", [](Forest const& f, Forest::node_type n) {
      return forest::path_from_root(f, n);
    });
    m.method("forest_path_to_root", [](Forest const& f, Forest::node_type n) {
      return forest::path_to_root(f, n);
    });

  }  // define_forest

}  // namespace libsemigroups_julia
