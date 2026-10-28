// konieczny.cpp - Konieczny<E> bindings for libsemigroups_julia
//
// Copyright (c) 2026
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
// This file exposes the libsemigroups Konieczny<E> template class to Julia
// via CxxWrap for the element types that have Lambda/Rho/Rank adapters in
// libsemigroups: Transf1/2/4, PPerm1/2/4 and BMat8. Konieczny<E> inherits
// directly from Runner. The nested abstract class Konieczny<E>::DClass is
// exposed as a non-owning handle (named "<Konieczny type>DClass") whose
// lifetime is tied to its parent Konieczny on the Julia side.

// CRITICAL: libsemigroups_julia.hpp MUST be included first (fmt consteval fix)
#include "libsemigroups_julia.hpp"

#include <libsemigroups/bmat8.hpp>
#include <libsemigroups/exception.hpp>
#include <libsemigroups/konieczny.hpp>
#include <libsemigroups/transf.hpp>

#include <cstddef>
#include <cstdint>
#include <iterator>
#include <string>
#include <vector>

////////////////////////////////////////////////////////////////////////
// CxxWrap type traits — IsMirroredType and SuperType specializations
////////////////////////////////////////////////////////////////////////

namespace jlcxx {

  // IsMirroredType — one per concrete Konieczny instantiation
  // specialising the type Transf<0, uint8_t/uint16_t/uint32_t>
  // This is the type that will be exposed to Julia as
  // KoniecznyTransf1/2/4 (resp.).
  template <>
  struct IsMirroredType< 
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint8_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint16_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint32_t>>>
      : std::false_type {};

  // Specialising
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint8_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint16_t>>>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint32_t>>>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::Konieczny<libsemigroups::BMat8>>
      : std::false_type {};

  // IsMirroredType — one per nested DClass type
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint8_t>>::DClass>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint16_t>>::DClass>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::Transf<0, uint32_t>>::DClass>
      : std::false_type {};

  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint8_t>>::DClass>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint16_t>>::DClass>
      : std::false_type {};
  template <>
  struct IsMirroredType<
      libsemigroups::Konieczny<libsemigroups::PPerm<0, uint32_t>>::DClass>
      : std::false_type {};

  template <>
  struct IsMirroredType<libsemigroups::Konieczny<libsemigroups::BMat8>::DClass>
      : std::false_type {};

  // SuperType — partial specialization for all Konieczny<E, Traits>
  template <typename E, typename T>
  struct SuperType<libsemigroups::Konieczny<E, T>> {
    using type = libsemigroups::Runner;
  };

}  // namespace jlcxx

namespace libsemigroups_julia {

  namespace {

    ////////////////////////////////////////////////////////////////////////
    // bind_konieczny<E> — registers Konieczny<E> and Konieczny<E>::DClass
    ////////////////////////////////////////////////////////////////////////

    template <typename E>
    void bind_konieczny(jl::Module& m, std::string const& name) {
      using K      = libsemigroups::Konieczny<E>;
      using DClass = typename K::DClass;
      using libsemigroups::Runner;

      // m.method are called when no type exists yet
      // type.method take the object as the first param (so is already defined  )

      auto type = m.add_type<K>(name, jlcxx::julia_base_type<Runner>());

      // DClass is abstract (RegularDClass / NonRegularDClass implement it),
      // so it gets no constructors. It is only ever obtained from a K.
      auto dtype = m.add_type<DClass>(name + "DClass");

      ////////////////////////////////////////////////////////////////////
      // 1. Constructors
      ////////////////////////////////////////////////////////////////////

      m.method(name, [](E const& g1) {
        std::vector<E> v{g1};
        K              k;
        k.add_generators(v.begin(), v.end());
        return k;
      });

      m.method(name, [](E const& g1, E const& g2) {
        std::vector<E> v{g1, g2};
        K              k;
        k.add_generators(v.begin(), v.end());
        return k;
      });

      m.method(name, [](E const& g1, E const& g2, E const& g3) {
        std::vector<E> v{g1, g2, g3};
        K              k;
        k.add_generators(v.begin(), v.end());
        return k;
      });

      m.method(name, [](E const& g1, E const& g2, E const& g3, E const& g4) {
        std::vector<E> v{g1, g2, g3, g4}; // array
        K              k;
        k.add_generators(v.begin(), v.end()); // iterators in v
        return k;
      });

      ////////////////////////////////////////////////////////////////////
      // 2. Generators
      ////////////////////////////////////////////////////////////////////

      // add_generator! (void — Julia wrapper returns self)
      type.method("add_generator!",
                  [](K& self, E const& x) { self.add_generator(x); });

      type.method("number_of_generators", [](K const& self) -> size_t {
        return self.number_of_generators();
      });

      // generator — returns by copy (GC safety)
      type.method("generator", [](K const& self, size_t i) -> E {
        return self.generator(i);
      });

      ////////////////////////////////////////////////////////////////////
      // 3. Size and degree
      ////////////////////////////////////////////////////////////////////

      type.method("size", [](K& self) -> size_t { return self.size(); });

      type.method("current_size",
                  [](K const& self) -> size_t { return self.current_size(); });

      type.method("degree",
                  [](K const& self) -> size_t { return self.degree(); });

      ////////////////////////////////////////////////////////////////////
      // 4. Counts of Green's classes etc. Each has a "current_" twin that
      //    does not trigger a run.
      ////////////////////////////////////////////////////////////////////

      type.method("number_of_D_classes",
                  [](K& self) -> size_t { return self.number_of_D_classes(); });
      type.method("current_number_of_D_classes", [](K const& self) -> size_t {
        return self.current_number_of_D_classes();
      });

      type.method("number_of_regular_D_classes", [](K& self) -> size_t {
        return self.number_of_regular_D_classes();
      });
      type.method("current_number_of_regular_D_classes",
                  [](K const& self) -> size_t {
                    return self.current_number_of_regular_D_classes();
                  });

      type.method("number_of_L_classes",
                  [](K& self) -> size_t { return self.number_of_L_classes(); });
      type.method("current_number_of_L_classes", [](K const& self) -> size_t {
        return self.current_number_of_L_classes();
      });

      type.method("number_of_regular_L_classes", [](K& self) -> size_t {
        return self.number_of_regular_L_classes();
      });
      type.method("current_number_of_regular_L_classes",
                  [](K const& self) -> size_t {
                    return self.current_number_of_regular_L_classes();
                  });

      type.method("number_of_R_classes",
                  [](K& self) -> size_t { return self.number_of_R_classes(); });
      type.method("current_number_of_R_classes", [](K const& self) -> size_t {
        return self.current_number_of_R_classes();
      });

      type.method("number_of_regular_R_classes", [](K& self) -> size_t {
        return self.number_of_regular_R_classes();
      });
      type.method("current_number_of_regular_R_classes",
                  [](K const& self) -> size_t {
                    return self.current_number_of_regular_R_classes();
                  });

      type.method("number_of_H_classes",
                  [](K& self) -> size_t { return self.number_of_H_classes(); });
      type.method("current_number_of_H_classes", [](K const& self) -> size_t {
        return self.current_number_of_H_classes();
      });

      type.method("number_of_idempotents", [](K& self) -> size_t {
        return self.number_of_idempotents();
      });
      type.method("current_number_of_idempotents", [](K const& self) -> size_t {
        return self.current_number_of_idempotents();
      });

      type.method("number_of_regular_elements", [](K& self) -> size_t {
        return self.number_of_regular_elements();
      });
      type.method("current_number_of_regular_elements",
                  [](K const& self) -> size_t {
                    return self.current_number_of_regular_elements();
                  });

      ////////////////////////////////////////////////////////////////////
      // 5. Membership
      ////////////////////////////////////////////////////////////////////

      type.method("contains",
                  [](K& self, E const& x) -> bool { return self.contains(x); });

      type.method("is_regular_element", [](K& self, E const& x) -> bool {
        return self.is_regular_element(x);
      });

      ////////////////////////////////////////////////////////////////////
      // 6. D-class access — all return non-owning references to objects
      //    owned by the Konieczny instance. The Julia wrapper keeps the
      //    parent alive for as long as a handle exists.
      ////////////////////////////////////////////////////////////////////

      type.method("D_class_of_element", [](K& self, E const& x) -> DClass& {
        return self.D_class_of_element(x);
      });

      // D_class(i): the i-th D-class (0-based) in the order they were found.
      type.method("D_class", [](K& self, size_t i) -> DClass& {
        self.run();
        size_t const n = self.number_of_D_classes();
        if (i >= n) {
          throw libsemigroups::LibsemigroupsException(
              __FILE__,
              __LINE__,
              __func__,
              fmt::format(
                  "expected a value in the range [0, {}), found {}", n, i));
        }
        auto it = self.cbegin_D_classes();
        std::advance(it, i);
        return const_cast<DClass&>(static_cast<DClass const&>(*it));
      });

      // regular_D_class(i): the i-th regular D-class (0-based).
      type.method("regular_D_class", [](K& self, size_t i) -> DClass& {
        self.run();
        size_t const n = self.number_of_regular_D_classes();
        if (i >= n) {
          throw libsemigroups::LibsemigroupsException(
              __FILE__,
              __LINE__,
              __func__,
              fmt::format(
                  "expected a value in the range [0, {}), found {}", n, i));
        }
        auto it = self.cbegin_regular_D_classes();
        std::advance(it, i);
        return const_cast<DClass&>(static_cast<DClass const&>(*it));
      });

      ////////////////////////////////////////////////////////////////////
      // 7. DClass methods
      ////////////////////////////////////////////////////////////////////

      // rep — returns by copy (GC safety)
      dtype.method("rep", [](DClass const& d) -> E { return d.rep(); });

      dtype.method("size", [](DClass const& d) -> size_t { return d.size(); });

      dtype.method("number_of_L_classes", [](DClass const& d) -> size_t {
        return d.number_of_L_classes();
      });

      dtype.method("number_of_R_classes", [](DClass const& d) -> size_t {
        return d.number_of_R_classes();
      });

      dtype.method("size_H_class",
                   [](DClass const& d) -> size_t { return d.size_H_class(); });

      dtype.method("is_regular_D_class", [](DClass const& d) -> bool {
        return d.is_regular_D_class();
      });

      dtype.method("number_of_idempotents", [](DClass const& d) -> size_t {
        return d.number_of_idempotents();
      });

      dtype.method("contains",
                   [](DClass& d, E const& x) -> bool { return d.contains(x); });

      ////////////////////////////////////////////////////////////////////
      // 8. Display
      ////////////////////////////////////////////////////////////////////

      m.method("to_human_readable_repr", [](K const& self) -> std::string {
        return libsemigroups::to_human_readable_repr(self);
      });
    }

  }  // anonymous namespace

  ////////////////////////////////////////////////////////////////////////
  // define_konieczny — register all 7 Konieczny<E> instantiations
  ////////////////////////////////////////////////////////////////////////

  void define_konieczny(jl::Module& m) {
    using namespace libsemigroups;

    // Transf types
    bind_konieczny<Transf<0, uint8_t>>(m, "KoniecznyTransf1");
    bind_konieczny<Transf<0, uint16_t>>(m, "KoniecznyTransf2");
    bind_konieczny<Transf<0, uint32_t>>(m, "KoniecznyTransf4");

    // PPerm types
    bind_konieczny<PPerm<0, uint8_t>>(m, "KoniecznyPPerm1");
    bind_konieczny<PPerm<0, uint16_t>>(m, "KoniecznyPPerm2");
    bind_konieczny<PPerm<0, uint32_t>>(m, "KoniecznyPPerm4");

    // BMat8
    bind_konieczny<BMat8>(m, "KoniecznyBMat8");
  }

}  // namespace libsemigroups_julia
