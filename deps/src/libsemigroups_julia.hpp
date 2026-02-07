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

// JlCxx requires C++20 (via INTERFACE_COMPILE_FEATURES cxx_std_20), but
// libsemigroups bundles fmt which enables consteval format string validation
// in C++20 mode. This causes compile errors when inline functions in
// libsemigroups headers (e.g. Reporter::emit_divider, Runner::run_until)
// pass runtime std::string_view to fmt::format.
//
// fmt/base.h unconditionally defines FMT_USE_CONSTEVAL via an #if/#elif
// chain (no #ifndef guard), so pre-defining it has no effect. Instead we
// include <type_traits> (which defines __cpp_lib_is_constant_evaluated),
// then #undef that macro. When fmt/base.h later includes <type_traits>,
// include guards prevent re-parsing, so the macro stays undefined and fmt
// takes the !defined(__cpp_lib_is_constant_evaluated) branch, setting
// FMT_USE_CONSTEVAL=0.
#include <type_traits>
#undef __cpp_lib_is_constant_evaluated

// JlCxx headers
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/stl.hpp"

// libsemigroups headers
#include <libsemigroups/constants.hpp>
#include <libsemigroups/types.hpp>

// Standard library
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace libsemigroups_julia {

// Namespace aliases for convenience
namespace jl = jlcxx;
namespace libsemigroups = ::libsemigroups;

// Forward declarations of binding functions
void define_constants(jl::Module & mod);
void define_runner(jl::Module & mod);
void define_transf(jl::Module & mod);

}    // namespace libsemigroups_julia

#endif    // LIBSEMIGROUPS_JULIA_HPP_
