# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A set of reusable **composite** GitHub Actions for Terraform, consumed by other repos as
`ThorstenSauter/terraform-actions/<action>@v1`. Each top-level directory (`init/`, `validate/`, `plan/`, `apply/`) is one
action: an `action.yml` plus a `README.md` with usage docs. There is no build, test suite, or CI workflow in this repo;
changes are verified by running the actions from a consuming repository.

## Shared assumptions across actions

- The Terraform backend is always `azurerm` (state in Azure Blob Storage). Backend settings are passed as inputs
  (`resource-group`, `storage-account`, `container`, `state-file`) and turned into `-backend-config` flags.
- Authentication is OIDC via Entra ID; callers must set `ARM_CLIENT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`,
  `ARM_USE_AZUREAD=true`, `ARM_USE_OIDC=true`. The actions do not take Terraform variables as inputs — callers use
  `TF_VAR_*` env vars.
- Every action installs Terraform itself via `hashicorp/setup-terraform` (`terraform-version` input, default `latest`)
  and runs Terraform steps with `TF_IN_AUTOMATION: true`, `-input=false`, and `working-directory: inputs.infra-directory`.

## Structure worth knowing before editing

- **The `terraform init` step is duplicated** verbatim in `init/`, `plan/`, and `apply/` (composite actions don't
  reference each other here). Changes to init flags, `lock-timeout` handling, or `setup-terraform` config usually need
  to be applied to all three.
- `plan/` is the only action that leaves the `setup-terraform` wrapper enabled (others set `terraform_wrapper: false`),
  because it reads `steps.plan.outputs.stdout` to embed the plan in a PR comment.
- `validate/` and `plan/` post/update a single bot PR comment via `actions/github-script` (only on `pull_request`
  events). The existing comment is located by matching a marker string in its body — `Terraform validation` for
  validate, `<environment-name> environment` for plan — so changing those headings breaks comment de-duplication.
- Both use the pattern: individual check steps run with `continue-on-error: true`, the comment reports each step's
  `outcome`, and a final step does `exit 1` if any outcome is `failure`. Keep new checks consistent with this.
- `validate/` runs `terraform fmt -check -recursive`, TFLint (`tflint --init` then compact output), Trivy config scan
  (skippable via `skip-trivy`, output also written to the job summary), and `terraform init -backend=false` +
  `terraform validate` (no Azure credentials needed).

## Conventions

- Never interpolate `${{ inputs.* }}` or step outputs directly into `run:` scripts or `github-script` code; map them to
  `env:` entries and reference `$VAR` / `process.env.VAR` instead.

## Conventions

- Third-party actions are pinned to full commit SHAs with a trailing `# vX.Y.Z` comment. Renovate
  (`.github/renovate.json`, extending `ThorstenSauter/renovate-config`) updates these — keep the same format so it keeps
  working.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore(deps):`, `chore(docs):`).
- Releases are semver tags (`v1.x.y`) plus a moving major tag `v1` that consumers reference.
- When adding/changing inputs, update the action's `README.md` (and the root `README.md` example if relevant).
- YAML/JSON/Markdown use 2-space indent (`.editorconfig`); `.yml`/`.md` files use LF line endings (`.gitattributes`).
  Existing `action.yml`/`README.md` files start with a UTF-8 BOM.
