#>>>>>>>>> create VPS <<<<<<

resource "google_compute_network" "zabbix_network" {
  name                    = "${var.network-name}"
  auto_create_subnetworks = false
  description             = "create VPC"
}


#>>>>>>>>> create subnet <<<<<<

resource "google_compute_subnetwork" "zabbix_sub_net" {
  name          = "${var.zabbix-sub-net-name}"
  ip_cidr_range = "${var.zabbix-sub-net-ip-range}"
  region        = "${var.region}"
  network       = google_compute_network.zabbix_network.id
  depends_on    = [google_compute_network.zabbix_network, ]
  description   = "create subnetwork"
}
resource "google_compute_firewall" "zabbix_firewall_web" {
  name        = "zabbix-firewall-web"
  network     = google_compute_network.zabbix_network.name
  target_tags = ["zabbix-web"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = "${var.web-port}"
  }
  allow {
    protocol = "udp"
    ports    = "${var.web-port}"
  }
  source_ranges = ["0.0.0.0/0"]
  description   = "create firewall web rules for 80,22 ports"
}


#>>>>>>>>> create External IP <<<<<<

resource "google_compute_address" "external_ip" {
  name = "my-external-address"
  #subnetwork   = google_compute_subnetwork.zabbix_sub_net.id
  address_type = "EXTERNAL"
  #  address      = "10.0.42.42"
  region = "${var.region}"
}


#>>>>>>>>> create Internal IP <<<<<<

resource "google_compute_address" "internal_ip" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.zabbix_sub_net.id
  address_type = "INTERNAL"
  #address      = "10.0.42.42"
  region = "${var.region}"
}


#>>>>>>>>> create server instance <<<<<<

resource "google_compute_instance" "default" {
  name         = "zabbix-${var.createway}"
  machine_type = "${var.machinetype}"
  zone         = "${var.zone}"
  description  = "create zabbix"
  tags         = ["zabbix-web"]
  metadata = {
    ssh-keys = "cmetaha17:${file("id_rsa.pub")}"
  }
  #    tags = var.tags
  #    labels = var.labels
  #metadata_startup_script = <<EFO
  #EFO
  metadata_startup_script = templatefile("startup.sh", {
    name    = "Sergei"
    surname = "Shevtsov"
    ext_ip  = google_compute_address.external_ip.address
    int_ip  = google_compute_address.internal_ip.address
  })

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size  = "${var.hdd-size}"
      type  = "${var.hdd-type}"
    }

  }

  network_interface {
    #  count      = "${var.network-name}" == "default" ? 0 : 1
    network    = google_compute_network.zabbix_network.name    #"${var.network-name}"
    subnetwork = google_compute_subnetwork.zabbix_sub_net.name #"${var.sub-network-name}"
    network_ip = google_compute_address.internal_ip.address
    access_config {
      // Ephemeral IP
      nat_ip = google_compute_address.external_ip.address
    }
  }
}


#>>>>>>>>> create agent instance <<<<<<

resource "google_compute_instance" "zabbix_cli" {
  count        = 1
  name         = "zabbix-cli-${var.createway}"
  machine_type = "${var.machinetype}"
  zone         = "${var.zone}"
  description  = "create zabbix clients"
  tags         = ["zabbix-web"]
  metadata = {
    ssh-keys = "cmetaha17:${file("id_rsa.pub")}"
  }
  #    tags = var.tags
  #    labels = var.labels
  #metadata_startup_script = <<EFO
  #EFO
  metadata_startup_script = templatefile("startup-cli.sh", {
    name               = "Sergei"
    surname            = "Shevtsov"
    ip_zabbix_serv_int = google_compute_instance.default.network_interface.0.network_ip
  })

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size  = "${var.hdd-size}"
      type  = "${var.hdd-type}"
    }

  }

  network_interface {
    network    = google_compute_network.zabbix_network.name    #"${var.network-name}"
    subnetwork = google_compute_subnetwork.zabbix_sub_net.name #"${var.sub-network-name}"
    access_config {
      // Ephemeral IP
    }
  }
}
