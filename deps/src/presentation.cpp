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

#include "libsemigroups_julia.hpp"

#include <libsemigroups/presentation.hpp>
#include <libsemigroups/types.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <iterator>
#include <string>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Presentation<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct IsMirroredType<
      libsemigroups::InversePresentation<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct SuperType<
      libsemigroups::InversePresentation<libsemigroups::word_type>> {
    using type = libsemigroups::Presentation<libsemigroups::word_type>;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_presentation(jl::Module& m) {
    using libsemigroups::Presentation;
    using libsemigroups::word_type;

    auto type = m.add_type<Presentation<word_type>>("Presentation");
    type.constructor<>();
    type.constructor<Presentation<word_type> const&>();  // copy ctor

    type.method("init!", [](Presentation<word_type>& self) { self.init(); });

    type.method("alphabet",
                [](Presentation<word_type> const& self) -> word_type {
                  return self.alphabet();
                });

    type.method(
        "set_alphabet_size!",
        [](Presentation<word_type>& self, size_t n) { self.alphabet(n); });

    type.method("set_alphabet!",
                [](Presentation<word_type>& self, jlcxx::ArrayRef<size_t> a) {
                  self.alphabet(word_type(a.begin(), a.end()));
                });

    type.method("alphabet_from_rules!", [](Presentation<word_type>& self) {
      self.alphabet_from_rules();
    });

    type.method("letter",
                [](Presentation<word_type> const& self, size_t i) -> size_t {
                  return self.letter(i);
                });

    type.method("index_of",
                [](Presentation<word_type> const& self, size_t x) -> size_t {
                  return self.index(x);
                });

    type.method("in_alphabet",
                [](Presentation<word_type> const& self, size_t x) -> bool {
                  return self.in_alphabet(x);
                });

    type.method("contains_empty_word",
                [](Presentation<word_type> const& self) -> bool {
                  return self.contains_empty_word();
                });
    type.method("set_contains_empty_word!",
                [](Presentation<word_type>& self, bool v) {
                  self.contains_empty_word(v);
                });

    type.method("add_generator_no_arg!",
                [](Presentation<word_type>& self) -> size_t {
                  return self.add_generator();
                });
    type.method("add_generator!", [](Presentation<word_type>& self, size_t x) {
      self.add_generator(x);
    });
    type.method("remove_generator!",
                [](Presentation<word_type>& self, size_t x) {
                  self.remove_generator(x);
                });

    m.method("add_rule_no_checks!",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  lhs,
                jlcxx::ArrayRef<size_t>  rhs) {
               word_type l(lhs.begin(), lhs.end());
               word_type r(rhs.begin(), rhs.end());
               libsemigroups::presentation::add_rule_no_checks(p, l, r);
             });

    m.method("add_rule!",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  lhs,
                jlcxx::ArrayRef<size_t>  rhs) {
               word_type l(lhs.begin(), lhs.end());
               word_type r(rhs.begin(), rhs.end());
               libsemigroups::presentation::add_rule(p, l, r);
             });

    type.method("number_of_rules",
                [](Presentation<word_type> const& self) -> size_t {
                  return self.rules.size() / 2;
                });

    type.method("rule_lhs",
                [](Presentation<word_type> const& self, size_t i) -> word_type {
                  return self.rules.at(2 * i);
                });

    type.method("rule_rhs",
                [](Presentation<word_type> const& self, size_t i) -> word_type {
                  return self.rules.at(2 * i + 1);
                });

    type.method("clear_rules!",
                [](Presentation<word_type>& self) { self.rules.clear(); });

    type.method("throw_if_alphabet_has_duplicates",
                [](Presentation<word_type> const& self) {
                  self.throw_if_alphabet_has_duplicates();
                });
    type.method("throw_if_letter_not_in_alphabet",
                [](Presentation<word_type> const& self, size_t x) {
                  self.throw_if_letter_not_in_alphabet(x);
                });
    type.method("throw_if_bad_rules", [](Presentation<word_type> const& self) {
      self.throw_if_bad_rules();
    });
    type.method("throw_if_bad_alphabet_or_rules",
                [](Presentation<word_type> const& self) {
                  self.throw_if_bad_alphabet_or_rules();
                });

    m.method("length_of", [](Presentation<word_type> const& p) -> size_t {
      return libsemigroups::presentation::length(p);
    });
    m.method("longest_rule_length",
             [](Presentation<word_type> const& p) -> size_t {
               return libsemigroups::presentation::longest_rule_length(p);
             });
    m.method("shortest_rule_length",
             [](Presentation<word_type> const& p) -> size_t {
               return libsemigroups::presentation::shortest_rule_length(p);
             });
    m.method("is_normalized", [](Presentation<word_type> const& p) -> bool {
      return libsemigroups::presentation::is_normalized(p);
    });
    m.method("are_rules_sorted", [](Presentation<word_type> const& p) -> bool {
      return libsemigroups::presentation::are_rules_sorted(p);
    });
    m.method("contains_rule",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  lhs,
                jlcxx::ArrayRef<size_t>  rhs) -> bool {
               word_type l(lhs.begin(), lhs.end());
               word_type r(rhs.begin(), rhs.end());
               return libsemigroups::presentation::contains_rule(p, l, r);
             });
    m.method("throw_if_odd_number_of_rules",
             [](Presentation<word_type> const& p) {
               // Fully qualified: the iterator-pair overload is also in scope.
               libsemigroups::presentation::throw_if_odd_number_of_rules(p);
             });

    m.method("normalize_alphabet!", [](Presentation<word_type>& p) {
      libsemigroups::presentation::normalize_alphabet(p);
    });
    m.method("change_alphabet!",
             [](Presentation<word_type>& p, jlcxx::ArrayRef<size_t> a) {
               libsemigroups::presentation::change_alphabet(
                   p, word_type(a.begin(), a.end()));
             });
    m.method("reverse_rules!", [](Presentation<word_type>& p) {
      libsemigroups::presentation::reverse(p);
    });
    m.method("sort_rules!", [](Presentation<word_type>& p) {
      libsemigroups::presentation::sort_rules(p);
    });
    m.method("sort_each_rule!", [](Presentation<word_type>& p) -> bool {
      return libsemigroups::presentation::sort_each_rule(p);
    });

    m.method("add_identity_rules!", [](Presentation<word_type>& p, size_t e) {
      libsemigroups::presentation::add_identity_rules(p, e);
    });
    m.method("add_zero_rules!", [](Presentation<word_type>& p, size_t z) {
      libsemigroups::presentation::add_zero_rules(p, z);
    });
    m.method("remove_duplicate_rules!", [](Presentation<word_type>& p) {
      libsemigroups::presentation::remove_duplicate_rules(p);
    });
    m.method("remove_trivial_rules!", [](Presentation<word_type>& p) {
      libsemigroups::presentation::remove_trivial_rules(p);
    });

    m.method("add_rules!",
             [](Presentation<word_type>& p, Presentation<word_type> const& q) {
               libsemigroups::presentation::add_rules(p, q);
             });

    m.method("add_inverse_rules!",
             [](Presentation<word_type>& p, jlcxx::ArrayRef<size_t> inverses) {
               word_type v(inverses.begin(), inverses.end());
               libsemigroups::presentation::add_inverse_rules(p, v);
             });

    m.method("add_inverse_rules_with_identity!",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  inverses,
                size_t                   e) {
               word_type v(inverses.begin(), inverses.end());
               libsemigroups::presentation::add_inverse_rules(p, v, e);
             });

    m.method("replace_subword!",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  existing,
                jlcxx::ArrayRef<size_t>  replacement) {
               word_type e(existing.begin(), existing.end());
               word_type r(replacement.begin(), replacement.end());
               libsemigroups::presentation::replace_subword(p, e, r);
             });

    m.method("replace_word!",
             [](Presentation<word_type>& p,
                jlcxx::ArrayRef<size_t>  existing,
                jlcxx::ArrayRef<size_t>  replacement) {
               word_type e(existing.begin(), existing.end());
               word_type r(replacement.begin(), replacement.end());
               libsemigroups::presentation::replace_word(p, e, r);
             });

    m.method(
        "replace_word_with_new_generator!",
        [](Presentation<word_type>& p, jlcxx::ArrayRef<size_t> w) -> size_t {
          word_type v(w.begin(), w.end());
          return libsemigroups::presentation::replace_word_with_new_generator(
              p, v);
        });

    m.method("first_unused_letter",
             [](Presentation<word_type> const& p) -> size_t {
               return libsemigroups::presentation::first_unused_letter(p);
             });

    m.method("index_rule",
             [](Presentation<word_type> const& p,
                jlcxx::ArrayRef<size_t>        lhs,
                jlcxx::ArrayRef<size_t>        rhs) -> size_t {
               word_type l(lhs.begin(), lhs.end());
               word_type r(rhs.begin(), rhs.end());
               return libsemigroups::presentation::index_rule(p, l, r);
             });

    m.method("is_rule",
             [](Presentation<word_type> const& p,
                jlcxx::ArrayRef<size_t>        lhs,
                jlcxx::ArrayRef<size_t>        rhs) -> bool {
               word_type l(lhs.begin(), lhs.end());
               word_type r(rhs.begin(), rhs.end());
               return libsemigroups::presentation::is_rule(p, l, r);
             });

    m.method("longest_rule_index",
             [](Presentation<word_type> const& p) -> size_t {
               auto it = libsemigroups::presentation::longest_rule(p);
               return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
             });

    m.method("shortest_rule_index",
             [](Presentation<word_type> const& p) -> size_t {
               auto it = libsemigroups::presentation::shortest_rule(p);
               return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
             });

    m.method(
        "throw_if_bad_inverses",
        [](Presentation<word_type> const& p, jlcxx::ArrayRef<size_t> inverses) {
          word_type v(inverses.begin(), inverses.end());
          libsemigroups::presentation::throw_if_bad_inverses(p, v);
        });

    m.method("to_gap_string",
             [](Presentation<word_type> const& p,
                std::string const&             var_name) -> std::string {
               return libsemigroups::presentation::to_gap_string(p, var_name);
             });

    m.method("rules_vector",
             [](Presentation<word_type> const& p) -> std::vector<word_type> {
               return std::vector<word_type>(p.rules.cbegin(), p.rules.cend());
             });

    type.method(
        "is_equal",
        [](Presentation<word_type> const& a,
           Presentation<word_type> const& b) -> bool { return a == b; });
    type.method("to_human_readable_repr",
                [](Presentation<word_type> const& p) -> std::string {
                  return libsemigroups::to_human_readable_repr(p);
                });

    // -----------------------------------------------------------------------
    // InversePresentation<word_type>
    // -----------------------------------------------------------------------
    using libsemigroups::InversePresentation;

    auto itype = m.add_type<InversePresentation<word_type>>(
        "InversePresentation",
        jlcxx::julia_base_type<Presentation<word_type>>());

    itype.constructor<Presentation<word_type> const&>();
    itype.constructor<InversePresentation<word_type> const&>();  // copy ctor

    itype.method(
        "set_inverses!",
        [](InversePresentation<word_type>& self, jlcxx::ArrayRef<size_t> w) {
          self.inverses(word_type(w.begin(), w.end()));
        });
    itype.method("inverses",
                 [](InversePresentation<word_type> const& self) -> word_type {
                   return self.inverses();
                 });
    itype.method("inverse_of",
                 [](InversePresentation<word_type> const& self,
                    size_t x) -> size_t { return self.inverse(x); });
    itype.method("throw_if_bad_alphabet_rules_or_inverses",
                 [](InversePresentation<word_type> const& self) {
                   self.throw_if_bad_alphabet_rules_or_inverses();
                 });
    itype.method(
        "is_equal_inv",
        [](InversePresentation<word_type> const& a,
           InversePresentation<word_type> const& b) -> bool { return a == b; });
    itype.method("to_human_readable_repr",
                 [](InversePresentation<word_type> const& self) -> std::string {
                   return libsemigroups::to_human_readable_repr(self);
                 });
  }

}  // namespace libsemigroups_julia
