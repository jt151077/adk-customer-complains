#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
GEMINI_ENT_APP_NAME=$(grep '^GEMINI_ENT_APP_NAME=' .env | cut -d '=' -f 2-)
GEMINI_ENT_DISPLAY_NAME=$(grep '^GEMINI_ENT_DISPLAY_NAME=' .env | cut -d '=' -f 2-)
GEMINI_ENT_AGENT_DESCRIPTION=$(grep '^GEMINI_ENT_AGENT_DESCRIPTION=' .env | cut -d '=' -f 2-)
AGENT_ENGINE_RESOURCE_NAME=$(grep '^AGENT_ENGINE_RESOURCE_NAME=' .env | cut -d '=' -f 2-)


deploy_resp=$(adk deploy agent_engine \
  --project=${GOOGLE_CLOUD_PROJECT} \
  --region=us-central1 \
  --staging_bucket=gs://${GOOGLE_CLOUD_PROJECT}-customer_complains \
  --display_name="Customer complains agent" \
  ./customer_complain)

echo "------------- STARTS HERE -----------------"
echo "$deploy_resp"

