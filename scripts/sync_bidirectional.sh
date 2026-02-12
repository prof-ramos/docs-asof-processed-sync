#!/usr/bin/env bash
set -euo pipefail

BRANCH="${BRANCH:-main}"

retry_cmd() {
  local attempts="$1"
  shift

  local n=1
  until "$@"; do
    if (( n >= attempts )); then
      echo "Command failed after ${attempts} attempts: $*"
      return 1
    fi
    local wait_time=$((2 ** n))
    echo "Attempt ${n}/${attempts} failed for: $*"
    echo "Retrying in ${wait_time}s..."
    sleep "${wait_time}"
    n=$((n + 1))
  done
}

echo "==> Fetching remotes..."
retry_cmd 5 git fetch --prune origin
retry_cmd 5 git fetch --prune hf

HAS_ORIGIN_BRANCH=0
if git show-ref --verify --quiet "refs/remotes/origin/${BRANCH}"; then
  HAS_ORIGIN_BRANCH=1
fi

HAS_HF_BRANCH=0
if git show-ref --verify --quiet "refs/remotes/hf/${BRANCH}"; then
  HAS_HF_BRANCH=1
fi

if (( HAS_ORIGIN_BRANCH == 0 && HAS_HF_BRANCH == 0 )); then
  echo "Neither origin/${BRANCH} nor hf/${BRANCH} exists. Cannot bootstrap."
  exit 1
fi

if (( HAS_ORIGIN_BRANCH == 0 && HAS_HF_BRANCH == 1 )); then
  echo "origin/${BRANCH} missing. Bootstrapping GitHub from hf/${BRANCH}..."
  retry_cmd 5 git push origin "refs/remotes/hf/${BRANCH}:refs/heads/${BRANCH}"
  retry_cmd 5 git fetch --prune origin
fi

if (( HAS_HF_BRANCH == 0 && HAS_ORIGIN_BRANCH == 1 )); then
  echo "hf/${BRANCH} missing. Bootstrapping Hugging Face from origin/${BRANCH}..."
  retry_cmd 5 git push hf "refs/remotes/origin/${BRANCH}:refs/heads/${BRANCH}"
  retry_cmd 5 git fetch --prune hf
fi

echo "==> Preparing working branch..."
git checkout -B "${BRANCH}" "origin/${BRANCH}"

ORIGIN_SHA="$(git rev-parse "origin/${BRANCH}")"
HF_SHA="$(git rev-parse "hf/${BRANCH}")"

echo "origin/${BRANCH}: ${ORIGIN_SHA}"
echo "hf/${BRANCH}:     ${HF_SHA}"

if [[ "${ORIGIN_SHA}" != "${HF_SHA}" ]]; then
  echo "==> Divergence detected. Attempting merge..."
  set +e
  git merge --no-ff --no-edit "hf/${BRANCH}"
  MERGE_RC=$?
  set -e
  if (( MERGE_RC != 0 )); then
    git merge --abort || true
    echo "Merge conflict detected between origin/${BRANCH} and hf/${BRANCH}."
    echo "Resolve manually and rerun workflow."
    exit 2
  fi
else
  echo "==> Branches already aligned. Nothing to merge."
fi

LOCAL_SHA="$(git rev-parse HEAD)"
echo "local HEAD:       ${LOCAL_SHA}"

if [[ "${LOCAL_SHA}" != "${ORIGIN_SHA}" ]]; then
  echo "==> Pushing updates to GitHub..."
  retry_cmd 5 git push origin "${BRANCH}:${BRANCH}"
else
  echo "==> GitHub already up to date."
fi

# Refresh hf reference in case another process updated it in the meantime
retry_cmd 5 git fetch --prune hf "${BRANCH}"
HF_SHA_NOW="$(git rev-parse "hf/${BRANCH}")"

if [[ "${LOCAL_SHA}" != "${HF_SHA_NOW}" ]]; then
  echo "==> Pushing updates to Hugging Face..."
  retry_cmd 5 git push hf "${BRANCH}:${BRANCH}"
else
  echo "==> Hugging Face already up to date."
fi

echo "==> Mirror sync completed successfully."
