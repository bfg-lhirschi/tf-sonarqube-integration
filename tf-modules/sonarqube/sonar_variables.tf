# Terraform Cloud Workspace Variables
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables 

variable "sonar_token" {
  description = "This variable overwritten by TFC workspace"
}

variable "sonar_host_url" {
  description = "This variable overwritten by TFC workspace"
  default = "https://quality-staging.aristocrat.com/"
}

variable "default_branch" {
  description = "The default repo branch to merge changes into"
  default = ""
}

variable "sonar_branch" {
  description = "Github branch for commits and PR"
  default     = "sonarqube-implementation-poc"
}

variable "repo" {
  description = "The repo to deploy Sonarqube to"
  default     = ""
}

variable "action_file" {
  description = "The Github action to deploy for use with Sonarqube"
  default     = "sonar_generic.yml"
}
