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

variable "cloudflare_zone_id" {
  description = "ID de la zone Cloudflare"
  type        = string
}

variable "cloudflare_account_id" {
  description = "ID du compte Cloudflare"
  type        = string
}

# Data source pour la zone
data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}

# Enregistrements DNS
locals {
  cname_records = {
    castopod  = "cartons.pastis-hosting.net"
    icecast   = "cartons.pastis-hosting.net"
    libretime = "cartons.pastis-hosting.net"
    sftp      = "cartons.pastis-hosting.net"
    status    = "constructions-incongrues.github.io"
    wiki      = "cartons.pastis-hosting.net"
    www       = "cartons.pastis-hosting.net"
  }
}

resource "cloudflare_record" "cnames" {
  for_each = local.cname_records

  zone_id = data.cloudflare_zone.main.id
  name    = each.key
  content = each.value
  type    = "CNAME"
  # Seul www passe par le proxy : castopod et libretime reçoivent des envois de plus de
  # 100 Mo (limite du plan Free), icecast est un flux continu, sftp n'est pas du HTTP.
  proxied = each.key == "www"
  ttl     = each.key == "www" ? 1 : 300 # un enregistrement proxifié est en TTL auto (1)
  comment = "Géré par Terraform"
}

# Caddy présente déjà un certificat valide pour www : Cloudflare le vérifie.
resource "cloudflare_zone_settings_override" "main" {
  zone_id = data.cloudflare_zone.main.id
  settings {
    ssl = "strict"
  }
}

# Le 2026-11-19, une rafale de « mot de passe oublié » a envoyé 11 mails en 58 s.
# Défi sur tout /wp-login.php : l'humain le passe en chargeant le formulaire (GET), son
# cookie cf_clearance (30 min) laisse passer l'envoi (POST) sans interstitiel. Un robot
# qui poste directement est arrêté. On ne filtre pas sur action=lostpassword : WordPress
# lit aussi l'action dans le corps du POST, que le plan Free ne sait pas inspecter.
resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = data.cloudflare_zone.main.id
  name        = "Règles personnalisées superlarsen.fr"
  description = "Géré par Terraform"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules {
    ref         = "defi_wp_login"
    description = "Défi sur wp-login.php (mot de passe oublié, connexion)"
    expression  = "(http.host eq \"www.superlarsen.fr\" and http.request.uri.path contains \"/wp-login.php\")"
    action      = "managed_challenge"
    enabled     = true
  }
}

# Bucket R2 avec le provider R2
resource "cloudflare_r2_bucket" "superlarsen" {
  provider   = cloudflare.r2
  account_id = var.cloudflare_account_id
  name       = "superlarsen"
  location   = "WEUR"
}

# Bucket R2 avec le provider R2 backups
resource "cloudflare_r2_bucket" "superlarsen_backups" {
  provider   = cloudflare.r2
  account_id = var.cloudflare_account_id
  name       = "superlarsen-backups"
  location   = "WEUR"
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

output "r2_bucket_backup_info" {
  description = "Informations sur le bucket R2"
  value = {
    bucket_name = cloudflare_r2_bucket.superlarsen_backups.name
    bucket_id   = cloudflare_r2_bucket.superlarsen_backups.id
    location    = cloudflare_r2_bucket.superlarsen_backups.location
  }
}