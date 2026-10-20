#!/usr/bin/env bash
# Repo-wide test run, excluding the throwaway baseline captures (tagged
# `baseline`; run those explicitly per app, see docs/ui-redesign/baseline/).
# Non-zero exit if any package fails.
# Usage (Windows): & "C:\Program Files\Git\bin\bash.exe" tool/test_all.sh
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
  (cd "$ROOT/$p" && flutter test --exclude-tags baseline)
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
  echo "TESTS FAILED"
fi
exit "$fail"
