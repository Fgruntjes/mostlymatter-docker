#!/bin/bash
# Script to wait for a GitHub Actions workflow run to complete

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <run-id>"
  exit 1
fi

RUN_ID=$1

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
  echo "Workflow run failed. Check logs for details:"
  echo "gh run view $RUN_ID --log"
  exit 1
fi

exit 0