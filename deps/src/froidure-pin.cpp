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

#include <libsemigroups/froidure-pin.hpp>
#include <libsemigroups/transf.hpp>

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

// CxxWrap SuperType: enables CxxBaseRef upcasting for all FroidurePin<E>
// types to FroidurePinBase when dispatching inherited methods.
namespace jlcxx {
template <typename E> struct SuperType<libsemigroups::FroidurePin<E>> {
  typedef libsemigroups::FroidurePinBase type;
};
}    // namespace jlcxx

namespace libsemigroups_julia {

namespace {

template <typename Element>
void bind_froidure_pin(jl::Module &                                              m,
                       jlcxx::TypeWrapper<libsemigroups::FroidurePin<Element>> & type,
                       std::string const & type_name)
{
  using FP = libsemigroups::FroidurePin<Element>;
  using word_type = libsemigroups::word_type;

  //////////////////////////////////////////////////////////////////////////
  // Constructors from individual generators
  // StdVector<WrappedType> cannot be constructed on the Julia side,
  // so we provide individual-element constructors that build the vector
  // internally on the C++ side.
  //////////////////////////////////////////////////////////////////////////

  m.method(type_name, [](Element const & g1) -> FP {
    std::vector<Element> gens = {g1};
    return FP(gens.begin(), gens.end());
  });

  m.method(type_name, [](Element const & g1, Element const & g2) -> FP {
    std::vector<Element> gens = {g1, g2};
    return FP(gens.begin(), gens.end());
  });

  m.method(type_name,
           [](Element const & g1, Element const & g2, Element const & g3) -> FP {
             std::vector<Element> gens = {g1, g2, g3};
             return FP(gens.begin(), gens.end());
           });

  m.method(type_name,
           [](Element const & g1, Element const & g2, Element const & g3,
              Element const & g4) -> FP {
             std::vector<Element> gens = {g1, g2, g3, g4};
             return FP(gens.begin(), gens.end());
           });

  //////////////////////////////////////////////////////////////////////////
  // Copy
  //////////////////////////////////////////////////////////////////////////

  type.method("copy", [](FP const & self) -> FP {
    return FP(self);
  });

  //////////////////////////////////////////////////////////////////////////
  // Generator access
  //////////////////////////////////////////////////////////////////////////

  type.method("number_of_generators", [](FP const & self) -> size_t {
    return self.number_of_generators();
  });

  type.method("generator", [](FP const & self, uint32_t i) -> Element {
    return self.generator(i);
  });

  //////////////////////////////////////////////////////////////////////////
  // Element access (return by copy for GC safety)
  //////////////////////////////////////////////////////////////////////////

  type.method("at", [](FP & self, uint32_t i) -> Element {
    return self.at(i);
  });

  type.method("sorted_at", [](FP & self, uint32_t i) -> Element {
    return self.sorted_at(i);
  });

  //////////////////////////////////////////////////////////////////////////
  // Position / membership (element-based overloads)
  // Named with _element suffix to avoid CxxWrap dispatch conflicts with
  // FroidurePinBase's index/word-based methods.
  //////////////////////////////////////////////////////////////////////////

  type.method("current_position_element",
              [](FP const & self, Element const & x) -> uint32_t {
                return self.current_position(x);
              });

  type.method("position_element", [](FP & self, Element const & x) -> uint32_t {
    return self.position(x);
  });

  type.method("sorted_position_element", [](FP & self, Element const & x) -> uint32_t {
    return self.sorted_position(x);
  });

  type.method("contains_element", [](FP & self, Element const & x) -> bool {
    return self.contains(x);
  });

  //////////////////////////////////////////////////////////////////////////
  // Products and index transforms
  //////////////////////////////////////////////////////////////////////////

  type.method("fast_product", [](FP const & self, uint32_t i, uint32_t j) -> uint32_t {
    return self.fast_product(i, j);
  });

  type.method("to_sorted_position", [](FP & self, uint32_t i) -> uint32_t {
    return self.to_sorted_position(i);
  });

  //////////////////////////////////////////////////////////////////////////
  // Idempotents
  //////////////////////////////////////////////////////////////////////////

  type.method("number_of_idempotents", [](FP & self) -> size_t {
    return self.number_of_idempotents();
  });

  type.method("is_idempotent", [](FP & self, uint32_t i) -> bool {
    return self.is_idempotent(i);
  });

  //////////////////////////////////////////////////////////////////////////
  // Generator management (mutating)
  //////////////////////////////////////////////////////////////////////////

  type.method("add_generator!", [](FP & self, Element const & x) {
    self.add_generator(x);
  });

  type.method("add_generators!", [](FP & self, std::vector<Element> const & gens) {
    self.add_generators(gens.begin(), gens.end());
  });

  type.method("closure!", [](FP & self, std::vector<Element> const & gens) {
    self.closure(gens.begin(), gens.end());
  });

  //////////////////////////////////////////////////////////////////////////
  // Copy operations (return new FP)
  //////////////////////////////////////////////////////////////////////////

  type.method("copy_add_generators",
              [](FP const & self, std::vector<Element> const & gens) -> FP {
                return self.copy_add_generators(gens.begin(), gens.end());
              });

  type.method("copy_closure", [](FP & self, std::vector<Element> const & gens) -> FP {
    return self.copy_closure(gens.begin(), gens.end());
  });

  //////////////////////////////////////////////////////////////////////////
  // Reserve
  //////////////////////////////////////////////////////////////////////////

  type.method("reserve!", [](FP & self, size_t val) {
    self.reserve(val);
  });

  //////////////////////////////////////////////////////////////////////////
  // Collection methods (collect iterators to vectors)
  //////////////////////////////////////////////////////////////////////////

  type.method("elements_vector", [](FP & self) -> std::vector<Element> {
    self.run();
    return std::vector<Element>(self.cbegin(), self.cend());
  });

  type.method("sorted_elements_vector", [](FP & self) -> std::vector<Element> {
    std::vector<Element> result;
    for (auto const & e : libsemigroups::froidure_pin::sorted_elements(self))
    {
      result.push_back(e);
    }
    return result;
  });

  type.method("idempotents_vector", [](FP & self) -> std::vector<Element> {
    std::vector<Element> result;
    for (auto const & e : libsemigroups::froidure_pin::idempotents(self))
    {
      result.push_back(e);
    }
    return result;
  });

  //////////////////////////////////////////////////////////////////////////
  // Free functions: element-dependent
  //////////////////////////////////////////////////////////////////////////

  // to_element: convert word -> Element (uses member function with iterators)
  m.method("to_element", [](FP & fp, std::vector<size_t> const & w) -> Element {
    return fp.to_element(w.begin(), w.end());
  });

  // equal_to_words: check if two words represent the same element
  m.method(
      "equal_to_words",
      [](FP & fp, std::vector<size_t> const & x, std::vector<size_t> const & y) -> bool {
        return fp.equal_to(x.begin(), x.end(), y.begin(), y.end());
      });

  // factorisation by element (distinct from FPB's index-based factorisation)
  m.method("factorisation_element", [](FP & fp, Element const & x) -> word_type {
    return libsemigroups::froidure_pin::factorisation(fp, x);
  });

  m.method("minimal_factorisation_element", [](FP & fp, Element const & x) -> word_type {
    return libsemigroups::froidure_pin::minimal_factorisation(fp, x);
  });
}

}    // anonymous namespace

// Main function to define all FroidurePin<E> template instantiations
void define_froidure_pin(jl::Module & m)
{
  using namespace libsemigroups;

  ////////////////////////////////////////////////////////////////////////
  // FroidurePin<Transf<0, ...>>
  ////////////////////////////////////////////////////////////////////////

  auto fp_transf1 = m.add_type<FroidurePin<Transf<0, uint8_t>>>(
      "FroidurePinTransf1", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Transf<0, uint8_t>>(m, fp_transf1, "FroidurePinTransf1");

  auto fp_transf2 = m.add_type<FroidurePin<Transf<0, uint16_t>>>(
      "FroidurePinTransf2", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Transf<0, uint16_t>>(m, fp_transf2, "FroidurePinTransf2");

  auto fp_transf4 = m.add_type<FroidurePin<Transf<0, uint32_t>>>(
      "FroidurePinTransf4", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Transf<0, uint32_t>>(m, fp_transf4, "FroidurePinTransf4");

  ////////////////////////////////////////////////////////////////////////
  // FroidurePin<PPerm<0, ...>>
  ////////////////////////////////////////////////////////////////////////

  auto fp_pperm1 = m.add_type<FroidurePin<PPerm<0, uint8_t>>>(
      "FroidurePinPPerm1", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<PPerm<0, uint8_t>>(m, fp_pperm1, "FroidurePinPPerm1");

  auto fp_pperm2 = m.add_type<FroidurePin<PPerm<0, uint16_t>>>(
      "FroidurePinPPerm2", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<PPerm<0, uint16_t>>(m, fp_pperm2, "FroidurePinPPerm2");

  auto fp_pperm4 = m.add_type<FroidurePin<PPerm<0, uint32_t>>>(
      "FroidurePinPPerm4", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<PPerm<0, uint32_t>>(m, fp_pperm4, "FroidurePinPPerm4");

  ////////////////////////////////////////////////////////////////////////
  // FroidurePin<Perm<0, ...>>
  ////////////////////////////////////////////////////////////////////////

  auto fp_perm1 = m.add_type<FroidurePin<Perm<0, uint8_t>>>(
      "FroidurePinPerm1", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Perm<0, uint8_t>>(m, fp_perm1, "FroidurePinPerm1");

  auto fp_perm2 = m.add_type<FroidurePin<Perm<0, uint16_t>>>(
      "FroidurePinPerm2", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Perm<0, uint16_t>>(m, fp_perm2, "FroidurePinPerm2");

  auto fp_perm4 = m.add_type<FroidurePin<Perm<0, uint32_t>>>(
      "FroidurePinPerm4", jlcxx::julia_base_type<FroidurePinBase>());
  bind_froidure_pin<Perm<0, uint32_t>>(m, fp_perm4, "FroidurePinPerm4");
}

}    // namespace libsemigroups_julia
