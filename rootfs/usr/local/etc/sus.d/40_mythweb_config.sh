#!/bin/sh
set -eu

# Target file (default) and timestamped backup
FILE="${1:-/etc/mythtv/mythweb.conf}"
BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"

# Ensure the file exists
if [ ! -f "$FILE" ]; then
  printf 'File not found: %s\n' "$FILE" >&2
  exit 2
fi

# Make a backup before any changes
cp -- "$FILE" "$BACKUP"

awk '
BEGIN {
  # The <Directory> block we care about
  start = "<Directory \"/usr/share/mythtv/mythweb\""
  in_block = 0

  # Flags for each required IP range
  have_10 = have_172 = have_192 = have_fc = 0
  have_loop4 = have_loop6 = 0   # ← new flags for loopback
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

  # Detect the opening <Directory> line
  if (in_block == 0 && index(line, start) > 0) {
    in_block = 1
    print line
    next
  }

  # Inside the target block
  if (in_block == 1) {
    # Closing tag – insert any missing Require ip lines before it
    if (line ~ /<\/Directory>/) {
      if (!have_10)   print "  Require ip 10.0.0.0/8"
      if (!have_172)  print "  Require ip 172.16.0.0/12"
      if (!have_192)  print "  Require ip 192.168.0.0/16"
      if (!have_fc)   print "  Require ip fc00::/7"
      if (!have_loop4) print "  Require ip 127.0.0.0/8"   # ← loopback IPv4
      if (!have_loop6) print "  Require ip ::1"            # ← loopback IPv6
      print line
      in_block = 0
      next
    }

    # Comment out generic “Require local”
    if (line ~ /^[[:space:]]*Require[[:space:]]+local[[:space:]]*$/) {
      print "#" line
      next
    }

    # Detect existing Require ip lines and set flags
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+10\.0\.0\.0\/8[[:space:]]*$/)   have_10   = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+172\.16\.0\.0\/12[[:space:]]*$/) have_172  = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+192\.168\.0\.0\/16[[:space:]]*$/) have_192  = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+fc00::\/7[[:space:]]*$/)       have_fc   = 1
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+127\.0\.0\.0\/8[[:space:]]*$/) have_loop4 = 1   # ← loopback IPv4
    if (line ~ /^[[:space:]]*Require[[:space:]]+ip[[:space:]]+::1[[:space:]]*$/)          have_loop6 = 1   # ← loopback IPv6

    print line
    next
  }

  # Outside the block – copy unchanged
  print line
}
END {
  # If the file ended while still inside the block, still add missing lines
  if (in_block == 1) {
    if (!have_10)   print "  Require ip 10.0.0.0/8"
    if (!have_172)  print "  Require ip 172.16.0.0/12"
    if (!have_192)  print "  Require ip 192.168.0.0/16"
    if (!have_fc)   print "  Require ip fc00::/7"
    if (!have_loop4) print "  Require ip 127.0.0.0/8"
    if (!have_loop6) print "  Require ip ::1"
  }
}
' "$BACKUP" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

printf 'Modified %s (backup: %s)\n' "$FILE" "$BACKUP"

