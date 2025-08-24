variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_server" "cartons" {
  name = "cartons"
}

resource "hcloud_volume" "superlarsen" {
  name      = "superlarsen"
  size      = 10 
  location  = "hel1-dc2"
  format    = "ext4"
  automount = true
  delete_protection = true
  server_id = data.hcloud_server.cartons.id
}

resource "hcloud_volume_attachment" "superlarsen_attachment" {
  volume_id = hcloud_volume.superlarsen.id
  server_id = data.hcloud_server.cartons.id
}
