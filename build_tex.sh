#!/usr/bin/env bash
# Build main.tex
# - Aux/log/minted/bbl live in out/
# - Final PDF is written to out/ and copied to the project root on success
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

TEX="main.tex"
JOB="main"
OUT_PDF="out/${JOB}.pdf"
ROOT_PDF="${JOB}.pdf"

# minted / custom ptjulia lexer
export PATH="${ROOT}/.venv-minted/bin:${PATH}"

if [[ ! -f "$TEX" ]]; then
  echo "error: missing $TEX" >&2
  exit 1
fi

if ! command -v pygmentize >/dev/null 2>&1; then
  echo "error: pygmentize not found (expected in .venv-minted/bin)" >&2
  echo "       create it with: python3 -m venv .venv-minted && .venv-minted/bin/pip install Pygments && .venv-minted/bin/pip install -e ./ptjulia_pygments" >&2
  exit 1
fi

mkdir -p out/minted

run_pdflatex() {
  pdflatex -shell-escape -interaction=nonstopmode -output-directory=out "$TEX"
}

echo "==> pdflatex (1/3, shell-escape)"
run_pdflatex

echo "==> bibtex"
(
  cd out
  BIBINPUTS=..: BSTINPUTS=..: bibtex "$JOB"
)

echo "==> pdflatex (2/3)"
run_pdflatex

echo "==> pdflatex (3/3)"
run_pdflatex

if [[ ! -f "$OUT_PDF" ]]; then
  echo "error: compile finished but $OUT_PDF was not produced" >&2
  exit 1
fi

cp -f "$OUT_PDF" "$ROOT_PDF"
echo "==> wrote ${OUT_PDF}"
echo "==> copied ${ROOT_PDF}"
