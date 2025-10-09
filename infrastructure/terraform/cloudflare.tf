terraform {
  required_version = ">= 1.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Provider pour DNS et gestion générale
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Provider pour R2 avec credentials spécifiques
provider "cloudflare" {
  alias     = "r2"
  api_token = var.cloudflare_r2_api_token
}

# Variables
variable "cloudflare_api_token" {
  description = "Token API Cloudflare pour DNS"
  type        = string
  sensitive   = true
}

variable "cloudflare_r2_api_token" {
  description = "Token API Cloudflare avec permissions R2"
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

variable "cloudflare_account_id" {
  description = "ID du compte Cloudflare"
  type        = string
}

# Data source pour la zone
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

# Enregistrements DNS
locals {
  cname_records = {
    libretime = "cartons.pastis-hosting.net"
    icecast   = "cartons.pastis-hosting.net"
    castopod  = "cartons.pastis-hosting.net"
    www       = "cartons.pastis-hosting.net"
    wiki      = "cartons.pastis-hosting.net"
    status    = "constructions-incongrues.github.io"
  }
}

resource "cloudflare_record" "cnames" {
  for_each = local.cname_records

  zone_id = data.cloudflare_zone.main.id
  name    = each.key
  content = each.value
  type    = "CNAME"
  ttl     = 300
  proxied = false
  comment = "Géré par Terraform"
}

# Bucket R2 avec le provider R2
resource "cloudflare_r2_bucket" "superlarsen" {
  provider   = cloudflare.r2
  account_id = var.cloudflare_account_id
  name       = "superlarsen"
  location   = "eeur"
}

# Outputs
output "zone_info" {
  description = "Informations sur la zone DNS"
  value = {
    zone_id = data.cloudflare_zone.main.id
    name    = data.cloudflare_zone.main.name
    status  = data.cloudflare_zone.main.status
  }
}

output "r2_bucket_info" {
  description = "Informations sur le bucket R2"
  value = {
    bucket_name = cloudflare_r2_bucket.superlarsen.name
    bucket_id   = cloudflare_r2_bucket.superlarsen.id
    location    = cloudflare_r2_bucket.superlarsen.location
  }
}