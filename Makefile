# Makefile for Mostlymatter Docker project

# Variables
WORKFLOW_NAME = "Build and Publish Docker Image"
WORKFLOW_FILE = build-and-publish.yml
BRANCH = main

# Targets
.PHONY: help trigger-workflow check-workflow wait-workflow test-workflow

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  trigger-workflow   Trigger the GitHub Actions workflow"
	@echo "  check-workflow     Check the status of the latest workflow run"
	@echo "  wait-workflow      Wait for the latest workflow run to complete"
	@echo "  test-workflow      Trigger, wait for, and check the latest workflow run"

trigger-workflow: ## Trigger the GitHub Actions workflow
	@echo "Triggering workflow: $(WORKFLOW_NAME)..."
	@gh workflow run $(WORKFLOW_FILE) --ref $(BRANCH)

check-workflow: ## Check the status of the latest workflow run
	@echo "Checking status of the latest workflow run..."
	@gh run list --workflow=$(WORKFLOW_FILE) --limit=1

wait-workflow: scripts/wait-for-workflow.sh ## Wait for the latest workflow run to complete
	@echo "Waiting for the latest workflow run to complete..."
	@chmod +x scripts/wait-for-workflow.sh # Ensure script is executable
	@RUN_ID=$$(gh run list --workflow=$(WORKFLOW_FILE) --limit=1 --json databaseId -q .[0].databaseId); \
	if [ -z "$$RUN_ID" ]; then \
		echo "No workflow runs found."; \
		exit 1; \
	fi; \
	echo "Monitoring run ID: $$RUN_ID"; \
	./scripts/wait-for-workflow.sh $$RUN_ID

test-workflow: trigger-workflow ## Trigger, wait for, and check the latest workflow run
	@echo "Waiting for 10 seconds before monitoring the workflow..."
	@sleep 10
	@make wait-workflow

# Ensure the wait script is executable
scripts/wait-for-workflow.sh:
	chmod +x scripts/wait-for-workflow.sh