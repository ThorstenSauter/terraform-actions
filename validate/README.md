# Validate

## Behavior

This action installs the Terraform CLI with either the given or the `latest` version by default. It then checks the
following items for the Terraform configuration files in the given infrastructure directory:

- File formatting using `terraform fmt`
- Validation using `terraform validate`
- Linting using `TFLint`
- Security using `tfsec`

If any of the steps fail, the entire action fails. If the action is run in a pull request, a comment displaying the
validation
result will be created or updated.

> [!IMPORTANT]
> This action disables the Terraform CLI wrapper.

## Example usage

```yaml
name: Terraform validate

on:
  pull-request:
    branches:
      - main

jobs:
  validate:
    name: Terraform validate
    runs-on: ubuntu-latest
    env:
      TERRAFORM_VERSION: '~> 1.9.0'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Terraform validate
        uses: ThorstenSauter/terraform-actions/validate@v1
        with:
          terraform-version: ${{ env.TERRAFORM_VERSION }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          infra-directory: ${{ vars.INFRA_DIRECTORY }}
```
