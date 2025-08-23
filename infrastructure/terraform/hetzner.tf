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
  size      = 10 # Taille en Go
  location  = "fsn1" # Remplace par la localisation de ton serveur
  format    = "ext4"
}

resource "hcloud_volume_attachment" "superlarsen_attachment" {
  volume_id = hcloud_volume.superlarsen.id
  server_id = hcloud_server.cartons.id
}
