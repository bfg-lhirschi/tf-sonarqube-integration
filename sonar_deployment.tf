/*
locals {
  gradle_repos    = data.github_repositories.gradle_repos.names
  gradle_repo_ids = data.github_repository.gradle_repos[*]
  maven_repos     = data.github_repositories.maven_repos.names
  maven_repo_ids  = data.github_repository.maven_repos[*]
}
*/

#---------
# Implement SonarQube on repos based on their Java build tools
module "gradle_repos" {
  source          = "./tf-modules/sonarqube"
  java_build_tool = "gradle"
  action_file     = "sonar_java_action.yml"
  sonar_token     = var.sonar_token
  github_query    = "org:bigfishgames magento language:Java topic:gradle archived:false"
}

#Functional but not in the current scope
module "maven_repos" {
  source          = "./tf-modules/sonarqube"
  java_build_tool = "maven"
  action_file     = "sonar_java_action.yml"
  sonar_token     = var.sonar_token
  github_query    = "org:bigfishgames language:Java topic:maven archived:false"
}

# Implement SonarQube on PHP based repos.
module "php_repos" {
  source       = "./tf-modules/sonarqube"
  action_file  = "sonar_generic_action.yml"
  sonar_token  = var.sonar_token
  github_query = "org:bigfishgames magento language:PHP language:HTML archived:false"
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
