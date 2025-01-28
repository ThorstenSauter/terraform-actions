# Apply

## Behavior

This action installs the Terraform CLI with either the given or the `latest` version by default. It then executes the
`init` command in the given infrastructure directory. One example of its usage is retrieving output variables.

> [!IMPORTANT]
> This action disables the Terraform CLI wrapper.

## Example usage

```yaml
name: Retrieve Terraform output

on:
  pull-request:
    branches:
      - main

permissions:
  contents: read
  id-token: write # Required for OIDC

jobs:
  retrieve-output:
    name: Retrieve Terraform output
    runs-on: ubuntu-latest
    environment: production
    env:
      ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
      ARM_USE_AZUREAD: true
      ARM_USE_OIDC: true
      TERRAFORM_VERSION: '~> 1.10.0'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Terraform init
        uses: ThorstenSauter/terraform-actions/init@v1
        with:
          terraform-version: ${{ env.TERRAFORM_VERSION }}
          infra-directory: ${{ vars.INFRA_DIRECTORY }}
          resource-group: ${{ vars.TF_BACKEND_RESOURCE_GROUP_NAME }}
          storage-account: ${{ vars.TF_BACKEND_STORAGE_ACCOUNT_NAME }}
          container: ${{ vars.TF_BACKEND_STATE_CONTAINER_NAME }}
          state-file: ${{ vars.TF_BACKEND_STATE_FILE_NAME }}
      - name: Terraform apply refresh only
        working-directory: ${{ vars.TF_WORKING_DIRECTORY }}
        run: terraform apply -refresh-only -auto-approve -input=false
      - name: Retrieve deployment token
        id: token-retrieval
        working-directory: ${{ vars.TF_WORKING_DIRECTORY }}
        run: |
          token=$(terraform output -raw deployment_token)
          echo "::add-mask::$token"
          echo "deployment-token=$token" >> "$GITHUB_OUTPUT"
```
