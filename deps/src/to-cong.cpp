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

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <cstdint>

#include <libsemigroups/cong-class.hpp>         // for Congruence
#include <libsemigroups/froidure-pin-base.hpp>  // for FroidurePinBase
#include <libsemigroups/to-cong.hpp>            // for to<Congruence<Word>>
#include <libsemigroups/types.hpp>       // for congruence_kind, word_type
#include <libsemigroups/word-graph.hpp>  // for WordGraph

namespace libsemigroups_julia {

  void define_to_cong(jl::Module& m) {
    // FroidurePin + Cayley-graph form. Throws LibsemigroupsException if `wg`
    // is neither `fpb.left_cayley_graph()` nor `fpb.right_cayley_graph()`
    // (see to-cong.tpp).
    m.method("to_congruence_from_fpb",
             [](libsemigroups::congruence_kind            knd,
                libsemigroups::FroidurePinBase&           fpb,
                libsemigroups::WordGraph<uint32_t> const& wg)
                 -> libsemigroups::Congruence<libsemigroups::word_type> {
               return libsemigroups::to<
                   libsemigroups::Congruence<libsemigroups::word_type>>(
                   knd, fpb, wg);
             });

    // WordGraph-only form. Performs no validation of `wg`; the resulting
    // Congruence wraps a ToddCoxeter built directly from the graph.
    m.method("to_congruence_from_wg",
             [](libsemigroups::congruence_kind            knd,
                libsemigroups::WordGraph<uint32_t> const& wg)
                 -> libsemigroups::Congruence<libsemigroups::word_type> {
               return libsemigroups::to<
                   libsemigroups::Congruence<libsemigroups::word_type>>(knd,
                                                                        wg);
             });
  }

}  // namespace libsemigroups_julia
