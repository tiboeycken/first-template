# Minimal GCP Nginx Template

This template is the first working slice for a Walrus + Google Cloud setup.

## What it does

- Provisions one Ubuntu VM in Google Compute Engine with Terraform.
- Uses a startup script to install and start nginx.
- Keeps the template intentionally small so the team can validate the full flow first.

## Folder layout

- `terraform/` contains the Google Cloud provisioning code.
- `scripts/` contains the startup script template for nginx.

## First deployment flow

1. Set Terraform input variables via environment variables (`TF_VAR_*`).
2. Authenticate to Infisical using machine identity credentials in the run environment.
3. Ensure all required GCP keys exist in Infisical before running Terraform.
4. Run `terraform init` and `terraform apply` inside `terraform/`.
5. Verify that the VM boots and that nginx is reachable.

Example variable export (PowerShell):

```powershell
$env:TF_VAR_infisical_workspace_id = "replace-with-workspace-id"
$env:TF_VAR_infisical_env_slug = "dev"
$env:TF_VAR_infisical_folder_path = "/GCP"
```

## Secret strategy

- Single source of truth: Infisical data source in Terraform.
- No local tfvars fallback for GCP credentials.
- Missing auth or missing key names now fail hard.

This design works for local runs and future Walrus runs with the same Infisical contract.

## Required Infisical keys

Store these keys under the configured folder path:

- `gcp_project_id`
- `gcp_region`
- `gcp_zone`
- `gcp_credentials_json`
- `gcp_network`
- `gcp_subnetwork` (optional, may be empty)
- `gcp_image` (for example `projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts`)
- `vm_ssh_public_key`

## Adding a new variable

Use this checklist when introducing a new runtime value from Infisical:

1. Add the secret in Infisical under the configured folder path.
2. Add an `infisical_key_*` variable in `terraform/variables.tf` for the secret key name.
3. Add a `resolved_*` local in `terraform/main.tf` that reads from `local.infisical_secret_map`.
4. Use the new `local.resolved_*` value in the target provider or resource.
5. If the value is required, add it to the `credential_guard` precondition so Terraform fails fast.

## Required Infisical auth environment variables

Set these in your execution context (local shell or runner):

- `INFISICAL_UNIVERSAL_AUTH_CLIENT_ID`
- `INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET`

## Security notes

- `terraform.tfstate` can contain sensitive values. Keep it local-only for development or move to a secure encrypted remote backend.
- Rotate any token that has been stored in plain text.

## Design choices for the first version

- One VM only.
- Ubuntu cloud image.
- Terraform first, Walrus on top later.
- Optional ephemeral public IP for quick validation.

## Next steps after this slice

- Add a Walrus-facing wrapper around the Terraform module.
- Split the template into shared Google Cloud building blocks once more VM types are added.
- Add TLS, DNS, and app-specific bootstrap only after the basic nginx VM is stable.

## Infisical bulk import files

- Environment format: `terraform/infisical-gcp-secrets.env`
- CSV format: `terraform/infisical-gcp-secrets.csv`

## Walrus schema usage

This template now includes `schema.yaml` in the template root. Walrus can use this file to render a user-facing deployment form and display selected outputs after deployment.

User-facing inputs in this template:

- `vm_name`
- `gcp_machine_type`
- `vm_disk_size_gb`
- `assign_public_ip`
- `create_http_firewall`
- `nginx_start_page_title`

Internal-only values (not exposed in the schema form):

- `infisical_workspace_id`
- `infisical_env_slug`
- `infisical_folder_path`
- All `infisical_key_*` variables

Visible schema outputs:

- `vm_name`
- `vm_public_ip`
- `vm_id`
- `gcp_zone`