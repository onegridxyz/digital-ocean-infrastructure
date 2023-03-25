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
variable "logTailApiKey" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_database_connection_pool" "pool-onegrid" {
  cluster_id = digitalocean_database_cluster.postgres-onegrid.id
  name       = "pool-onegrid"
  mode       = "transaction"
  size       = 22
  db_name    = "defaultdb"
  user       = "doadmin"
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
    domain {
      name = "gateway.onegrid.xyz"
      zone = "onegrid.xyz"
    }
    service {
      name           = "coreapi-app-service"
      http_port      = 8080
      instance_count = 1
      # instance_size_slug: https://docs.digitalocean.com/reference/api/api-reference/#operation/apps_list_instanceSizes
      instance_size_slug = "basic-xs"

      image {
        registry_type = "DOCKER_HUB"
        registry      = "travistrle"
        repository    = "core-api"
        tag           = "latest"
      }

      log_destination {
        name = "coreApiLogTail"
        logtail {
          token = var.logTailApiKey
        }
      }
    }

    env {
      key   = "JHIPSTER_SECURITY_AUTHENTICATION_JWT_BASE64_SECRET"
      value = var.jwtBaseSecret
    }

    env {
      key   = "SPRING_DATASOURCE_URL"
      value = "jdbc:postgresql://${digitalocean_database_connection_pool.pool-onegrid.host}:${digitalocean_database_connection_pool.pool-onegrid.port}/pool-onegrid?user=${digitalocean_database_cluster.postgres-onegrid.user}&password=${digitalocean_database_cluster.postgres-onegrid.password}&prepareThreshold=0"
    }

    env {
      key   = "SPRING_LIQUIBASE_URL"
      value = "jdbc:postgresql://${digitalocean_database_connection_pool.pool-onegrid.host}:${digitalocean_database_connection_pool.pool-onegrid.port}/pool-onegrid?user=${digitalocean_database_cluster.postgres-onegrid.user}&password=${digitalocean_database_cluster.postgres-onegrid.password}&prepareThreshold=0"
    }
  }
}

resource "digitalocean_app" "customer-portal" {
  spec {
    name   = "customer-portal"
    region = "nyc"
    domain {
      name = "playground.onegrid.xyz"
      zone = "onegrid.xyz"
    }
    static_site {
      name              = "customer-portal"
      catchall_document = "index.html"
      routes {
        path = "/"
      }

      github {
        repo           = "onegridxyz/customer-portal-deploy"
        branch         = "main"
        deploy_on_push = true
      }

      env {
        key   = "CORE_API_URL"
        value = digitalocean_app.coreapi-app.live_url
      }
    }
  }
}


resource "digitalocean_app" "one-app" {
  spec {
    name   = "one-app"
    region = "nyc1"
    domain {
      name = "www.onegrid.xyz"
      zone = "onegrid.xyz"
    }
    service {
      name           = "one-app-service"
      instance_count = 1
      # instance_size_slug: https://docs.digitalocean.com/reference/api/api-reference/#operation/apps_list_instanceSizes
      instance_size_slug = "basic-xxs"
      image {
        registry_type = "DOCKER_HUB"
        registry      = "travistrle"
        repository    = "one-app"
        tag           = "latest"
      }
      env {
        key   = "CORE_API_URL"
        value = digitalocean_app.coreapi-app.live_url
      }
    }
  }
}
