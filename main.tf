terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "jwtBaseSecret" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_database_db" "onegrid-coreapi-database" {
  cluster_id = digitalocean_database_cluster.postgres-onegrid.id
  name       = "coreapi"
}

resource "digitalocean_database_user" "onegridapiuser" {
  cluster_id = digitalocean_database_cluster.postgres-onegrid.id
  name       = "onegridapipostgresuser"
}

resource "digitalocean_database_cluster" "postgres-onegrid" {
  name       = "onegrid-postgres-cluster"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

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

    env {
      key   = "JHIPSTER_SECURITY_AUTHENTICATION_JWT_BASE64_SECRET"
      value = var.jwtBaseSecret
    }

    env {
      key   = "SPRING_DATASOURCE_URL"
      value = "jdbc:postgresql://${digitalocean_database_cluster.postgres-onegrid.private_uri}:${digitalocean_database_cluster.postgres-onegrid.port}/${digitalocean_database_cluster.postgres-onegrid.database}?user=${digitalocean_database_cluster.postgres-onegrid.user}&password=${digitalocean_database_cluster.postgres-onegrid.password}&prepareThreshold=0"
    }

    env {
      key   = "SPRING_LIQUIBASE_URL"
      value = "jdbc:postgresql://${digitalocean_database_cluster.postgres-onegrid.private_uri}:${digitalocean_database_cluster.postgres-onegrid.port}/${digitalocean_database_cluster.postgres-onegrid.database}?user=${digitalocean_database_cluster.postgres-onegrid.user}&password=${digitalocean_database_cluster.postgres-onegrid.password}&prepareThreshold=0"
    }
  }
}
