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
  out=$(cd "$ROOT/$p" && flutter test --exclude-tags baseline 2>&1)
  code=$?
  echo "$out" | tail -n 3
  if [ "$code" -eq 0 ]; then
    echo "PASS: $p"
  elif echo "$out" | grep -qE "No tests ran|does not appear to contain any test files|Test directory .test. not found"; then
    echo "SKIP: $p (no non-baseline tests yet — counts as pass)"
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
