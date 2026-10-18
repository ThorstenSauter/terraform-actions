# Plan

## Behavior

This action installs the Terraform CLI in the version given by the `terraform-version` input. Without it, the version
in a `.terraform-version` file at the repository root is used, falling back to `latest` if there is none.

It then executes the `plan` command in the given infrastructure directory.

The plan holds the state lock by default. On pull requests, set `lock: false`: with the `azurerm` backend, two plans
that start at the same moment can fail on each other's lock even with `lock-timeout`. A plan doesn't write state, so it
doesn't need the lock, but it can then read state while an apply is changing it and show changes that apply is about to
make. Keep the lock for anything that writes state, such as `apply -refresh-only`.

## Example usage

```yaml
name: Terraform plan

on:
  pull_request:
    branches:
      - main

permissions:
  contents: read
  id-token: write # Required for OIDC
  pull-requests: write # Required for pull request comment

jobs:
  plan:
    name: Terraform plan
    runs-on: ubuntu-latest
    environment: production
    env:
      ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
      ARM_USE_AZUREAD: true
      ARM_USE_OIDC: true
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Terraform plan
        uses: ThorstenSauter/terraform-actions/plan@v1
        with:
          environment-name: 'Production'
          github-token: ${{ secrets.GITHUB_TOKEN }}
          infra-directory: ${{ vars.INFRA_DIRECTORY }}
          resource-group: ${{ vars.TF_BACKEND_RESOURCE_GROUP_NAME }}
          storage-account: ${{ vars.TF_BACKEND_STORAGE_ACCOUNT_NAME }}
          container: ${{ vars.TF_BACKEND_STATE_CONTAINER_NAME }}
          state-file: ${{ vars.TF_BACKEND_STATE_FILE_NAME }}
          lock: false
```
