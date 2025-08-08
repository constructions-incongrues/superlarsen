# Configuration du provider Cloudflare
terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}

# Configuration du provider avec les credentials
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Variables
variable "cloudflare_api_token" {
  description = "Token API Cloudflare"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Nom de domaine principal"
  type        = string
  default     = "example.com"
}

variable "zone_id" {
  description = "ID de la zone Cloudflare"
  type        = string
}

variable "cloudflare_r2_access_key" {
  description = "Clé d'accès R2 Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_r2_secret_key" {
  description = "Clé secrète R2 Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "ID du compte Cloudflare"
  type        = string
}
# Data source pour récupérer les informations de la zone
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

# Enregistrement CNAME
resource "cloudflare_record" "libretime" {
  zone_id = data.cloudflare_zone.main.id
  name    = "libretime-superlarsen"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "icecast" {
  zone_id = data.cloudflare_zone.main.id
  name    = "icecast-superlarsen"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "castopod" {
  zone_id = data.cloudflare_zone.main.id
  name    = "castopod-superlarsen"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "wordpress" {
  zone_id = data.cloudflare_zone.main.id
  name    = "wordpress-superlarsen"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "status" {
  zone_id = data.cloudflare_zone.main.id
  name    = "status-superlarsen"
  content = "constructions-incongrues.github.io"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

# Outputs
output "zone_info" {
  description = "Informations sur la zone"
  value = {
    zone_id = data.cloudflare_zone.main.id
    name    = data.cloudflare_zone.main.name
    status  = data.cloudflare_zone.main.status
  }
}
