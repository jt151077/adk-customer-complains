#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
GEMINI_ENT_APP_NAME=$(grep '^GEMINI_ENT_APP_NAME=' .env | cut -d '=' -f 2-)

curl -X GET \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
"https://discoveryengine.googleapis.com/v1alpha/projects/${GOOGLE_CLOUD_PROJECT}/locations/global/collections/default_collection/engines/${GEMINI_ENT_APP_NAME}/assistants/default_assistant/agents" \

echo -e "\nAgent listing finished.\n"