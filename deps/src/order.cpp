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

#include <libsemigroups/order.hpp>
#include <libsemigroups/types.hpp>

#include <jlcxx/array.hpp>

#include <cstdint>
#include <vector>

namespace libsemigroups_julia {

  // Copy a Julia-owned array view into an owned word_type.
  static libsemigroups::word_type _to_word(jlcxx::ArrayRef<size_t> a) {
    return libsemigroups::word_type(a.begin(), a.end());
  }

  void define_order(jl::Module& m) {
    using libsemigroups::Order;

    // Register Order enum. The `CppEnum` Julia base type matches the
    // pattern used by Runner::state in runner.cpp.
    m.add_bits<Order>("Order", jl::julia_type("CppEnum"));
    m.set_const("order_none", Order::none);
    m.set_const("order_shortlex", Order::shortlex);
    m.set_const("order_lex", Order::lex);
    m.set_const("order_recursive", Order::recursive);

    // Compare free functions — instantiated for word_type.
    m.method("lexicographical_compare",
             [](jlcxx::ArrayRef<size_t> x, jlcxx::ArrayRef<size_t> y) -> bool {
               return libsemigroups::lexicographical_compare(_to_word(x),
                                                             _to_word(y));
             });
    m.method("shortlex_compare",
             [](jlcxx::ArrayRef<size_t> x, jlcxx::ArrayRef<size_t> y) -> bool {
               return libsemigroups::shortlex_compare(_to_word(x), _to_word(y));
             });
    m.method("recursive_path_compare",
             [](jlcxx::ArrayRef<size_t> x, jlcxx::ArrayRef<size_t> y) -> bool {
               return libsemigroups::recursive_path_compare(_to_word(x),
                                                            _to_word(y));
             });

    // Weighted variants — take an extra weights vector.
    m.method("wt_shortlex_compare",
             [](jlcxx::ArrayRef<size_t> x,
                jlcxx::ArrayRef<size_t> y,
                jlcxx::ArrayRef<size_t> weights) -> bool {
               return libsemigroups::wt_shortlex_compare(
                   _to_word(x),
                   _to_word(y),
                   std::vector<size_t>(weights.begin(), weights.end()));
             });
    m.method("wt_lex_compare",
             [](jlcxx::ArrayRef<size_t> x,
                jlcxx::ArrayRef<size_t> y,
                jlcxx::ArrayRef<size_t> weights) -> bool {
               return libsemigroups::wt_lex_compare(
                   _to_word(x),
                   _to_word(y),
                   std::vector<size_t>(weights.begin(), weights.end()));
             });
  }

}  // namespace libsemigroups_julia
