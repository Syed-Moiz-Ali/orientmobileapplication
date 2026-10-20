#!/usr/bin/env bash
# Repo-wide analyzer. melos is broken in this env (no scripts in root
# pubspec / 0 packages discovered), so every session uses this script until
# melos is fixed separately. Non-zero exit if any package fails.
# Usage (Windows): & "C:\Program Files\Git\bin\bash.exe" tool/analyze_all.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKGS=(
  packages/shared_core
  packages/shared_auth
  packages/shared_models
  apps/staff_app
  apps/owner_app
  apps/customer_app
  apps/crm_app
)
fail=0
for p in "${PKGS[@]}"; do
  echo "===== $p ====="
  (cd "$ROOT/$p" && flutter analyze --no-pub)
  code=$?
  if [ "$code" -eq 0 ]; then
    echo "PASS: $p"
  else
    echo "FAIL: $p (exit $code)"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "ALL GREEN"
else
  echo "ANALYZE FAILED"
fi
exit "$fail"
