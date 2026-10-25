#!/usr/bin/env bash
# Fails if the busted launcher drops any test file after the first
set -euo pipefail

out=$("$1" --output=TAP)
echo "$out"
grep -q '^1\.\.2$' <<<"$out"
