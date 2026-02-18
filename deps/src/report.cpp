// report.cpp - ReportGuard bindings for libsemigroups_julia
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

#include "libsemigroups_julia.hpp"

#include <libsemigroups/detail/report.hpp>

namespace libsemigroups_julia {

void define_report(jl::Module & m)
{
  using libsemigroups::ReportGuard;

  m.add_type<ReportGuard>("CppReportGuard").constructor<bool>();
}

}    // namespace libsemigroups_julia
