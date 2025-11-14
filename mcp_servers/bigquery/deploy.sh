#!/bin/bash

# Define variables
GOOGLE_CLOUD_PROJECT=$(grep '^GOOGLE_CLOUD_PROJECT=' .env | cut -d '=' -f 2-)
SERVICE_ACCOUNT_NAME="toolbox-cc-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
SECRET_NAME="tools"
SECRET_DATA_FILE="mcp_servers/bigquery/bigquery.yaml"
IMAGE="us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest"
CLOUD_RUN_SERVICE_NAME="toolbox"
GOOGLE_CLOUD_LOCATION=$(grep '^GOOGLE_CLOUD_LOCATION=' .env | cut -d '=' -f 2-)

echo "--- Enabling necessary Google Cloud services ---"
gcloud services enable \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    iam.googleapis.com \
    telemetry.googleapis.com \
    secretmanager.googleapis.com || { echo "Failed to enable services. Exiting."; exit 1; }

echo "--- Checking for existing service account: ${SERVICE_ACCOUNT_EMAIL} ---"
if gcloud iam service-accounts describe "${SERVICE_ACCOUNT_EMAIL}" &> /dev/null; then
    echo "Service account ${SERVICE_ACCOUNT_NAME} already exists."
else
    echo "Creating service account: ${SERVICE_ACCOUNT_NAME}"
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
        --project="${GOOGLE_CLOUD_PROJECT}" || { echo "Failed to create service account. Exiting."; exit 1; }
fi

echo "--- Adding IAM policy bindings to ${SERVICE_ACCOUNT_EMAIL} ---"
echo "Adding role: roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/secretmanager.secretAccessor" \
    --condition=None || { echo "Failed to add secretAccessor role. Exiting."; exit 1; }

echo "Adding role: roles/bigquery.admin"
gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/bigquery.admin" \
    --condition=None || { echo "Failed to add bigquery.admin role. Exiting."; exit 1; }

echo "--- Handling secret: ${SECRET_NAME} ---"
if [ ! -f "${SECRET_DATA_FILE}" ]; then
    echo "Error: Secret data file '${SECRET_DATA_FILE}' not found. Please create it."
    exit 1
fi

if gcloud secrets describe "${SECRET_NAME}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Secret '${SECRET_NAME}' already exists. Adding a new version."
    gcloud secrets versions add "${SECRET_NAME}" \
        --data-file="${SECRET_DATA_FILE}" \
        --project="${GOOGLE_CLOUD_PROJECT}" || { echo "Failed to add new secret version. Exiting."; exit 1; }
else
    echo "Secret '${SECRET_NAME}' does not exist. Creating it."
    gcloud secrets create "${SECRET_NAME}" \
        --data-file="${SECRET_DATA_FILE}" \
        --project="${GOOGLE_CLOUD_PROJECT}" || { echo "Failed to create secret. Exiting."; exit 1; }
fi

echo "--- Deploying Cloud Run service: ${CLOUD_RUN_SERVICE_NAME} ---"
gcloud run deploy "${CLOUD_RUN_SERVICE_NAME}" \
    --image="${IMAGE}" \
    --service-account="${SERVICE_ACCOUNT_EMAIL}" \
    --region="${GOOGLE_CLOUD_LOCATION}" \
    --set-secrets="/app/bigquery.yaml=${SECRET_NAME}:latest" \
    --args="--tools-file=/app/bigquery.yaml","--address=0.0.0.0","--port=8080" \
    --allow-unauthenticated \
    --project="${GOOGLE_CLOUD_PROJECT}" || { echo "Failed to deploy Cloud Run service. Exiting."; exit 1; }

echo "--- Deployment script finished successfully! ---"
