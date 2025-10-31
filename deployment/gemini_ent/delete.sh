#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
GEMINI_ENT_AGENT_NAME=$(grep '^GEMINI_ENT_AGENT_NAME=' .env | cut -d '=' -f 2-)

curl -X DELETE \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
"https://discoveryengine.googleapis.com/v1alpha/${GEMINI_ENT_AGENT_NAME}" \

echo -e "\nAgent deletion attempt finished.\n"
