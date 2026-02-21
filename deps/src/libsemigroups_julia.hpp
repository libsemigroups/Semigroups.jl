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

// This file provides the common includes and forward declarations used
// throughout the Julia bindings for libsemigroups.

#ifndef LIBSEMIGROUPS_JULIA_HPP_
#define LIBSEMIGROUPS_JULIA_HPP_

// JlCxx headers FIRST — these pull in standard library headers (<string>,
// <memory>, etc.) that on libstdc++ use __cpp_lib_is_constant_evaluated to
// decide constexpr-ness. They must be included while the macro is intact.
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/stl.hpp"

// FIX for fmt consteval issue:
// JlCxx requires C++20, but libsemigroups bundles fmt which enables
// consteval format string validation in C++20 mode, causing compile errors
// when inline functions pass runtime std::string_view to fmt::format.
//
// fmt/base.h unconditionally defines FMT_USE_CONSTEVAL via an #if/#elif
// chain (no #ifndef guard), so pre-defining it has no effect. Instead we
// #undef __cpp_lib_is_constant_evaluated AFTER all standard library headers
// are included (so their constexpr declarations are correct) but BEFORE any
// libsemigroups/fmt headers. When fmt/base.h later includes <type_traits>,
// include guards prevent re-parsing, so the macro stays undefined and fmt
// takes the !defined(__cpp_lib_is_constant_evaluated) branch, setting
// FMT_USE_CONSTEVAL=0.
#undef __cpp_lib_is_constant_evaluated

// libsemigroups headers (these transitively include fmt)
#include <libsemigroups/constants.hpp>
#include <libsemigroups/types.hpp>

// Index conversion utilities (1-based ↔ 0-based)
#include "index_utils.hpp"

namespace libsemigroups_julia {

  // Namespace aliases for convenience
  namespace jl            = jlcxx;
  namespace libsemigroups = ::libsemigroups;

  // Forward declarations of binding functions
  void define_constants(jl::Module& mod);
  void define_report(jl::Module& mod);
  void define_runner(jl::Module& mod);
  void define_transf(jl::Module& mod);
  void define_bmat8(jl::Module& mod);

}  // namespace libsemigroups_julia

#endif  // LIBSEMIGROUPS_JULIA_HPP_
