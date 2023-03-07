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

# resource "digitalocean_database_db" "onegrid-coreapi-database" {
#   cluster_id = digitalocean_database_cluster.postgres-onegrid.id
#   name       = "coreapi"
# }

# resource "digitalocean_database_user" "onegridapiuser" {
#   cluster_id = digitalocean_database_cluster.postgres-onegrid.id
#   name       = "onegridapipostgresuser"
# }

# resource "digitalocean_database_cluster" "postgres-onegrid" {
#   name       = "onegrid-postgres-cluster"
#   engine     = "pg"
#   version    = "15"
#   size       = "db-s-1vcpu-1gb"
#   region     = "nyc1"
#   node_count = 1
# }

resource "digitalocean_app" "coreapi-app" {
  spec {
    name   = "coreapi-app"
    region = "nyc1"

    # domain

    service {
      name           = "coreapi-app-service"
      http_port      = 8080
      instance_count = 1


      image {
        registry_type = "DOCKER_HUB"
        registry      = "travistrle"
        repository    = "core-api"
        tag           = "latest"
      }
    }
    database {
      name         = "coreapi-db"
      engine       = "PG"
      production   = false
      cluster_name = "coreapi-cluster"
      db_name      = "coreapi"
      db_user      = "coreapiuser"
    }
  }
}
