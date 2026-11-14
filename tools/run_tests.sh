#!/usr/bin/env bash
# Validation pipeline: import -> headless test suite -> headless boot of the real main scene.
# Usage:  GODOT_BIN=/path/to/Godot_v4.7.2-stable_win64_console.exe tools/run_tests.sh [--filter=name]
# Exit code is non-zero if any step fails or any engine/script error is logged.
set -uo pipefail

GODOT="${GODOT_BIN:-godot}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/.godot/test_logs"
mkdir -p "$LOG_DIR"

if ! command -v "$GODOT" >/dev/null 2>&1 && [ ! -x "$GODOT" ]; then
  echo "Godot not found. Set GODOT_BIN to the Godot 4.7.2 console executable." >&2
  exit 2
fi

ERROR_PATTERN='SCRIPT ERROR|^ERROR:|Parse Error|Failed to load|Cannot open file'
status=0

step() {  # step <name> <log> <command...>
  local name="$1" log="$2"; shift 2
  echo "== $name"
  "$@" >"$log" 2>&1
  local code=$?
  if [ $code -ne 0 ]; then
    echo "   exit code $code"; status=1
  fi
  if grep -En "$ERROR_PATTERN" "$log" >/dev/null; then
    echo "   engine errors:"; grep -En "$ERROR_PATTERN" "$log" | head -20; status=1
  fi
}

# Warm-up import: on a fresh checkout, or right after new assets are added, the editor loads the
# project theme and autoloads before it has imported the files they reference, which logs
# load-order errors once. The second, strict import must then be completely clean.
echo "== warm-up import"
"$GODOT" --headless --path "$ROOT" --import >"$LOG_DIR/warmup_import.log" 2>&1
step "import (strict)" "$LOG_DIR/import.log" "$GODOT" --headless --path "$ROOT" --import
step "tests" "$LOG_DIR/tests.log" "$GODOT" --headless --path "$ROOT" res://tests/test_runner.tscn -- "$@"
grep -E "^(PASS|FAIL|      - |[0-9]+ passed)" "$LOG_DIR/tests.log"
step "boot main scene (300 frames)" "$LOG_DIR/boot.log" "$GODOT" --headless --path "$ROOT" --quit-after 300

if [ $status -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "CHECKS FAILED (logs in .godot/test_logs)"; fi
exit $status
