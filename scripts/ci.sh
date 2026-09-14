#!/usr/bin/env bash

set -Eeuo pipefail

SCRATCH_ALIAS="ci-${BUILD_BUILDID:-local}-$$"

mkdir -p test-results

cleanup() {
    echo "=================================================="
    echo "Deleting Scratch Org: ${SCRATCH_ALIAS}"
    echo "=================================================="

    sf org delete scratch \
        --target-org "${SCRATCH_ALIAS}" \
        --no-prompt || true
}

trap cleanup EXIT
# Add 2 export variables############

echo "=================================================="
echo "Creating Scratch Org"
echo "=================================================="

sf org create scratch \
    --target-dev-hub DevHub \
    --definition-file config/project-scratch-def.json \
    --alias "${SCRATCH_ALIAS}" \
    --duration-days 1 \
    --wait 20 \
    --set-default

echo "=================================================="
echo "Scratch Org Created"
echo "=================================================="

sf org display \
    --target-org "${SCRATCH_ALIAS}"

echo "=================================================="
echo "Deploying Salesforce Metadata"
echo "=================================================="

sf project deploy start \
    --target-org "${SCRATCH_ALIAS}" \
    --source-dir force-app \
    --wait 30 \
    --verbose

echo "=================================================="
echo "Assigning Permission Set"
echo "=================================================="

sf org assign permset \
    --target-org "${SCRATCH_ALIAS}" \
    --name Account_Health_User || true

echo "=================================================="
echo "Running Apex Tests"
echo "=================================================="

sf apex run test \
    --target-org "${SCRATCH_ALIAS}" \
    --test-level RunLocalTests \
    --code-coverage \
    --result-format junit \
    --output-dir test-results \
    --wait 30

echo "=================================================="
echo "Generating Coverage Report"
echo "=================================================="

sf apex get test \
    --target-org "${SCRATCH_ALIAS}" \
    --code-coverage || true

echo "=================================================="
echo "Scratch Org Validation Successful"
echo "=================================================="
