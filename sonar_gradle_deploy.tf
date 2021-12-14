# Get a list of BFG Java repos and pass that to get a list of repo objects.
data "github_repositories" "java_repos" {
  query = "org:bigfishgames magento language:Java topic:gradle archived:false"
}

data "github_repository" "java_repos" {
  for_each  = toset(local.java_repos)
  full_name = "bigfishgames/${each.value}"
}

locals {
  java_repos    = data.github_repositories.java_repos.names
  java_repo_ids = data.github_repository.java_repos[*]
}

#---------
module "java_repos" {
  source         = "./tf-modules/sonarqube"
  for_each       = { for java_repos in local.java_repos : java_repos => java_repos }
  repo           = each.value
  action_file    = "sonar_gradle_action.yml"
  default_branch = data.github_repository.java_repos[each.value].default_branch
}

# Outputs of repos passed to module
output "java_repos" {
  description = "List of repos that use Java"
  value       = data.github_repositories.java_repos.full_names
}

/*
output "java_repo_ids" {
  description = "List of repo maps"
  value       = local.java_repo_ids
}
*/
