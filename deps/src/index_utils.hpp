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

// Utility functions for converting between Julia's 1-based indexing
// and C++'s 0-based indexing at the CxxWrap binding boundary.
//
// Convention for UNDEFINED:
//   - Julia side: 0 represents UNDEFINED (since 0 is never a valid 1-based
//   index)
//   - C++ side: std::numeric_limits<T>::max() represents UNDEFINED
//   - The _undef variants handle this conversion automatically
// This is the simplest implementation if we assume 0 is never a valid input
// index, as trying to use typemax results in edge cases (e.g. Transf Scalar
// boundary)

#ifndef LIBSEMIGROUPS_JULIA_INDEX_UTILS_HPP_
#define LIBSEMIGROUPS_JULIA_INDEX_UTILS_HPP_

#include <limits>
#include <type_traits>
#include <vector>

namespace libsemigroups_julia {

  ////////////////////////////////////////////////////////////////////////
  // Single-value conversions
  ////////////////////////////////////////////////////////////////////////

  // 1-based → 0-based (for passing indices into libsemigroups)
  template <typename T>
  inline T to_0_based(T val) {
    static_assert(std::is_unsigned_v<T>,
                  "Index conversion requires unsigned types");
    return val - 1;
  }

  // 0-based → 1-based (for returning indices from libsemigroups)
  template <typename T>
  inline T to_1_based(T val) {
    static_assert(std::is_unsigned_v<T>,
                  "Index conversion requires unsigned types");
    return val + 1;
  }

  // 1-based → 0-based with UNDEFINED handling:
  // Julia sends 0 for UNDEFINED → convert to typemax (libsemigroups sentinel)
  // Julia sends 1-based index → subtract 1
  template <typename T>
  inline T to_0_based_undef(T val) {
    static_assert(std::is_unsigned_v<T>,
                  "Index conversion requires unsigned types");
    return val == T(0) ? std::numeric_limits<T>::max() : val - 1;
  }

  // 0-based → 1-based with UNDEFINED handling:
  // C++ has typemax for UNDEFINED → convert to 0 (Julia sentinel)
  // C++ has 0-based index → add 1
  template <typename T>
  inline T to_1_based_undef(T val) {
    static_assert(std::is_unsigned_v<T>,
                  "Index conversion requires unsigned types");
    return val == std::numeric_limits<T>::max() ? T(0) : val + 1;
  }

  ////////////////////////////////////////////////////////////////////////
  // Vector conversions
  ////////////////////////////////////////////////////////////////////////

  template <typename T>
  inline std::vector<T> vec_to_0_based(std::vector<T> const& v) {
    std::vector<T> r;
    r.reserve(v.size());
    for (auto x : v) {
      r.push_back(to_0_based(x));
    }
    return r;
  }

  template <typename T>
  inline std::vector<T> vec_to_1_based(std::vector<T> const& v) {
    std::vector<T> r;
    r.reserve(v.size());
    for (auto x : v) {
      r.push_back(to_1_based(x));
    }
    return r;
  }

  template <typename T>
  inline std::vector<T> vec_to_0_based_undef(std::vector<T> const& v) {
    std::vector<T> r;
    r.reserve(v.size());
    for (auto x : v) {
      r.push_back(to_0_based_undef(x));
    }
    return r;
  }

  template <typename T>
  inline std::vector<T> vec_to_1_based_undef(std::vector<T> const& v) {
    std::vector<T> r;
    r.reserve(v.size());
    for (auto x : v) {
      r.push_back(to_1_based_undef(x));
    }
    return r;
  }

}  // namespace libsemigroups_julia

#endif  // LIBSEMIGROUPS_JULIA_INDEX_UTILS_HPP_
