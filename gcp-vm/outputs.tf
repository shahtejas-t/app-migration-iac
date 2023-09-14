# Outputs file
output "app_url" {
  value = "http://${google_compute_instance.erp_app.network_interface.0.access_config.0.nat_ip}:3000"
}

output "app_ip" {
  value = "http://${google_compute_instance.erp_app.network_interface.0.network_ip}"
}

output "ssh_username" {
  value = google_compute_instance.erp_app.metadata["ssh-keys"]
}

output "ssh_ip" {
  value = google_compute_instance.erp_app.network_interface[0].access_config[0].nat_ip
}

# output "ssh_password" {
#   value = google_compute_instance.erp_app.metadata["password"]
# }