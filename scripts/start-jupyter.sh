#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NOTEBOOK_DIR="${WORKSPACE_DIR}/repos/jdaviz/notebooks"
LOG_DIR="${WORKSPACE_DIR}/.logs"
export JUPYTER_CONFIG_DIR="${WORKSPACE_DIR}/.jupyter"

mkdir -p "${LOG_DIR}"

if [ -f "${LOG_DIR}/jupyter.pid" ]; then
    JUPYTER_PID="$(cat "${LOG_DIR}/jupyter.pid")"

    if [ -n "${JUPYTER_PID}" ] \
        && kill -0 "${JUPYTER_PID}" 2>/dev/null \
        && ps -p "${JUPYTER_PID}" -o command= | grep -q "jupyter-lab"; then
        echo "Jupyter Lab is already running at http://localhost:8888"
        exit 0
    fi

    rm -f "${LOG_DIR}/jupyter.pid"
fi

cd "${WORKSPACE_DIR}"
nohup uv run --project "${WORKSPACE_DIR}/env" jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --ServerApp.root_dir="${NOTEBOOK_DIR}" \
    --ServerApp.token='' \
    --ServerApp.password='' \
    > "${LOG_DIR}/jupyter.log" 2>&1 &

echo "$!" > "${LOG_DIR}/jupyter.pid"

echo "Jupyter Lab is starting"

for attempt in $(seq 1 120); do
    if curl -fsS "http://127.0.0.1:8888/api/status" >/dev/null 2>&1; then
        echo "Jupyter Lab is ready in the ports tab"
        exit 0
    fi

    if ! kill -0 "$(cat "${LOG_DIR}/jupyter.pid")" 2>/dev/null; then
        rm -f "${LOG_DIR}/jupyter.pid"
        echo "Jupyter Lab failed to start. See ${LOG_DIR}/jupyter.log"
        exit 1
    fi

    if [ "${attempt}" -eq 1 ] || [ $((attempt % 5)) -eq 0 ]; then
        echo "Still waiting for Jupyter Lab... (${attempt}s)"
    fi

    sleep 1
done

echo "Jupyter Lab is still starting after 120s. See ${LOG_DIR}/jupyter.log"
