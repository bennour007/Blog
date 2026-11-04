#!/usr/bin/env bash
# wrap-projects.sh: gives every old project folder an index.qmd that shows the HTML
# blogdown already rendered, inside the new site (menu, theme, correct characters).
# Nothing is re-run, so no R packages are needed. Safe to run twice.
# Run from the site folder:   bash wrap-projects.sh
set -euo pipefail

for dir in projects/*/; do
  dir=${dir%/}; slug=$(basename "$dir")
  case "$slug" in internal-project|index_files|_*) continue ;; esac
  [ -f "$dir/index.qmd" ] && { echo "skip   $slug (already wrapped)"; continue; }
  [ -f "$dir/index.html" ] || { echo "!!     $slug: no index.html, needs a card by hand"; continue; }

  # 1. park the old files in _source/ (Quarto ignores folders starting with _)
  mkdir -p "$dir/_source"
  for f in index.html index.Rmd index.Rmarkdown index.md index.markdown; do
    [ -f "$dir/$f" ] && mv "$dir/$f" "$dir/_source/"
  done
  old="$dir/_source/index.html"

  # 2. rename the old support folder (figures, widgets) so Quarto never overwrites it
  [ -d "$dir/index_files" ] && mv "$dir/index_files" "$dir/old_files"

  # 3. thumbnail
  img=""
  for ext in jpg jpeg png webp gif JPG PNG; do
    [ -f "$dir/featured.$ext" ] && { img="featured.$ext"; break; }
  done

  # 4. the old header: take it from the first source file that has one
  src=/dev/null
  for f in index.Rmd index.Rmarkdown index.md index.html; do
    if [ -f "$dir/_source/$f" ] && head -c 3 "$dir/_source/$f" | grep -q -- '---'; then src="$dir/_source/$f"; break; fi
  done

  {
    # new Quarto header
    awk -v slug="$slug" -v img="$img" -v sq="'" '
      function clean(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); gsub("^[\"" sq "]|[\"" sq "]$", "", s); return s }
      function q(s)     { gsub(/"/, "\\\"", s); return "\"" s "\"" }
      function addcats(s,   n, a, i, c) {
        gsub(/[\[\]]/, "", s); n = split(s, a, ",")
        for (i = 1; i <= n; i++) { c = clean(a[i]); if (c != "" && !(c in seen)) { seen[c] = 1; cats[++nc] = c } }
      }
      /^---[ \t]*$/ { fences++; if (fences == 2) exit; next }
      fences == 1 {
        if ($0 ~ /^[A-Za-z_]+:/) {
          key = $0; sub(/:.*/, "", key)
          val = $0; sub(/^[A-Za-z_]+:[ \t]*/, "", val)
          if (key == "title")    title = clean(val)
          if (key == "subtitle") subtitle = clean(val)
          if (key == "summary")  summary = clean(val)
          if (key == "date")     date = substr(clean(val), 1, 10)
          if (key == "draft" && clean(val) ~ /^(true|yes)$/) draft = 1
          if (key == "tags" || key == "categories") { inlist = 1; addcats(val) } else inlist = 0
        } else if (inlist && $0 ~ /^[ \t]*-[ \t]/) {
          item = $0; sub(/^[ \t]*-[ \t]*/, "", item); addcats(item)
        }
      }
      END {
        if (title == "") title = slug
        print "---"
        print "title: " q(title)
        if (subtitle != "") print "subtitle: " q(subtitle)
        if (date != "")     print "date: " date
        if (summary != "")  print "description: " q(summary)
        if (img != "")      print "image: " img
        if (nc > 0) { line = "categories: ["; for (i = 1; i <= nc; i++) line = line (i > 1 ? ", " : "") q(cats[i]); print line "]" }
        if (draft)          print "draft: true"
        print "---"
        print ""
      }
    ' "$src"

    # the old page body
    if head -c 3 "$old" | grep -q -- '---'; then
      # blogdown fragment: drop its header, paste the HTML into the page
      echo '```{=html}'
      awk '/^---[ \t]*$/ && n < 2 { n++; next } n >= 2' "$old" | sed 's#index_files/#old_files/#g'
      echo '```'
    else
      # a complete standalone report: publish it as is and embed it
      sed 's#index_files/#old_files/#g' "$old" > "$dir/report.html"
      echo '[Open the full report ↗](report.html){target="_blank"}'
      echo
      echo '<iframe src="report.html" width="100%" height="800" style="border:1px solid #ddd"></iframe>'
    fi
  } > "$dir/index.qmd"

  echo "done   $slug"
done
