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

#include <libsemigroups/presentation-examples.hpp>
#include <libsemigroups/presentation.hpp>
#include <libsemigroups/types.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <vector>

namespace libsemigroups_julia {

  void define_presentation_examples(jl::Module& m) {
    using libsemigroups::Presentation;
    using libsemigroups::word_type;
    namespace examples = libsemigroups::presentation::examples;

    m.method("example_symmetric_group",
             [](size_t n) -> Presentation<word_type> {
               return examples::symmetric_group(n);
             });
    m.method("example_alternating_group",
             [](size_t n) -> Presentation<word_type> {
               return examples::alternating_group(n);
             });
    m.method("example_braid_group", [](size_t n) -> Presentation<word_type> {
      return examples::braid_group(n);
    });
    m.method("example_not_symmetric_group",
             [](size_t n) -> Presentation<word_type> {
               return examples::not_symmetric_group(n);
             });
    m.method("example_full_transformation_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::full_transformation_monoid(n);
             });
    m.method("example_partial_transformation_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::partial_transformation_monoid(n);
             });
    m.method("example_symmetric_inverse_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::symmetric_inverse_monoid(n);
             });
    m.method("example_cyclic_inverse_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::cyclic_inverse_monoid(n);
             });
    m.method("example_order_preserving_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::order_preserving_monoid(n);
             });
    m.method("example_order_preserving_cyclic_inverse_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::order_preserving_cyclic_inverse_monoid(n);
             });
    m.method("example_orientation_preserving_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::orientation_preserving_monoid(n);
             });
    m.method("example_orientation_preserving_reversing_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::orientation_preserving_reversing_monoid(n);
             });
    m.method("example_partition_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::partition_monoid(n);
             });
    m.method("example_partial_brauer_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::partial_brauer_monoid(n);
             });
    m.method("example_brauer_monoid", [](size_t n) -> Presentation<word_type> {
      return examples::brauer_monoid(n);
    });
    m.method("example_singular_brauer_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::singular_brauer_monoid(n);
             });
    m.method("example_temperley_lieb_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::temperley_lieb_monoid(n);
             });
    m.method("example_motzkin_monoid", [](size_t n) -> Presentation<word_type> {
      return examples::motzkin_monoid(n);
    });
    m.method("example_partial_isometries_cycle_graph_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::partial_isometries_cycle_graph_monoid(n);
             });
    m.method("example_uniform_block_bijection_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::uniform_block_bijection_monoid(n);
             });
    m.method("example_dual_symmetric_inverse_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::dual_symmetric_inverse_monoid(n);
             });
    m.method("example_stellar_monoid", [](size_t l) -> Presentation<word_type> {
      return examples::stellar_monoid(l);
    });
    m.method("example_zero_rook_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::zero_rook_monoid(n);
             });
    m.method("example_abacus_jones_monoid",
             [](size_t n, size_t d) -> Presentation<word_type> {
               return examples::abacus_jones_monoid(n, d);
             });

    // ---- batch C: plactic / misc ----

    m.method("example_plactic_monoid", [](size_t n) -> Presentation<word_type> {
      return examples::plactic_monoid(n);
    });
    m.method("example_chinese_monoid", [](size_t n) -> Presentation<word_type> {
      return examples::chinese_monoid(n);
    });
    m.method("example_hypo_plactic_monoid",
             [](size_t n) -> Presentation<word_type> {
               return examples::hypo_plactic_monoid(n);
             });
    m.method("example_stylic_monoid", [](size_t n) -> Presentation<word_type> {
      return examples::stylic_monoid(n);
    });
    m.method("example_special_linear_group_2",
             [](size_t q) -> Presentation<word_type> {
               return examples::special_linear_group_2(q);
             });
    m.method("example_fibonacci_semigroup",
             [](size_t r, size_t n) -> Presentation<word_type> {
               return examples::fibonacci_semigroup(r, n);
             });
    m.method("example_monogenic_semigroup",
             [](size_t m, size_t r) -> Presentation<word_type> {
               return examples::monogenic_semigroup(m, r);
             });
    m.method("example_rectangular_band",
             [](size_t m, size_t n) -> Presentation<word_type> {
               return examples::rectangular_band(m, n);
             });
    m.method("example_sigma_plactic_monoid",
             [](jlcxx::ArrayRef<size_t> sigma) -> Presentation<word_type> {
               return examples::sigma_plactic_monoid(
                   std::vector<size_t>(sigma.begin(), sigma.end()));
             });
    m.method("example_renner_type_B_monoid",
             [](size_t l, int q) -> Presentation<word_type> {
               return examples::renner_type_B_monoid(l, q);
             });
    m.method("example_renner_type_D_monoid",
             [](size_t l, int q) -> Presentation<word_type> {
               return examples::renner_type_D_monoid(l, q);
             });
    m.method("example_not_renner_type_B_monoid",
             [](size_t l, int q) -> Presentation<word_type> {
               return examples::not_renner_type_B_monoid(l, q);
             });
    m.method("example_not_renner_type_D_monoid",
             [](size_t l, int q) -> Presentation<word_type> {
               return examples::not_renner_type_D_monoid(l, q);
             });
  }

}  // namespace libsemigroups_julia
