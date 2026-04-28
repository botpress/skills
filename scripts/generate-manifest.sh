#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

entries='[]'
for f in commands/*.md; do
  name=$(awk '/^name:/{print $2; exit}' "$f")
  desc=$(sed -n 's/^description: *//p' "$f" | head -1 | sed 's/^["'"'"']//;s/["'"'"']$//')
  path="${f#commands/}"
  entries=$(echo "$entries" | jq --arg name "$name" --arg path "$path" --arg desc "$desc" \
    '. + [{name: $name, path: $path, description: $desc}]')
done

jq -n --argjson commands "$entries" '{commands: $commands}' > commands/manifest.json
echo "Generated commands/manifest.json with $(echo "$entries" | jq length) commands."
