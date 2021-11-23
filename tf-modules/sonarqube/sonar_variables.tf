# Variables
variable "sonar_token" {
  description = "Protected TFC variable"
  default     = "local-test-value"
}

variable "sonar_host_url" {
  description = "Protected TFC variable"
  default     = "local-test-value"
}

variable "sonar_project" {
  description = "The Sonarqube ent. project to associate the scan with"
  default     = "BigfishgamesOrg-SonarQube-Staging"
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
