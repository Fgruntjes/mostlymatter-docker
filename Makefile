# Makefile for Mostlymatter Docker project

# Variables
WORKFLOW_FILE = build-and-publish.yml
BRANCH = main
IMAGE_NAME = ghcr.io/fgruntjes/mostlymatter-docker
LATEST_VERSION ?= $(shell curl -s https://packages.framasoft.org/projects/mostlymatter/ | grep -oP 'mostlymatter-amd64-v\d+\.\d+\.\d+' | sort -V | tail -n1 | sed 's/mostlymatter-amd64-//')

# Targets
.PHONY: help build test release test-workflow

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build              Build the Docker image locally"
	@echo "  test               Run tests on the Docker image (placeholder)"
	@echo "  release            Trigger the release workflow on GitHub (same as test-workflow)"
	@echo "  test-workflow      Trigger, wait for, and check the latest workflow run"

build: ## Build the Docker image locally
	@echo "Building Docker image for version $(LATEST_VERSION)..."
	@docker build --build-arg MOSTLYMATTER_VERSION=$(LATEST_VERSION) -t $(IMAGE_NAME):$(LATEST_VERSION) -t $(IMAGE_NAME):latest .

test: ## Run tests on the Docker image (placeholder)
	@echo "Running tests (placeholder)..."
	# Add test commands here, e.g., using docker run to check functionality

release: test-workflow ## Trigger the release workflow on GitHub

test-workflow: scripts/wait-for-workflow.sh ## Trigger, wait for, and check the latest workflow run
	@echo "Running test workflow..."
	@chmod +x scripts/wait-for-workflow.sh # Ensure script is executable
	./scripts/wait-for-workflow.sh $(WORKFLOW_FILE) $(BRANCH)

# Ensure the wait script is executable (redundant due to chmod in target, but good practice)
scripts/wait-for-workflow.sh:
	chmod +x scripts/wait-for-workflow.sh