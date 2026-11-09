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

// Shared template family used to instantiate the cong-common helper
// dispatch shims for each concrete congruence-algorithm type (KnuthBendix,
// ToddCoxeter, ...). The actual user-facing Julia helpers in
// `src/cong-common.jl` dispatch on the `CongruenceCommon` supertype, so
// once a derived algorithm registers these shims for its type, all common
// helpers (`reduce`, `contains`, `normal_forms`, `partition`,
// `non_trivial_classes`, ...) work on it for free.
//
// INCLUDE-ORDER REQUIREMENT (silent runtime bug if violated):
// Translation units that instantiate these templates MUST include the
// algorithm-specific helpers header (e.g.
// `<libsemigroups/knuth-bendix-helpers.hpp>` or
// `<libsemigroups/todd-coxeter-helpers.hpp>`) BEFORE including this file.
// The calls to `congruence_common::reduce`, `non_trivial_classes`, etc. are
// resolved by ADL at template-instantiation time; if the algorithm-specific
// overload isn't visible in the TU, the call silently binds to the generic
// base in `<libsemigroups/cong-common-helpers.hpp>`. The link succeeds and
// the wrong code runs at runtime. See `cong-common.cpp` (KnuthBendix) and
// `todd-coxeter.cpp` (ToddCoxeter) for the established pattern; future
// bindings (Kambites, Congruence, ...) must follow it.

#ifndef LIBSEMIGROUPS_JULIA_CONG_COMMON_HPP_
#define LIBSEMIGROUPS_JULIA_CONG_COMMON_HPP_

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/cong-common-helpers.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <string>
#include <vector>

namespace libsemigroups_julia {

  // JuliaWord<Word> describes how a word arrives from Julia for a congruence
  // whose `native_word_type` is `Word`, and how to convert it:
  //
  //   * `arg_type`        - the CxxWrap argument type of a single word;
  //   * `to_cpp(w)`       - convert an `arg_type` to `Word`;
  //   * `from_jl_value(v)` - convert one element of a Julia `Vector{Any}` of
  //                          words (used by `partition`) to `Word`.
  //
  // word_type words arrive as 0-based `Vector{UInt}` (see `_word_to_cpp`);
  // std::string words arrive as Julia `String`s (ASCII-checked on the Julia
  // side).
  template <typename Word>
  struct JuliaWord;

  template <>
  struct JuliaWord<libsemigroups::word_type> {
    using arg_type = jlcxx::ArrayRef<size_t>;

    static libsemigroups::word_type to_cpp(arg_type w) {
      return libsemigroups::word_type(w.begin(), w.end());
    }

    static libsemigroups::word_type from_jl_value(jl_value_t* v) {
      return to_cpp(jlcxx::ArrayRef<size_t>(reinterpret_cast<jl_array_t*>(v)));
    }
  };

  template <>
  struct JuliaWord<std::string> {
    using arg_type = std::string const&;

    static std::string const& to_cpp(arg_type w) {
      return w;
    }

    static std::string from_jl_value(jl_value_t* v) {
      return std::string(jl_string_data(v), jl_string_len(v));
    }
  };

  template <typename Thing>
  inline void define_cong_common_word_helpers(jl::Module& m) {
    using Word = typename Thing::native_word_type;
    using JW   = JuliaWord<Word>;
    using Arg  = typename JW::arg_type;

    // reduce (triggers full enumeration)
    m.method("cong_common_reduce", [](Thing& self, Arg w) -> Word {
      return libsemigroups::congruence_common::reduce(self, JW::to_cpp(w));
    });

    // reduce_no_run (no enumeration)
    m.method("cong_common_reduce_no_run", [](Thing const& self, Arg w) -> Word {
      return libsemigroups::congruence_common::reduce_no_run(self,
                                                             JW::to_cpp(w));
    });

    // contains (triggers full enumeration)
    m.method("cong_common_contains", [](Thing& self, Arg u, Arg v) -> bool {
      return libsemigroups::congruence_common::contains(
          self, JW::to_cpp(u), JW::to_cpp(v));
    });

    // currently_contains (no enumeration, returns tril)
    m.method("cong_common_currently_contains",
             [](Thing const& self, Arg u, Arg v) -> libsemigroups::tril {
               return libsemigroups::congruence_common::currently_contains(
                   self, JW::to_cpp(u), JW::to_cpp(v));
             });

    // add_generating_pair!
    m.method("cong_common_add_generating_pair!", [](Thing& self, Arg u, Arg v) {
      libsemigroups::congruence_common::add_generating_pair(
          self, JW::to_cpp(u), JW::to_cpp(v));
    });

    m.method("cong_common_partition",
             [](Thing& self, jlcxx::ArrayRef<jl_value_t*> words)
                 -> std::vector<std::vector<Word>> {
               std::vector<Word> input;
               input.reserve(words.size());
               for (jl_value_t* word_value : words) {
                 input.push_back(JW::from_jl_value(word_value));
               }
               return libsemigroups::congruence_common::partition(
                   self, input.begin(), input.end());
             });
  }

  template <typename Thing>
  inline void define_cong_common_normal_forms(jl::Module& m) {
    using Word = typename Thing::native_word_type;

    // normal_forms() returns an rx-style range; use
    // .at_end()/.get()/.next().
    m.method("cong_common_normal_forms", [](Thing& self) -> std::vector<Word> {
      std::vector<Word> result;
      auto range = libsemigroups::congruence_common::normal_forms(self);
      while (!range.at_end()) {
        result.push_back(range.get());
        range.next();
      }
      return result;
    });
  }

  template <typename Thing>
  inline void define_cong_common_non_trivial_classes(jl::Module& m) {
    using Word = typename Thing::native_word_type;

    m.method("cong_common_non_trivial_classes",
             [](Thing& x, Thing& y) -> std::vector<std::vector<Word>> {
               return libsemigroups::congruence_common::non_trivial_classes(x,
                                                                            y);
             });
  }

  // Aggregator: register the full cong-common helper family for one
  // concrete algorithm type. Each new algorithm binding (KnuthBendix,
  // ToddCoxeter, Kambites, ...) calls this once at the end of its
  // `define_<algorithm>(m)` function. The include-order requirement
  // documented above still applies - the algorithm-specific helpers
  // header must be included before this file in the calling TU.
  template <typename Thing>
  inline void define_cong_common_helpers(jl::Module& m) {
    define_cong_common_word_helpers<Thing>(m);
    define_cong_common_normal_forms<Thing>(m);
    define_cong_common_non_trivial_classes<Thing>(m);
  }

}  // namespace libsemigroups_julia

#endif  // LIBSEMIGROUPS_JULIA_CONG_COMMON_HPP_
