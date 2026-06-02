#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${WORKSPACE_DIR}"
mkdir -p ./repos/

if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
fi

JDAVIZ_REPO_URL="${JDAVIZ_REPO_URL:-https://github.com/mariobuikhuizen/jdaviz.git}"
JDAVIZ_REPO_BRANCH="${JDAVIZ_REPO_BRANCH:-vue3}"

if [ ! -d ./repos/jdaviz/.git ]; then
    (cd repos && git clone --depth 1 --branch "${JDAVIZ_REPO_BRANCH}" "${JDAVIZ_REPO_URL}")
else
    echo "Refreshing repos/jdaviz from ${JDAVIZ_REPO_BRANCH}"
    git -C ./repos/jdaviz remote set-url origin "${JDAVIZ_REPO_URL}"
    git -C ./repos/jdaviz fetch --depth 1 origin "${JDAVIZ_REPO_BRANCH}"
    git -C ./repos/jdaviz checkout -B "${JDAVIZ_REPO_BRANCH}" FETCH_HEAD
    git -C ./repos/jdaviz reset --hard FETCH_HEAD
fi

uv --project "${WORKSPACE_DIR}/env" lock \
    --refresh-package glue-jupyter \
    --refresh-package ipypopout \
    --refresh-package ipyvuetify \
    --refresh-package solara \
    --refresh-package solara-server \
    --refresh-package solara-ui
uv --project "${WORKSPACE_DIR}/env" sync --locked
