# Makefile for Mostlymatter Docker project

# Variables
WORKFLOW_NAME = "Build and Publish Docker Image"
WORKFLOW_FILE = build-and-publish.yml
BRANCH = main

# Targets
.PHONY: help trigger-workflow check-workflow wait-workflow

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  trigger-workflow   Trigger the GitHub Actions workflow"
	@echo "  check-workflow     Check the status of the latest workflow run"
	@echo "  wait-workflow      Wait for the latest workflow run to complete"

trigger-workflow:
	@echo "Triggering workflow: $(WORKFLOW_NAME)..."
	@gh workflow run $(WORKFLOW_FILE) --ref $(BRANCH)

check-workflow:
	@echo "Checking status of the latest workflow run..."
	@gh run list --workflow=$(WORKFLOW_FILE) --limit=1

wait-workflow: scripts/wait-for-workflow.sh
	@echo "Waiting for the latest workflow run to complete..."
	@RUN_ID=$$(gh run list --workflow=$(WORKFLOW_FILE) --limit=1 --json databaseId -q .[0].databaseId); \
	if [ -z "$$RUN_ID" ]; then \
		echo "No workflow runs found."; \
		exit 1; \
	fi; \
	echo "Monitoring run ID: $$RUN_ID"; \
	./scripts/wait-for-workflow.sh $$RUN_ID

# Ensure the wait script is executable
scripts/wait-for-workflow.sh:
	chmod +x scripts/wait-for-workflow.sh