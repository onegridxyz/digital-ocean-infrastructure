module "digitaloceandns" {
  terraform {
    required_providers {
      digitalocean = {
        source  = "digitalocean/digitalocean"
        version = "~> 2.0"
      }
    }
  }

  variable "do_token" {}

  provider "digitalocean" {
    token = var.do_token
  }

  resource "digitalocean_domain" "default" {
    name = "onegrid.xyz"
  }
}
