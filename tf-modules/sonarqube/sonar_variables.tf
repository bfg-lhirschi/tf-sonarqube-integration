# Terraform Cloud Workspace Variables
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables 

variable "default_branch" {
  description = "The default repo branch to merge changes into"
  default     = ""
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
  description  = "The Sonarqube token to access the BFG enterprise instance"
  #default     = "$${{ secrets.SONAR_TOKEN }}"
}

variable "sonar_host_url" {
  description = "The Sonarqube URL of the BFG enterprise instance"
  default     = "https://quality-staging.aristocrat.com/" 
}

variable "java_build_tool" {
  description = "The build tool used to generate Java artifacts"
  default     = ""
}

# Variables for PR message templating
variable "generic_requirements" {
  description = "Any additional configuration the generic action can't implement on the codebase"
  default     = "If the above check is failing additional configuration may be need to be committed to this branch before merging this PR."
}

variable "gradle_requirements" {
  description = "Plugins, dependancies, etc. that TF can't implement for repos using Gradle build tools"
  default     = <<-EOT
  - Ensure that the `SonarScanner for Gradle` Github Action is passing and the results are available in the SonarQube Enterprise project that is created.  
  https://quality-staging.aristocrat.com/projects
  - If the above check is failing, additional `build.gradle` configuration may need to be committed to this branch before merging this PR.
  ```
  plugins {
      id "org.sonarqube" version "3.0"
  }

  sonarqube {
      properties {
          property 'sonar.projectName', '$${github_repo_name}'
      }
  }

  dependencies {
      implementation "org.sonarsource.scanner.gradle:sonarqube-gradle-plugin:3.0"
  }
  ```
  EOT
}

variable "maven_requirements" {
  description = "Plugins, dependancies, etc. that TF can't implement for repos using Gradle build tools"
  default     = <<-EOT
  - Ensure that the `SonarScanner for Maven` Github Action is passing and the results are available in the SonarQube Enterprise project that is created.  
  https://quality-staging.aristocrat.com/projects
  - If the above check is failing, additional `pom.xml` configuration may need to be committed to this branch before merging this PR.
  ```
  Any specific Maven configuratione here

  ```
  EOT
}