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

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/cong-common-helpers.hpp>
#include <libsemigroups/knuth-bendix-class.hpp>
#include <libsemigroups/knuth-bendix-helpers.hpp>
#include <libsemigroups/presentation.hpp>
#include <libsemigroups/word-graph.hpp>

#include <jlcxx/array.hpp>

#include <chrono>
#include <cstddef>
#include <cstdint>
#include <iterator>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<
      libsemigroups::detail::KnuthBendixImpl<libsemigroups::detail::RewriteTrie,
                                             libsemigroups::ShortLexCompare>>
      : std::false_type {};

  template <>
  struct IsMirroredType<
      libsemigroups::KnuthBendix<libsemigroups::word_type,
                                 libsemigroups::detail::RewriteTrie,
                                 libsemigroups::ShortLexCompare>>
      : std::false_type {};

  template <>
  struct SuperType<
      libsemigroups::detail::KnuthBendixImpl<libsemigroups::detail::RewriteTrie,
                                             libsemigroups::ShortLexCompare>> {
    using type = libsemigroups::detail::CongruenceCommon;
  };

  template <>
  struct SuperType<
      libsemigroups::KnuthBendix<libsemigroups::word_type,
                                 libsemigroups::detail::RewriteTrie,
                                 libsemigroups::ShortLexCompare>> {
    using type = libsemigroups::detail::KnuthBendixImpl<
        libsemigroups::detail::RewriteTrie,
        libsemigroups::ShortLexCompare>;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_knuth_bendix(jl::Module& m) {
    using libsemigroups::congruence_kind;
    using libsemigroups::Presentation;
    using libsemigroups::word_type;

    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;
    using KBImpl           = libsemigroups::detail::KnuthBendixImpl<
        libsemigroups::detail::RewriteTrie,
        libsemigroups::ShortLexCompare>;
    using KB = libsemigroups::KnuthBendix<word_type,
                                          libsemigroups::detail::RewriteTrie,
                                          libsemigroups::ShortLexCompare>;

    ////////////////////////////////////////////////////////////////////////
    // overlap enum
    ////////////////////////////////////////////////////////////////////////

    m.add_bits<KB::options::overlap>("overlap", jl::julia_type("CppEnum"));
    m.set_const("overlap_ABC", KB::options::overlap::ABC);
    m.set_const("overlap_AB_BC", KB::options::overlap::AB_BC);
    m.set_const("overlap_MAX_AB_BC", KB::options::overlap::MAX_AB_BC);

    ////////////////////////////////////////////////////////////////////////
    // Type registration
    ////////////////////////////////////////////////////////////////////////

    m.add_type<KBImpl>("KnuthBendixImplRewriteTrie",
                       jlcxx::julia_base_type<CongruenceCommon>());
    auto type = m.add_type<KB>("KnuthBendixRewriteTrie",
                               jlcxx::julia_base_type<KBImpl>());

    ////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////

    type.constructor<congruence_kind, Presentation<word_type> const&>();
    type.constructor<KB const&>();  // copy ctor
    type.method("init!", [](KB& self) -> KB& { return self.init(); });
    type.method("init!",
                [](KB&                            self,
                   congruence_kind                knd,
                   Presentation<word_type> const& p) -> KB& {
                  return self.init(knd, p);
                });

    ////////////////////////////////////////////////////////////////////////
    // Settings (getter / setter with DISTINCT names)
    ////////////////////////////////////////////////////////////////////////

    // max_pending_rules
    type.method("max_pending_rules", [](KB const& self) -> size_t {
      return self.max_pending_rules();
    });
    type.method("set_max_pending_rules!",
                [](KB& self, size_t val) { self.max_pending_rules(val); });

    // check_confluence_interval
    type.method("check_confluence_interval", [](KB const& self) -> size_t {
      return self.check_confluence_interval();
    });
    type.method("set_check_confluence_interval!", [](KB& self, size_t val) {
      self.check_confluence_interval(val);
    });

    // max_overlap
    type.method("max_overlap",
                [](KB const& self) -> size_t { return self.max_overlap(); });
    type.method("set_max_overlap!",
                [](KB& self, size_t val) { self.max_overlap(val); });

    // max_rules
    type.method("max_rules",
                [](KB const& self) -> size_t { return self.max_rules(); });
    type.method("set_max_rules!",
                [](KB& self, size_t val) { self.max_rules(val); });

    // overlap_policy
    type.method("overlap_policy", [](KB const& self) -> KB::options::overlap {
      return self.overlap_policy();
    });
    type.method("set_overlap_policy!", [](KB& self, KB::options::overlap val) {
      self.overlap_policy(val);
    });

    ////////////////////////////////////////////////////////////////////////
    // Query methods
    ////////////////////////////////////////////////////////////////////////

    type.method("number_of_active_rules", [](KB const& self) -> size_t {
      return self.number_of_active_rules();
    });
    type.method("number_of_inactive_rules", [](KB const& self) -> size_t {
      return self.number_of_inactive_rules();
    });
    type.method("number_of_pending_rules", [](KB const& self) -> size_t {
      return self.number_of_pending_rules();
    });
    type.method("total_rules",
                [](KB const& self) -> size_t { return self.total_rules(); });

    type.method("confluent", [](KB& self) -> bool { return self.confluent(); });
    type.method("confluent_known",
                [](KB const& self) -> bool { return self.confluent_known(); });

    type.method("number_of_classes",
                [](KB& self) -> uint64_t { return self.number_of_classes(); });

    type.method("kind",
                [](KB const& self) -> congruence_kind { return self.kind(); });
    type.method("number_of_generating_pairs", [](KB const& self) -> size_t {
      return self.number_of_generating_pairs();
    });
    type.method("generating_pairs",
                [](KB const& self) -> std::vector<word_type> {
                  auto const& pairs = self.generating_pairs();
                  return std::vector<word_type>(pairs.begin(), pairs.end());
                });

    // presentation — return by copy
    type.method("presentation", [](KB const& self) -> Presentation<word_type> {
      return self.presentation();
    });

    ////////////////////////////////////////////////////////////////////////
    // Word operations (ArrayRef<size_t> for word inputs)
    ////////////////////////////////////////////////////////////////////////

    // reduce (triggers full enumeration)
    m.method("kb_reduce", [](KB& self, jlcxx::ArrayRef<size_t> w) -> word_type {
      word_type input(w.begin(), w.end());
      return libsemigroups::knuth_bendix::reduce(self, input);
    });

    // reduce_no_run (no enumeration)
    m.method("kb_reduce_no_run",
             [](KB const& self, jlcxx::ArrayRef<size_t> w) -> word_type {
               word_type input(w.begin(), w.end());
               return libsemigroups::knuth_bendix::reduce_no_run(self, input);
             });

    // contains (triggers full enumeration)
    m.method("kb_contains",
             [](KB&                     self,
                jlcxx::ArrayRef<size_t> u,
                jlcxx::ArrayRef<size_t> v) -> bool {
               word_type uw(u.begin(), u.end());
               word_type vw(v.begin(), v.end());
               return libsemigroups::knuth_bendix::contains(self, uw, vw);
             });

    // currently_contains (no enumeration, returns tril)
    m.method("kb_currently_contains",
             [](KB const&               self,
                jlcxx::ArrayRef<size_t> u,
                jlcxx::ArrayRef<size_t> v) -> libsemigroups::tril {
               word_type uw(u.begin(), u.end());
               word_type vw(v.begin(), v.end());
               return libsemigroups::knuth_bendix::currently_contains(
                   self, uw, vw);
             });

    // add_generating_pair!
    m.method(
        "kb_add_generating_pair!",
        [](KB& self, jlcxx::ArrayRef<size_t> u, jlcxx::ArrayRef<size_t> v) {
          word_type uw(u.begin(), u.end());
          word_type vw(v.begin(), v.end());
          libsemigroups::knuth_bendix::add_generating_pair(self, uw, vw);
        });

    ////////////////////////////////////////////////////////////////////////
    // Rules access
    ////////////////////////////////////////////////////////////////////////

    // active_rules — collect the range to a flat vector<word_type>
    // (even indices = lhs, odd indices = rhs)
    // active_rules() returns an rx range — use .at_end()/.get()/.next()
    m.method("kb_active_rules", [](KB& self) -> std::vector<word_type> {
      std::vector<word_type> result;
      auto                   range = self.active_rules();
      while (!range.at_end()) {
        auto const& pair = range.get();
        result.push_back(pair.first);
        result.push_back(pair.second);
        range.next();
      }
      return result;
    });

    ////////////////////////////////////////////////////////////////////////
    // Graph access
    ////////////////////////////////////////////////////////////////////////

    // gilman_graph — return by const reference (large stable data)
    type.method("gilman_graph",
                [](KB& self) -> libsemigroups::WordGraph<uint32_t> const& {
                  return self.gilman_graph();
                });

    // gilman_graph_node_labels — collect to vector of vectors by copy
    type.method("gilman_graph_node_labels",
                [](KB& self) -> std::vector<word_type> {
                  return self.gilman_graph_node_labels();
                });

    ////////////////////////////////////////////////////////////////////////
    // Display
    ////////////////////////////////////////////////////////////////////////

    type.method("to_human_readable_repr", [](KB& self) -> std::string {
      return libsemigroups::to_human_readable_repr(self);
    });

    ////////////////////////////////////////////////////////////////////////
    // Free functions (knuth_bendix:: namespace)
    ////////////////////////////////////////////////////////////////////////

    // by_overlap_length! (mutating)
    m.method("kb_by_overlap_length!", [](KB& self) {
      libsemigroups::knuth_bendix::by_overlap_length(self);
    });

    // is_reduced
    m.method("kb_is_reduced", [](KB& self) -> bool {
      return libsemigroups::knuth_bendix::is_reduced(self);
    });

    // redundant_rule — takes Presentation<word_type> and a timeout in
    // nanoseconds (int64_t), returns an index into p.rules (0-based).
    // Returns p.rules.size() if no redundant rule was found.
    m.method("kb_redundant_rule",
             [](Presentation<word_type> const& p, int64_t ns) -> size_t {
               auto it = libsemigroups::knuth_bendix::redundant_rule(
                   p, std::chrono::nanoseconds(ns));
               return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
             });

    // normal_forms — collect to vector<word_type>
    // normal_forms() returns an rx-style range — use .at_end()/.get()/.next()
    m.method("kb_normal_forms", [](KB& self) -> std::vector<word_type> {
      std::vector<word_type> result;
      auto range = libsemigroups::knuth_bendix::normal_forms(self);
      while (!range.at_end()) {
        result.push_back(range.get());
        range.next();
      }
      return result;
    });

    // non_trivial_classes — takes two KB objects
    m.method("kb_non_trivial_classes",
             [](KB& kb1, KB& kb2) -> std::vector<std::vector<word_type>> {
               return libsemigroups::knuth_bendix::non_trivial_classes(kb1,
                                                                       kb2);
             });

    m.method("kb_partition",
             [](KB& self, jlcxx::ArrayRef<jl_value_t*> words)
                 -> std::vector<std::vector<word_type>> {
               std::vector<word_type> input;
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

}  // namespace libsemigroups_julia
