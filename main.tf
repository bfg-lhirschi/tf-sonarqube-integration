# Providers
terraform {
  required_version = "1.0.11"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bfg"

    workspaces {
      name = "gis_sonarqube_github"
    }
  }
  required_providers {
    github = {
      version = "~>4.17.0"
    }
  }
}

# The TFC workspace accesses Github with a token. It's set as an env var named 'GITHUB_TOKEN'
provider "github" {
  owner = "bigfishgames"
}

#----------
# Variables
variable "sonar_token" {
  sensitive = true
}

variable "sonar_host_url" {
  sensitive = true
}
