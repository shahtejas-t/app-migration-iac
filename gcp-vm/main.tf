terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=4.45.0"
    }
  }
}

provider "google" { 
  credentials = file("~/.config/gcloud/application_default_credentials.json")
  project = var.project
  region  = var.region
}

resource "google_compute_network" "erp_app" {
  name                    = "${var.prefix}-vpc-${var.region}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "erp_app" {
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.erp_app.self_link
  ip_cidr_range = var.subnet_prefix
}

resource "google_compute_firewall" "http-server" {
  name    = "${var.prefix}-default-allow-ssh-http"
  network = google_compute_network.erp_app.self_link

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "erp_app" {
  name         = "${var.prefix}-erp-app"
  zone         = "${var.region}-b"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.machine_os
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.erp_app.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  tags = ["http-server"]

  labels = {
    name = "erp_app"
  }

}
