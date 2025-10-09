# Configuration du provider avec les credentials
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "cloudflare" {
  alias     = "r2"
  api_token = var.cloudflare_r2_api_token
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

variable "cloudflare_r2_api_token" {
  description = "Jeton d'API R2 Cloudflare"
  type        = string
  sensitive   = true
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

# Enregistrements CNAME
resource "cloudflare_record" "libretime" {
  zone_id = data.cloudflare_zone.main.id
  name    = "libretime"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "icecast" {
  zone_id = data.cloudflare_zone.main.id
  name    = "icecast"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "castopod" {
  zone_id = data.cloudflare_zone.main.id
  name    = "castopod"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "wordpress" {
  zone_id = data.cloudflare_zone.main.id
  name    = "www"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "status" {
  zone_id = data.cloudflare_zone.main.id
  name    = "status"
  content = "constructions-incongrues.github.io"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "wiki" {
  zone_id = data.cloudflare_zone.main.id
  name    = "wiki"
  content = "cartons.pastis-hosting.net"
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_r2_bucket" "superlarsen" {
  account_id = var.cloudflare_account_id
  name       = "superlarsen"
  provider = cloudflare.r2
  location = "EEUR"
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
  sensitive = true
  description = "Informations sur le bucket R2"
  value = {
    bucket_name = cloudflare_r2_bucket.superlarsen.name
    bucket_id   = cloudflare_r2_bucket.superlarsen.id
    access_key  = var.cloudflare_r2_access_key
    secret_key  = var.cloudflare_r2_secret_key
    endpoint    = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  }
}