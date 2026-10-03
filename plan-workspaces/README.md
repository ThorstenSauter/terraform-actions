# Plan workspaces

## Behavior

This action installs the Terraform CLI with either the given or the `latest` version by default. It then executes the
`plan` command for each of the given workspaces and posts one pull request comment per workspace, the same comment the
[Plan](../plan) action posts.

It is meant for repositories that split their infrastructure into several workspaces sharing one backend and one set of
credentials. Instead of one job per workspace, one job plans all of them:

- The workspaces are initialised one after another with a shared
  [provider plugin cache](https://developer.hashicorp.com/terraform/cli/config/config-file#provider-plugin-cache), so
  each provider is downloaded once. Set `TF_PLUGIN_CACHE_DIR` to use your own cache directory, e.g. one restored by
  `actions/cache`.
- The plans run in parallel. Each workspace's output is printed in its own log group once all plans have finished.
- A failed plan does not stop the others. Every workspace gets its comment, and the action fails at the end if any plan
  failed.

Workspaces share the job's environment, so `TF_VAR_*` variables apply to all of them. Terraform ignores a `TF_VAR_*`
variable a workspace does not declare.

## Inputs

`workspaces` lists one workspace per line, as three whitespace-separated fields:

1. The Terraform source directory
2. The name of its state file in the backend container
3. The environment name used in its pull request comment heading (`### <environment name> environment`)

The comment heading is the same as the [Plan](../plan) action's, so switching between the two actions updates the
existing comments instead of adding new ones.

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
  pull-requests: write # Required for pull request comments

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
        uses: ThorstenSauter/terraform-actions/plan-workspaces@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          resource-group: ${{ vars.TF_BACKEND_RESOURCE_GROUP_NAME }}
          storage-account: ${{ vars.TF_BACKEND_STORAGE_ACCOUNT_NAME }}
          container: ${{ vars.TF_BACKEND_STATE_CONTAINER_NAME }}
          workspaces: |
            infra/foundation production-foundation.tfstate production-foundation
            infra/apps       production.tfstate            production
```
