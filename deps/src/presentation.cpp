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

////////////////////////////////////////////////////////////////////////
// CxxWrap type traits IsMirroredType and SuperType
////////////////////////////////////////////////////////////////////////

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::Presentation<libsemigroups::word_type>>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::Presentation<std::string>>
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

  namespace {

    ////////////////////////////////////////////////////////////////////////
    // WordT — bridges jlcxx argument types for word_type vs std::string
    ////////////////////////////////////////////////////////////////////////

    template <typename Word>
    struct WordT;

    template <>
    struct WordT<libsemigroups::word_type> {
      using ArgType = jlcxx::ArrayRef<size_t>;
      static libsemigroups::word_type convert(ArgType arr) {
        return libsemigroups::word_type(arr.begin(), arr.end());
      }
    };

    template <>
    struct WordT<std::string> {
      using ArgType = std::string const&;
      static std::string const& convert(ArgType str) {
        return str;
      }
    };

    ////////////////////////////////////////////////////////////////////////
    // bind_presentation<Word> — template helper that registers all
    // word-type methods for a single Presentation<Word> instantiation.
    ////////////////////////////////////////////////////////////////////////

    template <typename Word>
    void bind_presentation(jl::Module& m, std::string const& name) {
      using P      = libsemigroups::Presentation<Word>;
      using Letter = typename P::letter_type;
      using Traits = WordT<Word>;
      using Arg    = typename Traits::ArgType;

      auto type = m.add_type<P>(name);

      ////////////////////////////////////////////////////////////////////
      // Constructors & Common Methods
      ////////////////////////////////////////////////////////////////////

      type.template constructor<>();
      type.template constructor<P const&>();

      type.method("init!", [](P& self) { self.init(); });
      type.method("alphabet",
                  [](P const& self) -> Word { return self.alphabet(); });
      type.method("set_alphabet_size!",
                  [](P& self, size_t n) { self.alphabet(n); });
      type.method("alphabet_from_rules!",
                  [](P& self) { self.alphabet_from_rules(); });
      type.method("letter", [](P const& self, size_t i) -> Letter {
        return self.letter(i);
      });
      type.method("index_of", [](P const& self, Letter x) -> size_t {
        return self.index(x);
      });
      type.method("in_alphabet", [](P const& self, Letter x) -> bool {
        return self.in_alphabet(x);
      });
      type.method("contains_empty_word", [](P const& self) -> bool {
        return self.contains_empty_word();
      });
      type.method("set_contains_empty_word!",
                  [](P& self, bool v) { self.contains_empty_word(v); });

      type.method("add_generator_no_arg!",
                  [](P& self) -> Letter { return self.add_generator(); });
      type.method("add_generator!",
                  [](P& self, Letter x) { self.add_generator(x); });
      type.method("remove_generator!",
                  [](P& self, Letter x) { self.remove_generator(x); });

      type.method("number_of_rules", [](P const& self) -> size_t {
        return self.rules.size() / 2;
      });
      type.method("rule_lhs", [](P const& self, size_t i) -> Word {
        return self.rules.at(2 * i);
      });
      type.method("rule_rhs", [](P const& self, size_t i) -> Word {
        return self.rules.at(2 * i + 1);
      });
      type.method("clear_rules!", [](P& self) { self.rules.clear(); });

      type.method("throw_if_alphabet_has_duplicates", [](P const& self) {
        self.throw_if_alphabet_has_duplicates();
      });
      type.method("throw_if_letter_not_in_alphabet",
                  [](P const& self, Letter x) {
                    self.throw_if_letter_not_in_alphabet(x);
                  });
      type.method("throw_if_bad_rules",
                  [](P const& self) { self.throw_if_bad_rules(); });
      type.method("throw_if_bad_alphabet_or_rules",
                  [](P const& self) { self.throw_if_bad_alphabet_or_rules(); });

      m.method("length_of", [](P const& p) -> size_t {
        return libsemigroups::presentation::length(p);
      });
      m.method("longest_rule_length", [](P const& p) -> size_t {
        return libsemigroups::presentation::longest_rule_length(p);
      });
      m.method("shortest_rule_length", [](P const& p) -> size_t {
        return libsemigroups::presentation::shortest_rule_length(p);
      });
      m.method("is_normalized", [](P const& p) -> bool {
        return libsemigroups::presentation::is_normalized(p);
      });
      m.method("are_rules_sorted", [](P const& p) -> bool {
        return libsemigroups::presentation::are_rules_sorted(p);
      });
      m.method("throw_if_odd_number_of_rules", [](P const& p) {
        libsemigroups::presentation::throw_if_odd_number_of_rules(p);
      });
      m.method("normalize_alphabet!", [](P& p) {
        libsemigroups::presentation::normalize_alphabet(p);
      });
      m.method("reverse_rules!",
               [](P& p) { libsemigroups::presentation::reverse(p); });
      m.method("sort_rules!",
               [](P& p) { libsemigroups::presentation::sort_rules(p); });
      m.method("sort_each_rule!", [](P& p) -> bool {
        return libsemigroups::presentation::sort_each_rule(p);
      });
      m.method("add_identity_rules!", [](P& p, Letter e) {
        libsemigroups::presentation::add_identity_rules(p, e);
      });
      m.method("add_zero_rules!", [](P& p, Letter z) {
        libsemigroups::presentation::add_zero_rules(p, z);
      });
      m.method("remove_duplicate_rules!", [](P& p) {
        libsemigroups::presentation::remove_duplicate_rules(p);
      });
      m.method("remove_trivial_rules!", [](P& p) {
        libsemigroups::presentation::remove_trivial_rules(p);
      });
      m.method("add_rules!", [](P& p, P const& q) {
        libsemigroups::presentation::add_rules(p, q);
      });
      m.method("first_unused_letter", [](P const& p) -> Letter {
        return libsemigroups::presentation::first_unused_letter(p);
      });
      m.method("longest_rule_index", [](P const& p) -> size_t {
        auto it = libsemigroups::presentation::longest_rule(p);
        return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
      });
      m.method("shortest_rule_index", [](P const& p) -> size_t {
        auto it = libsemigroups::presentation::shortest_rule(p);
        return static_cast<size_t>(std::distance(p.rules.cbegin(), it));
      });
      m.method("to_gap_string",
               [](P const& p, std::string const& var_name) -> std::string {
                 return libsemigroups::presentation::to_gap_string(p, var_name);
               });
      m.method("rules_vector", [](P const& p) -> std::vector<Word> {
        return std::vector<Word>(p.rules.cbegin(), p.rules.cend());
      });
      type.method("is_equal",
                  [](P const& a, P const& b) -> bool { return a == b; });
      type.method("to_human_readable_repr", [](P const& p) -> std::string {
        return libsemigroups::to_human_readable_repr(p);
      });

      ////////////////////////////////////////////////////////////////////
      // 2. Word-argument specific methods
      ////////////////////////////////////////////////////////////////////

      type.method("set_alphabet!",
                  [](P& self, Arg a) { self.alphabet(Traits::convert(a)); });

      m.method("add_rule_no_checks!", [](P& p, Arg lhs, Arg rhs) {
        libsemigroups::presentation::add_rule_no_checks(
            p, Traits::convert(lhs), Traits::convert(rhs));
      });

      m.method("add_rule!", [](P& p, Arg lhs, Arg rhs) {
        libsemigroups::presentation::add_rule(
            p, Traits::convert(lhs), Traits::convert(rhs));
      });

      m.method("contains_rule", [](P& p, Arg lhs, Arg rhs) -> bool {
        return libsemigroups::presentation::contains_rule(
            p, Traits::convert(lhs), Traits::convert(rhs));
      });

      m.method("change_alphabet!", [](P& p, Arg a) {
        libsemigroups::presentation::change_alphabet(p, Traits::convert(a));
      });

      m.method("add_inverse_rules!", [](P& p, Arg inverses) {
        libsemigroups::presentation::add_inverse_rules(
            p, Traits::convert(inverses));
      });

      m.method("add_inverse_rules_with_identity!",
               [](P& p, Arg inverses, Letter e) {
                 libsemigroups::presentation::add_inverse_rules(
                     p, Traits::convert(inverses), e);
               });

      m.method("replace_subword!", [](P& p, Arg existing, Arg replacement) {
        libsemigroups::presentation::replace_subword(
            p, Traits::convert(existing), Traits::convert(replacement));
      });

      m.method("replace_word!", [](P& p, Arg existing, Arg replacement) {
        libsemigroups::presentation::replace_word(
            p, Traits::convert(existing), Traits::convert(replacement));
      });

      m.method("replace_word_with_new_generator!", [](P& p, Arg w) -> Letter {
        return libsemigroups::presentation::replace_word_with_new_generator(
            p, Traits::convert(w));
      });

      m.method("index_rule", [](P const& p, Arg lhs, Arg rhs) -> size_t {
        return libsemigroups::presentation::index_rule(
            p, Traits::convert(lhs), Traits::convert(rhs));
      });

      m.method("is_rule", [](P const& p, Arg lhs, Arg rhs) -> bool {
        return libsemigroups::presentation::is_rule(
            p, Traits::convert(lhs), Traits::convert(rhs));
      });

      m.method("throw_if_bad_inverses", [](P const& p, Arg inverses) {
        libsemigroups::presentation::throw_if_bad_inverses(
            p, Traits::convert(inverses));
      });
    }

  }  // namespace

  ////////////////////////////////////////////////////////////////////////
  // define_presentation — register Presentation<W> & InversePresentation
  ////////////////////////////////////////////////////////////////////////

  void define_presentation(jl::Module& m) {
    using libsemigroups::Presentation;
    using libsemigroups::word_type;

    // Bind Presentation<word_type> and Presentation<std::string>
    bind_presentation<word_type>(m, "PresentationWord");
    bind_presentation<std::string>(m, "PresentationString");

    // -----------------------------------------------------------------------
    // InversePresentation<word_type>
    // -----------------------------------------------------------------------
    using libsemigroups::InversePresentation;

    auto itype = m.add_type<InversePresentation<word_type>>(
        "InversePresentation",
        jlcxx::julia_base_type<Presentation<word_type>>());

    itype.constructor<Presentation<word_type> const&>();
    itype.constructor<InversePresentation<word_type> const&>();

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
