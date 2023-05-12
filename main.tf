# Providers
terraform {
  required_version = ">= 1.0.11"
  # backend "remote" {
  #   hostname     = "app.terraform.io"
  #   organization = "bfg"

  #   workspaces {
  #     name = "gis_sonarqube_github"
  #   }
  # }
  required_providers {
    github = {
      version = "~>4.19.0"
    }
  }
}

# The TFC workspace accesses Github with a token. It's set as an env var named 'GITHUB_TOKEN'
# provider "github" {
#   owner = "bigfishgames"
# }

# Creates the Github organization secrets that contain the SonarQube token and URL
resource "github_actions_organization_secret" "sonar_token" {
  plaintext_value = var.sonar_token #This value is a protected TFC var
  secret_name     = "SONAR_TOKEN"
  selected_repository_ids = [ #Remove for access by all org repos
    "639904973",
  ]
  visibility = "selected" #Remove for access by all org repos
}

resource "github_actions_organization_secret" "sonar_host_url" {
  plaintext_value = var.sonar_host_url #This value is a protected TFC var
  secret_name     = "SONAR_HOST_URL"
  selected_repository_ids = [ #Remove for access by all org repos
    "639904973",
  ]
  visibility = "selected" #Remove for access by all org repos
}

#----------
# Variables
# variable "sonar_token" {
#   sensitive = true
# }

# variable "sonar_host_url" {
#   sensitive = true
# }
