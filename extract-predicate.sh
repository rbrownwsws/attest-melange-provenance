#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "${STATEMENT_FILE:-}" ]]; then
  echo "::error::statement-file does not exist at ${STATEMENT_FILE}"
  exit 1
fi

IN_TOTO_JSON=$(cat "${STATEMENT_FILE}")

SUBJECT_COUNT=$(jq -r '.subject | if type == "array" then length else error("not an array") end' <<<"${IN_TOTO_JSON}")
if (( SUBJECT_COUNT != 1 )); then
  echo "::error::Unexpected number of attestation subjects: ${SUBJECT_COUNT}"
  exit 1
fi

SUBJECT_JSON=$(jq '.subject[0]' <<<"${IN_TOTO_JSON}")
SUBJECT_NAME=$(jq -r '.name' <<<"${SUBJECT_JSON}")
SUBJECT_DIGEST=$(jq -r '.digest.sha256' <<<"${SUBJECT_JSON}")

PREDICATE_TYPE=$(jq -r '.predicate_type' <<<"${IN_TOTO_JSON}")
if [[ "${PREDICATE_TYPE}" != 'https://slsa.dev/provenance/v1' ]]; then
  echo "::error::Unexpected predicate type: ${PREDICATE_TYPE}"
  exit 1
fi

PREDICATE=$(jq '.predicate' <<<"${IN_TOTO_JSON}")
PREDICATE_FILE=$(mktemp --tmpdir="${RUNNER_TEMP}" --suffix='.provenance.json')
printf '%s' "${PREDICATE}" > "${PREDICATE_FILE}"

echo "subject-name=${SUBJECT_NAME}" >> "${GITHUB_OUTPUT}"
echo "subject-digest=sha256:${SUBJECT_DIGEST}" >> "${GITHUB_OUTPUT}"
echo "predicate-file=${PREDICATE_FILE}" >> "${GITHUB_OUTPUT}"
