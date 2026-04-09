provider "infisical" {
  host = var.infisical_host
}

data "infisical_secrets" "runtime" {
  workspace_id = var.infisical_workspace_id
  env_slug     = var.infisical_env_slug
  folder_path  = var.infisical_folder_path
}

locals {
  infisical_secret_map = data.infisical_secrets.runtime.secrets

  resolved_gcp_project_id = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_project_id].value, "")
  )

  resolved_gcp_region = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_region].value, "")
  )

  resolved_gcp_zone = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_zone].value, "")
  )

  resolved_gcp_credentials_json = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_credentials_json].value, "")
  )

  resolved_gcp_network = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_network].value, "")
  )

  resolved_gcp_subnetwork = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_subnetwork].value, "")
  )

  resolved_gcp_image = trimspace(
    try(local.infisical_secret_map[var.infisical_key_gcp_image].value, "")
  )

  resolved_vm_ssh_public_key = trimspace(
    try(local.infisical_secret_map[var.infisical_key_vm_ssh_public_key].value, "")
  )

  rendered_startup_script = replace(
    templatefile("${path.module}/../scripts/startup.sh.tftpl", {
      vm_name     = var.vm_name
      page_title  = var.nginx_start_page_title
      environment = var.infisical_env_slug
    }),
    "\r\n",
    "\n"
  )
}

provider "google" {
  project     = local.resolved_gcp_project_id
  region      = local.resolved_gcp_region
  zone        = local.resolved_gcp_zone
  credentials = local.resolved_gcp_credentials_json
}

resource "terraform_data" "credential_guard" {
  input = "guard"

  lifecycle {
    precondition {
      condition = (
        local.resolved_gcp_project_id != "" &&
        local.resolved_gcp_region != "" &&
        local.resolved_gcp_zone != "" &&
        local.resolved_gcp_credentials_json != "" &&
        local.resolved_gcp_network != "" &&
        local.resolved_gcp_image != "" &&
        local.resolved_vm_ssh_public_key != ""
      )
      error_message = "Missing required values from Infisical. Check auth, workspace/env/folder, and required key names for GCP + VM settings."
    }
  }
}

resource "google_compute_firewall" "allow_http" {
  count = var.create_http_firewall ? 1 : 0

  name    = "${var.vm_name}-allow-http"
  network = local.resolved_gcp_network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "${var.vm_name}-nginx"]

  depends_on = [terraform_data.credential_guard]
}

resource "google_compute_instance" "nginx" {
  name         = var.vm_name
  description  = var.vm_description
  machine_type = var.gcp_machine_type
  zone         = local.resolved_gcp_zone

  boot_disk {
    initialize_params {
      image = local.resolved_gcp_image
      size  = var.vm_disk_size_gb
    }
  }

  network_interface {
    network    = local.resolved_gcp_network
    subnetwork = local.resolved_gcp_subnetwork != "" ? local.resolved_gcp_subnetwork : null

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    ssh-keys           = "${var.vm_ssh_username}:${local.resolved_vm_ssh_public_key}"
    serial-port-enable = "TRUE"
    startup-script     = local.rendered_startup_script
  }

  tags = ["http-server", "${var.vm_name}-nginx"]

  depends_on = [
    terraform_data.credential_guard,
    google_compute_firewall.allow_http
  ]
}
