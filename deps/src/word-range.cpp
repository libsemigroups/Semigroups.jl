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
#include <libsemigroups/word-range.hpp>

#include <jlcxx/array.hpp>

#include <cstdint>
#include <vector>

namespace jlcxx {
  template <>
  struct IsMirroredType<libsemigroups::WordRange> : std::false_type {};
}  // namespace jlcxx

namespace libsemigroups_julia {

  void define_word_range(jl::Module& m) {
    using libsemigroups::Order;
    using libsemigroups::word_type;
    using libsemigroups::WordRange;

    auto type = m.add_type<WordRange>("WordRange");

    type.constructor<>();

    //////////////////////////////////////////////////////////////////////////
    // Iteration protocol
    //////////////////////////////////////////////////////////////////////////

    type.method("get",
                [](WordRange const& self) -> word_type { return self.get(); });
    type.method("next!", [](WordRange& self) { self.next(); });
    type.method("at_end",
                [](WordRange const& self) -> bool { return self.at_end(); });
    type.method("size_hint", [](WordRange const& self) -> uint64_t {
      return self.size_hint();
    });
    type.method("count",
                [](WordRange const& self) -> uint64_t { return self.count(); });
    type.method("valid",
                [](WordRange const& self) -> bool { return self.valid(); });
    type.method("init!",
                [](WordRange& self) -> WordRange& { return self.init(); });

    //////////////////////////////////////////////////////////////////////////
    // Getter/setter pairs — split names to avoid CxxWrap overload issues
    //////////////////////////////////////////////////////////////////////////

    type.method("alphabet_size", [](WordRange const& self) -> size_t {
      return self.alphabet_size();
    });
    type.method("set_alphabet_size!",
                [](WordRange& self, size_t n) { self.alphabet_size(n); });

    type.method("first", [](WordRange const& self) -> word_type {
      return self.first();
    });
    type.method("set_first!", [](WordRange& self, jlcxx::ArrayRef<size_t> w) {
      self.first(word_type(w.begin(), w.end()));
    });

    type.method("last",
                [](WordRange const& self) -> word_type { return self.last(); });
    type.method("set_last!", [](WordRange& self, jlcxx::ArrayRef<size_t> w) {
      self.last(word_type(w.begin(), w.end()));
    });

    type.method("order", [](WordRange const& self) { return self.order(); });
    type.method("set_order!", [](WordRange& self, Order o) { self.order(o); });

    type.method("upper_bound", [](WordRange const& self) -> size_t {
      return self.upper_bound();
    });
    type.method("set_upper_bound!",
                [](WordRange& self, size_t n) { self.upper_bound(n); });

    // min / max are setter-only upstream (they set first/last to word_type(val,
    // 0)).
    type.method("set_min!", [](WordRange& self, size_t n) { self.min(n); });
    type.method("set_max!", [](WordRange& self, size_t n) { self.max(n); });

    //////////////////////////////////////////////////////////////////////////
    // Free functions (module-level)
    //////////////////////////////////////////////////////////////////////////

    m.method("number_of_words",
             [](size_t n, size_t min, size_t max) -> uint64_t {
               return libsemigroups::number_of_words(n, min, max);
             });
    m.method("random_word", [](size_t length, size_t nr_letters) -> word_type {
      return libsemigroups::random_word(length, nr_letters);
    });
  }

}  // namespace libsemigroups_julia
