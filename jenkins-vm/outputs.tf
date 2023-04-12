# Outputs file
output "app_url" {
  value = "http://${google_compute_instance.jenkins.network_interface.0.access_config.0.nat_ip}"
}

output "app_ip" {
  value = "http://${google_compute_instance.jenkins.network_interface.0.network_ip}"
}
