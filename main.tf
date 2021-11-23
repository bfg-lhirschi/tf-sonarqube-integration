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
      #source  = "mycorp/mycloud"
      version = "~>4.17.0"
    }
  }
}

# To set access create an env var and PAT in the TFC workspace called 'GITHUB_TOKEN'
provider "github" {
  owner   = "bigfishgames"
}
