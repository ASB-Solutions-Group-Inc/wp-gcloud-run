# Wordpress on Google Cloud Run

## Documentation for Dockerfile
This Dockerfile contains the steps to build an image and deploy it to Google Cloud Run.

### Steps
Pull the experimental Dockerfile from the cloud builders.
Pull the version 1.0-experimental Dockerfile from the cloud builders.
Build the image with the 
_ACCESS_TOKEN
 argument from the secret manager.
Push the built image to the Docker registry.
Deploy the image to Google Cloud Run.
Images
The image used in this Dockerfile is 
us-docker.pkg.dev/wp-cloudrun-demo/wordpress/wordpress-2.0:latest
.

### Available Secrets
The secret manager provides access to the 
_ACCESS_TOKEN
 environment variable. The version name for the secret is 
projects/$PROJECT_ID/secrets/gcs-json-file/versions/latest
.

## Build and deploy
```bash
gcloud builds submit --tag gcr.io/PROJECT_NAME/IMAGE_NAME // build an image
gcloud run deploy wordpress [--region REGION] --platform managed --image gcr.io/PROJECT_NAME/IMAGE_NAME --set-env-vars DB_NAME=wordpress,DB_USER=root,DB_PASSWORD=mysecretpassword,DB_HOST=database_host --port 80 // deploy to Cloud run
```

Environment variables and port could be set via Cloud Run interface, or pass it via yaml file as `--env-vars-file .env.yaml` https://cloud.google.com/functions/docs/env-var

## Setup
- Dockerfile contains oficial PHP image with Apache and configuration for mysql connect and image handling.
- wp-config.php uses environment variables for database parameters instead of hard-coded values
- contains [WP-Stateless plugin](https://wordpress.org/plugins/wp-stateless/), which allow us to use Google Cloud Storage instead of local storage

