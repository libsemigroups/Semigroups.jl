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

// kambites-class.hpp and kambites-helpers.hpp MUST come BEFORE cong-common.hpp
// so the template bodies in cong-common.hpp see Kambites-specific overloads of
// congruence_common helpers. ADL resolves these at template-instantiation time;
// see the include-order requirement documented at cong-common.hpp:27-38.
#include <libsemigroups/kambites-class.hpp>
#include <libsemigroups/kambites-helpers.hpp>

// Required for KambitesNormalFormRange::init to instantiate
// libsemigroups::to<FroidurePin>(Kambites&); the template definition lives in
// to-froidure-pin.tpp (transitively included by to-froidure-pin.hpp). Without
// this, define_cong_common_normal_forms<Kambites<word_type>> compiles but
// fails to link with an undefined `libsemigroups::to<FroidurePin, ...>` symbol.
#include <libsemigroups/to-froidure-pin.hpp>

#include "cong-common.hpp"

#include <cstddef>
#include <cstdint>
#include <string>
#include <type_traits>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Kambites<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct SuperType<libsemigroups::Kambites<libsemigroups::word_type>> {
    using type = libsemigroups::detail::CongruenceCommon;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_kambites(jl::Module& m) {
    using libsemigroups::congruence_kind;
    using libsemigroups::Presentation;
    using libsemigroups::word_type;

    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;
    using K                = libsemigroups::Kambites<word_type>;

    // Type registration
    auto type
        = m.add_type<K>("KambitesWord", jlcxx::julia_base_type<CongruenceCommon>());

    // Constructors. Direct registration (no defensive lambda); CxxWrap
    // converts C++ exceptions through the std::function path for direct
    // constructor bindings (Phase 3a/3b precedent).
    type.constructor<>();
    type.constructor<congruence_kind, Presentation<word_type> const&>();
    type.constructor<K const&>();  // copy ctor

    // init! overloads (mirror constructors)
    type.method("init!", [](K& self) -> K& { return self.init(); });
    type.method("init!",
                [](K&                             self,
                   congruence_kind                knd,
                   Presentation<word_type> const& p) -> K& {
                  return self.init(knd, p);
                });

    // presentation - return by copy (storage may relocate)
    type.method("presentation", [](K const& self) -> Presentation<word_type> {
      return self.presentation();
    });

    // generating_pairs - return by copy
    type.method("generating_pairs",
                [](K const& self) -> std::vector<word_type> {
                  auto const& pairs = self.generating_pairs();
                  return std::vector<word_type>(pairs.begin(), pairs.end());
                });

    // kind / number_of_generating_pairs (inherited; exposed for parity with TC)
    type.method("kind",
                [](K const& self) -> congruence_kind { return self.kind(); });

    type.method("number_of_generating_pairs", [](K const& self) -> size_t {
      return self.number_of_generating_pairs();
    });

    // number_of_classes
    type.method("number_of_classes",
                [](K& self) -> uint64_t { return self.number_of_classes(); });

    // Const-overload split (kambites-class.hpp:731-744): the two
    // small_overlap_class() overloads differ only on receiver const-ness, which
    // CxxWrap cannot dispatch. Split into two distinctly-named Julia methods.
    //
    // small_overlap_class — mutable variant (calls run, returns the class).
    type.method("small_overlap_class",
                [](K& self) -> size_t { return self.small_overlap_class(); });

    // current_small_overlap_class — const variant (returns UNDEFINED if
    // unknown). Receiver-by-const-ref selects the const overload.
    type.method("current_small_overlap_class", [](K const& self) -> size_t {
      return self.small_overlap_class();
    });

    // throw_if_not_C4 — bind only the mutable overload
    // (kambites-class.hpp:801). The const variant (kambites-class.hpp:813) is
    // deferred per the design spec.
    type.method("throw_if_not_C4", [](K& self) { self.throw_if_not_C4(); });

    // throw_if_letter_not_in_alphabet — accept ArrayRef<size_t>, build a
    // word_type inside the lambda (mirrors todd-coxeter.cpp:256-260).
    type.method("throw_if_letter_not_in_alphabet",
                [](K const& self, jlcxx::ArrayRef<size_t> w) {
                  word_type ww(w.begin(), w.end());
                  self.throw_if_letter_not_in_alphabet(ww.begin(), ww.end());
                });

    // Display
    type.method("to_human_readable_repr", [](K const& self) -> std::string {
      return libsemigroups::to_human_readable_repr(self);
    });

    // Cong-common helper subset. Do NOT call define_cong_common_helpers (the
    // aggregator) — kambites-helpers.hpp:128-133 documents that
    // non_trivial_classes(Kambites, Kambites) is intentionally undefined
    // upstream because both Kambites instances always represent infinite-class
    // congruences, so the construction does not generalize. ADL would silently
    // bind the generic congruence_common::non_trivial_classes here, producing
    // nonsense at runtime. The Julia wrapper provides a throwing override.
    define_cong_common_word_helpers<K>(m);
    define_cong_common_normal_forms<K>(m);
  }

}  // namespace libsemigroups_julia
