#!/usr/bin/env bash
set -euo pipefail

find stable -name Chart.yaml -exec dirname {} \; | while IFS= read -r d; do
  if [ -f "$d/values.example.yaml" ]; then
    vf="values.example.yaml"
  else
    vf="values.yaml"
  fi
  helm-docs \
    --chart-search-root="$d" \
    --template-files=readme.md.gotmpl \
    --template-files=../_templates.gotmpl \
    --output-file=readme.md \
    --values-file="$vf"
done
