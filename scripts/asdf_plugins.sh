#!/usr/bin/env bash

plugins=(
  "github-cli"
  "elixir"
  "erlang"
  "postgres"
)

echo "Installing plugins..."

for plugin in "${plugins[@]}"; do
  asdf plugin add "$plugin" || true
done

echo "Installation complete."
echo "Restart your terminal or sourcer your profile."
