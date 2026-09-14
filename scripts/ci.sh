#!/usr/bin/env bash
set -Eeuo pipefail
SCRATCH_ALIAS="ci-${BUILD_BUILDID:-local}-$$"
mkdir -p test-results
cleanup() {
  echo "Cleaning up scratch org ${SCRATCH_ALIAS}"
  sf org delete scratch --target-org "${SCRATCH_ALIAS}" --no-prompt || true
}
trap cleanup EXIT

echo "Creating scratch org"
sf org create scratch --target-dev-hub DevHub --definition-file config/project-scratch-def.json --alias "${SCRATCH_ALIAS}" --duration-days 1 --wait 20 --set-default

echo "Deploying source"
sf project deploy start --target-org "${SCRATCH_ALIAS}" --source-dir force-app --wait 20

echo "Assigning permission set"
sf org assign permset --target-org "${SCRATCH_ALIAS}" --name Account_Health_User

echo "Running Apex tests"
sf apex run test --target-org "${SCRATCH_ALIAS}" --test-level RunLocalTests --code-coverage --wait 20 --result-format junit --output-dir test-results
