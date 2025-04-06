#!/bin/bash
# Script to check for new versions of mostlymatter and trigger GitHub Actions workflow
# Usage: ./check-new-versions.sh <github-token> <repository-owner/repository-name>
# Example: ./check-new-versions.sh ghp_1234567890abcdef teda-tech/mostlymatter-docker

set -e

# Check if required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <github-token> <repository-owner/repository-name>"
  exit 1
fi

GITHUB_TOKEN=$1
REPOSITORY=$2
VERSIONS_FILE=".mostlymatter-versions"

# Create versions file if it doesn't exist
if [ ! -f "$VERSIONS_FILE" ]; then
  touch "$VERSIONS_FILE"
fi

# Get the list of available versions from Framasoft
echo "Checking for new mostlymatter versions..."
AVAILABLE_VERSIONS=$(curl -s https://packages.framasoft.org/projects/mostlymatter/ | 
                    grep -oP 'mostlymatter-amd64-v\d+\.\d+\.\d+' | 
                    sort -u | 
                    sed 's/mostlymatter-amd64-//')

# Get the list of versions we've already processed
PROCESSED_VERSIONS=$(cat "$VERSIONS_FILE")

# Find new versions
NEW_VERSIONS=()
for VERSION in $AVAILABLE_VERSIONS; do
  if ! grep -q "^$VERSION$" "$VERSIONS_FILE"; then
    NEW_VERSIONS+=("$VERSION")
  fi
done

# If there are new versions, trigger the GitHub Actions workflow
if [ ${#NEW_VERSIONS[@]} -gt 0 ]; then
  echo "Found new versions: ${NEW_VERSIONS[@]}"
  
  for VERSION in "${NEW_VERSIONS[@]}"; do
    echo "Triggering build for version $VERSION..."
    
    # Trigger the GitHub Actions workflow via repository_dispatch
    curl -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json" \
      "https://api.github.com/repos/$REPOSITORY/dispatches" \
      -d "{\"event_type\": \"new-mostlymatter-version\", \"client_payload\": {\"version\": \"$VERSION\"}}"
    
    # Add the version to the processed versions file
    echo "$VERSION" >> "$VERSIONS_FILE"
    
    echo "Build triggered for version $VERSION"
  done
else
  echo "No new versions found"
fi

echo "Done"