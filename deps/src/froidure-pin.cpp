// froidure-pin.cpp - FroidurePin<E> bindings for libsemigroups_julia
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
// This file exposes the libsemigroups FroidurePin<E> template class to Julia
// via CxxWrap for all 10 element types (Transf1/2/4, PPerm1/2/4, Perm1/2/4,
// BMat8). FroidurePin<E> inherits from FroidurePinBase.

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/bmat8.hpp>
#include <libsemigroups/froidure-pin.hpp>
#include <libsemigroups/transf.hpp>

#include <jlcxx/array.hpp>

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

////////////////////////////////////////////////////////////////////////
// CxxWrap type traits — IsMirroredType and SuperType specializations
////////////////////////////////////////////////////////////////////////

namespace jlcxx {

  // IsMirroredType — one per concrete FroidurePin instantiation
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Transf<0, uint8_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Transf<0, uint16_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Transf<0, uint32_t>>>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::PPerm<0, uint8_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::PPerm<0, uint16_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::PPerm<0, uint32_t>>>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Perm<0, uint8_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Perm<0, uint16_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::Perm<0, uint32_t>>>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::FroidurePin<libsemigroups::BMat8>>
      : std::false_type {};

  // SuperType — partial specialization for all FroidurePin<E>
  template <typename E, typename T>
  struct SuperType<libsemigroups::FroidurePin<E, T>> {
    using type = libsemigroups::FroidurePinBase;
  };

}  // namespace jlcxx

namespace libsemigroups_julia {

  namespace {

    ////////////////////////////////////////////////////////////////////////
    // bind_froidure_pin<E> — template helper that registers all
    // element-typed methods for a single FroidurePin<E> instantiation.
    ////////////////////////////////////////////////////////////////////////

    template <typename E>
    void bind_froidure_pin(jl::Module& m, std::string const& name) {
      using FP = libsemigroups::FroidurePin<E>;
      using libsemigroups::FroidurePinBase;
      using libsemigroups::word_type;

      auto type
          = m.add_type<FP>(name, jlcxx::julia_base_type<FroidurePinBase>());

      ////////////////////////////////////////////////////////////////////
      // 1. Constructors — 1-4 generator arg lambdas
      //    (Can't construct StdVector of wrapped types Julia-side)
      ////////////////////////////////////////////////////////////////////

      m.method(name, [](E const& g1) {
        std::vector<E> v{g1};
        return FP(v.begin(), v.end());
      });

      m.method(name, [](E const& g1, E const& g2) {
        std::vector<E> v{g1, g2};
        return FP(v.begin(), v.end());
      });

      m.method(name, [](E const& g1, E const& g2, E const& g3) {
        std::vector<E> v{g1, g2, g3};
        return FP(v.begin(), v.end());
      });

      m.method(
          name, [](E const& g1, E const& g2, E const& g3, E const& g4) {
            std::vector<E> v{g1, g2, g3, g4};
            return FP(v.begin(), v.end());
          });

      ////////////////////////////////////////////////////////////////////
      // 2. Element access — ALL return by copy (GC safety)
      ////////////////////////////////////////////////////////////////////

      // at (triggers partial enumeration)
      type.method("at", [](FP& self, size_t i) -> E { return self.at(i); });

      // sorted_at (triggers full enumeration)
      type.method(
          "sorted_at", [](FP& self, size_t i) -> E { return self.sorted_at(i); });

      // sorted_at_no_checks
      type.method("sorted_at_no_checks",
                  [](FP& self, size_t i) -> E {
                    return self.sorted_at_no_checks(i);
                  });

      // generator (const self)
      type.method("generator",
                  [](FP const& self, size_t i) -> E {
                    return self.generator(i);
                  });

      // generator_no_checks (const self)
      type.method("generator_no_checks",
                  [](FP const& self, size_t i) -> E {
                    return self.generator_no_checks(i);
                  });

      // getindex_no_checks — binds operator[], const self
      type.method("getindex_no_checks",
                  [](FP const& self, size_t i) -> E { return self[i]; });

      ////////////////////////////////////////////////////////////////////
      // 3. Containment / position
      ////////////////////////////////////////////////////////////////////

      // contains(FP&, E const&) -> bool
      type.method("contains",
                  [](FP& self, E const& x) -> bool {
                    return self.contains(x);
                  });

      // position(FP&, E const&) -> element_index_type
      type.method("position",
                  [](FP& self, E const& x) -> uint32_t {
                    return self.position(x);
                  });

      // current_position(FP const&, E const&) -> element_index_type
      type.method("current_position",
                  [](FP const& self, E const& x) -> uint32_t {
                    return self.current_position(x);
                  });

      // sorted_position(FP&, E const&) -> element_index_type
      type.method("sorted_position",
                  [](FP& self, E const& x) -> uint32_t {
                    return self.sorted_position(x);
                  });

      // to_sorted_position(FP&, size_t) -> element_index_type
      type.method("to_sorted_position",
                  [](FP& self, size_t i) -> uint32_t {
                    return self.to_sorted_position(i);
                  });

      ////////////////////////////////////////////////////////////////////
      // 4. Fast product
      ////////////////////////////////////////////////////////////////////

      type.method("fast_product",
                  [](FP const& self, size_t i, size_t j) -> uint32_t {
                    return self.fast_product(i, j);
                  });

      type.method("fast_product_no_checks",
                  [](FP const& self, size_t i, size_t j) -> uint32_t {
                    return self.fast_product_no_checks(i, j);
                  });

      ////////////////////////////////////////////////////////////////////
      // 5. Idempotents
      ////////////////////////////////////////////////////////////////////

      type.method("number_of_idempotents",
                  [](FP& self) -> size_t {
                    return self.number_of_idempotents();
                  });

      type.method("is_idempotent",
                  [](FP& self, size_t i) -> bool {
                    return self.is_idempotent(i);
                  });

      type.method("is_idempotent_no_checks",
                  [](FP& self, size_t i) -> bool {
                    return self.is_idempotent_no_checks(i);
                  });

      ////////////////////////////////////////////////////////////////////
      // 6. Modification
      ////////////////////////////////////////////////////////////////////

      // add_generator! (void — Julia wrapper returns self)
      type.method("add_generator!",
                  [](FP& self, E const& x) { self.add_generator(x); });

      // add_generator_no_checks!
      type.method("add_generator_no_checks!",
                  [](FP& self, E const& x) {
                    self.add_generator_no_checks(x);
                  });

      // closure! — single element wrapped in 1-element vector
      type.method("closure!", [](FP& self, E const& x) {
        std::vector<E> v{x};
        self.closure(v.begin(), v.end());
      });

      // copy_closure — single element, returns new FP by value
      // NOTE: copy_closure is not const in C++ (it may enumerate)
      type.method("copy_closure",
                  [](FP& self, E const& x) -> FP {
                    std::vector<E> v{x};
                    return self.copy_closure(v.begin(), v.end());
                  });

      // copy_add_generators — single element, returns new FP by value
      type.method("copy_add_generators",
                  [](FP const& self, E const& x) -> FP {
                    std::vector<E> v{x};
                    return self.copy_add_generators(v.begin(), v.end());
                  });

      ////////////////////////////////////////////////////////////////////
      // 7. Word-element conversion (ArrayRef<size_t> for Julia Vector{UInt})
      ////////////////////////////////////////////////////////////////////

      // to_element — returns by copy (volatile const_reference!)
      m.method("to_element",
               [](FP const& self, jlcxx::ArrayRef<size_t> arr) -> E {
                 word_type w(arr.begin(), arr.end());
                 return self.to_element(w.begin(), w.end());
               });

      // to_element_no_checks
      m.method("to_element_no_checks",
               [](FP const& self, jlcxx::ArrayRef<size_t> arr) -> E {
                 word_type w(arr.begin(), arr.end());
                 return self.to_element_no_checks(w.begin(), w.end());
               });

      // equal_to — two words
      m.method("equal_to",
               [](FP const& self,
                  jlcxx::ArrayRef<size_t> arr1,
                  jlcxx::ArrayRef<size_t> arr2) -> bool {
                 word_type w1(arr1.begin(), arr1.end());
                 word_type w2(arr2.begin(), arr2.end());
                 return self.equal_to(
                     w1.begin(), w1.end(), w2.begin(), w2.end());
               });

      // equal_to_no_checks
      m.method("equal_to_no_checks",
               [](FP const& self,
                  jlcxx::ArrayRef<size_t> arr1,
                  jlcxx::ArrayRef<size_t> arr2) -> bool {
                 word_type w1(arr1.begin(), arr1.end());
                 word_type w2(arr2.begin(), arr2.end());
                 return self.equal_to_no_checks(
                     w1.begin(), w1.end(), w2.begin(), w2.end());
               });

      ////////////////////////////////////////////////////////////////////
      // 8. Materialized collections
      ////////////////////////////////////////////////////////////////////

      // idempotents — iterate cbegin_idempotents..cend_idempotents
      // Use !(it == end) to avoid C++20 ambiguous reversed operator!=
      m.method("idempotents", [](FP& self) -> std::vector<E> {
        std::vector<E> result;
        auto           it  = self.cbegin_idempotents();
        auto           end = self.cend_idempotents();
        for (; !(it == end); ++it) {
          result.push_back(*it);
        }
        return result;
      });

      // sorted_elements — iterate cbegin_sorted..cend_sorted
      // Use !(it == end) to avoid C++20 ambiguous reversed operator!=
      m.method("sorted_elements", [](FP& self) -> std::vector<E> {
        std::vector<E> result;
        auto           it  = self.cbegin_sorted();
        auto           end = self.cend_sorted();
        for (; !(it == end); ++it) {
          result.push_back(*it);
        }
        return result;
      });

      ////////////////////////////////////////////////////////////////////
      // 9. Memory
      ////////////////////////////////////////////////////////////////////

      type.method(
          "reserve!", [](FP& self, size_t val) { self.reserve(val); });

      ////////////////////////////////////////////////////////////////////
      // 10. Display
      ////////////////////////////////////////////////////////////////////

      m.method("to_human_readable_repr",
               [](FP const& self) -> std::string {
                 return libsemigroups::to_human_readable_repr(self);
               });
    }

  }  // anonymous namespace

  ////////////////////////////////////////////////////////////////////////
  // define_froidure_pin — register all 10 FroidurePin<E> instantiations
  ////////////////////////////////////////////////////////////////////////

  void define_froidure_pin(jl::Module& m) {
    using namespace libsemigroups;

    // Transf types
    bind_froidure_pin<Transf<0, uint8_t>>(m, "FroidurePinTransf1");
    bind_froidure_pin<Transf<0, uint16_t>>(m, "FroidurePinTransf2");
    bind_froidure_pin<Transf<0, uint32_t>>(m, "FroidurePinTransf4");

    // PPerm types
    bind_froidure_pin<PPerm<0, uint8_t>>(m, "FroidurePinPPerm1");
    bind_froidure_pin<PPerm<0, uint16_t>>(m, "FroidurePinPPerm2");
    bind_froidure_pin<PPerm<0, uint32_t>>(m, "FroidurePinPPerm4");

    // Perm types
    bind_froidure_pin<Perm<0, uint8_t>>(m, "FroidurePinPerm1");
    bind_froidure_pin<Perm<0, uint16_t>>(m, "FroidurePinPerm2");
    bind_froidure_pin<Perm<0, uint32_t>>(m, "FroidurePinPerm4");

    // BMat8
    bind_froidure_pin<BMat8>(m, "FroidurePinBMat8");
  }

}  // namespace libsemigroups_julia
