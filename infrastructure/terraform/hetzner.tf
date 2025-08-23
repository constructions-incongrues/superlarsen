provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_volume" "superlarsen" {
  name      = "superlarsen"
  size      = 10 # Taille en Go
  location  = "fsn1" # Remplace par la localisation de ton serveur
  format    = "ext4"
}

resource "hcloud_volume_attachment" "superlarsen_attachment" {
  volume_id = hcloud_volume.superlarsen.id
  server_id = hcloud_server.existing_server.id
}

# Remplace cette ressource par la définition de ton serveur existant
data "hcloud_server" "existing_server" {
  name = "cartons"
}