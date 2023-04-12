# Outputs file
output "app_url" {
  value = "http://${google_compute_instance.mono_erp.network_interface.0.access_config.0.nat_ip}:3000"
}

output "app_ip" {
  value = "http://${google_compute_instance.mono_erp.network_interface.0.network_ip}"
}
