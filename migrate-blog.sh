#!/usr/bin/env bash
# Copies Hugo blog posts from _archive into blog/, keeping each post's resources.
set -euo pipefail
SRC=_archive/content/blog
DEST=blog

for dir in "$SRC"/*/; do
  slug=$(basename "$dir")
  out="$DEST/$slug"

  # don't overwrite a post you've already migrated and fixed
  if [ -e "$out" ]; then echo "skip   $slug (already exists)"; continue; fi

  # pick the source file
  src=""
  for f in index.Rmarkdown index.Rmd index.md; do
    if [ -f "$dir$f" ]; then src=$f; break; fi
  done
  if [ -z "$src" ]; then echo "!!     $slug: no source file, check by hand"; continue; fi

  # copy everything except Hugo's generated files and the old source names
  mkdir -p "$out"
  rsync -a \
    --exclude 'index.html' --exclude 'index.markdown' --exclude 'index_files/' \
    --exclude 'index.Rmarkdown' --exclude 'index.Rmd' --exclude 'index.md' \
    "$dir" "$out/"

  # the source becomes index.qmd
  cp "$dir$src" "$out/index.qmd"
  echo "copied $slug  <- $src"
done
