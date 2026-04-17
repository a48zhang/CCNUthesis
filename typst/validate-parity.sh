#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LATEX_ENTRY="${1:-$ROOT_DIR/main.tex}"
TYPST_ENTRY="${2:-$ROOT_DIR/typst/main.typ}"
WORK_DIR="$(mktemp -d)"
KEEP_WORKDIR="${KEEP_WORKDIR:-0}"
REQUIRED_FONTS="${REQUIRED_FONTS:-Times New Roman,Arial,Courier New}"
LATEX_ENTRY_ABS="$(realpath "$LATEX_ENTRY")"
LATEX_DIR="$(dirname "$LATEX_ENTRY_ABS")"
LATEX_BASENAME="$(basename "$LATEX_ENTRY_ABS")"
LATEX_STEM="${LATEX_BASENAME%.tex}"

cleanup() {
  status=$?
  if [[ "$status" -ne 0 || "$KEEP_WORKDIR" == "1" ]]; then
    echo "preserved work directory: $WORK_DIR"
    return
  fi
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

LATEX_PDF="$WORK_DIR/latex.pdf"
TYPST_PDF="$WORK_DIR/typst.pdf"

echo "[0/4] preflight font check"
IFS=',' read -r -a FONT_LIST <<< "$REQUIRED_FONTS"
for font in "${FONT_LIST[@]}"; do
  font_name="$(echo "$font" | xargs)"
  if ! fc-list -q "$font_name"; then
    echo "missing required font: $font_name"
    echo "set REQUIRED_FONTS to match your local LaTeX font config before parity validation."
    exit 1
  fi
done

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

LATEX_PAGES="$(pdfinfo "$LATEX_PDF" | awk '/^Pages:/ {print $2}')"
TYPST_PAGES="$(pdfinfo "$TYPST_PDF" | awk '/^Pages:/ {print $2}')"

if [[ "$LATEX_PAGES" != "$TYPST_PAGES" ]]; then
  echo "page count mismatch: latex=$LATEX_PAGES typst=$TYPST_PAGES"
  exit 1
fi

echo "[4/4] pixel diff (exact, AE == 0)"
mapfile -t LATEX_IMAGES < <(find "$WORK_DIR" -name 'latex-*.png' | sort)
mapfile -t TYPST_IMAGES < <(find "$WORK_DIR" -name 'typst-*.png' | sort)

if [[ "${#LATEX_IMAGES[@]}" != "$LATEX_PAGES" || "${#TYPST_IMAGES[@]}" != "$TYPST_PAGES" ]]; then
  echo "rasterized page count mismatch"
  exit 1
fi

for ((i=0; i<LATEX_PAGES; i++)); do
  L="${LATEX_IMAGES[$i]}"
  T="${TYPST_IMAGES[$i]}"
  PAGE=$((i + 1))

  DIFF_PIXELS="$(compare -metric AE "$L" "$T" null: 2>&1 || true)"
  if [[ "$DIFF_PIXELS" != "0" ]]; then
    echo "page $PAGE mismatch: AE=$DIFF_PIXELS"
    exit 1
  fi
done

echo "pixel parity check passed for all $LATEX_PAGES pages."
