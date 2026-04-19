#!/bin/bash

# Source environment variables
if [ -f "./env.sh" ]; then
  source ./env.sh
else
  echo "Error: env.sh not found."
  exit 1
fi

# Check required variables
if [ -z "$PROJECT" ]; then
  echo "Error: PROJECT is not set in env.sh"
  exit 1
fi

if [ -z "$ROUTER_SERVICE_ACCOUNT" ] || [ "$ROUTER_SERVICE_ACCOUNT" == "YOUR_SERVICE_ACCOUNT_EMAIL" ]; then
  echo "Error: Please set ROUTER_SERVICE_ACCOUNT in env.sh"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Error: REGION is not set in env.sh"
  exit 1
fi

echo "Deploying llm-router to Cloud Run..."
gcloud run deploy llm-router \
  --source ./llm-router \
  --service-account "$ROUTER_SERVICE_ACCOUNT" \
  --region "$REGION" \
  --project "$PROJECT" \
  --ingress internal-and-cloud-load-balancing \
  --min-instances 1
