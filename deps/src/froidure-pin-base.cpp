// froidure-pin-base.cpp - FroidurePinBase bindings for libsemigroups_julia
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
// This file exposes the libsemigroups FroidurePinBase class to Julia via
// CxxWrap. FroidurePinBase is an abstract base class inheriting from Runner
// that provides non-element-specific member functions for FroidurePin<E>.

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/froidure-pin-base.hpp>
#include <libsemigroups/runner.hpp>
#include <libsemigroups/types.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <cstdint>
#include <iterator>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::FroidurePinBase> : std::false_type {};

  template <>
  struct SuperType<libsemigroups::FroidurePinBase> {
    using type = libsemigroups::Runner;
  };
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_froidure_pin_base(jl::Module& m) {
    using libsemigroups::FroidurePinBase;
    using libsemigroups::Runner;
    using libsemigroups::word_type;

    // Register FroidurePinBase inheriting from Runner.
    // No constructors — this is an abstract base class only instantiated
    // through FroidurePin<E>.
    auto type = m.add_type<FroidurePinBase>(
        "FroidurePinBase", jlcxx::julia_base_type<Runner>());

    ////////////////////////////////////////////////////////////////////////
    // Settings (getter/setter split per CxxWrap convention)
    ////////////////////////////////////////////////////////////////////////

    // batch_size - Returns the current batch size
    type.method("batch_size",
                [](FroidurePinBase const& self) -> size_t {
                  return self.batch_size();
                });

    // set_batch_size! - Sets the batch size
    type.method("set_batch_size!",
                [](FroidurePinBase& self, size_t val) {
                  self.batch_size(val);
                });

    ////////////////////////////////////////////////////////////////////////
    // Size / enumeration
    ////////////////////////////////////////////////////////////////////////

    // size - Returns the total number of elements (triggers full enumeration)
    type.method("size", [](FroidurePinBase& self) -> size_t {
      return self.size();
    });

    // current_size - Returns elements enumerated so far (no enumeration)
    type.method("current_size",
                [](FroidurePinBase const& self) -> size_t {
                  return self.current_size();
                });

    // degree - Returns the degree of the elements
    type.method("degree", [](FroidurePinBase const& self) -> size_t {
      return self.degree();
    });

    // number_of_generators - Returns the number of generators
    type.method("number_of_generators",
                [](FroidurePinBase const& self) -> size_t {
                  return self.number_of_generators();
                });

    // enumerate! - Enumerate until at least `limit` elements are found
    type.method("enumerate!",
                [](FroidurePinBase& self, size_t limit) {
                  self.enumerate(limit);
                });

    // number_of_rules - Total number of rules (triggers full enumeration)
    type.method("number_of_rules",
                [](FroidurePinBase& self) -> size_t {
                  return self.number_of_rules();
                });

    // current_number_of_rules - Rules found so far (no enumeration)
    type.method("current_number_of_rules",
                [](FroidurePinBase const& self) -> size_t {
                  return self.current_number_of_rules();
                });

    // current_max_word_length - Max word length so far (no enumeration)
    type.method("current_max_word_length",
                [](FroidurePinBase const& self) -> size_t {
                  return self.current_max_word_length();
                });

    // contains_one - Is the identity an element? (triggers full enumeration)
    type.method("contains_one",
                [](FroidurePinBase& self) -> bool {
                  return self.contains_one();
                });

    // currently_contains_one - Is the identity known to be an element?
    type.method("currently_contains_one",
                [](FroidurePinBase const& self) -> bool {
                  return self.currently_contains_one();
                });

    // number_of_elements_of_length (one-arg) - Elements with given length
    type.method("number_of_elements_of_length",
                [](FroidurePinBase const& self, size_t len) -> size_t {
                  return self.number_of_elements_of_length(len);
                });

    // number_of_elements_of_length (two-arg) - Elements with length in
    // [min, max)
    type.method("number_of_elements_of_length_range",
                [](FroidurePinBase const& self,
                   size_t                  min,
                   size_t                  max) -> size_t {
                  return self.number_of_elements_of_length(min, max);
                });

    ////////////////////////////////////////////////////////////////////////
    // Index queries — checked and _no_checks variants
    ////////////////////////////////////////////////////////////////////////

    // prefix / prefix_no_checks
    type.method("prefix",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.prefix(pos);
                });
    type.method("prefix_no_checks",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.prefix_no_checks(pos);
                });

    // suffix / suffix_no_checks
    type.method("suffix",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.suffix(pos);
                });
    type.method("suffix_no_checks",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.suffix_no_checks(pos);
                });

    // first_letter / first_letter_no_checks
    type.method("first_letter",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.first_letter(pos);
                });
    type.method("first_letter_no_checks",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.first_letter_no_checks(pos);
                });

    // final_letter / final_letter_no_checks
    type.method("final_letter",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.final_letter(pos);
                });
    type.method("final_letter_no_checks",
                [](FroidurePinBase const& self, uint32_t pos) -> uint32_t {
                  return self.final_letter_no_checks(pos);
                });

    // current_length / current_length_no_checks
    type.method("current_length",
                [](FroidurePinBase const& self, uint32_t pos) -> size_t {
                  return self.current_length(pos);
                });
    type.method("current_length_no_checks",
                [](FroidurePinBase const& self, uint32_t pos) -> size_t {
                  return self.current_length_no_checks(pos);
                });

    // length / length_no_checks (trigger full enumeration)
    type.method("length",
                [](FroidurePinBase& self, uint32_t pos) -> size_t {
                  return self.length(pos);
                });
    type.method("length_no_checks",
                [](FroidurePinBase& self, uint32_t pos) -> size_t {
                  return self.length_no_checks(pos);
                });

    // position_of_generator / position_of_generator_no_checks
    type.method("position_of_generator",
                [](FroidurePinBase const& self, uint32_t i) -> uint32_t {
                  return self.position_of_generator(i);
                });
    type.method("position_of_generator_no_checks",
                [](FroidurePinBase const& self, uint32_t i) -> uint32_t {
                  return self.position_of_generator_no_checks(i);
                });

    ////////////////////////////////////////////////////////////////////////
    // Factorisation — froidure_pin:: free functions returning word_type
    ////////////////////////////////////////////////////////////////////////

    // current_minimal_factorisation (checked, no enumeration)
    m.method("current_minimal_factorisation",
             [](FroidurePinBase const& fpb,
                uint32_t               pos) -> word_type {
               return libsemigroups::froidure_pin::
                   current_minimal_factorisation(fpb, pos);
             });

    // current_minimal_factorisation_no_checks (unchecked, no enumeration)
    m.method("current_minimal_factorisation_no_checks",
             [](FroidurePinBase const& fpb,
                uint32_t               pos) -> word_type {
               return libsemigroups::froidure_pin::
                   current_minimal_factorisation_no_checks(fpb, pos);
             });

    // minimal_factorisation (checked, triggers partial enumeration)
    m.method("minimal_factorisation",
             [](FroidurePinBase& fpb, uint32_t pos) -> word_type {
               return libsemigroups::froidure_pin::minimal_factorisation(
                   fpb, pos);
             });

    // factorisation (checked, triggers partial enumeration)
    m.method("factorisation",
             [](FroidurePinBase& fpb, uint32_t pos) -> word_type {
               return libsemigroups::froidure_pin::factorisation(fpb, pos);
             });

    ////////////////////////////////////////////////////////////////////////
    // Word-position queries — ArrayRef<size_t> for Julia Vector{UInt}
    ////////////////////////////////////////////////////////////////////////

    // froidure_pin::current_position (checked, no enumeration)
    m.method("current_position",
             [](FroidurePinBase const& fpb,
                jlcxx::ArrayRef<size_t> arr) -> uint32_t {
               word_type w(arr.begin(), arr.end());
               return libsemigroups::froidure_pin::current_position(fpb, w);
             });

    // froidure_pin::current_position_no_checks (unchecked, no enumeration)
    m.method("current_position_no_checks",
             [](FroidurePinBase const& fpb,
                jlcxx::ArrayRef<size_t> arr) -> uint32_t {
               word_type w(arr.begin(), arr.end());
               return libsemigroups::froidure_pin::current_position_no_checks(
                   fpb, w);
             });

    // froidure_pin::position (checked, triggers full enumeration)
    m.method("position",
             [](FroidurePinBase& fpb,
                jlcxx::ArrayRef<size_t> arr) -> uint32_t {
               word_type w(arr.begin(), arr.end());
               return libsemigroups::froidure_pin::position(fpb, w);
             });

    // froidure_pin::position_no_checks (unchecked, triggers full enumeration)
    m.method("position_no_checks",
             [](FroidurePinBase& fpb,
                jlcxx::ArrayRef<size_t> arr) -> uint32_t {
               word_type w(arr.begin(), arr.end());
               return libsemigroups::froidure_pin::position_no_checks(fpb, w);
             });

    // froidure_pin::product_by_reduction (checked)
    m.method("product_by_reduction",
             [](FroidurePinBase const& fpb,
                uint32_t               i,
                uint32_t               j) -> uint32_t {
               return libsemigroups::froidure_pin::product_by_reduction(
                   fpb, i, j);
             });

    // froidure_pin::product_by_reduction_no_checks (unchecked)
    m.method("product_by_reduction_no_checks",
             [](FroidurePinBase const& fpb,
                uint32_t               i,
                uint32_t               j) -> uint32_t {
               return libsemigroups::froidure_pin::
                   product_by_reduction_no_checks(fpb, i, j);
             });

    ////////////////////////////////////////////////////////////////////////
    // Cayley graphs — return const& to already-bound WordGraph<uint32_t>
    ////////////////////////////////////////////////////////////////////////

    // right_cayley_graph (triggers full enumeration)
    type.method(
        "right_cayley_graph",
        [](FroidurePinBase& self)
            -> FroidurePinBase::cayley_graph_type const& {
          return self.right_cayley_graph();
        });

    // current_right_cayley_graph (no enumeration)
    type.method(
        "current_right_cayley_graph",
        [](FroidurePinBase const& self)
            -> FroidurePinBase::cayley_graph_type const& {
          return self.current_right_cayley_graph();
        });

    // left_cayley_graph (triggers full enumeration)
    type.method(
        "left_cayley_graph",
        [](FroidurePinBase& self)
            -> FroidurePinBase::cayley_graph_type const& {
          return self.left_cayley_graph();
        });

    // current_left_cayley_graph (no enumeration)
    type.method(
        "current_left_cayley_graph",
        [](FroidurePinBase const& self)
            -> FroidurePinBase::cayley_graph_type const& {
          return self.current_left_cayley_graph();
        });

    ////////////////////////////////////////////////////////////////////////
    // Materialized collections — rules and normal forms
    ////////////////////////////////////////////////////////////////////////
    // const_rule_iterator dereferences to relation_type =
    //   std::pair<word_type, word_type>
    // CxxWrap cannot return std::pair, so we split into two parallel
    // vectors: rules_lhs and rules_rhs.

    // rules_lhs / rules_rhs — full enumeration, then collect
    m.method("rules_lhs",
             [](FroidurePinBase& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_rules();
               auto                   end = fpb.cend_rules();
               for (; it != end; ++it) {
                 result.push_back((*it).first);
               }
               return result;
             });

    m.method("rules_rhs",
             [](FroidurePinBase& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_rules();
               auto                   end = fpb.cend_rules();
               for (; it != end; ++it) {
                 result.push_back((*it).second);
               }
               return result;
             });

    // current_rules_lhs / current_rules_rhs — no enumeration
    m.method("current_rules_lhs",
             [](FroidurePinBase const& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_current_rules();
               auto                   end = fpb.cend_current_rules();
               for (; it != end; ++it) {
                 result.push_back((*it).first);
               }
               return result;
             });

    m.method("current_rules_rhs",
             [](FroidurePinBase const& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_current_rules();
               auto                   end = fpb.cend_current_rules();
               for (; it != end; ++it) {
                 result.push_back((*it).second);
               }
               return result;
             });

    // normal_forms — full enumeration, collect into vector<word_type>
    m.method("normal_forms",
             [](FroidurePinBase& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_normal_forms();
               auto                   end = fpb.cend_normal_forms();
               for (; it != end; ++it) {
                 result.push_back(*it);
               }
               return result;
             });

    // current_normal_forms — no enumeration
    m.method("current_normal_forms",
             [](FroidurePinBase const& fpb) -> std::vector<word_type> {
               std::vector<word_type> result;
               auto                   it  = fpb.cbegin_current_normal_forms();
               auto                   end = fpb.cend_current_normal_forms();
               for (; it != end; ++it) {
                 result.push_back(*it);
               }
               return result;
             });
  }

}  // namespace libsemigroups_julia
