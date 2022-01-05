# Calling modules to deploy SonarQube as Github Action.
# The 'github_query' argument should match the syntax defined in the following document:
# https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories

# Apply the Terraform run after merging changes into the 'main' branch of this repo.
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/runs
#---------

# Implement SonarQube on repos based on their Java build tools
module "gradle_repos" {
  source          = "./tf-modules/sonarqube"
  java_build_tool = "gradle"
  action_file     = "sonar_java_action.yml"
  sonar_token     = var.sonar_token
  github_query    = "magento language:Java topic:gradle "
}

module "maven_repos" {
  source          = "./tf-modules/sonarqube"
  java_build_tool = "maven"
  action_file     = "sonar_java_action.yml"
  sonar_token     = var.sonar_token
  github_query    = "language:Java topic:maven "
}

# Implement SonarQube on PHP based repos.
module "php_repos" {
  source       = "./tf-modules/sonarqube"
  action_file  = "sonar_generic_action.yml"
  sonar_token  = var.sonar_token
  github_query = "magento language:PHP language:HTML "
}

#---------
# Output lists of repos passed to module
/*
output "gradle_repos" {
  description = "List of Java repos that use Gradle build tools"
  value       = data.github_repositories.gradle_repos.full_names
}

output "maven_repos" {
  description = "List of Java repos that use Maven build tools"
  value       = data.github_repositories.maven_repos.full_names
}
*/
