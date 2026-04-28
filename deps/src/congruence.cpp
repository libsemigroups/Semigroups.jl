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

// cong-class.hpp + cong-helpers.hpp MUST come BEFORE cong-common.hpp so the
// template bodies in cong-common.hpp see Congruence-specific overloads of
// congruence_common helpers at instantiation time.
#include <libsemigroups/cong-class.hpp>
#include <libsemigroups/cong-helpers.hpp>
#include <libsemigroups/kambites-class.hpp>
#include <libsemigroups/knuth-bendix-class.hpp>
// knuth-bendix-helpers.hpp brings `congruence_common::normal_forms` and
// `non_trivial_classes` declarations into scope, which the templates in
// cong-common.hpp reference by qualified name at parse time. Removing
// it breaks the build even though we never instantiate those templates
// for Congruence.
#include <libsemigroups/knuth-bendix-helpers.hpp>
#include <libsemigroups/presentation.hpp>
#include <libsemigroups/todd-coxeter-class.hpp>

#include "cong-common.hpp"

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>
#include <type_traits>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Congruence<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct SuperType<libsemigroups::Congruence<libsemigroups::word_type>> {
    using type = libsemigroups::detail::CongruenceCommon;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  // Templated helper that binds the `has<Thing>()` / `get<Thing>()` member
  // templates of `Congruence<word_type>` as named module methods. CxxWrap
  // cannot bind C++ template member functions directly; we instantiate a
  // separate pair of named methods per `Thing` and dispatch from the Julia
  // side on `::Type{T}`.
  template <typename Thing>
  inline void define_cong_has_get(jl::Module& m, std::string const& suffix) {
    using Cong = libsemigroups::Congruence<libsemigroups::word_type>;
    m.method("cong_has_" + suffix,
             [](Cong const& c) -> bool { return c.template has<Thing>(); });
    m.method("cong_get_" + suffix,
             [](Cong const& c) -> Thing { return *c.template get<Thing>(); });
  }

  void define_congruence(jl::Module& m) {
    using libsemigroups::Congruence;
    using libsemigroups::congruence_kind;
    using libsemigroups::Kambites;
    using libsemigroups::KnuthBendix;
    using libsemigroups::Presentation;
    using libsemigroups::ToddCoxeter;
    using libsemigroups::word_type;

    using CongruenceCommon = libsemigroups::detail::CongruenceCommon;
    using C                = Congruence<word_type>;

    ////////////////////////////////////////////////////////////////////////
    // Type registration
    ////////////////////////////////////////////////////////////////////////

    auto type = m.add_type<C>("CongruenceWord",
                              jlcxx::julia_base_type<CongruenceCommon>());

    ////////////////////////////////////////////////////////////////////////
    // Constructors. Direct registration; the (kind, p) form throws
    // LibsemigroupsException, but CxxWrap's direct-constructor path
    // surfaces it as Base.ErrorException - the Julia wrapper layer
    // (src/congruence.jl) preempts this by routing through init!.
    ////////////////////////////////////////////////////////////////////////

    type.constructor<>();
    type.constructor<congruence_kind, Presentation<word_type> const&>();
    type.constructor<C const&>();  // copy ctor

    ////////////////////////////////////////////////////////////////////////
    // init! overloads (mirror constructors)
    ////////////////////////////////////////////////////////////////////////

    type.method("init!", [](C& self) -> C& { return self.init(); });
    type.method("init!",
                [](C&                             self,
                   congruence_kind                knd,
                   Presentation<word_type> const& p) -> C& {
                  return self.init(knd, p);
                });

    ////////////////////////////////////////////////////////////////////////
    // Accessors
    ////////////////////////////////////////////////////////////////////////

    // presentation - return by copy (storage may relocate)
    type.method("presentation", [](C const& self) -> Presentation<word_type> {
      return self.presentation();
    });

    // generating_pairs - return by copy (flat vector; pairs concatenated)
    type.method("generating_pairs",
                [](C const& self) -> std::vector<word_type> {
                  auto const& pairs = self.generating_pairs();
                  return std::vector<word_type>(pairs.begin(), pairs.end());
                });

    // kind / number_of_generating_pairs -- inherited inline accessors
    type.method("kind",
                [](C const& self) -> congruence_kind { return self.kind(); });

    type.method("number_of_generating_pairs", [](C const& self) -> size_t {
      return self.number_of_generating_pairs();
    });

    // number_of_classes - non-const (may run the race)
    type.method("number_of_classes",
                [](C& self) -> uint64_t { return self.number_of_classes(); });

    // throw_if_letter_not_in_alphabet - accept ArrayRef<size_t>, build a
    // word_type inside the lambda
    type.method("throw_if_letter_not_in_alphabet",
                [](C const& self, jlcxx::ArrayRef<size_t> w) {
                  word_type ww(w.begin(), w.end());
                  self.throw_if_letter_not_in_alphabet(ww.begin(), ww.end());
                });

    ////////////////////////////////////////////////////////////////////////
    // Race-state queries
    // (max_threads getter/setter intentionally NOT bound)
    ////////////////////////////////////////////////////////////////////////

    type.method("number_of_runners", [](C const& self) -> size_t {
      return self.number_of_runners();
    });

    ////////////////////////////////////////////////////////////////////////
    // Race introspection: has<Thing>() / get<Thing>()
    ////////////////////////////////////////////////////////////////////////

    define_cong_has_get<Kambites<word_type>>(m, "kambites");
    define_cong_has_get<KnuthBendix<word_type>>(m, "knuth_bendix");
    define_cong_has_get<ToddCoxeter<word_type>>(m, "todd_coxeter");

    ////////////////////////////////////////////////////////////////////////
    // Free function: is_obviously_infinite
    ////////////////////////////////////////////////////////////////////////

    m.method("is_obviously_infinite", [](C const& c) -> bool {
      return libsemigroups::is_obviously_infinite(c);
    });

    ////////////////////////////////////////////////////////////////////////
    // Display
    ////////////////////////////////////////////////////////////////////////

    type.method("to_human_readable_repr", [](C const& self) -> std::string {
      return libsemigroups::to_human_readable_repr(self);
    });

    ////////////////////////////////////////////////////////////////////////
    // Cong-common helpers (word-helpers subset only).
    ////////////////////////////////////////////////////////////////////////

    define_cong_common_word_helpers<C>(m);
  }

}  // namespace libsemigroups_julia
