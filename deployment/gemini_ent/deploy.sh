#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
GEMINI_ENT_APP_NAME=$(grep '^GEMINI_ENT_APP_NAME=' .env | cut -d '=' -f 2-)
GEMINI_ENT_DISPLAY_NAME=$(grep '^GEMINI_ENT_DISPLAY_NAME=' .env | cut -d '=' -f 2-)
GEMINI_ENT_AGENT_DESCRIPTION=$(grep '^GEMINI_ENT_AGENT_DESCRIPTION=' .env | cut -d '=' -f 2-)
AGENT_ENGINE_RESOURCE_NAME=$(grep '^AGENT_ENGINE_RESOURCE_NAME=' .env | cut -d '=' -f 2-)


http_response=$(curl -X POST \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
"https://discoveryengine.googleapis.com/v1alpha/projects/${GOOGLE_CLOUD_PROJECT}/locations/global/collections/default_collection/engines/${GEMINI_ENT_APP_NAME}/assistants/default_assistant/agents" \
-d @- <<EOF
{
  "displayName": ${GEMINI_ENT_DISPLAY_NAME},
  "description": ${GEMINI_ENT_AGENT_DESCRIPTION},
  "adk_agent_definition": {
    "tool_settings": {
      "tool_description": ${GEMINI_ENT_AGENT_DESCRIPTION}
    },
    "provisioned_reasoning_engine": {
      "reasoning_engine": ${AGENT_ENGINE_RESOURCE_NAME}
    }
  }
}
EOF
)


KEY_TO_SET="GEMINI_ENT_AGENT_NAME"
ENV_FILE=".env"

# This variable should be set before this script runs
# For testing, let's give it a default value:
agent_name=$(echo "$http_response" | jq -r '.name')
VALUE_TO_SET=$agent_name


# Check if the key already exists in the file
if grep -q "^${KEY_TO_SET}=" "$ENV_FILE"; then
    # Key exists, so update its value.
    # We use a different separator (#) for sed in case the value contains slashes.
    echo "Updating existing key: ${KEY_TO_SET}"
    # The -i.bak flag edits the file in-place and creates a backup.
    sed -i.bak "s#^${KEY_TO_SET}=.*#${KEY_TO_SET}=${VALUE_TO_SET}#" "$ENV_FILE"

else
    # Key does not exist, so append it.
    echo "Appending new key: ${KEY_TO_SET}"

    # First, ensure the file ends with a newline character for a clean append.
    if [ -s "$ENV_FILE" ] && [ -n "$(tail -n 1 "$ENV_FILE")" ]; then
        echo "" >> "$ENV_FILE" # Add the missing newline
    fi
    
    # Now, append the new key-value pair.
    echo "${KEY_TO_SET}=${VALUE_TO_SET}" >> "$ENV_FILE"
fi


echo -e "\nAgent creation attempt finished.\n"
