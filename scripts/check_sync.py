#!/usr/bin/env python3
"""
This module checks for missing features from libsemigroups in
Semigroups.jl (libsemigroups_julia).

Adapted from libsemigroups_pybind11/etc/check_sync.py for JlCxx bindings.
"""

import argparse
import os
import re
import sys
from glob import glob
from os.path import exists, isfile

import bs4
from bs4 import BeautifulSoup
from rich.console import Console
from rich.syntax import Syntax

__DOXY_DICT = {}


def __parse_args():
    parser = argparse.ArgumentParser(
        prog="check_sync.py", usage="%(prog)s [options]"
    )
    parser.add_argument(
        "things",
        nargs="+",
        help="the name(s) of the subpackage(s) or class(es) to check",
    )
    parser.add_argument(
        "--libsemigroups-dir",
        nargs=1,
        type=str,
        required=True,
        help="the path to the libsemigroups dir",
    )
    parser.add_argument(
        "--cpp-files",
        nargs="+",
        type=str,
        help="the Semigroups.jl JlCxx cpp file(s) to check",
    )

    result = parser.parse_args()
    result.libsemigroups_dir = result.libsemigroups_dir[0]
    return result


########################################################################
# Doxygen XML helpers
# (adapted from libsemigroups/etc/generate_pybind11.py)
########################################################################


def __error(msg: str) -> None:
    sys.stderr.write(f"\033[0;31m{msg}\n\033[0m")


def __bold(msg: str) -> None:
    sys.stderr.write(f"\033[1m{msg}\n\033[0m")


def is_namespace(args, thing: str) -> bool:
    fname = doxygen_filename(args, thing)
    return fname is not None and "namespace" in fname


def is_public(args, thing: str, fn: str) -> bool:
    if is_namespace(args, thing):
        return True
    xml = get_xml(args, thing, fn)
    if xml is None:
        return False
    prot = xml.get("prot")
    return prot is not None and prot == "public"


def is_typedef(args, thing: str, fn: str) -> bool:
    xml = get_xml(args, thing, fn)
    if xml is None:
        return False
    kind = xml.get("kind")
    return kind is not None and kind == "typedef"


def is_variable(args, thing: str, fn: str) -> bool:
    xml = get_xml(args, thing, fn)
    if xml is None:
        return False
    kind = xml.get("kind")
    return kind is not None and kind == "variable"


def is_operator(args, thing: str, fn: str) -> bool:
    return fn.startswith("operator") and fn != "operator()"


def doxygen_filename(args, thing: str) -> str:
    """
    Returns the xml filename used by Doxygen for the class with name
    <thing>.

    Arguments:
        thing -- a string containing the fully qualified name of a C++
        class, struct, or namespace.
    """
    orig = thing

    thing = re.sub("_", "__", thing)
    if thing.endswith("_group"):
        fname = f"{args.libsemigroups_dir}/docs/xml/group__{thing}.xml"
        if exists(fname) and isfile(fname):
            return fname
    p = re.compile(r"::")
    thing = p.sub("_1_1", thing)
    p = re.compile(r"([A-Z])")
    thing = p.sub(r"_\1", thing).lower()
    for possible in ("class", "struct", "namespace"):
        fname = (
            f"{args.libsemigroups_dir}/docs/xml/{possible}{thing}.xml"
        )
        if exists(fname) and isfile(fname):
            return fname
    thing = thing.split("_1_1")[-1]
    pattern = re.compile(rf">{thing}<")
    for fname in glob(
        f"{args.libsemigroups_dir}/docs/xml/group__*.xml"
    ):
        with open(fname, encoding="utf-8") as file:
            lines = file.read()
        if pattern.search(lines):
            return fname
    __error(f'Can\'t find the doxygen file for "{orig}" IGNORING!!!')


def get_xml(
    args, thing: str, fn: str | None = None
) -> dict[str, bs4.element.Tag]:
    """
    Returns parsed Doxygen XML data for the given thing (class/namespace).
    If fn is provided, returns the specific memberdef for that function.
    """
    if thing not in __DOXY_DICT:
        doxy_file = doxygen_filename(args, thing)
        if doxy_file is None:
            return
        with open(doxy_file, encoding="utf-8") as xml:
            xml = BeautifulSoup(xml, "xml")
            fn_list = xml.find_all("memberdef")
            fn_dict = {}

            for x in fn_list:
                nm = x.find("name").text
                if nm not in fn_dict:
                    fn_dict[nm] = {}
                fn_dict[nm] = x
            __DOXY_DICT[thing] = fn_dict
    if fn is not None:
        return __DOXY_DICT[thing][fn]
    return __DOXY_DICT[thing]


def _skip(console: Console, args, thing: str, fn: str) -> bool:
    if (
        fn.endswith("_no_checks")
        or fn.startswith("cend")
        or fn.startswith("end")
        or fn.startswith("cbegin")
        or fn.startswith("begin")
        or fn.startswith("_")
        or fn.endswith("_type")
        or "iterator" in fn
        or not is_public(args, thing, fn)
        or thing.endswith(fn)  # for constructors
        or fn in ("operator=", "operator<<")
        or is_typedef(args, thing, fn)
    ):
        if is_public(args, thing, fn):
            console.print(
                f":warning-emoji: [dim]skipping "
                f"[yellow]{thing}::{fn}[/yellow] . . .[/dim]"
            )
        return True
    return False


def translate_to_jl(fn: str) -> str:
    """Translate a C++ function name to its Julia/JlCxx binding name."""
    translator = {
        "operator==": "is_equal",
        "operator!=": "is_not_equal",
        "operator<": "is_less",
        "operator>": "is_greater",
        "operator<=": "is_less_equal",
        "operator>=": "is_greater_equal",
        "operator+": "add",
        "operator*": "multiply",
        "operator*=": "multiply!",
        "operator+=": "add!",
        "operator()": "__call__",
        "at": "at",
        "operator[]": "getindex",
        "hash_value": "hash",
        "to_human_readable_repr": "to_string",
        "product_inplace": "product_inplace!",
        "increase_degree_by": "increase_degree_by!",
    }
    if fn in translator:
        return translator[fn]
    return fn


########################################################################
# finders
########################################################################


def _strip_cxx_comments(lines: list[str]) -> list[str]:
    """Removes comments from C++ lines."""
    for i, line in enumerate(lines):
        pos = line.find("//")
        if pos != -1:
            lines[i] = lines[i][:pos]
    return lines


def _regex_pattern(args, thing: str, fn: str) -> str:
    cxx_fn = fn[:]
    fn = translate_to_jl(fn)
    # Escape regex special characters in the translated name
    fn_escaped = re.escape(fn)
    if is_namespace(args, thing):
        # For namespace functions, search by the function name directly
        # (JlCxx bindings typically don't include namespace prefixes)
        pattern = rf"(\w*){fn_escaped}"
    else:
        pattern = rf"(\w*){fn_escaped}"
    # In JlCxx, all bindings (including operators) use quoted string names
    pattern = f'"{pattern}"'
    if is_variable(args, thing, cxx_fn):
        # JlCxx uses .set_const() for constants and .add_bits() for enums
        pattern = rf"(?:\.method|\.set_const|\.add_bits)\w*\(\s*{pattern}"
    else:
        pattern = rf"\.method\(\s*{pattern}"
    return pattern


def find_in_cpp(args, thing: str, fn: str, info: dict) -> bool:
    console = Console()
    if _skip(console, args, thing, fn):
        return
    pattern = _regex_pattern(args, thing, fn)
    for cpp_file_name in args.cpp_files:
        try:
            with open(cpp_file_name, encoding="utf-8") as cpp_file:
                lines = cpp_file.read().split("\n")
        except FileNotFoundError:
            console.print(
                f"[bright_red]File not found: {cpp_file_name}[/bright_red]"
            )
            continue
        lines = "\n".join(_strip_cxx_comments(lines))
        matches = [x for x in re.finditer(pattern, lines, re.DOTALL)]
        if len(matches) == 0:
            console.print(
                f":x: [bright_red]{thing}::{fn} not found![/bright_red]"
            )
            return

        for match in matches:
            line_num = lines[: match.start()].count("\n") + 1
            if len(match.group(1)) == 0:
                console.print(
                    f":white_heavy_check_mark: found "
                    f"[green]{thing}::{fn}[/green] "
                    f"in [green]{cpp_file_name}:{line_num}:[/green]"
                )
            else:
                console.print(
                    f":grey_question: possibly found "
                    f"[purple]{thing}::{fn}[/purple] "
                    f"in [purple]{cpp_file_name}:{line_num}:[/purple]"
                )

            end = lines.find("\n", match.end() + 1)
            chunk = lines[match.start() : end]
            if ";" not in chunk:
                end = lines.find("\n", end + 1)
                chunk = lines[match.start() : end]

            console.print(
                Syntax(
                    f"{chunk}",
                    "cpp",
                    line_numbers=True,
                    start_line=line_num,
                )
            )


def check_thing(args, thing: str) -> None:
    if not thing.startswith("libsemigroups::"):
        thing = f"libsemigroups::{thing}"
    xml = get_xml(args, thing)
    if xml is None:
        return
    for fn, info in xml.items():
        if fn != thing:
            find_in_cpp(args, thing, fn, info)


def main():
    if not os.path.isfile(os.path.join(os.getcwd(), "Project.toml")):
        raise Exception(
            "This script must be run from the Semigroups.jl root directory!"
        )
    args = __parse_args()
    for thing in args.things:
        check_thing(args, thing)

    sys.exit(0)


if __name__ == "__main__":
    main()
