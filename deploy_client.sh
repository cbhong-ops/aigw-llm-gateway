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

if [ -z "$CLIENT_SERVICE_ACCOUNT" ] || [ "$CLIENT_SERVICE_ACCOUNT" == "YOUR_SERVICE_ACCOUNT_EMAIL" ]; then
  echo "Error: Please set CLIENT_SERVICE_ACCOUNT in env.sh"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Error: REGION is not set in env.sh"
  exit 1
fi

echo "Deploying apigee-llm-gw-client to Cloud Run..."
gcloud run deploy apigee-llm-gw-client \
  --source ./client \
  --service-account "$CLIENT_SERVICE_ACCOUNT" \
  --region "$REGION" \
  --project "$PROJECT" \
  --ingress all \
  --min-instances 1
  
#  --ingress internal-and-cloud-load-balancing \

