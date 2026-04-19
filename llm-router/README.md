# LLM Router

This directory contains the LLM Router service, which routes requests to different LLM providers.

## Configuration

Before deploying the service to Cloud Run, you must configure the model endpoints in `eval.properties`.

1.  Open `eval.properties`.
2.  Replace the placeholders with your actual values:
    *   `YOUR_PROJECT_ID`: Your Google Cloud Project ID.
    *   `YOUR_AZURE_HOSTNAME`: Your Azure AI Services endpoint hostname (e.g., `your-resource.cognitiveservices.azure.com`).
    *   `YOUR_API_KEY`: Your Azure API Key.

> [!IMPORTANT]
> Make sure to update these values before deploying, otherwise the router will not be able to reach the backends.
