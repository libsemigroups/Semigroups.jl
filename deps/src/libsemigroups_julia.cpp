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

// This file defines the main Julia module that wraps libsemigroups
// functionality.

#include "libsemigroups_julia.hpp"

namespace libsemigroups_julia {

JLCXX_MODULE define_julia_module(jl::Module & mod)
{
  // Define constants first (UNDEFINED, POSITIVE_INFINITY, etc.)
  define_constants(mod);

  // Define base types (must be registered before derived types)
  define_runner(mod);

  // Define WordGraph (must be before FroidurePinBase)
  define_word_graph(mod);

  // Define FroidurePinBase (inherits Runner, uses WordGraph)
  define_froidure_pin_base(mod);

  // Define element types
  define_transf(mod);

  // Define FroidurePin<E> template instantiations
  // Must be AFTER transf (element types) AND froidure_pin_base
  define_froidure_pin(mod);
}

}    // namespace libsemigroups_julia
