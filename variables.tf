variable "infisical_host" {
  description = "Infisical host URL. Keep default for Infisical Cloud."
  type        = string
  default     = "https://app.infisical.com"
}

variable "infisical_ws_id" {
  description = "Infisical project/workspace ID used to fetch runtime values."
  type        = string
}

variable "infisical_auth_id" {
  description = "Infisical universal auth client ID."
  type        = string
}

variable "infisical_auth_secret" {
  description = "Infisical universal auth client secret."
  type        = string
  sensitive   = true
}

variable "infisical_env_slug" {
  description = "Infisical environment slug, for example dev or prod."
  type        = string
  default     = "dev"
}

variable "infisical_folder_path" {
  description = "Infisical folder path where first-template values are stored."
  type        = string
  default     = "/GCP"
}

variable "infisical_key_gcp_project_id" {
  description = "Infisical secret key for the GCP project ID."
  type        = string
  default     = "gcp_project_id"
}

variable "infisical_key_gcp_region" {
  description = "Infisical secret key for the GCP region."
  type        = string
  default     = "gcp_region"
}

variable "infisical_key_gcp_zone" {
  description = "Infisical secret key for the GCP zone."
  type        = string
  default     = "gcp_zone"
}

variable "infisical_key_gcp_credentials_json" {
  description = "Infisical secret key for the GCP service account credentials JSON."
  type        = string
  default     = "gcp_credentials_json"
}

variable "infisical_key_gcp_network" {
  description = "Infisical secret key for the GCP network."
  type        = string
  default     = "gcp_network"
}

variable "infisical_key_gcp_subnetwork" {
  description = "Infisical secret key for the GCP subnetwork. Leave empty for default."
  type        = string
  default     = "gcp_subnetwork"
}

variable "infisical_key_gcp_image" {
  description = "Infisical secret key for the VM image/family reference."
  type        = string
  default     = "gcp_image"
}

variable "infisical_key_vm_ssh_public_key" {
  description = "Infisical secret key for the VM SSH public key."
  type        = string
  default     = "vm_ssh_public_key"
}

variable "gcp_machine_type" {
  description = "GCP machine type for the VM."
  type        = string
  default     = "e2-micro"
}

variable "create_http_firewall" {
  description = "Create a firewall rule that allows inbound HTTP traffic on port 80."
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "Assign an ephemeral public IP address to the VM."
  type        = bool
  default     = true
}

variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
  default     = "nginx"
}

variable "vm_description" {
  description = "Optional VM description"
  type        = string
  default     = "Minimal nginx VM for Walrus + GCP"
}

variable "vm_disk_size_gb" {
  description = "Primary disk size in GB"
  type        = number
  default     = 12
}

variable "vm_ssh_username" {
  description = "Default user created by cloud-init"
  type        = string
  default     = "walrus"
}

variable "nginx_start_page_title" {
  description = "Title used in the generated nginx landing page."
  type        = string
  default     = "Nginx is running"
}
