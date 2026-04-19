#!/bin/bash

# Source environment variables
if [ -f "./env.sh" ]; then
  source ./env.sh
else
  echo "Error: env.sh not found. Please create it based on the template."
  exit 1
fi

# Check required variables
if [ "$PROJECT" == "YOUR_GCP_PROJECT_ID" ] || [ -z "$PROJECT" ]; then
  echo "Error: Please set PROJECT in env.sh"
  exit 1
fi

if [ "$APIGEE_ENV" == "YOUR_APIGEE_ENVIRONMENT" ] || [ -z "$APIGEE_ENV" ]; then
  echo "Error: Please set APIGEE_ENV in env.sh"
  exit 1
fi

if [ -z "$PROXY_SERVICE_ACCOUNT" ]; then
  echo "Error: Please set PROXY_SERVICE_ACCOUNT in env.sh"
  exit 1
fi

if [ -z "$PROXY_NAME" ]; then
  echo "Error: Please set PROXY_NAME in env.sh"
  exit 1
fi

echo "Getting access token..."
TOKEN=$(gcloud auth print-access-token)

if [ -z "$TOKEN" ]; then
  echo "Error: Failed to get access token."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq."
    exit 1
fi

# Check if apigeecli is installed
if ! command -v apigeecli &> /dev/null; then
    echo "apigeecli not found. Installing..."
    curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
    export PATH=$PATH:$HOME/.apigeecli/bin
fi

echo "Creating API Proxy bundle..."
# Assuming the folder 'apiproxy' is in the current directory
# We use the name specified in PROXY_NAME
REV=$(apigeecli apis create bundle -f apiproxy -n "$PROXY_NAME" --org "$PROJECT" --default-token --disable-check | jq -r '.revision')

if [ -z "$REV" ] || [ "$REV" == "null" ]; then
  echo "Error: Failed to create bundle or extract revision."
  exit 1
fi

echo "Deploying revision $REV..."
apigeecli apis deploy --wait --name "$PROXY_NAME" --ovr --rev "$REV" --org "$PROJECT" --env "$APIGEE_ENV" --default-token --sa "$PROXY_SERVICE_ACCOUNT"

echo "Deployment complete!"
