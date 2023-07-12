terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=3.68.0"
    }
  }
}

provider "google" { 
  credentials = file("../app-migration-poc-tf-auth.json")
  project = var.project
  region  = var.region
}

resource "google_compute_network" "mono_erp" {
  name                    = "${var.prefix}-vpc-${var.region}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mono_erp" {
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.mono_erp.self_link
  ip_cidr_range = var.subnet_prefix
}

resource "google_compute_firewall" "http-server" {
  name    = "${var.prefix}-default-allow-ssh-http"
  network = google_compute_network.mono_erp.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3000", "3306", "8080"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "mono_erp" {
  name         = "${var.prefix}-mono-erp"
  zone         = "${var.region}-b"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mono_erp.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  tags = ["http-server"]

  labels = {
    name = "mono_erp"
  }

}

resource "null_resource" "configure-erp-app" {
  depends_on = [
    google_compute_instance.mono_erp,
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.mono_erp.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "chmod +x *.sh",
      "./install_git.sh",
      "./install_docker.sh",
      "./install_node.sh",
      "./deploy_mono_app.sh",

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.mono_erp.network_interface.0.access_config.0.nat_ip
    }
  }
}
