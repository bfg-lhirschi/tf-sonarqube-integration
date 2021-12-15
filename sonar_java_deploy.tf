# Create lists of BFG Java repos, then create lists of repo objects.

data "github_repositories" "gradle_repos" {
  query = "org:bigfishgames magento language:Java topic:gradle archived:false"
}

data "github_repository" "gradle_repos" {
  for_each  = toset(local.gradle_repos)
  full_name = "bigfishgames/${each.value}"
}

data "github_repositories" "maven_repos" {
  query = "org:bigfishgames language:Java topic:maven archived:false"
}

data "github_repository" "maven_repos" {
  for_each  = toset(local.maven_repos)
  full_name = "bigfishgames/${each.value}"
}

locals {
  gradle_repos    = data.github_repositories.gradle_repos.names
  gradle_repo_ids = data.github_repository.gradle_repos[*]
  maven_repos     = data.github_repositories.maven_repos.names
  maven_repo_ids  = data.github_repository.maven_repos[*]
}

#---------
# Implement SonarQube on repos based on their Java build tools
module "gradle_repos" {
  source          = "./tf-modules/sonarqube"
  for_each        = { for gradle_repos in local.gradle_repos : gradle_repos => gradle_repos }
  repo            = each.value
  java_build_tool = "gradle"
  action_file     = "sonar_java_action.yml"
  default_branch  = data.github_repository.gradle_repos[each.value].default_branch
}

/* #Functional but not in the current scope
module "maven_repos" {
  source          = "./tf-modules/sonarqube"
  for_each        = { for maven_repos in local.maven_repos : maven_repos => maven_repos }
  repo            = each.value
  java_build_tool = "maven"
  action_file     = "sonar_java_action.yml"
  default_branch  = data.github_repository.maven_repos[each.value].default_branch
}
*/

#---------
# Output lists of repos passed to module
output "gradle_repos" {
  description = "List of Java repos that use Gradle build tools"
  value       = data.github_repositories.gradle_repos.full_names
}

output "maven_repos" {
  description = "List of Java repos that use Maven build tools"
  value       = data.github_repositories.maven_repos.full_names
}
