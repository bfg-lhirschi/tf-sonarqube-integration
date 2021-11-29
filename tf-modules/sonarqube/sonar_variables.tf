# Terraform Cloud Workspace Variables
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables 
variable "sonar_token" {
  default = ""
}

variable "sonar_host_url" {
  default = ""
}

variable "sonar_project" {
  description = "The Sonarqube ent. project to associate the scan with"
  default     = "BigfishgamesOrg-SonarQube-Staging"
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
