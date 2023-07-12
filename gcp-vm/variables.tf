variable "project" {
  description = "project-08-05-2023"
}

variable "prefix" {
  description = "This prefix will be included in the name of some resources. You can use your own name or any other short string here."
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-central1"
}

variable "zone" {
  description = "The zone where the resources are created."
  default     = "us-central1-b"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "machine_type" {
  description = "Specifies the GCP instance type."
  # default     = "g1-small"
  default     = "n2-standard-2"
}

variable "machine_os" {
  description = "Specifies the OS type for machine."
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "allowed_ports" {
  description = "Specifies the Allowed outbound ports."
  default     = ["22", "80", "3000", "3306", "8080"]
}
