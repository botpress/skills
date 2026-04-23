#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

manifest='{ "generatedAt": "'$(date -u +%Y-%m-%d)'", "commands": ['
first=true
for f in commands/*.md; do
  name=$(awk '/^name:/{print $2; exit}' "$f")
  desc=$(awk -F': ' '/^description:/{print $2; exit}' "$f" | sed 's/^["'"'"']//;s/["'"'"']$//')
  if [ "$first" = true ]; then first=false; else manifest="$manifest,"; fi
  manifest="$manifest"$'\n    { "name": "'"$name"'", "path": "'"$f"'", "description": "'"$desc"'" }'
done
manifest="$manifest"$'\n  ]\n}\n'

echo "$manifest" > commands/manifest.json
echo "Generated commands/manifest.json with $(echo "$manifest" | grep -c '"name"') commands."
