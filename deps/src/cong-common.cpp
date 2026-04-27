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

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/detail/cong-common-class.hpp>
#include <libsemigroups/runner.hpp>

#include <type_traits>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::detail::CongruenceCommon>
      : std::false_type {};

  template <>
  struct SuperType<libsemigroups::detail::CongruenceCommon> {
    using type = libsemigroups::Runner;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_cong_common(jl::Module& m) {
    using libsemigroups::Runner;
    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;

    // No constructors: CongruenceCommon is a shared implementation base.
    // Derived algorithms register their concrete methods on their own types,
    // and instantiate the cong-common helper templates from cong-common.hpp
    // in their own translation units (see knuth-bendix.cpp,
    // todd-coxeter.cpp, ...).
    m.add_type<CongruenceCommon>("CongruenceCommon",
                                 jlcxx::julia_base_type<Runner>());
  }

}  // namespace libsemigroups_julia
