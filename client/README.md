# Apigee AIGW Client

This directory contains the Streamlit client application for the Apigee LLM Gateway.

## Configuration

The client application requires Apigee OAuth2 credentials (`client_id` and `client_secret`) to obtain access tokens.

These credentials should be set as environment variables before running or deploying the application.

### Environment Variables

The following environment variables are supported:

*   `APIGEE_HOSTNAME`: Apigee gateway hostname.
*   `BASIC_CLIENT_ID`: Client ID for the Basic tier.
*   `BASIC_CLIENT_SECRET`: Client Secret for the Basic tier.
*   `PREMIUM_CLIENT_ID`: Client ID for the Premium tier.
*   `PREMIUM_CLIENT_SECRET`: Client Secret for the Premium tier.

### Local Setup

You can use the `.env` file in this directory to set these variables for local testing.

1.  Edit the `.env` file in this directory and replace the placeholders with your actual Apigee credentials.

### Running the Application

To run the application locally with the environment variables loaded from `.env`:

```bash
export $(cat .env | xargs)
streamlit run apigee-llm-gw-client.py
```
