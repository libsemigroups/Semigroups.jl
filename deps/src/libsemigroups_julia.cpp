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

#include <libsemigroups/config.hpp>

#include <string>

namespace libsemigroups_julia {

  JLCXX_MODULE define_julia_module(jl::Module& mod) {
    mod.method("libsemigroups_version",
               []() -> std::string { return LIBSEMIGROUPS_VERSION; });

    // Define constants first (UNDEFINED, POSITIVE_INFINITY, etc.)
    define_constants(mod);

    // Define ReportGuard (RAII reporting control)
    define_report(mod);

    // Define base types (must be registered before derived types)
    define_runner(mod);
    define_cong_common(mod);

    // Define element types
    define_transf(mod);
    define_bmat8(mod);

    define_order(mod);
    define_word_range(mod);
    define_word_graph(mod);
    define_paths(mod);
    define_froidure_pin_base(mod);
    define_froidure_pin(mod);
    define_presentation(mod);
    define_presentation_examples(mod);
    define_knuth_bendix(mod);
    define_todd_coxeter(mod);
  }

}  // namespace libsemigroups_julia
