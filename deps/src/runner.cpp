// runner.cpp - Runner base class bindings for libsemigroups_julia
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
// This file exposes the libsemigroups Runner class to Julia via CxxWrap.
// Runner is an abstract base class providing algorithm execution control
// (run, run_for, timeout, stop, etc.) used by FroidurePinBase and other
// algorithm classes.

#include "libsemigroups_julia.hpp"

#include <libsemigroups/runner.hpp>

#include <jlcxx/functions.hpp>

#include <chrono>
#include <cstdint>
#include <functional>

namespace libsemigroups_julia {

  void define_runner(jl::Module& m) {
    using libsemigroups::Runner;

    // Register Runner as a base type.
    // Runner is abstract (pure virtual run_impl/finished_impl) so we do NOT
    // add constructors. It will only be usable through derived types
    // (e.g. FroidurePinBase).
    auto type = m.add_type<Runner>("Runner");

    //////////////////////////////////////////////////////////////////////////
    // State enum
    //////////////////////////////////////////////////////////////////////////

    m.add_bits<Runner::state>("state", jl::julia_type("CppEnum"));
    m.set_const("state_never_run", Runner::state::never_run);
    m.set_const("state_running_to_finish", Runner::state::running_to_finish);
    m.set_const("state_running_for", Runner::state::running_for);
    m.set_const("state_running_until", Runner::state::running_until);
    m.set_const("state_timed_out", Runner::state::timed_out);
    m.set_const("state_stopped_by_predicate",
                Runner::state::stopped_by_predicate);
    m.set_const("state_not_running", Runner::state::not_running);
    m.set_const("state_dead", Runner::state::dead);

    //////////////////////////////////////////////////////////////////////////
    // Core algorithm control
    //////////////////////////////////////////////////////////////////////////

    // run / run! - Run the algorithm to completion
    type.method("run!", [](Runner& self) { self.run(); });

    // run_for / run_for! - Run for a specified duration.
    // We accept Int64 nanoseconds from Julia (the Julia layer converts
    // Dates.TimePeriod to nanoseconds before calling this binding).
    type.method("run_for!", [](Runner& self, int64_t ns) {
      self.run_for(std::chrono::nanoseconds(ns));
    });

    // run_until / run_until! - Run until a nullary predicate returns true.
    // CxxWrap does not support std::function<bool()> as a parameter type, so we
    // accept a SafeCFunction and convert it to a function pointer via
    // make_function_pointer. The Julia side uses @safe_cfunction to create the
    // SafeCFunction from a closure. A uint8_t is used instead of bool to
    // avoid C++ bool ABI issues across platforms.
    type.method("run_until!", [](Runner& self, jlcxx::SafeCFunction func) {
      auto fp = jlcxx::make_function_pointer<uint8_t()>(func);
      self.run_until([fp]() -> bool { return fp() != 0; });
    });

    // init - Re-initialize the runner to its default-constructed state
    type.method("init!", [](Runner& self) -> Runner& { return self.init(); });

    //////////////////////////////////////////////////////////////////////////
    // State queries
    //////////////////////////////////////////////////////////////////////////

    // finished - Has the algorithm run to completion?
    type.method("finished", &Runner::finished);

    // success - Has the algorithm completed successfully?
    type.method("success", &Runner::success);

    // started - Has run() been called at least once?
    type.method("started", &Runner::started);

    // running - Is the algorithm currently executing?
    type.method("running", &Runner::running);

    // timed_out - Did run_for! exhaust its time limit?
    type.method("timed_out", &Runner::timed_out);

    // stopped - Is the algorithm stopped for any reason?
    // (finished, timed_out, dead, or stopped_by_predicate)
    type.method("stopped", &Runner::stopped);

    // dead - Was the runner killed from another thread?
    type.method("dead", &Runner::dead);

    // stopped_by_predicate - Was run_until's predicate satisfied?
    type.method("stopped_by_predicate", &Runner::stopped_by_predicate);

    // running_for - Is it currently in a run_for! call?
    type.method("running_for", &Runner::running_for);

    // running_for_how_long - Return last run_for duration in nanoseconds
    type.method("running_for_how_long", [](Runner const& self) -> int64_t {
      return self.running_for_how_long().count();
    });

    // running_until - Is it currently in a run_until call?
    type.method("running_until", &Runner::running_until);

    // current_state - Return the current state enum value
    type.method("current_state", &Runner::current_state);

    //////////////////////////////////////////////////////////////////////////
    // Control
    //////////////////////////////////////////////////////////////////////////

    // kill / kill! - Stop the runner from another thread (thread-safe)
    type.method("kill!", [](Runner& self) { self.kill(); });

    //////////////////////////////////////////////////////////////////////////
    // Reporting
    //////////////////////////////////////////////////////////////////////////

    // report_why_we_stopped - Print reason for stopping to stderr
    type.method("report_why_we_stopped", &Runner::report_why_we_stopped);

    // string_why_we_stopped - Return reason for stopping as a string
    type.method("string_why_we_stopped", &Runner::string_why_we_stopped);
  }

}  // namespace libsemigroups_julia
