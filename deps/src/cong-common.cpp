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

#include <libsemigroups/cong-common-helpers.hpp>
#include <libsemigroups/detail/cong-common-class.hpp>
#include <libsemigroups/knuth-bendix-class.hpp>
#include <libsemigroups/knuth-bendix-helpers.hpp>
#include <libsemigroups/runner.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <cstdint>
#include <type_traits>
#include <vector>

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

  namespace {
    template <typename Thing>
    void define_cong_common_word_helpers(jl::Module& m) {
      using Word = typename Thing::native_word_type;

      // reduce (triggers full enumeration)
      m.method("cong_common_reduce",
               [](Thing& self, jlcxx::ArrayRef<size_t> w) -> Word {
                 Word input(w.begin(), w.end());
                 return libsemigroups::congruence_common::reduce(self, input);
               });

      // reduce_no_run (no enumeration)
      m.method("cong_common_reduce_no_run",
               [](Thing const& self, jlcxx::ArrayRef<size_t> w) -> Word {
                 Word input(w.begin(), w.end());
                 return libsemigroups::congruence_common::reduce_no_run(self,
                                                                        input);
               });

      // contains (triggers full enumeration)
      m.method("cong_common_contains",
               [](Thing& self,
                  jlcxx::ArrayRef<size_t> u,
                  jlcxx::ArrayRef<size_t> v) -> bool {
                 Word uw(u.begin(), u.end());
                 Word vw(v.begin(), v.end());
                 return libsemigroups::congruence_common::contains(self,
                                                                   uw,
                                                                   vw);
               });

      // currently_contains (no enumeration, returns tril)
      m.method("cong_common_currently_contains",
               [](Thing const& self,
                  jlcxx::ArrayRef<size_t> u,
                  jlcxx::ArrayRef<size_t> v) -> libsemigroups::tril {
                 Word uw(u.begin(), u.end());
                 Word vw(v.begin(), v.end());
                 return libsemigroups::congruence_common::currently_contains(
                     self, uw, vw);
               });

      // add_generating_pair!
      m.method(
          "cong_common_add_generating_pair!",
          [](Thing& self, jlcxx::ArrayRef<size_t> u, jlcxx::ArrayRef<size_t> v) {
            Word uw(u.begin(), u.end());
            Word vw(v.begin(), v.end());
            libsemigroups::congruence_common::add_generating_pair(self, uw, vw);
          });

      m.method("cong_common_partition",
               [](Thing& self, jlcxx::ArrayRef<jl_value_t*> words)
                   -> std::vector<std::vector<Word>> {
                 std::vector<Word> input;
                 input.reserve(words.size());
                 for (jl_value_t* word_value : words) {
                   auto word = jlcxx::ArrayRef<size_t>(
                       reinterpret_cast<jl_array_t*>(word_value));
                   input.emplace_back(word.begin(), word.end());
                 }
                 return libsemigroups::congruence_common::partition(
                     self, input.begin(), input.end());
               });
    }

    template <typename Thing>
    void define_cong_common_normal_forms(jl::Module& m) {
      using Word = typename Thing::native_word_type;

      // normal_forms() returns an rx-style range; use
      // .at_end()/.get()/.next().
      m.method("cong_common_normal_forms",
               [](Thing& self) -> std::vector<Word> {
                 std::vector<Word> result;
                 auto range = libsemigroups::congruence_common::normal_forms(
                     self);
                 while (!range.at_end()) {
                   result.push_back(range.get());
                   range.next();
                 }
                 return result;
               });
    }

    template <typename Thing>
    void define_cong_common_non_trivial_classes(jl::Module& m) {
      using Word = typename Thing::native_word_type;

      m.method("cong_common_non_trivial_classes",
               [](Thing& x, Thing& y) -> std::vector<std::vector<Word>> {
                 return libsemigroups::congruence_common::non_trivial_classes(
                     x, y);
               });
    }
  }  // namespace

  void define_cong_common(jl::Module& m) {
    using libsemigroups::Runner;
    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;

    // No constructors: CongruenceCommon is a shared implementation base.
    // Derived algorithms register their concrete methods on their own types.
    m.add_type<CongruenceCommon>("CongruenceCommon",
                                 jlcxx::julia_base_type<Runner>());
  }

  void define_knuth_bendix_cong_common_helpers(jl::Module& m) {
    using libsemigroups::word_type;
    using KB = libsemigroups::KnuthBendix<word_type,
                                          libsemigroups::detail::RewriteTrie,
                                          libsemigroups::ShortLexCompare>;

    define_cong_common_word_helpers<KB>(m);
    define_cong_common_normal_forms<KB>(m);
    define_cong_common_non_trivial_classes<KB>(m);
  }

}  // namespace libsemigroups_julia
