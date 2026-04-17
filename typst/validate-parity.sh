#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LATEX_ENTRY="${1:-$ROOT_DIR/main.tex}"
TYPST_ENTRY="${2:-$ROOT_DIR/typst/main.typ}"
WORK_DIR="$(mktemp -d /tmp/ccnu-parity-XXXXXX)"
LATEX_ENTRY_ABS="$(realpath "$LATEX_ENTRY")"
LATEX_DIR="$(dirname "$LATEX_ENTRY_ABS")"
LATEX_BASENAME="$(basename "$LATEX_ENTRY_ABS")"
LATEX_STEM="${LATEX_BASENAME%.tex}"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

LATEX_PDF="$WORK_DIR/latex.pdf"
TYPST_PDF="$WORK_DIR/typst.pdf"

echo "[1/4] compile LaTeX: $LATEX_ENTRY"
(
  cd "$LATEX_DIR"
  latexmk -C >/dev/null 2>&1 || true
  latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error "$LATEX_BASENAME" >/dev/null
)
cp "$LATEX_DIR/$LATEX_STEM.pdf" "$LATEX_PDF"

echo "[2/4] compile Typst: $TYPST_ENTRY"
typst compile "$TYPST_ENTRY" "$TYPST_PDF" >/dev/null

echo "[3/4] rasterize pdf pages"
pdftoppm -r 200 -png "$LATEX_PDF" "$WORK_DIR/latex"
pdftoppm -r 200 -png "$TYPST_PDF" "$WORK_DIR/typst"

LATEX_PAGES=$(find "$WORK_DIR" -name 'latex-*.png' | wc -l | tr -d ' ')
TYPST_PAGES=$(find "$WORK_DIR" -name 'typst-*.png' | wc -l | tr -d ' ')

if [[ "$LATEX_PAGES" != "$TYPST_PAGES" ]]; then
  echo "page count mismatch: latex=$LATEX_PAGES typst=$TYPST_PAGES"
  exit 1
fi

echo "[4/4] pixel diff (exact, AE == 0)"
for ((i=1; i<=LATEX_PAGES; i++)); do
  PAGE="$(printf "%02d" "$i")"
  L="$WORK_DIR/latex-$PAGE.png"
  T="$WORK_DIR/typst-$PAGE.png"
  if [[ ! -f "$L" || ! -f "$T" ]]; then
    echo "missing rasterized page: $PAGE"
    exit 1
  fi

  DIFF_PIXELS="$(compare -metric AE "$L" "$T" null: 2>&1 || true)"
  if [[ "$DIFF_PIXELS" != "0" ]]; then
    echo "page $i mismatch: AE=$DIFF_PIXELS"
    exit 1
  fi
done

echo "pixel parity check passed for all $LATEX_PAGES pages."
