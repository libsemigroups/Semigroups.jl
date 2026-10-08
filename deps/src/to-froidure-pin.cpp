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

#include <cstdint>

#include <libsemigroups/froidure-pin.hpp>
#include <libsemigroups/to-froidure-pin.hpp>
#include <libsemigroups/transf.hpp>
#include <libsemigroups/word-graph.hpp>

namespace libsemigroups_julia {

  void define_to_froidure_pin(jl::Module& m) {
    using FP = libsemigroups::FroidurePin<libsemigroups::Transf<0, uint32_t>>;

    // Complete WordGraph to FroidurePin<Transf<0, uint32_t>>. The wider
    m.method("to_froidure_pin_from_wg",
             [](libsemigroups::WordGraph<uint32_t> const& wg) {
               return libsemigroups::to<FP>(wg);
             });
  }

}  // namespace libsemigroups_julia
