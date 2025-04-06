# Makefile for Mostlymatter Docker project

# Variables
WORKFLOW_NAME = "Build and Publish Docker Image"
WORKFLOW_FILE = build-and-publish.yml
BRANCH = main
IMAGE_NAME = ghcr.io/fgruntjes/mostlymatter-docker
LATEST_VERSION ?= $(shell curl -s https://packages.framasoft.org/projects/mostlymatter/ | grep -oP 'mostlymatter-amd64-v\d+\.\d+\.\d+' | sort -V | tail -n1 | sed 's/mostlymatter-amd64-//')

# Targets
.PHONY: help build test release trigger-workflow check-workflow wait-workflow test-workflow

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build              Build the Docker image locally"
	@echo "  test               Run tests on the Docker image (placeholder)"
	@echo "  release            Trigger the release workflow on GitHub"
	@echo "  trigger-workflow   Trigger the GitHub Actions workflow"
	@echo "  check-workflow     Check the status of the latest workflow run"
	@echo "  wait-workflow      Wait for the latest workflow run to complete"
	@echo "  test-workflow      Trigger, wait for, and check the latest workflow run"

build: ## Build the Docker image locally
	@echo "Building Docker image for version $(LATEST_VERSION)..."
	@docker build --build-arg MOSTLYMATTER_VERSION=$(LATEST_VERSION) -t $(IMAGE_NAME):$(LATEST_VERSION) -t $(IMAGE_NAME):latest .

test: ## Run tests on the Docker image (placeholder)
	@echo "Running tests (placeholder)..."
	# Add test commands here, e.g., using docker run to check functionality

release: trigger-workflow ## Trigger the release workflow on GitHub
	@echo "Release workflow triggered. Monitor progress on GitHub Actions."

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