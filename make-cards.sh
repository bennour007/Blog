#!/usr/bin/env bash
# make-cards.sh: builds projects/projects.yml (one card per project) from the old headers.
# Run from the site folder:   bash make-cards.sh
set -euo pipefail
out=projects/projects.yml
: > "$out"

for dir in projects/*/; do
  dir=${dir%/}; slug=$(basename "$dir")
  case "$slug" in internal-project|index_files|_*) continue ;; esac

  # header source: first old file that starts with a --- header
  src=""
  for f in index.Rmd index.Rmarkdown index.md index.html; do
    if [ -f "$dir/$f" ] && head -c 3 "$dir/$f" | grep -q -- '---'; then src="$dir/$f"; break; fi
  done
  [ -z "$src" ] && { echo "!! $slug: no header found, card added with folder name only" >&2; src=/dev/null; }

  # thumbnail
  img=""
  for ext in jpg jpeg png webp gif JPG PNG; do
    [ -f "$dir/featured.$ext" ] && { img="$slug/featured.$ext"; break; }
  done

  # where the card links to
  if [ -f "$dir/index.html" ]; then path="$slug/index.html"
  else path="$slug/"; echo "!! $slug: no index.html, card links to the folder" >&2; fi

  awk -v slug="$slug" -v img="$img" -v path="$path" -v sq="'" '
    function clean(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); gsub("^[\"" sq "]|[\"" sq "]$", "", s); return s }
    function q(s)     { gsub(/"/, "\\\"", s); return "\"" s "\"" }
    function addcats(s,   n, a, i, c) {
      gsub(/[\[\]]/, "", s); n = split(s, a, ",")
      for (i = 1; i <= n; i++) { c = clean(a[i]); if (c != "" && !(c in seen)) { seen[c] = 1; cats[++nc] = c } }
    }
    /^---[ \t]*$/ { fences++; if (fences == 2) exit; next }
    fences == 1 {
      if ($0 ~ /^[A-Za-z_]+:/) {                         # a new key
        key = $0; sub(/:.*/, "", key)
        val = $0; sub(/^[A-Za-z_]+:[ \t]*/, "", val)
        if (key == "title")   title = clean(val)
        if (key == "summary") summary = clean(val)
        if (key == "date")    date = substr(clean(val), 1, 10)
        if (key == "external_link") ext = clean(val)
        if (key == "tags" || key == "categories") { inlist = 1; addcats(val) } else inlist = 0
      } else if (inlist && $0 ~ /^[ \t]*-[ \t]/) {       # list item under tags:/categories:
        item = $0; sub(/^[ \t]*-[ \t]*/, "", item); addcats(item)
      }
    }
    END {
      if (title == "") title = slug
      print "- title: " q(title)
      if (summary != "") print "  description: " q(summary)
      if (date != "")    print "  date: " date
      if (img != "")     print "  image: " img
      print "  path: " (ext != "" ? ext : path)
      if (nc > 0) { line = "  categories: ["; for (i = 1; i <= nc; i++) line = line (i > 1 ? ", " : "") q(cats[i]); print line "]" }
      print ""
    }
  ' "$src" >> "$out"
  echo "card   $slug"
done

echo; echo "Wrote $out"
