#!/usr/bin/env python3
"""Convert GAP plain-TeX (``gapmacro.tex``) manuals to GAPDoc XML.

This replaces ``dev/gapmacro2gapdoc.g`` (Thomas Breuer, removed in the commit
that added this file; see the git history).  That script applied ~30 sequential
global find/replace passes to the whole file at once, which is why it could not
tell a backquote inside ``\\beginexample`` from one in running text, nor a
``\\>`` inside ``\\beginitems`` (an item mark) from one in a chapter body (a
declaration).  Here we instead

  1. carve out verbatim regions (``\\beginexample``/``\\begintt``) first, so
     their contents are never touched,
  2. run a line-driven structural parser that keeps an explicit context stack
     (chapter / section / ManSection / items / list),
  3. run an inline scanner with a mode stack, so markup nested inside ``$...$``
     or `` `...' `` is handled according to that context, and
  4. validate every emitted file as XML before writing it.

The result still needs human review -- see the ``TODO(g2g)`` markers and the
report printed at the end -- but it should be structurally sound.

Usage
-----
    gapmacro2gapdoc.py PKGDIR [-o OUTDIR]   convert one package
    gapmacro2gapdoc.py --survey PKGDIR...   report unhandled constructs only

The converter is deliberately conservative: anything it does not understand is
passed through with a ``TODO(g2g)`` marker rather than silently dropped.

Converting a package
--------------------
1.  Run ``--survey`` on the package first.  It writes nothing and tells you
    what will need hand-finishing, so you know what you are in for.

2.  Convert into a scratch directory (``-o``) and read the XML.  Every
    ``TODO(g2g)`` marker is a spot the converter was not sure about.  The
    end-of-run report groups the rest by kind; the ones that always want a
    human are:

    - *declaration type unknown* -- the ``\\>`` line had no F/O/A/P/... letter
      and the name is not declared in this package (usually a method installed
      for an operation owned by GAP or another package).  Pick the right
      element by hand.
    - *type taken from source, manual was out of date* -- the ``\\>`` line and
      the ``Declare...`` call said different things, so the declared type was
      used.  No action needed, but the list is worth skimming: it says which
      parts of the old manual had drifted from the code.
    - *unresolved reference* -- a ``"..."`` cross-reference that no longer
      resolves, typically because the target section was renamed in GAP.
    - *atindex subkey dropped* -- the two-level index entry lost its subkey.

3.  Move the generated ``makedoc.g`` to the package root, then build with
    ``gap makedoc.g`` **from the package directory** and fix what GAPDoc
    reports.  Check the HTML for ``???``, which marks a reference GAPDoc could
    not resolve.

4.  Old ``.bib`` files often still use gapmacro-only macros such as
    ``\\URL{...}``; GAPDoc's LaTeX does not define those, and they surface as
    "Missing $ inserted" at the very end of the build.  The converter warns
    when it sees one.

5.  Only once the manual builds: delete ``doc/make_doc``, the ``doc/*.tex``
    sources and the generated TeX leftovers (``manual.aux``, ``.dvi``, ``.six``,
    ``.lab``, ...), and update ``PackageInfo.g`` (``AutoDoc`` in
    ``Dependencies.SuggestedOtherPackages``, and the ``BookName``).

Caveats
-------
- Packages that ship several books in ``doc/<book>/`` subdirectories (sonata)
  need one run per book.
- Images (``\\epsfbox`` and friends) are not converted.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass, field
from typing import Iterable
from xml.etree import ElementTree

# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------

#: gapmacro's trailing classification letter -> (GAPDoc element, Type attribute)
TYPE_MAP = {
    "F": ("Func", None),
    "O": ("Oper", None),
    "A": ("Attr", None),
    "P": ("Prop", None),
    "M": ("Meth", None),
    "V": ("Var", None),
    "C": ("Filt", "Category"),
    "R": ("Filt", "Representation"),
}

#: Elements that take no Arg attribute.
NO_ARG = {"Var", "InfoClass", "Fam"}

#: ``{\Foo}`` / ``\Foo`` text macros with a direct GAPDoc entity equivalent.
ENTITY_MACROS = {
    "GAP": "GAP", "GAPDoc": "GAPDoc", "TeX": "TeX", "LaTeX": "LaTeX",
    "BibTeX": "BibTeX", "MeatAxe": "MeatAxe", "XGAP": "XGAP",
    "copyright": "copyright",
}

#: Math macros for blackboard-bold sets.
BB_MACROS = {"Z": "ZZ", "Q": "QQ", "R": "RR", "C": "CC", "N": "NN", "F": "PP"}

#: GAP keywords that deserve <K> rather than <C>.
GAP_KEYWORDS = {
    "true", "false", "fail", "quit", "for", "while", "do", "od", "if", "then",
    "else", "elif", "fi", "function", "end", "return", "local", "not", "and",
    "or", "in", "repeat", "until", "rec", "break", "continue",
}

#: TeX accent command -> the Unicode combining character it applies.  Composing
#: and then NFC-normalising beats a hand-written table: it covers every
#: base letter, including the ones nobody remembers to list.
ACCENT_COMBINING = {
    "'": "́",   # acute
    "`": "̀",   # grave
    "^": "̂",   # circumflex
    '"': "̈",   # diaeresis
    "~": "̃",   # tilde
    "=": "̄",   # macron
    ".": "̇",   # dot above
    "u": "̆",   # breve
    "v": "̌",   # caron
    "H": "̋",   # double acute
    "c": "̧",   # cedilla
    "k": "̨",   # ogonek
    "r": "̊",   # ring above
    "d": "̣",   # dot below
    "b": "̱",   # macron below
}

#: Accents whose name is a letter (``\v{e}``) are only recognised when the
#: argument is braced or space-separated -- otherwise ``\vec`` would be read as
#: a caron on "e".  The punctuation-named ones (``\'e``) are unambiguous.
LETTER_ACCENTS = set("uvHckrdb")

#: Standalone TeX symbol macros.
TEX_SPECIALS = {
    "ss": "ß", "o": "ø", "O": "Ø", "l": "ł", "L": "Ł",
    "aa": "å", "AA": "Å", "ae": "æ", "AE": "Æ", "oe": "œ", "OE": "Œ",
    "i": "i", "j": "j",          # dotless forms; the accent is applied around
    "copyright": "©", "pounds": "£", "dag": "†", "ddag": "‡",
    # gapmacro.tex spells a few characters as macros to dodge its own catcodes.
    "pif": "'", "excl": "!",
}

#: GAP's manuals used ``\accent127`` for a diaeresis and ``\accent23`` for a
#: tilde, from the old font encoding.
ACCENT_NUMBERS = {"127": "̈", "23": "̃", "18": "̀",
                  "19": "́", "20": "̂", "21": "̈",
                  "24": "̧", "22": "̊"}

#: Purely presentational macros with no GAPDoc counterpart -- dropped silently.
DROP_MACROS = {
    "medskip", "bigskip", "smallskip", "noindent", "par", "hfill", "vfill",
    "break", "goodbreak", "penalty", "relax", "leavevmode", "strut", "null",
    "rm", "it", "bf", "sl", "tt", "sf", "mdseries", "slshape", "secfont",
    "titlefont", "subtitlefont", "smallrom", "kernttindent", "quad", "qquad",
    "noexpand", "protect",
    "," , ";", ":", "!", "/",
}

#: Math macros passed straight through to <M>/<Display> (GAPDoc renders TeX).
MATH_PASSTHROUGH = re.compile(
    r"\\(?:[A-Za-z]+|[^A-Za-z])"
)

#: Standard LaTeX math operators.  Written bare in the old sources ("gcd(a,b)"),
#: they come out italic, as if a product of variables.  Only names that LaTeX
#: really defines are listed -- \Aut and \End are not among them.
MATH_OPERATORS = (
    "arccos arcsin arctan arg cos cosh cot coth csc deg det dim exp gcd hom "
    "inf ker lg lim ln log max min sec sin sinh sup tan tanh"
).split()

#: A bare URL in running text.  gapmacro.tex had poor URL support, so many
#: manuals just typed them out; GAPDoc wants <URL>.
BARE_URL = re.compile(r"(?:https?://|ftp://|www\.)[^\s<>{}\\$]*")


def detex_accents(text: str) -> tuple[str, int]:
    """Replace TeX accent and symbol macros with the Unicode they stand for.

    Returns the new text and the number of replacements made.  Composes with
    combining characters and NFC-normalises, so ``\\'e`` and ``\\v{e}`` and
    ``\\accent127 o`` all come out as real letters.
    """
    import unicodedata

    count = 0

    def compose(base: str, combining: str) -> str:
        return unicodedata.normalize("NFC", base + combining)

    # \i and \j are dotless forms that only exist to carry an accent.
    text = re.sub(r"\\i\b\s*|\{\\i\}", "i", text)
    text = re.sub(r"\\j\b\s*|\{\\j\}", "j", text)

    def acc_num(m: re.Match) -> str:
        nonlocal count
        comb = ACCENT_NUMBERS.get(m.group(1))
        if comb is None:
            return m.group(0)
        count += 1
        return compose(m.group(2), comb)

    # Brace-wrapped first: in "Cical{\\`o}" the outer braces belong to the group,
    # so a pattern that swallows a lone "}" would leave the "{" orphaned.
    text = re.sub(r"\{\\accent(\d+)\s*\{?([A-Za-z])\}?\}", acc_num, text)
    text = re.sub(r"\\accent(\d+)\s*\{([A-Za-z])\}", acc_num, text)
    text = re.sub(r"\\accent(\d+)\s*([A-Za-z])", acc_num, text)

    def acc(m: re.Match) -> str:
        nonlocal count
        count += 1
        return compose(m.group(2), ACCENT_COMBINING[m.group(1)])

    # Punctuation-named accents, again braced forms before the bare one:
    # {\'e} / {\'{e}}, then \'{e}, then \'e.
    text = re.sub(r"\{\\(['`^\"~=.])\s*\{?([A-Za-z])\}?\}", acc, text)
    text = re.sub(r"\\(['`^\"~=.])\s*\{([A-Za-z])\}", acc, text)
    text = re.sub(r"\\(['`^\"~=.])\s*([A-Za-z])", acc, text)
    def acc_letter(m: re.Match) -> str:
        nonlocal count
        count += 1
        return compose(m.group(2) or m.group(3), ACCENT_COMBINING[m.group(1)])

    # Letter-named accents must be braced or space-separated, so that \vec and
    # \cite are not mistaken for a caron and a cedilla.
    letters = "".join(sorted(LETTER_ACCENTS))
    text = re.sub(r"\{\\([" + letters + r"])(?:\{([A-Za-z])\}|\s*([A-Za-z]))\}",
                  acc_letter, text)
    text = re.sub(r"\\([" + letters + r"])"
                  r"(?:\{([A-Za-z])\}|\s+([A-Za-z])\b)", acc_letter, text)

    def special(m: re.Match) -> str:
        nonlocal count
        count += 1
        return TEX_SPECIALS[m.group(1)]

    text = re.sub(r"\{\\(" + "|".join(sorted(TEX_SPECIALS, key=len, reverse=True))
                  + r")\}", special, text)
    return text, count


def clean_bib(path: str, notes: Notes) -> int:
    """Rewrite a .bib file, replacing gapmacro-era TeX with Unicode.

    The old manuals routinely wrote ``\\accent127o`` and ``\\'E``; GAPDoc's
    LaTeX copes, but the HTML and text outputs do not render them, so it is
    worth normalising these once at conversion time.
    """
    with open(path, encoding="utf8", errors="replace") as fh:
        original = fh.read()

    text, count = detex_accents(original)
    text, n_sp = re.subn(r"\\sp\b\s*", "^", text)
    text, n_sb = re.subn(r"\\sb\b\s*", "_", text)
    count += n_sp + n_sb

    name = os.path.basename(path)

    # A URL parked in some unrelated field is the old format's way of recording
    # a link; BibTeX styles will not turn it into one.
    for m in re.finditer(r"(\w+)\s*=\s*[{\"]([^}\"]*)[}\"]", text):
        field, value = m.group(1).lower(), m.group(2)
        if field in ("url", "howpublished", "note", "doi", "eprint"):
            continue
        if BARE_URL.search(value):
            notes.add("URL in a non-URL .bib field",
                      f'{name}: {field} = {{{value[:48]}}} -- move it to "url"')

    # GAPDoc splits author/editor into individual names and cannot cope with
    # TeX escapes there: "Kenneth S.\ Brown" aborts the build with an
    # unassigned list element, from deep inside NormalizedNameAndKey.
    for m in re.finditer(r"\b(author|editor)\s*=\s*[{\"]([^}\"]*)[}\"]", text):
        if re.search(r"\\[^A-Za-z]|\\[A-Za-z]+", m.group(2)):
            notes.add("TeX escape in a .bib author/editor field",
                      f"{name}: {m.group(1)} = {m.group(2)[:46]!r} -- "
                      f"GAPDoc cannot parse names containing TeX")

    # GAPDoc renders note/howpublished verbatim -- it strips brace groups in a
    # title but not here, and knows no TeX macros -- so anything but plain text
    # shows up literally in the HTML.  A URL belongs in a "url" field, which
    # GAPDoc turns into a link on the entry's title.
    for m in re.finditer(r"\b(note|notes|howpublished)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}",
                         text, re.S):
        value = m.group(2)
        if re.search(r"\\[A-Za-z]+|\{", value):
            notes.add("TeX markup in a .bib note field",
                      f"{name}: {m.group(1)} = {{{value[:46]}}} -- renders literally; "
                      f"use plain text, and a \"url\" field for links")

    for macro in ("URL", "GAP", "Mailto", "package"):
        if f"\\{macro}{{" in text:
            hint = (' -- use a standard BibTeX "url = {...}" field instead'
                    if macro == "URL" else "")
            notes.add("gapmacro macro left in .bib",
                      f"{name}: \\{macro}{{...}} is undefined in GAPDoc's LaTeX{hint}")

    if count:
        with open(path, "w", encoding="utf8") as fh:
            fh.write(text)
        notes.add("TeX accents replaced by Unicode in .bib", f"{name}: {count}")
    return count


# ---------------------------------------------------------------------------
# Cross-reference index (manual.six)
# ---------------------------------------------------------------------------

class SixIndex:
    """Maps a label to its kind, using ``manual.six`` files.

    Old-format lines look like ``F 2.1. IsSolvable`` / ``S 1.1. License`` /
    ``C intro.tex 1. Introduction``.  That first letter is exactly the
    Chap/Sect/Func distinction ``<Ref>`` needs, so we reuse it rather than
    guessing from the label text (which is what makes the old script emit
    ``<Ref ???=...>``).

    GAPDoc-format (``#SIXFORMAT GapDocGAP``) files are also read, so that
    references into the current GAP reference manual resolve too; there the
    kind is recovered from the ``[chapter, section, subsection]`` triple.
    """

    KIND_ATTR = {"C": "Chap", "S": "Sect", "F": "Func", "U": "Subsect"}

    def __init__(self) -> None:
        self.books: dict[str, dict[str, str]] = {}

    #: GAPDoc writes labels wrapped in terminal colour markup, e.g.
    #: ``\033[1X\033[33X\033[0;-2YInfo Functions\033[133X\033[101X``.
    ESCAPES = re.compile(r"\\0\d\d(?:\[[\d;\-]*[A-Za-z])?")

    @classmethod
    def _norm(cls, label: str) -> str:
        label = cls.ESCAPES.sub("", label)
        return re.sub(r"\s+", " ", label).strip().lower()

    def load(self, book: str, path: str) -> bool:
        if not os.path.isfile(path):
            return False
        with open(path, encoding="utf8", errors="replace") as fh:
            text = fh.read()
        entries: dict[str, str] = {}
        if "#SIXFORMAT" in text.split("\n", 1)[0]:
            # GAPDoc format:
            #   [ "display", "1.2-3", [ c, s, ss ], num,, "normalised", "id" ]
            # Match on the 6th field, which is already lowercased and free of
            # the terminal colour markup that riddles the display string, and
            # survives the backslash-newline wrapping GAP applies to long
            # lines.  Keep the 1st field too: it carries the original spelling,
            # which is what a Ref has to match.  The 5th field is empty in GAP's
            # own books but carries a number in books built by newer GAPDoc, so
            # it must be optional -- otherwise package books silently yield no
            # entries at all.
            for m in re.finditer(
                r'\[\s*"((?:[^"\\]|\\.)*)"\s*,\s*"[^"]*"\s*,\s*'
                r"\[\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\]\s*,\s*\d+\s*,\s*\d*\s*,\s*"
                r'"((?:[^"\\]|\\.)*)"',
                text, re.S,
            ):
                c, s, ss = (int(x) for x in m.group(2, 3, 4))
                clean = self._norm(m.group(5))
                canon = self.ESCAPES.sub("", m.group(1).replace("\\\n", ""))
                canon = re.sub(r"\s+", " ", canon).strip()
                if s == 0 and ss == 0:
                    kind = "C"
                elif ss == 0:
                    kind = "S"
                else:
                    # Subsection level covers both ManSections (a GAP name) and
                    # plain <Subsection>s (prose); <Ref> spells those Func vs
                    # Subsect, so tell them apart by the shape of the label.
                    kind = "F" if re.fullmatch(r"[a-z_][\w.]*", clean) else "U"
                entries.setdefault(clean, (kind, canon))
        else:
            for line in text.split("\n"):
                m = re.match(r"^([CSF])\s+(?:\S+\s+)?[\d.]+\.?\s+(.*)$", line.rstrip())
                if m:
                    entries.setdefault(self._norm(m.group(2)),
                                       (m.group(1), m.group(2).strip()))
        if entries:
            self.books[book] = entries
        return bool(entries)

    def lookup(self, book: str | None,
               label: str) -> tuple[str, str, str] | None:
        """Return (attribute, book, canonical label), or None if unresolved.

        The canonical label matters: the old format matched references
        case-insensitively, so manuals drifted (cubefree refers to a chapter
        "Installing and Loading the Cubefree Package" that is actually titled
        "Installing and loading the Cubefree package").  GAPDoc matches a Ref
        against the Label exactly, so emit the target's own spelling.
        """
        key = self._norm(label)
        for name in ([book] if book else [None]) + list(self.books):
            if name is None:
                continue
            entries = self.books.get(name)
            if entries and key in entries:
                kind, canon = entries[key]
                return self.KIND_ATTR[kind], name, canon
            if book:  # an explicit book prefix must not fall back to another
                break
        return None


# ---------------------------------------------------------------------------
# Declaration index (real types, read from the package's GAP source)
# ---------------------------------------------------------------------------

class DeclIndex:
    """Maps a GAP name to its real GAPDoc element, by reading the source.

    677 of the 1732 ``\\>`` lines across the remaining packages carry no
    classification letter, and some of the ones that do are stale.  The
    package's own ``DeclareAttribute``/``DeclareOperation``/... calls are the
    authority, so we consult them instead of guessing from the syntax.
    """

    DECLARERS = {
        "DeclareGlobalFunction": ("Func", None),
        "DeclareSynonym": ("Func", None),
        "DeclareOperation": ("Oper", None),
        "DeclareConstructor": ("Constr", None),
        "DeclareAttribute": ("Attr", None),
        "DeclareSynonymAttr": ("Attr", None),
        "DeclareProperty": ("Prop", None),
        "DeclareCategory": ("Filt", "Category"),
        "DeclareRepresentation": ("Filt", "Representation"),
        "DeclareFilter": ("Filt", None),
        "DeclareInfoClass": ("InfoClass", None),
        "DeclareGlobalVariable": ("Var", None),
        "InstallGlobalFunction": ("Func", None),
        "BindGlobal": ("Var", None),
    }

    SOURCE_DIRS = ("gap", "lib", "src")

    def __init__(self) -> None:
        self.names: dict[str, tuple[str, str | None]] = {}

    def scan(self, pkgdir: str) -> int:
        # Capture what follows the name too: BindGlobal and InstallValue bind
        # whatever they are given, and binding a function makes the name a
        # function, not a variable.
        pattern = re.compile(
            r"\b(" + "|".join(self.DECLARERS) + r")\s*\(\s*\"([^\"]+)\"\s*(,[^;]{0,120})?"
        )
        synonyms: dict[str, str] = {}
        for sub in self.SOURCE_DIRS:
            root = os.path.join(pkgdir, sub)
            if not os.path.isdir(root):
                continue
            for dirpath, _dirs, files in os.walk(root):
                for fn in files:
                    if not fn.endswith((".g", ".gd", ".gi")):
                        continue
                    try:
                        with open(os.path.join(dirpath, fn),
                                  encoding="utf8", errors="replace") as fh:
                            src = fh.read()
                    except OSError:
                        continue
                    for m in pattern.finditer(src):
                        kind = self.DECLARERS[m.group(1)]
                        tail = (m.group(3) or "").lstrip(",").strip()
                        if kind[0] == "Var" and m.group(1) != "DeclareGlobalVariable":
                            # BindGlobal binds whatever it is given; a function
                            # makes the name a function, not a variable.
                            if tail.startswith("function"):
                                kind = ("Func", None)
                        if m.group(1) == "DeclareSynonym":
                            # A synonym is whatever it aliases: a conjunction of
                            # filters is a filter, a single name inherits that
                            # name's kind.  Resolved after the whole scan.
                            synonyms[m.group(2)] = tail
                            continue
                        # A .gd DeclareX beats a .gi InstallX for the same name.
                        prev = self.names.get(m.group(2))
                        if prev is None or (m.group(1).startswith("Declare")
                                            and not fn.endswith(".gi")):
                            self.names[m.group(2)] = kind

        for name, rhs in synonyms.items():
            rhs = rhs.rstrip(") ;")
            if re.search(r"\band\b", rhs) or re.fullmatch(r"Is[A-Z]\w*", rhs.strip()):
                self.names.setdefault(name, ("Filt", None))
            else:
                target = re.match(r"\s*([A-Za-z_]\w*)\s*$", rhs)
                if target and target.group(1) in self.names:
                    self.names.setdefault(name, self.names[target.group(1)])
                # otherwise leave it unknown rather than guess
        return len(self.names)

    def lookup(self, name: str) -> tuple[str, str | None] | None:
        hit = self.names.get(name)
        if hit and hit[0] == "Var" and re.match(r"^Info[A-Z]", name):
            return ("InfoClass", None)
        return hit


# ---------------------------------------------------------------------------
# Inline markup
# ---------------------------------------------------------------------------

def xml_escape(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def attr_escape(text: str) -> str:
    return xml_escape(text).replace('"', "&quot;")


#: A ``<...>`` group is an argument reference only if it looks like one.  The
#: old docs freely mixed ``<a>`` (argument) with ``a < b`` (math), so we require
#: an identifier-ish body on a single line.
ARG_RE = re.compile(
    r"^(?:"
    r"[A-Za-z_][A-Za-z0-9_.\-]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_.\-]*)*"
    r"|\([^()<>]*\)"      # parenthesised, e.g. <(a,b)> or the marks <(1)>..<(7)>
    r")$")


@dataclass
class Notes:
    """Collects things a human needs to look at after conversion."""
    items: list[str] = field(default_factory=list)
    counts: dict[str, int] = field(default_factory=dict)

    def add(self, kind: str, detail: str = "") -> None:
        self.counts[kind] = self.counts.get(kind, 0) + 1
        if detail and len(self.items) < 400:
            self.items.append(f"{kind}: {detail}")


class Inline:
    """Scanner for inline (non-structural) markup.

    Runs a single left-to-right pass with an explicit mode, so that e.g. ``$``
    is not treated as math while inside `` `...' ``, and ``<...>`` is only an
    argument reference where that is plausible.
    """

    def __init__(self, six: SixIndex, notes: Notes, book: str = "",
                 entities: Iterable[str] = ()) -> None:
        self.six = six
        self.notes = notes
        self.book = book
        self.entities = set(entities)

    def _sub(self) -> "Inline":
        return Inline(self.six, self.notes, self.book, self.entities)

    # -- entry point --------------------------------------------------------

    def run(self, text: str, mode: str = "text") -> str:
        self.s = text
        self.i = 0
        self.n = len(text)
        self.out: list[str] = []
        self.mode = mode
        while self.i < self.n:
            self._step()
        return "".join(self.out)

    def _emit(self, s: str) -> None:
        self.out.append(s)

    def _peek(self, k: int = 0) -> str:
        j = self.i + k
        return self.s[j] if j < self.n else ""

    # -- main dispatch ------------------------------------------------------

    def _step(self) -> None:
        c = self._peek()

        if c == "\\":
            self._macro()
            return

        if self.mode in ("code", "math"):
            # Inside `...' only argument references stay live; inside math we
            # pass TeX through untouched (braces and all).
            if c == "<" and self.mode == "code":
                if self._try_arg():
                    return
            if c == "{" and self.mode == "code" and not self._brace_is_gap():
                # TeX grouping that happens to sit in a code span: cryst writes
                # the setting names as `\pif{1}\pif', which is '1', and \^{} is
                # how plain TeX spells a bare caret.
                body = self._balanced_group()
                if body is not None:
                    self._emit(self._sub().run(body, "code"))
                    return
            self._emit(xml_escape(c))
            self.i += 1
            return

        if c == "%":  # TeX comment to end of line
            j = self.s.find("\n", self.i)
            self.i = self.n if j < 0 else j + 1
            return

        if c == "$":
            self._math()
            return

        if c == "`":
            if self._peek(1) == "`":
                self._quote()
            else:
                self._code()
            return

        if c == "<":
            if self._try_arg():
                return
            self._emit("&lt;")
            self.i += 1
            return

        if c == '"':
            self._ref()
            return

        if c == "*":
            if self._try_emph():
                return
            self._emit("*")
            self.i += 1
            return

        if c in "hfw" and self.mode == "text":
            # gapmacro.tex had no real URL support, so manuals often just typed
            # them out.  Converting automatically is unsafe -- a trailing "." is
            # usually sentence punctuation, not part of the URL -- so leave the
            # text alone and point the reader at it.
            m = BARE_URL.match(self.s, self.i)
            if m and (self.i == 0 or not self.s[self.i - 1].isalnum()):
                raw = m.group(0)
                self.i = m.end()
                suggest = raw.rstrip(".,;:)]}'\"")
                self.notes.add("bare URL, consider <URL>", suggest[:70])
                safe = re.sub(r"-{2,}", "-", suggest)
                self._emit(f"<!-- TODO(g2g) bare URL; consider "
                           f"<URL>{safe}</URL> -->{xml_escape(raw)}")
                return

        if c == "~":
            self._emit("&nbsp;")
            self.i += 1
            return

        if c in "{}":
            # Bare TeX grouping in running text carries no meaning of its own
            # (``{\GAP}`` -> ``&GAP;``).  Braces are kept in code and math,
            # where they are part of the GAP/TeX syntax.
            self.i += 1
            return

        if c in "&>":
            self._emit("&amp;" if c == "&" else "&gt;")
            self.i += 1
            return

        self._emit(c)
        self.i += 1

    # -- constructs ---------------------------------------------------------

    def _brace_is_gap(self) -> bool:
        """Is the "{" at the cursor GAP syntax rather than TeX grouping?

        GAP only writes "{" after something it can subscript -- an identifier,
        ")" or "]", as in ``l{[1..3]}``.  What matters is the character already
        emitted, not the one in the source: ``\\pif{1}`` ends in "f" but has
        produced "'".
        """
        for chunk in reversed(self.out):
            if chunk:
                prev = chunk[-1]
                return prev.isalnum() or prev in "_)]"
        return False

    def _balanced_group(self) -> str | None:
        """Read a ``{...}`` group at the cursor, honouring nesting."""
        if self._peek() != "{":
            return None
        depth, j = 0, self.i
        while j < self.n:
            if self.s[j] == "{":
                depth += 1
            elif self.s[j] == "}":
                depth -= 1
                if depth == 0:
                    body = self.s[self.i + 1:j]
                    self.i = j + 1
                    return body
            elif self.s[j] == "\\":
                j += 1
            j += 1
        return None

    def _macro(self) -> None:
        m = re.match(r"\\([A-Za-z]+|.)", self.s[self.i:], re.S)
        if not m:
            self.i += 1
            return
        name = m.group(1)
        self.i += m.end()

        # Escaped literals.
        simple = {
            "{": "{", "}": "}", "$": "$", "%": "%", "#": "#", "_": "_",
            "&": "&amp;", ".": ".", " ": " ", "-": "",
            "<": "&lt;", ">": "&gt;",
        }
        if name in simple:
            if self.mode == "math" and name in "{}$%#_&":
                # In math these are literal characters: an unescaped "{"
                # would open a group and swallow the rest of the formula.
                self._emit("\\" + xml_escape(name))
            else:
                self._emit(simple[name])
            return

        if name in ENTITY_MACROS:
            self._emit(f"&{ENTITY_MACROS[name]};")
            return

        # Package-specific \def macros from manual.tex become AutoDoc entities.
        if name in self.entities:
            self._emit(f"&{name};")
            return

        if name in BB_MACROS:
            self._emit(f"&{BB_MACROS[name]};")
            return

        if name in ("cite",):
            key = self._balanced_group() or ""
            self._emit(f'<Cite Key="{attr_escape(key.strip())}"/>')
            return

        if name in ("index", "indextt"):
            body = self._balanced_group() or ""
            inner = self._sub().run(body)
            self._emit(f"<Index>{inner}</Index>")
            return

        if name == "atindex":
            # \atindex{sortkey}{@display} -- the second argument is makeindex
            # syntax, where a leading "@" separates the sort key from the text
            # actually shown and "!" separates index levels.  So the tail is
            # usually just a display override, but it can carry a real subkey,
            # which GAPDoc spells as an Index/Subkey child.
            key = self._balanced_group() or ""
            tail = (self._balanced_group() or "").strip()
            subkey = None
            if tail.startswith("@"):
                tail = tail[1:]
            if "!" in tail:
                tail, subkey = tail.split("!", 1)
                subkey = subkey.split("@")[-1].strip()
            display = tail.strip() or key.split("!")[0].strip()
            inner = self._sub().run(display)
            if subkey:
                # GAPDoc's own manuals put the displayed text first, then Subkey.
                self._emit(f"<Index>{inner}"
                           f"<Subkey>{self._sub().run(subkey)}</Subkey></Index>")
            else:
                self._emit(f"<Index>{inner}</Index>")
            return

        if name == "URL":
            body = self._balanced_group() or ""
            self._emit(f"<URL>{xml_escape(body.strip())}</URL>")
            return

        if name in ("Mailto", "email"):
            body = self._balanced_group() or ""
            self._emit(f"<Email>{xml_escape(body.strip())}</Email>")
            return

        if name == "package":
            body = self._balanced_group() or ""
            self._emit(f"<Package>{xml_escape(body.strip())}</Package>")
            return

        if name == "accent":
            m2 = re.match(r"\s*(\d+)\s*\{?([A-Za-z])\}?", self.s[self.i:])
            if m2:
                self.i += m2.end()
                out, _ = detex_accents(f"\\accent{m2.group(1)}{{{m2.group(2)}}}")
                self._emit(out)
            return

        if self.mode == "code" and len(name) == 1 and not name.isalpha():
            # Inside `...' a backslash escapes a literal character: the old
            # manuals write `Read(\"f.g\")' to show a GAP string.  Reading
            # that \" as an umlaut would put a combining diaeresis on the next
            # letter, which LaTeX then cannot typeset.
            self._emit(xml_escape(name))
            return

        if name in ACCENT_COMBINING and self.mode == "text":
            # Accent applied to the next letter or to a {x} group.  The macro
            # regex is greedy over letters, so \vec already lexed as "vec" and
            # can never arrive here as the caron \v -- no extra guard needed.
            grp = self._balanced_group()
            if grp is None:
                nxt = self._peek()
                if nxt:
                    self.i += 1
                    grp = nxt
                else:
                    grp = ""
            grp = grp.strip()
            if len(grp) == 1 and grp.isalpha():
                out, _ = detex_accents(f"\\{name}{{{grp}}}")
                self._emit(out)
            else:
                self._emit(xml_escape(grp))
            return

        if name in TEX_SPECIALS:
            self._emit(TEX_SPECIALS[name])
            return

        if name in ("dots", "ldots", "cdots"):
            self._emit("\\" + name if self.mode == "math" else "...")
            return

        if name in DROP_MACROS:
            return

        if name in ("texttt", "tt", "verb", "code"):
            body = self._balanced_group()
            if body is not None:
                self._emit(f"<C>{self._sub().run(body, 'code')}</C>")
            return

        if name in ("textbf", "bf", "strong"):
            body = self._balanced_group()
            if body is not None:
                self._emit(f"<E>{self._sub().run(body, self.mode)}</E>")
            return

        if name == "textcolor":          # \textcolor{colour}{text} -- keep text
            self._balanced_group()
            body = self._balanced_group()
            if body is not None:
                self._emit(self._sub().run(body, self.mode))
            return

        if name in ("label", "nameddest", "setbookmark", "definecolor",
                    "hyphenation"):
            # Discard the macro and its arguments.  _balanced_group returns None
            # without advancing when the braces do not close, so stop on that or
            # the loop spins forever.
            while self._peek() == "{":
                if self._balanced_group() is None:
                    self.i += 1
                    break
            return

        if name == "space":
            self._emit(" ")
            return

        if name in ("centerline", "mbox", "hbox", "text", "emph", "textit",
                    "textsf", "textrm", "underline"):
            body = self._balanced_group()
            if body is not None:
                self._emit(self._sub().run(body, self.mode))
            return

        # Anything else: keep as-is inside math (GAPDoc passes TeX through),
        # flag it outside.
        if self.mode == "math":
            self._emit("\\" + name)
            return

        self.notes.add("unhandled macro", "\\" + name)
        self._emit(f"<!-- TODO(g2g) unhandled macro \\{name} -->")

    def _math(self) -> None:
        display = self._peek(1) == "$"
        delim = "$$" if display else "$"
        start = self.i + len(delim)
        end = self.s.find(delim, start)
        if end < 0:
            self.notes.add("unterminated math")
            self._emit("$")
            self.i += 1
            return
        body = self.s[start:end]
        self.i = end + len(delim)
        # Plain TeX's \sp/\sb for super- and subscript; GAPDoc's LaTeX has no
        # such macros, and its HTML output shows them verbatim.
        body = re.sub(r"\\sp\b\s*", "^", body)
        body = re.sub(r"\\sb\b\s*", "_", body)
        # gapmacro.tex made * active, so the sources spell it \* even inside
        # maths, where LaTeX has no such macro and stops with "Missing {".
        body = body.replace("\\*", "*")
        body = re.sub(r"(?<![\\A-Za-z])(" + "|".join(MATH_OPERATORS) + r")(?![A-Za-z])",
                      r"\\\1", body)
        body = self._detex_alignment(body)
        inner = self._sub().run(body, "math")
        tag = "Display" if display else "M"
        self._emit(f"<{tag}>{inner}</{tag}>")

    def _detex_alignment(self, body: str) -> str:
        """Rewrite plain TeX's \\eqalign and \\cr for GAPDoc's LaTeX.

        GAPDoc loads amssymb but not amsmath, so there is no `aligned`
        environment; a two-column `array` is the nearest thing plain LaTeX has.
        """
        while True:
            i = body.find(r"\eqalign")
            j = body.find("{", i) if i >= 0 else -1
            if j < 0:
                break
            depth, k = 0, j
            while k < len(body):
                if body[k] == "{":
                    depth += 1
                elif body[k] == "}":
                    depth -= 1
                    if depth == 0:
                        break
                k += 1
            if k >= len(body):
                break
            inner = body[j + 1:k].replace(r"\cr", r"\\")
            inner = re.sub(r"\\\\\s*$", "", inner.strip())
            body = (body[:i] + r"\begin{array}{rl}" + inner + r"\end{array}"
                    + body[k + 1:])

        body = body.replace(r"\cr", r"\\")
        for macro in ("matrix", "pmatrix", "cases", "over", "atop"):
            if re.search(r"\\" + macro + r"\b", body):
                self.notes.add("plain-TeX math construct needs rewriting",
                               f"\\{macro} has no equivalent without amsmath")
        return body

    def _quote(self) -> None:
        end = self.s.find("''", self.i + 2)
        if end < 0:
            self._emit("&#x201c;")
            self.i += 2
            return
        body = self.s[self.i + 2:end]
        self.i = end + 2
        inner = self._sub().run(body, self.mode)
        self._emit(f"<Q>{inner}</Q>")

    def _code(self) -> None:
        # `...' -- typewriter.  The closing quote is a bare "'".
        j = self.i + 1
        while j < self.n:
            if self.s[j] == "\\":
                j += 2
                continue
            if self.s[j] == "'":
                break
            j += 1
        if j >= self.n:
            self._emit("&#x2018;")
            self.i += 1
            return
        body = self.s[self.i + 1:j]
        self.i = j + 1
        stripped = body.strip()
        if stripped in GAP_KEYWORDS:
            self._emit(f"<K>{xml_escape(stripped)}</K>")
            return
        # Heuristic: things that look like file names get <F>.
        if re.fullmatch(r"[\w./\-]+\.(g|gd|gi|c|h|tst|xml|tex|txt|bib)", stripped):
            self._emit(f"<F>{xml_escape(stripped)}</F>")
            return
        inner = self._sub().run(body, "code")
        self._emit(f"<C>{inner}</C>")

    def _try_arg(self) -> bool:
        end = self.s.find(">", self.i + 1)
        if end < 0:
            return False
        body = self.s[self.i + 1:end]
        if "\n" in body or not ARG_RE.match(body.strip()):
            return False
        self.i = end + 1
        self._emit(f"<A>{xml_escape(body.strip())}</A>")
        return True

    def _try_emph(self) -> bool:
        if not self._peek(1) or self._peek(1).isspace():
            return False
        end = self.s.find("*", self.i + 1)
        if end < 0 or end - self.i > 120:
            return False
        body = self.s[self.i + 1:end]
        if "\n\n" in body or self.s[end - 1].isspace():
            return False
        self.i = end + 1
        inner = self._sub().run(body, self.mode)
        self._emit(f"<E>{inner}</E>")
        return True

    def _ref(self) -> None:
        end = self.s.find('"', self.i + 1)
        if end < 0 or end - self.i > 200:
            self._emit("&quot;")
            self.i += 1
            return
        body = self.s[self.i + 1:end]
        self.i = end + 1
        label = re.sub(r"\s+", " ", body).strip()
        book: str | None = None
        if ":" in label:
            head, tail = label.split(":", 1)
            if re.fullmatch(r"[A-Za-z][\w\-]*", head):
                book, label = head.lower(), tail.strip()
        hit = self.six.lookup(book, label)
        bookattr = ""
        if book and book != self.book:
            bookattr = f' BookName="{attr_escape(book)}"'
        if hit:
            attr, _book, canon = hit
            # Prefer the target's own spelling; fall back if it looks unusable.
            if canon and not re.search(r"[\\\x00-\x1f]", canon):
                label = canon
            self._emit(f'<Ref {attr}="{attr_escape(label)}"{bookattr}/>')
        else:
            self.notes.add("unresolved reference", label[:70])
            kind = "Sect" if " " in label else "Func"
            self._emit(
                f'<!-- TODO(g2g) verify reference kind -->'
                f'<Ref {kind}="{attr_escape(label)}"{bookattr}/>'
            )


# ---------------------------------------------------------------------------
# Declaration (\>) parsing
# ---------------------------------------------------------------------------

@dataclass
class Decl:
    element: str
    name: str
    arg: str | None
    label: str | None = None
    type_attr: str | None = None
    uncertain: bool = False

    def render(self) -> str:
        bits = [f'Name="{attr_escape(self.name)}"']
        if self.label:
            bits.append(f'Label="{attr_escape(self.label)}"')
        if self.element not in NO_ARG:
            bits.append(f'Arg="{attr_escape(self.arg or "")}"')
        if self.type_attr:
            bits.append(f'Type="{attr_escape(self.type_attr)}"')
        lead = "<!-- TODO(g2g) guessed element type -->\n" if self.uncertain else ""
        return f'{lead}<{self.element} {" ".join(bits)}/>'


def _split_index_groups(rest: str) -> tuple[str | None, str]:
    """Pull ``{label}``, ``{label}@{idx}``, ``{name}!{sub}`` suffixes off a decl.

    gapmacro's ``\\operation`` reads ``{#2}`` then a single token ``#3`` that is
    ``!`` or ``@`` (index subentry forms) or the classification letter.  We keep
    the human-meaningful part as a GAPDoc ``Label``.
    """
    rest = rest.strip()
    label = None
    m = re.match(r"^\{([^{}]*)\}\s*", rest)
    if m:
        inner = m.group(1)
        rest = rest[m.end():]
        if "!" in inner:
            label = inner.split("!", 1)[1].strip()
        m2 = re.match(r"^[@!]\s*\{([^{}]*)\}\s*", rest)
        if m2:
            if label is None:
                label = m2.group(1).strip()
            rest = rest[m2.end():]
    m3 = re.match(r"^[@!]\s*\{([^{}]*)\}\s*", rest)
    if m3:
        if label is None:
            label = m3.group(1).strip()
        rest = rest[m3.end():]
    return label, rest


def _split_name_args(text: str) -> tuple[str, str | None]:
    """Split ``Foo( <a>, <b> )`` into ``Foo`` and ``a, b``."""
    p = text.find("(")
    if p < 0:
        return text.strip(), None
    q = text.rfind(")")
    if q < p:
        return text.strip(), None
    name = text[:p].strip()
    args = text[p + 1:q]
    args = args.replace("<", "").replace(">", "")
    args = re.sub(r"\s+", " ", args).strip()
    return name, args


def is_bullet(mark: str) -> bool:
    """Is this item mark a plain bullet, carrying no information?

    GAPDoc bullets a <List> whose items have no <Mark>, so ``\\item{$\\bullet$}``
    and ``\\item{--}`` should produce no mark at all.
    """
    m = mark.strip().strip("$").strip()
    return m in ("", r"\bullet", r"\circ", r"\ast", r"\cdot",
                 "--", "-", "*", "o", "+")


def is_enumeration(marks: list[str]) -> bool:
    """Are these marks just 1, 2, 3, ...?  Then <Enum> numbers them instead."""
    nums = [re.fullmatch(r"[<(\[]*\s*(\d+)\s*[.)\]>]*", m or "") for m in marks]
    return (bool(marks) and all(nums)
            and [int(m.group(1)) for m in nums] == list(range(1, len(nums) + 1)))


def merge_overloads(decls: list[Decl], notes: Notes) -> list[Decl]:
    """Collapse repeated declarations of one name into a single element.

    The old format spells optional arguments out as one ``\\>`` line per
    signature::

        \\> FrattiniExtensionMethod( <order> ) F
        \\> FrattiniExtensionMethod( <order>, <uncoded> ) F
        \\> FrattiniExtensionMethod( <order>, <flags> ) F
        \\> FrattiniExtensionMethod( <order>, <flags>, <uncoded> ) F

    GAPDoc derives a label from each element's name, so emitting these
    separately gives "Label multiply defined" and ambiguous cross-references.
    GAPDoc writes optional arguments inline, so merge the group into
    ``order[, flags][, uncoded]``: the longest signature fixes the argument
    order, and an argument missing from any signature is optional.

    A group whose signatures are not all contained in the longest one is a
    genuine ambiguity; it is left alone and reported.
    """
    groups: dict[tuple, list[Decl]] = {}
    order: list[tuple] = []
    for d in decls:
        key = (d.element, d.name, d.label)
        if key not in groups:
            groups[key] = []
            order.append(key)
        groups[key].append(d)

    out: list[Decl] = []
    for key in order:
        group = groups[key]
        first = group[0]
        if len(group) == 1:
            out.append(first)
            continue

        sigs = [[a.strip() for a in (d.arg or "").split(",") if a.strip()]
                for d in group]
        longest = max(sigs, key=len)
        if any(a not in longest for sig in sigs for a in sig):
            # Genuinely different calling conventions rather than optional
            # arguments -- crystcat's DisplayZClass takes a Z-class as
            # (dim, system, q-class, z-class), as (dim, IT-number), or as a
            # Hermann-Mauguin symbol.  They must stay separate elements, but
            # GAPDoc needs their labels to differ, so name each by its
            # arguments the way GAPDoc labels method variants.
            notes.add("repeated declaration, labelled by its arguments",
                      f"{first.name}: " + " / ".join(d.arg or "" for d in group))
            for d in group[1:]:
                if not d.label:
                    d.label = f"for {d.arg}" if d.arg else "no arguments"
            out.extend(group)
            continue

        parts = []
        for a in longest:
            if all(a in sig for sig in sigs):
                parts.append(a)
            else:
                parts.append(f"[{a}]")
        first.arg = ", ".join(parts).replace(", [", "[, ")
        out.append(first)
        notes.add("merged repeated declarations into optional arguments",
                  f"{first.name}: {len(group)} signatures -> {first.arg}")
    return out


def parse_decl(body: str, notes: Notes,
               decls: "DeclIndex | None" = None) -> tuple[Decl | None, str]:
    """Parse the body of a ``\\>`` line.  Returns (decl, leftover-mark-text)."""
    body = body.strip()

    # Trailing classification letter.
    letter = None
    m = re.search(r"(?:^|\s)([FOAPMVCR])\s*$", body)
    if m:
        letter = m.group(1)
        body = body[:m.start()].rstrip()

    if body.startswith("`"):
        close = body.find("'")
        if close < 0:
            return None, body
        display = body[1:close]
        label, leftover = _split_index_groups(body[close + 1:])
        name, args = _split_name_args(display)
        if leftover.strip():
            notes.add("unparsed declaration tail", leftover.strip()[:60])
    else:
        # ``Name( args )!{subentry}``
        m2 = re.match(r"^(.*?\))\s*(.*)$", body, re.S)
        if m2:
            head, tail = m2.group(1), m2.group(2)
        else:
            head, tail = body, ""
        label, leftover = _split_index_groups(tail)
        name, args = _split_name_args(head)
        if leftover.strip():
            notes.add("unparsed declaration tail", leftover.strip()[:60])

    if not name:
        return None, body

    # A name that is not a plain identifier cannot be a real GAP name; keep the
    # leading identifier and record the original for the human.
    if not re.fullmatch(r"[A-Za-z_][\w.]*", name):
        ident = re.match(r"[A-Za-z_][\w.]*", name)
        if ident:
            if label is None:
                label = name
            name = ident.group(0)
        else:
            notes.add("undecipherable declaration name", name[:60])
            return None, body

    real = decls.lookup(name) if decls else None
    uncertain = False

    if letter:
        element, type_attr = TYPE_MAP[letter]
        if real and real[0] != element:
            # The source is the authority: where the two disagree the manual is
            # simply out of date, and the documentation should say what is
            # actually declared.  A "M" line claiming a method is no exception
            # -- we only get here when the package declares the name itself, so
            # it owns the operation and should document it as such.  A method
            # installed for someone else's operation has no entry here at all.
            notes.add("type taken from source, manual was out of date",
                      f"{name}: .tex said {element}, declared as {real[0]}")
            element, type_attr = real
        elif real and real[0] == element and type_attr is None:
            # Same element, but the source may know the Filt subtype.
            type_attr = real[1]
    elif real:
        element, type_attr = real
    else:
        # gapmacro allowed omitting the letter and the name is not declared in
        # this package's source (often a method for a foreign operation).
        element, type_attr = ("Func" if args is not None else "Var"), None
        uncertain = True
        notes.add("declaration type unknown", name)

    if element == "Var" and re.match(r"^Info[A-Z]", name):
        element = "InfoClass"

    if label:
        # The index text the label came from is TeX, so it may be wrapped in
        # gapmacro's `...' code quotes.  A Label is an attribute, not markup,
        # and one that merely repeats the name carries nothing.
        label = re.sub(r"`([^']*)'", r"\1", label).strip()
        if label == name or not label:
            label = None

    return Decl(element, name, args, label, type_attr, uncertain), ""


# ---------------------------------------------------------------------------
# Structural conversion
# ---------------------------------------------------------------------------

@dataclass
class ChapterFile:
    stem: str
    xml: str


class Converter:
    def __init__(self, six: SixIndex, notes: Notes, book: str,
                 entities: Iterable[str] = (),
                 decls: DeclIndex | None = None) -> None:
        self.six = six
        self.notes = notes
        self.book = book
        self.entities = set(entities)
        self.decls = decls
        self._verb: list[str] = []   # reset per file in convert_file

    #: ``\beginexample``/``\begintt`` regions nested inside a ``\beginitems`` or
    #: ``\beginlist`` block, which are collected as raw text.
    VERBATIM_RE = re.compile(
        r"\\begin(example|tt)[ \t]*\n(.*?)\n?[ \t]*\\end\1", re.S)

    _PLACEHOLDER = "\x00g2gverb{}\x00"

    @staticmethod
    def _dedent(text: str) -> str:
        """Strip the indentation the old sources used to set a session off.

        AutoDoc extracts <Example> verbatim, and GAP's test format only sees a
        prompt at the start of a line -- an indented "gap>" is read as expected
        output instead, so a whole indented block fails as one chunk against
        START_TEST.  sonata indented every one of its examples.  Only the
        common prefix goes, so continuation lines keep their relative layout.

        Only <Example> is dedented.  <Log> and <Listing> are never extracted,
        and their indentation is deliberate -- cryst centres two matrices in a
        \\begintt block.
        """
        lines = text.split("\n")
        real = [l for l in lines if l.strip()]
        if not real:
            return text
        pad = min(len(l) - len(l.lstrip(" \t")) for l in real)
        if not pad:
            return text
        return "\n".join(l[pad:] if l.strip() else l for l in lines)

    @staticmethod
    def _verbatim(tag: str, text: str) -> str:
        """Emit a verbatim block, splitting <Example> at blank lines.

        A blank line inside a GAP test file is part of the expected output, so
        an <Example> containing one always fails once AutoDoc extracts it --
        the old manuals used blank lines purely to group a session visually and
        were never tested.  Emitting one <Example> per group keeps that visual
        grouping and makes AutoDoc write a "#" separator between the chunks,
        which is what the test format wants.  <Log> is not extracted, so it is
        left as a single block.
        """
        if tag != "Example":
            return f"<{tag}><![CDATA[\n{text}\n]]></{tag}>"
        # A trailing bare "gap>" is the old manuals' way of showing that you are
        # back at the prompt.  As extracted test input it is an empty statement
        # and fails, so drop it.
        text = re.sub(r"\ngap>[ \t]*$", "", text)
        # Split only where a new command follows.  A blank line that is not
        # followed by "gap>" belongs to the preceding command's output --
        # DisplaySpaceGroupGenerators prints one, and cutting there would
        # strand the rest of the output in a chunk with nothing to produce it.
        groups = [g for g in re.split(r"\n[ \t]*\n(?=gap>)", text) if g.strip()]
        return "\n".join(f"<Example><![CDATA[\n{g}\n]]></Example>" for g in groups)

    @staticmethod
    def _ends_statement(stmt: str) -> bool:
        """Does this input line finish its statement?

        A trailing comment does not make it unfinished, so cut at the first
        "#" that is not inside a string or character literal.
        """
        quote = None
        for i, ch in enumerate(stmt):
            if quote:
                if ch == "\\":
                    continue
                if ch == quote:
                    quote = None
            elif ch in "\"'":
                quote = ch
            elif ch == "#":
                stmt = stmt[:i]
                break
        return stmt.rstrip().endswith(";")

    def _check_indent(self, text: str) -> None:
        """Report a "gap>" still indented after the block was dedented.

        Only the common prefix is stripped, so a block that indents some of its
        prompts but not others keeps them -- sonata has one.  GAP would read
        the indented line as expected output, so say so rather than guess which
        lines were meant to line up.
        """
        for line in text.split("\n"):
            if re.match(r"[ \t]+gap> ", line):
                self.notes.add("indented gap> line, reads as output not input",
                               line.strip()[:70])

    def _check_continuations(self, text: str) -> None:
        """Report a "gap>" line that does not finish its statement.

        GAP would prompt "> " and read the next line as input, so the extracted
        test reads the manual's *output* as part of the command. Either the
        statement really is spread over several lines and the continuations
        need their "> " prompts (modisom writes a rec() that way), or the
        semicolon is simply missing (rds has "gap> d1=d2"). Adding the prompts
        automatically would paper over the second case, so report instead.
        """
        prev = None
        for line in text.split("\n"):
            if line.startswith("gap> "):
                if not self._ends_statement(line[5:]):
                    prev = line
                    continue
            elif prev is not None and not line.startswith(("gap>", "> ")):
                self.notes.add(
                    "gap> line does not end in ';', so the next line reads as input",
                    prev.strip()[:70])
            prev = None

    def stash_verbatim(self, text: str) -> str:
        """Replace nested verbatim regions with placeholders.

        Must run before any paragraph splitting: a ``\\beginexample`` block
        containing a blank line would otherwise be torn in half and its two
        halves converted as ordinary prose.
        """
        def stash(m: re.Match) -> str:
            tag = "Example" if m.group(1) == "example" else "Log"
            body = m.group(2).strip("\n").replace("]]>", "]]]]><![CDATA[>")
            if tag == "Example":
                body = self._dedent(body)
                self._check_indent(body)
                self._check_continuations(body)
            self._verb.append(self._verbatim(tag, body))
            return self._PLACEHOLDER.format(len(self._verb) - 1)

        return self.VERBATIM_RE.sub(stash, text)

    def inline(self, text: str) -> str:
        """Convert running text, keeping any nested verbatim region intact."""
        out = Inline(self.six, self.notes, self.book,
                     self.entities).run(self.stash_verbatim(text))
        for idx, block in enumerate(self._verb):
            out = out.replace(self._PLACEHOLDER.format(idx), block)
        return out

    # -- helpers ------------------------------------------------------------

    @staticmethod
    def _strip_braces(s: str) -> str:
        """Take a sectioning title: the first braced group, or the whole line.

        ``\\Section{Title}`` is often followed by a control token such as
        ``\\null`` or ``\\nolabel``, which suppresses the automatic index
        entry.  Those must not end up in the title -- a backslash in a Label
        makes LaTeX fail with "Missing \\endcsname".
        """
        s = s.strip()
        if s.startswith("{"):
            depth = 0
            for i, ch in enumerate(s):
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
                    if depth == 0:
                        return s[1:i].strip()
        return s

    def convert_file(self, path: str) -> str:
        with open(path, encoding="utf8", errors="replace") as fh:
            lines = fh.read().replace("\r\n", "\n").split("\n")

        out: list[str] = []
        # Context flags
        self.in_chapter = False
        self.in_section = False
        self.in_mansection = False
        self.implicit_section = False
        self.chapter_title = ""
        self._verb: list[str] = []
        self.pending: list[str] = []      # paragraph buffer (raw TeX)
        self.header_comment: list[str] = []

        i = 0
        n = len(lines)
        seen_content = False

        while i < n:
            line = lines[i]
            stripped = line.strip()

            # --- verbatim regions --------------------------------------------
            if stripped.startswith("\\beginexample") or stripped.startswith("\\begintt"):
                is_example = stripped.startswith("\\beginexample")
                endtok = "\\endexample" if is_example else "\\endtt"
                tag = "Example" if is_example else "Log"
                body: list[str] = []
                i += 1
                while i < n and not lines[i].strip().startswith(endtok):
                    body.append(lines[i])
                    i += 1
                i += 1
                self._flush(out)
                text = "\n".join(body).strip("\n")
                text = text.replace("]]>", "]]]]><![CDATA[>")
                if tag == "Example":
                    text = self._dedent(text)
                    self._check_indent(text)
                    self._check_continuations(text)
                out.append(self._verbatim(tag, text))
                seen_content = True
                continue

            # --- item lists ---------------------------------------------------
            if stripped.startswith("\\beginitems"):
                i, block = self._collect(lines, i + 1, "\\enditems")
                self._flush(out)
                out.append(self._items(block))
                seen_content = True
                continue

            if stripped.startswith("\\beginlist"):
                i, block = self._collect(lines, i + 1, "\\endlist")
                self._flush(out)
                out.append(self._list(block))
                seen_content = True
                continue

            # --- sectioning ---------------------------------------------------
            if stripped.startswith("\\Chapter") or stripped.startswith("\\PreliminaryChapter"):
                self._flush(out)
                self._close_mansection(out)
                self._close_section(out)
                if self.in_chapter:
                    out.append("</Chapter>")
                title = self._strip_braces(stripped.split("Chapter", 1)[1])
                if stripped.startswith("\\Preliminary"):
                    title += " (preliminary)"
                out.append(f'<Chapter Label="{attr_escape(title)}">')
                out.append(f"<Heading>{self.inline(title)}</Heading>")
                self.in_chapter = True
                self.chapter_title = title
                seen_content = True
                i += 1
                continue

            if stripped.startswith("\\Section"):
                self._flush(out)
                self._close_mansection(out)
                self._close_section(out)
                title = self._strip_braces(stripped[len("\\Section"):])
                out.append(f'<Section Label="{attr_escape(title)}">')
                out.append(f"<Heading>{self.inline(title)}</Heading>")
                self.in_section = True
                self.implicit_section = False
                seen_content = True
                i += 1
                continue

            # --- declarations --------------------------------------------------
            if stripped.startswith("\\>"):
                i = self._mansection(lines, i, out)
                seen_content = True
                continue

            # --- \) continuation blocks ---------------------------------------
            if stripped.startswith("\\)"):
                block = []
                while i < n and lines[i].strip().startswith("\\)"):
                    raw = lines[i].strip()[2:]
                    raw = re.sub(r"\{\\kernttindent(?:\\quad)*\}", lambda m: "  " * (1 + m.group(0).count("\\quad")), raw)
                    raw = re.sub(r"\\(?:kernttindent|quad)", "  ", raw)
                    block.append(raw.rstrip())
                    i += 1
                self._flush(out)
                text = "\n".join(block).strip("\n")
                out.append(f"<Log><![CDATA[\n{text}\n]]></Log>")
                seen_content = True
                continue

            # --- \Input (main file only) ---------------------------------------
            if stripped.startswith("\\Input"):
                i += 1
                continue

            # --- raw TeX programming -------------------------------------------
            if TEX_PROGRAMMING.match(stripped):
                self.notes.add("dropped TeX preamble line", stripped[:60])
                i += 1
                continue

            # --- comments ------------------------------------------------------
            if stripped.startswith("%"):
                if not seen_content:
                    txt = stripped.lstrip("%").strip()
                    if txt and not set(txt) <= {"%"}:
                        self.header_comment.append(txt)
                i += 1
                continue

            self.pending.append(line)
            if stripped:
                seen_content = True
            i += 1

        self._flush(out)
        self._close_mansection(out)
        self._close_section(out)
        if self.in_chapter:
            out.append("</Chapter>")

        body = "\n".join(x for x in out if x is not None)
        head = ""
        if self.header_comment:
            # "--" may not appear inside an XML comment.
            joined = re.sub(r"-{2,}", "-", " / ".join(self.header_comment))
            head = f"<!-- {joined} -->\n"
        return head + body + "\n"

    # -- section/mansection bookkeeping -------------------------------------

    def _ensure_section(self, out: list[str]) -> None:
        """ManSection is only valid inside Section (see gapdoc.dtd)."""
        if not self.in_section:
            # No Label: this section is an artifact of the DTD requiring
            # ManSection to sit inside a Section, and reusing the chapter's
            # title as a label would collide with the chapter's own label.
            title = self.chapter_title or "Overview"
            out.append("<Section>")
            out.append(f"<Heading>{self.inline(title)}</Heading>")
            self.in_section = True
            self.implicit_section = True
            self.notes.add("synthesised wrapper section")

    def _close_section(self, out: list[str]) -> None:
        if self.in_section:
            out.append("</Section>")
            self.in_section = False
            self.implicit_section = False

    def _close_mansection(self, out: list[str]) -> None:
        if self.in_mansection:
            out.append("</Description>")
            out.append("</ManSection>")
            self.in_mansection = False

    def _flush(self, out: list[str]) -> None:
        """Emit the buffered running text as paragraphs."""
        raw = "\n".join(self.pending)
        self.pending = []
        if not raw.strip():
            return
        paras = [p for p in re.split(r"\n\s*\n", raw) if p.strip()]
        chunks = []
        for p in paras:
            converted = self.inline(p).strip()
            if converted:
                chunks.append(converted)
        if chunks:
            out.append("\n<P/>\n".join(chunks))

    # -- \> handling ---------------------------------------------------------

    def _mansection(self, lines: list[str], i: int, out: list[str]) -> int:
        """Consume a run of ``\\>`` lines into one ManSection.

        Declarations that share a description belong in a single ManSection
        (GAPDoc allows several Func/Oper/... before the Description).  The old
        manuals write those either on consecutive lines or separated by blank
        lines, so we keep collecting across blank lines and only stop at real
        description text -- otherwise the leading declarations end up in
        ManSections with an empty Description.
        """
        self._flush(out)
        self._close_mansection(out)
        self._ensure_section(out)

        decls: list[Decl] = []
        n = len(lines)
        while i < n:
            if not lines[i].strip():          # blank line: look further ahead
                j = i
                while j < n and not lines[j].strip():
                    j += 1
                if j < n and lines[j].strip().startswith("\\>"):
                    i = j
                    continue
                break
            if not lines[i].strip().startswith("\\>"):
                break

            body = lines[i].strip()[2:]
            # Line continuation: gapmacro reads to end of line, but a trailing
            # backslash-free unbalanced paren means the decl wraps.
            while body.count("(") > body.count(")") and i + 1 < n:
                i += 1
                body += " " + lines[i].strip()
            if body.rstrip().endswith("&"):
                # An items-list mark that leaked out of \beginitems.
                self.notes.add("\\> used as item mark outside \\beginitems")
                body = body.rstrip()[:-1]
            decl, _ = parse_decl(body, self.notes, self.decls)
            if decl:
                decls.append(decl)
            else:
                self.notes.add("undecipherable declaration", body.strip()[:70])
                out.append(f"<!-- TODO(g2g) could not parse: {xml_escape(body.strip())[:200]} -->")
            i += 1

        if not decls:
            return i

        decls = merge_overloads(decls, self.notes)

        out.append("<ManSection>")
        for d in decls:
            out.append(d.render())
        out.append("<Description>")
        self.in_mansection = True
        return i

    # -- lists ---------------------------------------------------------------

    @staticmethod
    def _collect(lines: list[str], i: int, endtok: str) -> tuple[int, list[str]]:
        body: list[str] = []
        n = len(lines)
        while i < n and not lines[i].strip().startswith(endtok):
            body.append(lines[i])
            i += 1
        return i + 1, body

    def _items(self, block: list[str]) -> str:
        """``\\beginitems``: entries are ``MARK & BODY``, separated by blank lines."""
        text = self.stash_verbatim("\n".join(block).strip("\n"))
        paras = [e for e in re.split(r"\n\s*\n", text) if e.strip()]

        # An entry starts at the paragraph containing '&' (which separates its
        # mark from its body).  Paragraphs without '&' are further paragraphs of
        # the entry already open -- not new entries.
        entries: list[tuple[str, list[str]]] = []
        lead: list[str] = []
        for para in paras:
            if "&" in para:
                mark, body = para.split("&", 1)
                entries.append((mark.strip(), [body]))
            elif entries:
                entries[-1][1].append(para)
            else:
                lead.append(para)

        parts = []
        if lead:
            parts.append(self.inline("\n\n".join(lead)))
        if not entries:
            self.notes.add("items block with no '&' separator at all")
            return "\n".join(parts) if parts else ""

        if is_enumeration([m for m, _ in entries]):
            parts.append("<Enum>")
            for _mark, bodies in entries:
                body_xml = "\n<P/>\n".join(
                    x for x in (self.inline(b).strip() for b in bodies) if x)
                parts.append(f"<Item>{body_xml}</Item>")
            parts.append("</Enum>")
            return "\n".join(parts)

        parts.append("<List>")
        for mark, bodies in entries:
            if mark.startswith("\\>"):
                decl, _ = parse_decl(mark[2:], self.notes, self.decls)
                mark_xml = (f"<C>{xml_escape(decl.name)}</C>" if decl
                            else self.inline(mark[2:]))
            else:
                mark_xml = self.inline(mark)
            body_xml = "\n<P/>\n".join(
                x for x in (self.inline(b).strip() for b in bodies) if x)
            parts.append(f"<Mark>{mark_xml}</Mark>")
            parts.append(f"<Item>{body_xml}</Item>")
        parts.append("</List>")
        return "\n".join(parts)

    def _list(self, block: list[str]) -> str:
        """``\\beginlist`` with ``\\item{MARK} BODY`` entries."""
        text = self.stash_verbatim("\n".join(block).strip("\n"))
        chunks = re.split(r"\\item", text)
        lead = chunks[0].strip()
        parts = []
        if lead:
            parts.append(self.inline(lead))

        items: list[tuple[str, str]] = []
        for chunk in chunks[1:]:
            m = re.match(r"\s*\{([^{}]*)\}(.*)$", chunk, re.S)
            items.append((m.group(1), m.group(2)) if m else ("", chunk))

        marks = [m for m, _ in items]
        if is_enumeration(marks):
            parts.append("<Enum>")
            for _m, body in items:
                parts.append(f"<Item>{self.inline(body)}</Item>")
            parts.append("</Enum>")
            return "\n".join(parts)

        drop = all(is_bullet(m) for m in marks)
        parts.append("<List>")
        for mark, body in items:
            if not drop and mark.strip():
                parts.append(f"<Mark>{self.inline(mark)}</Mark>")
            parts.append(f"<Item>{self.inline(body)}</Item>")
        parts.append("</List>")
        return "\n".join(parts)


# ---------------------------------------------------------------------------
# Package-level driver
# ---------------------------------------------------------------------------

def parse_manual_tex(path: str) -> dict:
    """Extract book name, package name, \\def macros and chapter order."""
    info = {"book": "", "package": "", "defs": {}, "inputs": []}
    if not os.path.isfile(path):
        return info
    with open(path, encoding="utf8", errors="replace") as fh:
        text = fh.read()
    m = re.search(r"\\BeginningOfBook\{([^}]*)\}", text)
    if m:
        info["book"] = m.group(1).strip()
    m = re.search(r"\\Package\{([^}]*)\}", text)
    if m:
        info["package"] = m.group(1).strip()
    # gapmacro.tex:776 -- \Package{Foo} defines the macro \Foo, rendering the
    # package name.  This, not \def, is how most manuals introduce \Radiroot
    # and friends.
    for m in re.finditer(r"\\Package\{([A-Za-z][\w]*)\}", text):
        name = m.group(1)
        info["defs"].setdefault(name, f"<Package>{name}</Package>")
    for m in re.finditer(r"\\def\\([A-Za-z]+)\{((?:[^{}]|\{[^{}]*\})*)\}", text):
        info["defs"][m.group(1)] = m.group(2)
    # \Input lines routinely carry a trailing TeX comment, and disabled
    # chapters are commented out -- so strip comments first, then match without
    # anchoring to end of line.
    for line in text.split("\n"):
        code = re.split(r"(?<!\\)%", line, maxsplit=1)[0]
        m = re.search(r"\\Input\s*\{?([\w\-.]+?)\}?\s*$", code.rstrip())
        if m:
            info["inputs"].append(m.group(1).replace(".tex", ""))
    return info


def find_gap_books() -> list[tuple[str, str]]:
    """Locate manual.six for GAP's own books, so ``"ref:..."`` refs resolve.

    Honours $GAPROOT, else asks the ``gap`` on $PATH where it lives.
    """
    roots = []
    if os.environ.get("GAPROOT"):
        roots.append(os.environ["GAPROOT"])
    else:
        import shutil
        import subprocess
        if shutil.which("gap"):
            try:
                # RootPaths[1] is the user preferences dir, so take them all
                # and let the doc/ref/manual.six check below pick the winner.
                out = subprocess.run(
                    ["gap", "-q", "-A", "-b", "--norepl", "-c",
                     'for p in GAPInfo.RootPaths do Print(p,"\\n"); od; QUIT_GAP(0);'],
                    stdin=subprocess.DEVNULL, capture_output=True,
                    text=True, timeout=60,
                )
                roots.extend(p.strip() for p in out.stdout.split("\n") if p.strip())
            except (subprocess.SubprocessError, OSError):
                pass
    found = []
    seen = set()
    for root in roots:
        for book in ("ref", "tut"):
            path = os.path.join(root, "doc", book, "manual.six")
            if os.path.isfile(path) and book not in seen:
                seen.add(book)
                found.append((book, path))
        # Package books too, so qualified references like "smallgrp:..." and a
        # package's references to its own book by name can be resolved.
        import glob as _glob
        for path in sorted(_glob.glob(os.path.join(root, "pkg", "*", "doc", "manual.six"))):
            book = os.path.basename(os.path.dirname(os.path.dirname(path))).lower()
            book = re.sub(r"-[\d.]+$", "", book)      # strip a version suffix
            if book not in seen:
                seen.add(book)
                found.append((book, path))
    return found


#: Files that live in doc/ but are never documentation source: the manual's
#: own driver, and bundled copies of TeX macro libraries.
NOT_DOCUMENTATION = {"manual.tex", "gapmacro.tex", "epsf.tex", "epsfig.tex"}

#: TeX programming that only ever appears in a preamble block.  A line opening
#: with one of these is dropped whole rather than half-translated.
TEX_PROGRAMMING = re.compile(
    r"^\\(?:def|edef|gdef|xdef|let|font|newif|newdimen|newbox|newcount|newskip|"
    r"dimen|count|skip|global|advance|multiply|divide|catcode|noexpand|"
    r"expandafter|immediate|write|openout|closeout|input|hoffset|voffset|"
    r"parindent|parskip|hsize|vsize|baselineskip|topskip|ttindent|manindent|"
    r"epsf[a-z]*|ifx|ifnum|ifdim|else|fi|loop|csname|endcsname)\b"
)


def harvest_macros(doc: str, files: Iterable[str]) -> dict[str, str]:
    """Collect ``\\def``/``\\Package`` macros from every documentation file.

    Packages define their name macro (``\\GRAPE``, ``\\ITC``, ...) either in
    manual.tex via ``\\Package{}`` or -- just as often -- with a plain ``\\def``
    repeated at the top of each chapter file, so both must be scanned.
    """
    defs: dict[str, str] = {}
    for fn in files:
        path = os.path.join(doc, fn)
        if not os.path.isfile(path):
            continue
        with open(path, encoding="utf8", errors="replace") as fh:
            text = fh.read()
        for m in re.finditer(r"\\Package\{([A-Za-z][\w]*)\}", text):
            defs.setdefault(m.group(1), f"<Package>{m.group(1)}</Package>")
        for m in re.finditer(
                r"\\(?:def|gdef|edef)\\([A-Za-z]+)\{((?:[^{}]|\{[^{}]*\})*)\}", text):
            defs.setdefault(m.group(1), m.group(2))
    return defs


def select_sources(doc: str, info: dict, notes: Notes) -> tuple[list[str], list[str]]:
    """Pick the real chapter files, in manual order.

    ``doc/`` routinely also holds files that are not documentation source at
    all -- bundled TeX libraries such as ``epsf.tex``, and GAPDoc-generated
    output such as ``_main.tex`` -- and converting those produces garbage.
    manual.tex's ``\\Input`` list is authoritative when present.
    """
    present = [f for f in sorted(os.listdir(doc))
               if f.endswith(".tex") and f not in NOT_DOCUMENTATION]
    listed = [f"{s}.tex" for s in info["inputs"]]
    if listed:
        chosen = [f for f in listed if os.path.isfile(os.path.join(doc, f))]
        skipped = [f for f in present if f not in chosen]
        for fn in skipped:
            notes.add("file not listed in manual.tex, skipped", fn)
        return chosen, skipped

    chosen, skipped = [], []
    for fn in present:
        with open(os.path.join(doc, fn), encoding="utf8", errors="replace") as fh:
            text = fh.read()
        if "\\logpage" in text or "\\hyperdef" in text:
            notes.add("skipped GAPDoc-generated file", fn)
            skipped.append(fn)
        elif "\\Chapter" not in text and "\\Section" not in text:
            notes.add("skipped non-chapter file", fn)
            skipped.append(fn)
        else:
            chosen.append(fn)
    return chosen, skipped


#: A rendered declaration element, for the duplicate-label check.
DECL_ELEMENT = re.compile(
    r'<(Func|Oper|Attr|Prop|Meth|Filt|Var|InfoClass|Constr|Fam)\s+'
    r'Name="([^"]*)"(?:\s+Label="([^"]*)")?')


def report_duplicate_labels(pieces: dict[str, str], notes: Notes) -> None:
    """Report a name declared twice with no Label to tell the copies apart.

    GAPDoc derives a label from each declaration's name, book-wide, and
    otherwise reports "Label multiply defined" and resolves references to it
    arbitrarily.  merge_overloads only sees one ManSection at a time, so it
    cannot catch a name documented in two of them -- liepring documents
    LiePRingsByLibrary once with a prime and once without.  The right label
    says why the forms differ, so leave it to a human.
    """
    seen: dict[tuple[str, str, str], list[str]] = {}
    for fn, xml in pieces.items():
        for el, name, label in DECL_ELEMENT.findall(xml):
            seen.setdefault((el, name, label), []).append(fn)
    for (el, name, _label), files in sorted(seen.items()):
        if len(files) > 1:
            notes.add("name declared more than once, needs a Label",
                      f"{name} ({el}) in {', '.join(sorted(set(files)))}")


SECTION_LABEL = re.compile(r'<(Chapter|Section) Label="([^"]*)">')
REF_TARGET = re.compile(r'<Ref [^>]*?(?:Sect|Chap|Subsect)="([^"]*)"')


def drop_colliding_section_labels(pieces: dict[str, str],
                                  notes: Notes) -> dict[str, str]:
    """Unlabel a section named after the one function it documents.

    gapmacro kept section and declaration labels apart; GAPDoc has a single
    namespace, so `\\Section{CHR}` wrapping `\\>CHR(...)` becomes "Label
    multiply defined" and a reference resolves to whichever came last. grape
    does this 73 times.

    Where the section wraps exactly that one declaration, the section label is
    redundant: drop it, and point any reference at the declaration instead --
    it lands the reader in the same place. Anything less clear-cut is left
    alone and reported.
    """
    # which declarations does each section contain?
    sole: dict[str, str] = {}      # label -> element of its single declaration
    multi: set[str] = set()
    for xml in pieces.values():
        for chunk in re.split(r"(?=<(?:Chapter|Section)[ >])", xml):
            m = SECTION_LABEL.match(chunk)
            if not m:
                continue
            found = DECL_ELEMENT.findall(chunk)
            names = {f[1] for f in found}
            if names == {m.group(2)} and len(found) == 1:
                sole[m.group(2)] = found[0][0]
            else:
                multi.add(m.group(2))

    decls = {f[1] for xml in pieces.values() for f in DECL_ELEMENT.findall(xml)}

    dropped = retargeted = 0
    out = {}
    for fn, xml in pieces.items():
        def fix_section(m: re.Match) -> str:
            nonlocal dropped
            label = m.group(2)
            if label in decls and label in sole and label not in multi:
                dropped += 1
                return f"<{m.group(1)}>"
            if label in decls:
                notes.add("section shares a label with a declaration",
                          f"{label} in {fn} -- section holds more than that "
                          f"declaration, so left alone")
            return m.group(0)

        def fix_ref(m: re.Match) -> str:
            nonlocal retargeted
            label = m.group(2)
            if label in sole and label not in multi:
                retargeted += 1
                return m.group(0).replace(f'{m.group(1)}="{label}"',
                                          f'{sole[label]}="{label}"')
            return m.group(0)

        xml = re.sub(r'<Ref [^>]*?(Sect|Chap|Subsect)="([^"]*)"[^>]*/>',
                     fix_ref, xml)
        out[fn] = SECTION_LABEL.sub(fix_section, xml)

    if dropped:
        notes.add("section label dropped, clashed with its own declaration",
                  f"{dropped} section(s); {retargeted} reference(s) retargeted "
                  f"at the declaration")
    return out


def validate(xml: str, label: str, notes: Notes) -> bool:
    """Parse the fragment (with entities neutralised) to catch malformed XML."""
    probe = re.sub(r"&[A-Za-z][\w.\-]*;", "ENT", xml)
    try:
        ElementTree.fromstring(f"<root>{probe}</root>")
        return True
    except ElementTree.ParseError as exc:
        notes.add("XML not well-formed", f"{label}: {exc}")
        return False


MAKEDOC_TEMPLATE = '''#############################################################################
##
##  makedoc.g
##
##  Builds the package documentation with AutoDoc/GAPDoc.
##
#############################################################################

LoadPackage("AutoDoc");

# Run this from the package's root directory: gap makedoc.g
AutoDoc(rec(
    autodoc := rec(scan_dirs := []),
    gapdoc := rec(main := "main", files := []),
    extract_examples := true,
    scaffold := rec(
        includes := [
{includes}
        ],
{entities}{bibline}    ),
));

QuitGap();
'''


def convert_package(pkgdir: str, outdir: str | None, notes: Notes) -> int:
    pkgdir = os.path.abspath(pkgdir)
    doc = os.path.join(pkgdir, "doc")
    if not os.path.isdir(doc):
        print(f"error: no doc/ directory in {pkgdir}", file=sys.stderr)
        return 1
    out = outdir or doc
    os.makedirs(out, exist_ok=True)

    info = parse_manual_tex(os.path.join(doc, "manual.tex"))
    book = info["book"] or os.path.basename(pkgdir).lower()

    six = SixIndex()
    six.load(book, os.path.join(doc, "manual.six"))
    for other, path in find_gap_books():
        six.load(other, path)

    decls = DeclIndex()
    n_decls = decls.scan(pkgdir)
    print(f"  indexed {n_decls} declarations from the package source")

    sources, skipped = select_sources(doc, info, notes)
    if not sources:
        subs = sorted(d for d in os.listdir(doc)
                      if os.path.isdir(os.path.join(doc, d))
                      and any(f.endswith(".tex") for f in os.listdir(os.path.join(doc, d))))
        print(f"error: no documentation sources found in {doc}", file=sys.stderr)
        if subs:
            print(f"note: .tex files live in sub-directories ({', '.join(subs)}); "
                  f"this package ships several books and needs one run per book, "
                  f"e.g. point this script at each in turn.", file=sys.stderr)
        return 1
    if skipped:
        print(f"  skipping {len(skipped)} non-chapter file(s): {', '.join(skipped)}")

    macros = harvest_macros(doc, ["manual.tex"] + sources)
    entities = {k: v for k, v in macros.items()
                if k not in ENTITY_MACROS and re.fullmatch(r"[A-Za-z][\w]*", k)}

    # Convert everything first: the label checks below need the whole book.
    pieces: dict[str, str] = {}
    stems: dict[str, str] = {}
    for src in sources:
        stem = src[:-4]
        if stem in ("main", "title") or stem.startswith("_"):
            # AutoDoc writes doc/main.xml, doc/title.xml and doc/_*.xml itself
            # and would overwrite the chapter without saying so.
            stem = f"{book}_{stem}"
            notes.add("chapter renamed to keep clear of AutoDoc's scaffold",
                      f"{src} -> {stem}.xml")
        stems[src] = stem
        conv = Converter(six, notes, book, entities, decls)
        pieces[stem + ".xml"] = conv.convert_file(os.path.join(doc, src))

    pieces = drop_colliding_section_labels(pieces, notes)
    report_duplicate_labels(pieces, notes)

    written: list[str] = []
    for src in sources:
        stem = stems[src]
        xml = pieces[stem + ".xml"]
        ok = validate(xml, stem + ".xml", notes)
        with open(os.path.join(out, stem + ".xml"), "w", encoding="utf8") as fh:
            fh.write(xml)
        written.append(stem + ".xml")
        print(f"  {src:24s} -> {stem + '.xml':24s} {'ok' if ok else 'MALFORMED XML'}")

    # makedoc.g
    pkgname = info["package"] or os.path.basename(pkgdir)
    includes = ",\n".join(f'            "{w}"' for w in written)
    bibs = [f for f in os.listdir(doc) if f.endswith(".bib")]
    bibline = f'        bib := "{bibs[0]}",\n' if bibs else ""
    if not bibs:
        cited = sorted({m.group(1) for w in written
                        for m in re.finditer(r'<Cite Key="([^"]*)"',
                                             open(os.path.join(out, w),
                                                  encoding="utf8").read())})
        if cited:
            # GAPDoc aborts with an unassigned "bibentries" record element when
            # a document cites anything and no bibliography is configured.
            notes.add("citations but no .bib file",
                      f"{', '.join(cited)} -- the build will fail until a "
                      f"bibliography exists; doc/manual.bbl may hold the entries")
    for b in bibs:
        n_fixed = clean_bib(os.path.join(doc, b), notes)
        if n_fixed:
            print(f"  {b}: replaced {n_fixed} TeX accent(s) with Unicode")

    entlines = ""
    if entities:
        rows = []
        for k, v in sorted(entities.items()):
            if v.startswith("<"):          # already XML (from \Package{...})
                clean = v
            else:                          # strip TeX font macros from a \def
                clean = re.sub(r"\\[A-Za-z]+\s*", "", v).strip().strip("{}") or k
            rows.append(f'            {k} := "{clean}",')
        entlines = "        entities := rec(\n" + "\n".join(rows) + "\n        ),\n"

    makedoc = os.path.join(pkgdir if outdir is None else out, "makedoc.g")
    with open(makedoc, "w", encoding="utf8") as fh:
        fh.write(MAKEDOC_TEMPLATE.format(includes=includes,
                                         entities=entlines, bibline=bibline))
    print(f"  wrote {os.path.relpath(makedoc, pkgdir)}"
          + (f" ({len(entities)} entities)" if entities else ""))
    return 0


def survey(pkgdirs: Iterable[str]) -> int:
    """Convert everything in memory and report what still needs work."""
    total = Notes()
    gapbooks = find_gap_books()
    for pkgdir in pkgdirs:
        doc = os.path.join(pkgdir, "doc")
        if not os.path.isdir(doc):
            continue
        notes = Notes()
        info = parse_manual_tex(os.path.join(doc, "manual.tex"))
        book = info["book"] or os.path.basename(pkgdir).lower()
        six = SixIndex()
        six.load(book, os.path.join(doc, "manual.six"))
        for other, path in gapbooks:
            six.load(other, path)
        decls = DeclIndex()
        decls.scan(pkgdir)
        sources, _skipped = select_sources(doc, info, notes)
        if not sources:
            notes.add("no documentation sources found", doc)
        entities = {k for k in harvest_macros(doc, ["manual.tex"] + sources)
                    if k not in ENTITY_MACROS}
        bad = 0
        pieces: dict[str, str] = {}
        for src in sources:
            conv = Converter(six, notes, book, entities, decls)
            try:
                xml = conv.convert_file(os.path.join(doc, src))
            except Exception as exc:  # noqa: BLE001 - survey must not abort
                notes.add("converter crash", f"{src}: {exc}")
                bad += 1
                continue
            pieces[src] = xml
            if not validate(xml, src, notes):
                bad += 1
        pieces = drop_colliding_section_labels(pieces, notes)
        report_duplicate_labels(pieces, notes)
        for k, v in notes.counts.items():
            total.counts[k] = total.counts.get(k, 0) + v
        flag = f"  {bad} malformed" if bad else ""
        print(f"{os.path.basename(pkgdir):18s} {sum(notes.counts.values()):5d} notes{flag}")
    print("\n=== aggregate ===")
    for k, v in sorted(total.counts.items(), key=lambda kv: -kv[1]):
        print(f"{v:6d}  {k}")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pkgdir", nargs="+", help="package directory (containing doc/)")
    ap.add_argument("-o", "--outdir", help="write XML here instead of into doc/")
    ap.add_argument("--survey", action="store_true",
                    help="do not write anything; report unhandled constructs")
    args = ap.parse_args(argv)

    if args.survey:
        return survey(args.pkgdir)

    if len(args.pkgdir) != 1:
        print("error: give exactly one package (or use --survey)", file=sys.stderr)
        return 2

    notes = Notes()
    rc = convert_package(args.pkgdir[0], args.outdir, notes)
    if notes.counts:
        print("\n=== needs human review ===")
        for k, v in sorted(notes.counts.items(), key=lambda kv: -kv[1]):
            print(f"{v:6d}  {k}")
        print("\nfirst occurrences:")
        for item in notes.items[:40]:
            print("  " + item)
    return rc


if __name__ == "__main__":
    sys.exit(main())
