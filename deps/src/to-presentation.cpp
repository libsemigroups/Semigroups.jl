#include "libsemigroups_julia.hpp"

#include <libsemigroups/bmat8.hpp>
#include <libsemigroups/cong-class.hpp>
#include <libsemigroups/froidure-pin.hpp>
#include <libsemigroups/kambites-class.hpp>
#include <libsemigroups/knuth-bendix-class.hpp>
#include <libsemigroups/presentation.hpp>
#include <libsemigroups/to-presentation.hpp>
#include <libsemigroups/todd-coxeter-class.hpp>
#include <libsemigroups/transf.hpp>
#include <libsemigroups/types.hpp>

namespace libsemigroups_julia {

  namespace {

    // Register the conversion for one concrete FroidurePin<E> instantiation.
    template <typename E>
    void define_froidure_pin_to_presentation(jl::Module& m) {
      using FP = libsemigroups::FroidurePin<E>;
      m.method("to_presentation_word", [](FP& self) {
        return libsemigroups::to<
            libsemigroups::Presentation<libsemigroups::word_type>>(self);
      });
    }

  }  // namespace

  void define_to_presentation(jl::Module& m) {
    // Presentation<word_type> to InversePresentation<word_type>.
    m.method(
        "to_inverse_presentation_word",
        [](libsemigroups::Presentation<libsemigroups::word_type> const& p) {
          return libsemigroups::to<libsemigroups::InversePresentation>(p);
        });
    m.method(
        "to_inverse_presentation_word",
        [](libsemigroups::InversePresentation<libsemigroups::word_type> const&
               ip) {
          return libsemigroups::InversePresentation<libsemigroups::word_type>(
              ip);
        });
    // Congruence, Kambites, ToddCoxeter, or KnuthBendix to Presentation.
    m.method("to_presentation_word",
             [](libsemigroups::Congruence<libsemigroups::word_type>& c) {
               return libsemigroups::to<
                   libsemigroups::Presentation<libsemigroups::word_type>>(c);
             });
    m.method("to_presentation_word",
             [](libsemigroups::Kambites<libsemigroups::word_type>& k) {
               return libsemigroups::to<
                   libsemigroups::Presentation<libsemigroups::word_type>>(k);
             });
    m.method("to_presentation_word",
             [](libsemigroups::ToddCoxeter<libsemigroups::word_type>& tc) {
               return libsemigroups::to<
                   libsemigroups::Presentation<libsemigroups::word_type>>(tc);
             });
    m.method("to_presentation_word",
             [](libsemigroups::KnuthBendix<libsemigroups::word_type>& kb) {
               return libsemigroups::to<
                   libsemigroups::Presentation<libsemigroups::word_type>>(kb);
             });

    // FroidurePin<E> to Presentation<word_type> for all 10 E instantiations.
    define_froidure_pin_to_presentation<libsemigroups::Transf<0, uint8_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::Transf<0, uint16_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::Transf<0, uint32_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::PPerm<0, uint8_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::PPerm<0, uint16_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::PPerm<0, uint32_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::Perm<0, uint8_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::Perm<0, uint16_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::Perm<0, uint32_t>>(m);
    define_froidure_pin_to_presentation<libsemigroups::BMat8>(m);
  }

}  // namespace libsemigroups_julia
