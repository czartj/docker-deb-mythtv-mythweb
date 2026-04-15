#!/bin/sh
set -eu
FILE="${1:-/etc/mythtv/mythweb.conf}"
BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"
if [ ! -f "$FILE" ]; then
  printf 'File not found: %s\n' "$FILE" >&2
  exit 2
fi
cp -- "$FILE" "$BACKUP"
awk '
BEGIN {
  start = "<Directory \"/usr/share/mythtv/mythweb\""
  in_block = 0
  have_10 = have_172 = have_192 = have_fc = 0
  aliasDest = ""
  after_alias = 0
}
{
  line = $0

  # ------------------------------------------------------------------
  # Detect "Alias /mythweb …" and remember the path
  # ------------------------------------------------------------------
  if (line ~ /^[[:space:]]*Alias[[:space:]]+\/mythweb[[:space:]]+(.+)/) {
    aliasDest = $NF                # last field = filesystem path
    print line                     # print the Alias line
    after_alias = 1                # we will need to insert DocumentRoot after it
    next
  }

  # ------------------------------------------------------------------
  # The line immediately after the Alias – add DocumentRoot if missing
  # ------------------------------------------------------------------
  if (after_alias == 1) {
    after_alias = 0
    # Only insert if the current line is NOT already a DocumentRoot line
    if (line !~ /^[[:space:]]*DocumentRoot[[:space:]]+/) {
      print "  DocumentRoot " aliasDest
    }
    # Continue processing this line normally (do not skip)
  }

  # ------------------------------------------------------------------
  # Handle the <Directory> block (same as before, no DocumentRoot here)
  # ------------------------------------------------------------------
  if (in_block == 0 && index(line, start) > 0) {
    in_block = 1
    print line
    next
  }
  if (in_block == 1) {
    if (line ~ /<\/Directory>/) {
      if (!have_10) print "  Require ip 10.0.0.0/8"
      if (!have_172) print "  Require ip 172.16.0.0/12"
      if (!have_192) print "  Require ip 192.168.0.0/16"
      if (!have_fc) print "  Require ip fc00::/7"
      print line
      in_block = 0
      next
    }
    if (line ~ /^[[:space:]]*Require[[:space:]]+local[[:space:]]*$/) {
      print "#" line
      next
    }
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+10\.0\.0\.0\/8[[:space:]]*$/) have_10 = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+172\.16\.0\.0\/12[[:space:]]*$/) have_172 = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+192\.168\.0\.0\/16[[:space:]]*$/) have_192 = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+fc00::\/7[[:space:]]*$/) have_fc = 1
    print line
    next
  }

  # ------------------------------------------------------------------
  # Any other line – print as‑is
  # ------------------------------------------------------------------
  print line
}
END {
  # If the Alias line was the last line, we still need the DocumentRoot
  if (after_alias == 1) {
    print "  DocumentRoot " aliasDest
  }
  # Close the block if the file ended inside it
  if (in_block == 1) {
    if (!have_10) print "  Require ip 10.0.0.0/8"
    if (!have_172) print "  Require ip 172.16.0.0/12"
    if (!have_192) print "  Require ip 192.168.0.0/16"
    if (!have_fc) print "  Require ip fc00::/7"
  }
}
' "$BACKUP" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
printf 'Modified %s (backup: %s)\n' "$FILE" "$BACKUP"

