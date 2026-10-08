//
// Semigroups.jl
// Copyright (C) 2026, Joseph E. Macgowan
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

#include <libsemigroups/froidure-pin-base.hpp>
#include <libsemigroups/knuth-bendix-class.hpp>
#include <libsemigroups/to-knuth-bendix.hpp>
#include <libsemigroups/todd-coxeter-class.hpp>
#include <libsemigroups/types.hpp>

namespace libsemigroups_julia {

  void define_to_knuth_bendix(jl::Module& m) {
    using KB = libsemigroups::KnuthBendix<libsemigroups::word_type,
                                          libsemigroups::detail::RewriteTrie,
                                          libsemigroups::ShortLexCompare>;

    // FroidurePinBase and congruence kind to KnuthBendix<word_type>.
    m.method("to_knuth_bendix_from_fpb",
             [](libsemigroups::congruence_kind  knd,
                libsemigroups::FroidurePinBase& fpb) {
               return libsemigroups::to<KB>(knd, fpb);
             });

    // ToddCoxeter and congruence kind to KnuthBendix<word_type>.
    m.method("to_knuth_bendix_from_tc",
             [](libsemigroups::congruence_kind                        knd,
                libsemigroups::ToddCoxeter<libsemigroups::word_type>& tc) {
               return libsemigroups::to<KB>(knd, tc);
             });
  }

}  // namespace libsemigroups_julia
