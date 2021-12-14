# Terraform Cloud Workspace Variables
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables 

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

# Terraform and Github actions use the same interpolation syntax.
# To overcome using the action file as a template the Github interpolation needs to be set by Terraform.
variable "sonar_token" {
  description = "The Sonarqube token to access the BFG enterprise instance"
  default     = "$${{ secrets.SONAR_TOKEN }}"
}

variable "sonar_host_url" {
  description = "The Sonarqube URL of the BFG enterprise instance"
  default     = "$${{ secrets.SONAR_HOST_URL }}"
}

variable "github_runner_os" {
  description = "The OS of the Github Runner the action is running on" 
  default     = "$${{ os.runner }}"
}

variable "github_hash_files" {
  description = "Github files that the action will hash"
  default     = "$${{ hashFiles('**/*.gradle') }}"
}
