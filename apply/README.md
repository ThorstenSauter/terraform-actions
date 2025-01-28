# Apply

## Behavior

This action installs the Terraform CLI with either the given or the `latest` version by default. It then executes the
`apply` command in the given infrastructure directory.

> [!IMPORTANT]
> This action disables the Terraform CLI wrapper.

## Example usage

```yaml
name: Terraform apply

on:
  pull-request:
    branches:
      - main

permissions:
  contents: read
  id-token: write # Required for OIDC

jobs:
  apply:
    name: Terraform apply
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
      - name: Terraform apply
        uses: ThorstenSauter/terraform-actions/apply@v1
        with:
          terraform-version: ${{ env.TERRAFORM_VERSION }}
          infra-directory: ${{ vars.INFRA_DIRECTORY }}
          resource-group: ${{ vars.TF_BACKEND_RESOURCE_GROUP_NAME }}
          storage-account: ${{ vars.TF_BACKEND_STORAGE_ACCOUNT_NAME }}
          container: ${{ vars.TF_BACKEND_STATE_CONTAINER_NAME }}
          state-file: ${{ vars.TF_BACKEND_STATE_FILE_NAME }}
```
