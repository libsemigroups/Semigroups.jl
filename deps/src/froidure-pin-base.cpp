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

#include "libsemigroups_julia.hpp"

#include <libsemigroups/froidure-pin-base.hpp>

#include <cstddef>
#include <cstdint>
#include <vector>

// Explicit SuperType specialization for CxxWrap upcasting.
// Enables CxxBaseRef<FroidurePinBase> to upcast to Runner when calling
// inherited Runner methods (finished, run!, etc.) on FroidurePinBase instances.
namespace jlcxx {
template <> struct SuperType<libsemigroups::FroidurePinBase> {
  typedef libsemigroups::Runner type;
};
}    // namespace jlcxx

namespace libsemigroups_julia {

void define_froidure_pin_base(jl::Module & m)
{
  using libsemigroups::FroidurePinBase;
  using libsemigroups::Runner;
  using libsemigroups::word_type;
  using libsemigroups::froidure_pin::product_by_reduction;

  using FPB = FroidurePinBase;
  using WG = FPB::cayley_graph_type;

  // Register FroidurePinBase inheriting from Runner
  auto type =
      m.add_type<FroidurePinBase>("FroidurePinBase", jlcxx::julia_base_type<Runner>());

  //////////////////////////////////////////////////////////////////////////
  // Settings
  //////////////////////////////////////////////////////////////////////////

  // batch_size - getter
  type.method("batch_size", [](FPB const & self) -> size_t {
    return self.batch_size();
  });

  // set_batch_size! - setter (different name to avoid CxxWrap overload issue)
  type.method("set_batch_size!", [](FPB & self, size_t val) -> FPB & {
    return self.batch_size(val);
  });

  //////////////////////////////////////////////////////////////////////////
  // Size and enumeration
  //////////////////////////////////////////////////////////////////////////

  // current_size - number of elements enumerated so far (no enumeration)
  type.method("current_size", [](FPB const & self) -> size_t {
    return self.current_size();
  });

  // size - full enumeration, returns total size
  type.method("size", [](FPB & self) -> size_t {
    return self.size();
  });

  // degree - degree of elements
  type.method("degree", [](FPB const & self) -> size_t {
    return self.degree();
  });

  // enumerate - enumerate up to limit elements
  type.method("enumerate", [](FPB & self, size_t limit) {
    self.enumerate(limit);
  });

  //////////////////////////////////////////////////////////////////////////
  // Rules
  //////////////////////////////////////////////////////////////////////////

  // number_of_rules - total (triggers full enumeration)
  type.method("number_of_rules", [](FPB & self) -> size_t {
    return self.number_of_rules();
  });

  // current_number_of_rules - so far enumerated (no enumeration)
  type.method("current_number_of_rules", [](FPB const & self) -> size_t {
    return self.current_number_of_rules();
  });

  //////////////////////////////////////////////////////////////////////////
  // Identity element
  //////////////////////////////////////////////////////////////////////////

  // contains_one - triggers full enumeration
  type.method("contains_one", [](FPB & self) -> bool {
    return self.contains_one();
  });

  // currently_contains_one - no enumeration
  type.method("currently_contains_one", [](FPB const & self) -> bool {
    return self.currently_contains_one();
  });

  //////////////////////////////////////////////////////////////////////////
  // Position queries
  //////////////////////////////////////////////////////////////////////////

  // position_of_generator - position of i-th generator
  type.method("position_of_generator", [](FPB const & self, uint32_t i) -> uint32_t {
    return self.position_of_generator(i);
  });

  //////////////////////////////////////////////////////////////////////////
  // Prefix / suffix / first / final letter
  //////////////////////////////////////////////////////////////////////////

  type.method("prefix", [](FPB const & self, uint32_t pos) -> uint32_t {
    return self.prefix(pos);
  });

  type.method("suffix", [](FPB const & self, uint32_t pos) -> uint32_t {
    return self.suffix(pos);
  });

  type.method("first_letter", [](FPB const & self, uint32_t pos) -> uint32_t {
    return self.first_letter(pos);
  });

  type.method("final_letter", [](FPB const & self, uint32_t pos) -> uint32_t {
    return self.final_letter(pos);
  });

  //////////////////////////////////////////////////////////////////////////
  // Word lengths
  //////////////////////////////////////////////////////////////////////////

  // current_length - no enumeration
  type.method("current_length", [](FPB const & self, uint32_t pos) -> size_t {
    return self.current_length(pos);
  });

  // length - triggers enumeration
  type.method("length", [](FPB & self, uint32_t pos) -> size_t {
    return self.length(pos);
  });

  // current_max_word_length - no enumeration
  type.method("current_max_word_length", [](FPB const & self) -> size_t {
    return self.current_max_word_length();
  });

  //////////////////////////////////////////////////////////////////////////
  // Number of elements by length
  //////////////////////////////////////////////////////////////////////////

  // number_of_elements_of_length - single length (no enumeration)
  type.method("number_of_elements_of_length", [](FPB const & self, size_t len) -> size_t {
    return self.number_of_elements_of_length(len);
  });

  // number_of_elements_of_length_range - range [min, max) (no enumeration)
  type.method("number_of_elements_of_length_range",
              [](FPB const & self, size_t min, size_t max) -> size_t {
                return self.number_of_elements_of_length(min, max);
              });

  //////////////////////////////////////////////////////////////////////////
  // Cayley graphs (return by copy for safety)
  //////////////////////////////////////////////////////////////////////////

  // right_cayley_graph - triggers full enumeration
  type.method("right_cayley_graph", [](FPB & self) -> WG {
    return self.right_cayley_graph();
  });

  // left_cayley_graph - triggers full enumeration
  type.method("left_cayley_graph", [](FPB & self) -> WG {
    return self.left_cayley_graph();
  });

  // current_right_cayley_graph - no enumeration
  type.method("current_right_cayley_graph", [](FPB const & self) -> WG {
    return self.current_right_cayley_graph();
  });

  // current_left_cayley_graph - no enumeration
  type.method("current_left_cayley_graph", [](FPB const & self) -> WG {
    return self.current_left_cayley_graph();
  });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: product_by_reduction
  //////////////////////////////////////////////////////////////////////////

  m.method("product_by_reduction",
           [](FPB const & fpb, uint32_t i, uint32_t j) -> uint32_t {
             return product_by_reduction(fpb, i, j);
           });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: factorisation
  //////////////////////////////////////////////////////////////////////////

  // current_minimal_factorisation - no enumeration, returns word_type
  m.method("current_minimal_factorisation",
           [](FPB const & fpb, uint32_t pos) -> word_type {
             return libsemigroups::froidure_pin::current_minimal_factorisation(fpb, pos);
           });

  // minimal_factorisation - triggers enumeration, returns word_type
  m.method("minimal_factorisation", [](FPB & fpb, uint32_t pos) -> word_type {
    return libsemigroups::froidure_pin::minimal_factorisation(fpb, pos);
  });

  // factorisation - triggers enumeration, returns word_type
  m.method("factorisation", [](FPB & fpb, uint32_t pos) -> word_type {
    return libsemigroups::froidure_pin::factorisation(fpb, pos);
  });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: position from word
  //////////////////////////////////////////////////////////////////////////

  // current_position_word - no enumeration, returns UNDEFINED if not found
  m.method("current_position_word",
           [](FPB const & fpb, std::vector<size_t> const & w) -> uint32_t {
             return libsemigroups::froidure_pin::current_position(fpb, w);
           });

  // position_word - triggers full enumeration
  m.method("position_word", [](FPB & fpb, std::vector<size_t> const & w) -> uint32_t {
    return libsemigroups::froidure_pin::position(fpb, w);
  });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: rules (two parallel vectors)
  //////////////////////////////////////////////////////////////////////////

  // rules_lhs_vector - full enumeration, returns LHS of all rules
  m.method("rules_lhs_vector", [](FPB & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & [lhs, rhs] : libsemigroups::froidure_pin::rules(fpb))
    {
      result.push_back(lhs);
    }
    return result;
  });

  // rules_rhs_vector - full enumeration, returns RHS of all rules
  m.method("rules_rhs_vector", [](FPB & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & [lhs, rhs] : libsemigroups::froidure_pin::rules(fpb))
    {
      result.push_back(rhs);
    }
    return result;
  });

  // current_rules_lhs_vector - no enumeration
  m.method("current_rules_lhs_vector", [](FPB const & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & [lhs, rhs] : libsemigroups::froidure_pin::current_rules(fpb))
    {
      result.push_back(lhs);
    }
    return result;
  });

  // current_rules_rhs_vector - no enumeration
  m.method("current_rules_rhs_vector", [](FPB const & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & [lhs, rhs] : libsemigroups::froidure_pin::current_rules(fpb))
    {
      result.push_back(rhs);
    }
    return result;
  });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: normal forms
  //////////////////////////////////////////////////////////////////////////

  // normal_forms_vector - full enumeration
  m.method("normal_forms_vector", [](FPB & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & w : libsemigroups::froidure_pin::normal_forms(fpb))
    {
      result.push_back(w);
    }
    return result;
  });

  // current_normal_forms_vector - no enumeration
  m.method("current_normal_forms_vector", [](FPB const & fpb) -> std::vector<word_type> {
    std::vector<word_type> result;
    for (auto const & w : libsemigroups::froidure_pin::current_normal_forms(fpb))
    {
      result.push_back(w);
    }
    return result;
  });
}

}    // namespace libsemigroups_julia
