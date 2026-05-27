#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(jq -r '."adk-version"' skills.json)

if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "Error: adk-version not found in skills.json"
  exit 1
fi

jq --arg v "$VERSION" '.version = $v' .claude-plugin/plugin.json > tmp.json && mv tmp.json .claude-plugin/plugin.json
jq --arg v "$VERSION" '.plugins[0].version = $v' .claude-plugin/marketplace.json > tmp.json && mv tmp.json .claude-plugin/marketplace.json

echo "Synced version $VERSION to plugin.json and marketplace.json"
