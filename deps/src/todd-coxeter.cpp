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

// todd-coxeter-helpers.hpp MUST come BEFORE cong-common.hpp so the template
// bodies in cong-common.hpp see TC-specific overloads of
// congruence_common helpers (e.g., non_trivial_classes(TC&, TC&)).
#include <libsemigroups/order.hpp>
#include <libsemigroups/presentation.hpp>
#include <libsemigroups/todd-coxeter-class.hpp>
#include <libsemigroups/todd-coxeter-helpers.hpp>
#include <libsemigroups/word-graph.hpp>

#include "cong-common.hpp"

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
  struct IsMirroredType<libsemigroups::detail::ToddCoxeterImpl>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::ToddCoxeter<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct SuperType<libsemigroups::detail::ToddCoxeterImpl> {
    using type = libsemigroups::detail::CongruenceCommon;
  };

  template <>
  struct SuperType<libsemigroups::ToddCoxeter<libsemigroups::word_type>> {
    using type = libsemigroups::detail::ToddCoxeterImpl;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_todd_coxeter(jl::Module& m) {
    using libsemigroups::congruence_kind;
    using libsemigroups::Order;
    using libsemigroups::Presentation;
    using libsemigroups::word_type;
    using libsemigroups::WordGraph;

    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;
    using TCImpl           = libsemigroups::detail::ToddCoxeterImpl;
    using TC               = libsemigroups::ToddCoxeter<word_type>;

    ////////////////////////////////////////////////////////////////////////
    // Enums
    ////////////////////////////////////////////////////////////////////////

    // strategy: TCImpl::options::strategy has 8 values; we only expose the
    // 6 that appear on the user-facing ToddCoxeter::options::strategy.
    m.add_bits<TCImpl::options::strategy>("strategy",
                                          jl::julia_type("CppEnum"));
    m.set_const("strategy_hlt", TCImpl::options::strategy::hlt);
    m.set_const("strategy_felsch", TCImpl::options::strategy::felsch);
    m.set_const("strategy_CR", TCImpl::options::strategy::CR);
    m.set_const("strategy_R_over_C", TCImpl::options::strategy::R_over_C);
    m.set_const("strategy_Cr", TCImpl::options::strategy::Cr);
    m.set_const("strategy_Rc", TCImpl::options::strategy::Rc);

    // lookahead_extent
    m.add_bits<TCImpl::options::lookahead_extent>("lookahead_extent",
                                                  jl::julia_type("CppEnum"));
    m.set_const("lookahead_extent_full",
                TCImpl::options::lookahead_extent::full);
    m.set_const("lookahead_extent_partial",
                TCImpl::options::lookahead_extent::partial);

    // lookahead_style
    m.add_bits<TCImpl::options::lookahead_style>("lookahead_style",
                                                 jl::julia_type("CppEnum"));
    m.set_const("lookahead_style_hlt",
                TCImpl::options::lookahead_style::hlt);
    m.set_const("lookahead_style_felsch",
                TCImpl::options::lookahead_style::felsch);

    // def_policy
    m.add_bits<TCImpl::options::def_policy>("def_policy",
                                            jl::julia_type("CppEnum"));
    m.set_const("def_policy_no_stack_if_no_space",
                TCImpl::options::def_policy::no_stack_if_no_space);
    m.set_const("def_policy_purge_from_top",
                TCImpl::options::def_policy::purge_from_top);
    m.set_const("def_policy_purge_all",
                TCImpl::options::def_policy::purge_all);
    m.set_const("def_policy_discard_all_if_no_space",
                TCImpl::options::def_policy::discard_all_if_no_space);
    m.set_const("def_policy_unlimited",
                TCImpl::options::def_policy::unlimited);

    // def_version (lives on FelschGraphSettings::options, inherited via
    // TCImpl::options)
    m.add_bits<TCImpl::options::def_version>("def_version",
                                             jl::julia_type("CppEnum"));
    m.set_const("def_version_one", TCImpl::options::def_version::one);
    m.set_const("def_version_two", TCImpl::options::def_version::two);

    ////////////////////////////////////////////////////////////////////////
    // Type registration
    ////////////////////////////////////////////////////////////////////////

    m.add_type<TCImpl>("ToddCoxeterImpl",
                       jlcxx::julia_base_type<CongruenceCommon>());
    auto type
        = m.add_type<TC>("ToddCoxeterWord", jlcxx::julia_base_type<TCImpl>());

    ////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////

    type.constructor<congruence_kind, Presentation<word_type> const&>();
    type.constructor<congruence_kind, TC const&>();
    type.constructor<congruence_kind, WordGraph<uint32_t> const&>();
    type.constructor<TC const&>();  // copy ctor

    ////////////////////////////////////////////////////////////////////////
    // init! overloads (mirror constructors)
    ////////////////////////////////////////////////////////////////////////

    type.method("init!", [](TC& self) -> TC& { return self.init(); });
    type.method("init!",
                [](TC&                            self,
                   congruence_kind                knd,
                   Presentation<word_type> const& p) -> TC& {
                  return self.init(knd, p);
                });
    type.method("init!",
                [](TC& self, congruence_kind knd, TC const& other) -> TC& {
                  return self.init(knd, other);
                });
    type.method(
        "init!",
        [](TC& self, congruence_kind knd, WordGraph<uint32_t> const& wg)
            -> TC& { return self.init(knd, wg); });

    ////////////////////////////////////////////////////////////////////////
    // Settings (getter / setter pairs with DISTINCT names)
    ////////////////////////////////////////////////////////////////////////

    // strategy
    type.method("strategy", [](TC const& self) -> TCImpl::options::strategy {
      return self.strategy();
    });
    type.method("set_strategy!",
                [](TC& self, TCImpl::options::strategy val) {
                  self.strategy(val);
                });

    // lookahead_extent
    type.method("lookahead_extent",
                [](TC const& self) -> TCImpl::options::lookahead_extent {
                  return self.lookahead_extent();
                });
    type.method("set_lookahead_extent!",
                [](TC& self, TCImpl::options::lookahead_extent val) {
                  self.lookahead_extent(val);
                });

    // lookahead_style
    type.method("lookahead_style",
                [](TC const& self) -> TCImpl::options::lookahead_style {
                  return self.lookahead_style();
                });
    type.method("set_lookahead_style!",
                [](TC& self, TCImpl::options::lookahead_style val) {
                  self.lookahead_style(val);
                });

    // save
    type.method("save", [](TC const& self) -> bool { return self.save(); });
    type.method("set_save!", [](TC& self, bool val) { self.save(val); });

    // use_relations_in_extra
    type.method("use_relations_in_extra", [](TC const& self) -> bool {
      return self.use_relations_in_extra();
    });
    type.method("set_use_relations_in_extra!",
                [](TC& self, bool val) { self.use_relations_in_extra(val); });

    // lower_bound
    type.method("lower_bound",
                [](TC const& self) -> size_t { return self.lower_bound(); });
    type.method("set_lower_bound!",
                [](TC& self, size_t val) { self.lower_bound(val); });

    // def_version
    type.method("def_version",
                [](TC const& self) -> TCImpl::options::def_version {
                  return self.def_version();
                });
    type.method("set_def_version!",
                [](TC& self, TCImpl::options::def_version val) {
                  self.def_version(val);
                });

    // def_policy
    type.method("def_policy",
                [](TC const& self) -> TCImpl::options::def_policy {
                  return self.def_policy();
                });
    type.method("set_def_policy!",
                [](TC& self, TCImpl::options::def_policy val) {
                  self.def_policy(val);
                });

    ////////////////////////////////////////////////////////////////////////
    // Standardize / word-graph access
    ////////////////////////////////////////////////////////////////////////

    type.method("standardize!", [](TC& self, Order ord) -> bool {
      return self.standardize(ord);
    });

    type.method("is_standardized",
                [](TC const& self) -> bool { return self.is_standardized(); });

    type.method("is_standardized", [](TC const& self, Order ord) -> bool {
      return self.is_standardized(ord);
    });

    // current_word_graph: large stable data, return by const reference.
    type.method("current_word_graph",
                [](TC const& self) -> WordGraph<uint32_t> const& {
                  return self.current_word_graph();
                });

    // word_graph: triggers run; non-const this.
    type.method("word_graph",
                [](TC& self) -> WordGraph<uint32_t> const& {
                  return self.word_graph();
                });

    ////////////////////////////////////////////////////////////////////////
    // Word <-> class index
    ////////////////////////////////////////////////////////////////////////

    type.method("current_index_of",
                [](TC const& self, jlcxx::ArrayRef<size_t> w) -> size_t {
                  word_type ww(w.begin(), w.end());
                  return self.current_index_of(ww.begin(), ww.end());
                });

    type.method("index_of",
                [](TC& self, jlcxx::ArrayRef<size_t> w) -> size_t {
                  word_type ww(w.begin(), w.end());
                  return self.index_of(ww.begin(), ww.end());
                });

    type.method("current_word_of",
                [](TC const& self, size_t i) -> word_type {
                  word_type out;
                  self.current_word_of(std::back_inserter(out), i);
                  return out;
                });

    type.method("word_of", [](TC& self, size_t i) -> word_type {
      word_type out;
      self.word_of(std::back_inserter(out), i);
      return out;
    });

    ////////////////////////////////////////////////////////////////////////
    // Query methods
    ////////////////////////////////////////////////////////////////////////

    type.method("number_of_classes",
                [](TC& self) -> uint64_t { return self.number_of_classes(); });

    type.method("kind",
                [](TC const& self) -> congruence_kind { return self.kind(); });

    type.method("number_of_generating_pairs", [](TC const& self) -> size_t {
      return self.number_of_generating_pairs();
    });

    type.method("generating_pairs",
                [](TC const& self) -> std::vector<word_type> {
                  auto const& pairs = self.generating_pairs();
                  return std::vector<word_type>(pairs.begin(), pairs.end());
                });

    // presentation - return by copy
    type.method("presentation", [](TC const& self) -> Presentation<word_type> {
      return self.presentation();
    });

    ////////////////////////////////////////////////////////////////////////
    // Display
    ////////////////////////////////////////////////////////////////////////

    type.method("to_human_readable_repr", [](TC const& self) -> std::string {
      return libsemigroups::to_human_readable_repr(self);
    });

    ////////////////////////////////////////////////////////////////////////
    // Free functions (todd_coxeter:: namespace)
    ////////////////////////////////////////////////////////////////////////

    // is_non_trivial - takes nanoseconds at the boundary, converts to
    // milliseconds (the helper takes std::chrono::milliseconds).
    m.method("tc_is_non_trivial",
             [](TC& self, size_t tries, int64_t try_for_ns, float threshold)
                 -> libsemigroups::tril {
               auto try_for = std::chrono::duration_cast<
                   std::chrono::milliseconds>(
                   std::chrono::nanoseconds(try_for_ns));
               return libsemigroups::todd_coxeter::is_non_trivial(
                   self, tries, try_for, threshold);
             });

    // redundant_rule - returns a 0-based index into p.rules (lhs position),
    // or p.rules.size() if no redundant rule was found.
    m.method("tc_redundant_rule",
             [](Presentation<word_type> const& p, int64_t ns) -> size_t {
               auto it = libsemigroups::todd_coxeter::redundant_rule(
                   p, std::chrono::nanoseconds(ns));
               return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
             });
  }

  void define_todd_coxeter_cong_common_helpers(jl::Module& m) {
    using libsemigroups::word_type;
    using TC = libsemigroups::ToddCoxeter<word_type>;

    define_cong_common_word_helpers<TC>(m);
    define_cong_common_normal_forms<TC>(m);
    define_cong_common_non_trivial_classes<TC>(m);
  }

}  // namespace libsemigroups_julia
