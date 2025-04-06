#!/bin/bash
# Script to trigger, wait for, and check a GitHub Actions workflow run

set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <workflow-file> <branch>"
  exit 1
fi

WORKFLOW_FILE=$1
BRANCH=$2

# Trigger the workflow
echo "Triggering workflow: $WORKFLOW_FILE on branch $BRANCH..."
gh workflow run "$WORKFLOW_FILE" --ref "$BRANCH"

# Wait a moment for the run to appear
echo "Waiting for 10 seconds for the workflow run to start..."
sleep 10

# Get the ID of the latest run for this workflow
echo "Fetching the latest run ID..."
RUN_ID=$(gh run list --workflow="$WORKFLOW_FILE" --limit=1 --json databaseId -q .[0].databaseId)

if [ -z "$RUN_ID" ]; then
  echo "Error: Could not find the latest workflow run ID."
  exit 1
fi

echo "Monitoring run ID: $RUN_ID"
echo "Waiting for workflow run $RUN_ID to complete..."

while true; do
  STATUS=$(gh run view "$RUN_ID" --json status -q .status)

  if [[ "$STATUS" != "in_progress" && "$STATUS" != "queued" ]]; then
    echo "Workflow run $RUN_ID completed with status: $STATUS"
    break
  fi

  echo "Current status: $STATUS. Waiting..."
  sleep 15 # Check every 15 seconds
done

# Check the final conclusion
CONCLUSION=$(gh run view "$RUN_ID" --json conclusion -q .conclusion)
echo "Final conclusion: $CONCLUSION"

if [[ "$CONCLUSION" != "success" ]]; then
  echo "Workflow run failed. Fetching logs..."
  gh run view "$RUN_ID" --log
  exit 1
fi

echo "Workflow run completed successfully."
exit 0