#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

uv --project "${WORKSPACE_DIR}/env" lock --refresh
uv --project "${WORKSPACE_DIR}/env" sync --reinstall
