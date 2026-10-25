#!/usr/bin/env bash
# Runs the binary from a working directory outside the runfiles tree, as a direct bazel-bin/ run does,
# once with a runfiles tree and once with only a manifest (which one Bazel makes depends on the platform)
set -euo pipefail

bin="$PWD/$1"
# The test sandbox has no runfiles manifest, so build one from the runfiles tree
find -L "$RUNFILES_DIR" -mindepth 1 -printf '%P %p\n' >"$TEST_TMPDIR/MANIFEST"
cd "$TEST_TMPDIR"

out=$("$bin")
echo "runfiles tree: $out"
[[ "$out" == 4 ]]

out=$(env -u RUNFILES_DIR RUNFILES_MANIFEST_FILE="$TEST_TMPDIR/MANIFEST" "$bin")
echo "manifest only: $out"
[[ "$out" == 4 ]]
