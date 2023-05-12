# Terraform Cloud Workspace Variables
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables 

variable "github_action_file" {
  description = "The Github action to deploy for use with Sonarqube"
  default     = "sonar_generic.yml"
}

variable "github_default_branch" {
  description = "The default repo branch to merge changes into"
  default     = ""
}

variable "github_query" {
  description = "The Github query that returns a list of repos"
}

variable "java_build_tool" {
  description = "The build tool used to generate Java artifacts"
  default     = ""
}

variable "sonar_branch" {
  description = "Github branch for commits and PR"
  default     = "github-sonarqube-implementation"
}

variable "sonar_host_url" {
  description = "The Sonarqube URL of the BFG enterprise instance"
  default     = "https://quality-staging.aristocrat.com/" 
}

variable "sonar_token" {
  description  = "The Sonarqube token to access the BFG enterprise instance"
  #default     = "$${{ secrets.SONAR_TOKEN }}"
  default      = "squ_66b2b597c98ace5953f0645b9eaf5642a3ca9a22"
}

# Variables for PR message templating
# Only add details that are implementation specific.
variable "sonar_requirements_generic" {
  description = "Any additional configuration the generic action can't implement on the codebase"
  default     = "If the `SonarScanner` check in this PR is failing, additional configuration may be before needed"
}

variable "sonar_requirements_gradle" {
  description = "Plugins, dependancies, etc. that TF can't implement for repos using Gradle build tools"
  default     = <<-EOT
  - Ensure that the `SonarScanner for Gradle` Github Action is passing and the results are available in the SonarQube Enterprise project that is created.  
  https://quality-staging.aristocrat.com/projects
  - If the `SonarScanner for Gradle` check in this PR is failing, additional configuration may be needed in `pom.xml` before merging.
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

variable "sonar_requirements_maven" {
  description = "Plugins, dependancies, etc. that TF can't implement for repos using Gradle build tools"
  default     = <<-EOT
  - Ensure that the `SonarScanner for Maven` Github Action is passing and the results are available in the SonarQube Enterprise project that is created.  
  https://quality-staging.aristocrat.com/projects
  - If the `SonarScanner for Maven` check in this PR is failing, additional configuration may be needed in `pom.xml` before merging.
  ```
  No specific Maven dependencies identified at this time.
  ```
  EOT
}
