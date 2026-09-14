# Salesforce Account Health sample with Azure Pipelines

A minimal, deployable Salesforce DX application containing an Apex service, Apex tests, a Lightning Web Component, a permission set, scratch-org configuration, and an Azure DevOps pipeline.

## What the pipeline does

1. Installs the current Salesforce CLI.
2. Authenticates the Dev Hub with JWT.
3. Creates a one-day scratch org.
4. Deploys `force-app` metadata.
5. Assigns the permission set.
6. Runs all local Apex tests with code coverage and JUnit output.
7. Publishes test results to Azure Pipelines.
8. Deletes the scratch org via a shell `EXIT` trap, including failed runs.
9. Removes the temporary JWT key and logs out of the Dev Hub.

## Azure DevOps secret variables

Create a variable group or pipeline variables with these names:

- `SF_DEVHUB_USERNAME`: Dev Hub integration-user username.
- `SF_CONSUMER_KEY`: Connected App consumer key.
- `SF_JWT_KEY_B64`: Base64 representation of the private key. Mark it secret.
- `SF_INSTANCE_URL`: Optional override. The YAML defaults to `https://login.salesforce.com`.

Generate a key pair for the Salesforce Connected App:

```bash
openssl genrsa -out server.key 2048
openssl req -new -x509 -key server.key -out server.crt -days 3650 -subj "/CN=Salesforce Azure Pipeline"
base64 -w 0 server.key
```

Upload `server.crt` to the Connected App, enable OAuth, select the `api` and `refresh_token, offline_access` scopes, and approve the Dev Hub integration user according to your org policy. Never commit `server.key`.

## Run locally

Prerequisites: Salesforce CLI, a Dev Hub, and an authenticated alias named `DevHub`.

```bash
sf org login web --alias DevHub --set-default-dev-hub
chmod +x scripts/ci.sh
./scripts/ci.sh
```

## Create the Azure pipeline

1. Push this folder to Azure Repos or GitHub.
2. In Azure DevOps, create a YAML pipeline and select `azure-pipelines.yml`.
3. Add the secret variables described above.
4. Run the pipeline.

## Notes

- The sample uses API version 65.0. If your Dev Hub does not support it, change `sourceApiVersion` and every metadata `apiVersion` to a version supported by your org.
- A Dev Hub must be enabled and allowed to create scratch orgs.
- The application is intentionally small and uses standard Account data, so no custom object dependency is required.
