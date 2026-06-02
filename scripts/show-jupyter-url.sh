#!/usr/bin/env bash
set -euo pipefail

bash scripts/start-jupyter.sh

echo
echo "Jupyter Lab is available in the ports tab"

tail -f /dev/null
