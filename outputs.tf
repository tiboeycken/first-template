output "vm_name" {
  description = "Created VM name"
  value       = google_compute_instance.nginx.name
}

output "gcp_zone" {
  description = "GCP zone where the VM is deployed"
  sensitive   = true
  value       = google_compute_instance.nginx.zone
}

output "vm_id" {
  description = "Created VM ID"
  value       = google_compute_instance.nginx.instance_id
}

output "vm_public_ip" {
  description = "Ephemeral public IP address when assign_public_ip=true"
  value       = try(google_compute_instance.nginx.network_interface[0].access_config[0].nat_ip, "")
}

output "vm_internal_ip" {
  description = "Internal IP address assigned to the VM"
  value       = google_compute_instance.nginx.network_interface[0].network_ip
}
