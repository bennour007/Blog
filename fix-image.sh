#!/usr/bin/env bash
# fix-image.sh: replaces Hugo's `image:` block with Quarto's `image:` + `image-alt:`.
# Run from the site folder:   bash fix-image.sh
# Only touches the header (between the first two --- lines). Safe to run twice.

for f in blog/*/index.qmd project/*/index.qmd; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")

  # find the featured image, if there is one
  img=""
  for ext in jpg jpeg png webp gif; do
    if [ -f "$dir/featured.$ext" ]; then img="featured.$ext"; break; fi
  done

  # only process files that still have the old block or an empty image: line
  awk 'BEGIN { found = 0 }
       /^---[[:space:]]*$/ { n++; if (n == 2) exit }
       n == 1 && /^image:[[:space:]]*$/ { found = 1; exit }
       END { exit !found }' "$f" || continue

  awk -v img="$img" '
    BEGIN { fences = 0; inblock = 0 }
    {
      if ($0 ~ /^---[[:space:]]*$/) fences++

      # inside the header, on the old "image:" line: start skipping its block
      if (fences == 1 && $0 ~ /^image:[[:space:]]*$/) { inblock = 1; caption = ""; next }

      if (inblock) {
        if ($0 ~ /^[[:space:]]+/) {                       # indented line = part of the block
          if ($0 ~ /^[[:space:]]+caption:/) {
            caption = $0
            sub(/^[[:space:]]+caption:[[:space:]]*/, "", caption)
          }
          next
        }
        # block finished: write the new lines
        if (img != "") print "image: " img
        if (caption != "" && caption != "\"\"" && caption != "'\'''\''") print "image-alt: " caption
        inblock = 0
      }
      print
    }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  echo "fixed  $f  ${img:-(no featured image found)}"
done
