#!/bin/bash

GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
AGENT_ENGINE_NAME=$(grep '^AGENT_ENGINE_NAME=' .env | cut -d '=' -f 2-)
GOOGLE_CLOUD_LOCATION=$(grep '^GOOGLE_CLOUD_LOCATION=' .env | cut -d '=' -f 2-)
GEMINI_ENT_DISPLAY_NAME=$(grep '^GEMINI_ENT_DISPLAY_NAME=' .env | cut -d '=' -f 2-)


deploy_resp=$(adk deploy agent_engine \
  --project=${GOOGLE_CLOUD_PROJECT} \
  --region=${GOOGLE_CLOUD_LOCATION} \
  --staging_bucket=gs://${GOOGLE_CLOUD_PROJECT}-${AGENT_ENGINE_NAME} \
  --display_name="${AGENT_ENGINE_NAME}" \
  ./customer_complain)

echo "------------- AGENT DEPLOYED SUCCESSFULLY -----------------"
extracted_id=$(echo "$deploy_resp" | grep "Created agent engine:" | awk '{print $5}')

# Print the new variable to verify
echo "The extracted ID is: ${extracted_id}"

KEY_TO_SET="AGENT_ENGINE_RESOURCE_NAME"
ENV_FILE=".env"

VALUE_TO_SET=$extracted_id

# Check if the key already exists in the file
if grep -q "^${KEY_TO_SET}=" "$ENV_FILE"; then
    # Key exists, so update its value.
    # We use a different separator (#) for sed in case the value contains slashes.
    echo "Updating existing key: ${KEY_TO_SET}"
    # The -i.bak flag edits the file in-place and creates a backup.
    sed -i.bak "s#^${KEY_TO_SET}=.*#${KEY_TO_SET}='${VALUE_TO_SET}'#" "$ENV_FILE"

else
    # Key does not exist, so append it.
    echo "Appending new key: ${KEY_TO_SET}"

    # First, ensure the file ends with a newline character for a clean append.
    if [ -s "$ENV_FILE" ] && [ -n "$(tail -n 1 "$ENV_FILE")" ]; then
        echo "" >> "$ENV_FILE" # Add the missing newline
    fi
    
    # Now, append the new key-value pair.
    echo "${KEY_TO_SET}='${VALUE_TO_SET}'" >> "$ENV_FILE"
fi


echo "------------- ENV FILE UPDATED SUCCESSFULLY -----------------"
