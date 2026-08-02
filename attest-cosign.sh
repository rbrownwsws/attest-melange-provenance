#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "${STATEMENT_FILE:-}" ]]; then
  echo "::error::statement-file does not exist at ${STATEMENT_FILE}"
  exit 1
fi

BUNDLE_PATH=$(mktemp --tmpdir="${RUNNER_TEMP}" --suffix='.provenance.json')

cosign attest-blob \
  --oidc-provider github-actions \
  --statement "${STATEMENT_FILE}" \
  --bundle "${BUNDLE_PATH}"

echo "bundle-path=${BUNDLE_PATH}" >> "${GITHUB_OUTPUT}"
