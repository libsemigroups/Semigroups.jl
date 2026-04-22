// froidure-pin-base.cpp - FroidurePinBase bindings for libsemigroups_julia
//
// Copyright (c) 2026 James W. Swent
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
// This file exposes the libsemigroups FroidurePinBase class to Julia via
// CxxWrap. FroidurePinBase is an abstract base class inheriting from Runner
// that provides non-element-specific member functions for FroidurePin<E>.

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/froidure-pin-base.hpp>
#include <libsemigroups/runner.hpp>

#include <cstddef>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::FroidurePinBase> : std::false_type {};

  template <>
  struct SuperType<libsemigroups::FroidurePinBase> {
    using type = libsemigroups::Runner;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_froidure_pin_base(jl::Module& m) {
    using libsemigroups::FroidurePinBase;
    using libsemigroups::Runner;

    // Register FroidurePinBase inheriting from Runner.
    // No constructors — this is an abstract base class only instantiated
    // through FroidurePin<E>.
    auto type = m.add_type<FroidurePinBase>(
        "FroidurePinBase", jlcxx::julia_base_type<Runner>());

    ////////////////////////////////////////////////////////////////////////
    // Minimal methods to prove the type is wired up
    ////////////////////////////////////////////////////////////////////////

    // size - Returns the total number of elements (triggers full enumeration)
    type.method("size", [](FroidurePinBase& self) -> size_t {
      return self.size();
    });

    // current_size - Returns elements enumerated so far (no enumeration)
    type.method("current_size",
                [](FroidurePinBase const& self) -> size_t {
                  return self.current_size();
                });

    // degree - Returns the degree of the elements
    type.method("degree", [](FroidurePinBase const& self) -> size_t {
      return self.degree();
    });

    // number_of_generators - Returns the number of generators
    type.method("number_of_generators",
                [](FroidurePinBase const& self) -> size_t {
                  return self.number_of_generators();
                });
  }

}  // namespace libsemigroups_julia
