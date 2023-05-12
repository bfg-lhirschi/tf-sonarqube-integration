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
provider "github" {
  token = var.token
}

# Creates the Github organization secrets that contain the SonarQube token and URL
resource "github_actions_organization_secret" "sonar_token" {
  plaintext_value = "squ_66b2b597c98ace5953f0645b9eaf5642a3ca9a22s" #This value is a protected TFC var
  secret_name     = "SONAR_TOKEN"
  selected_repository_ids = [ #Remove for access by all org repos
    "639904973",
  ]
  visibility = "selected" #Remove for access by all org repos
}

resource "github_actions_organization_secret" "sonar_host_url" {
  plaintext_value =  "https://quality-staging.aristocrat.com/" #This value is a protected TFC var
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

variable "sonar_host_url" {
  description = "The Sonarqube URL of the BFG enterprise instance"
  default     = "https://quality-staging.aristocrat.com/" 
}

variable "sonar_token" {
  description  = "The Sonarqube token to access the BFG enterprise instance"
  #default     = "$${{ secrets.SONAR_TOKEN }}"
  default      = "squ_66b2b597c98ace5953f0645b9eaf5642a3ca9a22"
}

variable "token" {
  default = "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"
}