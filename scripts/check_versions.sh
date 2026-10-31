#!/usr/bin/env bash
# Print the latest published version and release date of npm and/or PyPI packages,
# so stack recommendations use current releases.
# Usage:
#   scripts/check_versions.sh @tanstack/react-start drizzle-orm pypi:fastapi
#   (bare names = npm; prefix pypi: for Python packages)
set -uo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 [npm:]<package> [pypi:<package>] ..." >&2
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    pypi:*)
      pkg="${arg#pypi:}"
      curl -fsS "https://pypi.org/pypi/${pkg}/json" 2>/dev/null | PKG="$pkg" python3 -c '
import json, os, sys
P = os.environ.get("PKG")
try:
    d = json.load(sys.stdin)
except Exception:
    print(f"pypi  {P}: not found / unreachable"); sys.exit()
v = d["info"]["version"]
files = d["releases"].get(v, [])
date = files[0]["upload_time"][:10] if files else "unknown"
print(f"pypi  {P}: {v} (released {date})")'
      ;;
    *)
      pkg="${arg#npm:}"
      curl -fsS "https://registry.npmjs.org/${pkg/\//%2F}" 2>/dev/null | PKG="$pkg" python3 -c '
import json, os, sys
P = os.environ.get("PKG")
try:
    d = json.load(sys.stdin)
except Exception:
    print(f"npm   {P}: not found / unreachable"); sys.exit()
v = d.get("dist-tags", {}).get("latest", "unknown")
date = d.get("time", {}).get(v, "unknown")[:10]
print(f"npm   {P}: {v} (released {date})")'
      ;;
  esac
done
