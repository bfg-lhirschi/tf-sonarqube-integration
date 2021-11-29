# Get a list of BFG PHP repos and pass that to get a list of repo objects.
data "github_repositories" "php_repos" {
  query = "org:bigfishgames magento language:PHP language:HTML archived:false"
}

data "github_repository" "php_repos" {
  for_each  = toset(local.php_repos)
  full_name = "bigfishgames/${each.value}"
}

locals {
  php_repos        = data.github_repositories.php_repos.names
  php_repo_details = data.github_repository.php_repos[*]
}

module "php_repos" {
  source         = "./tf-modules/sonarqube"
  for_each       = { for php_repos in local.php_repos : php_repos => php_repos }
  repo           = each.value
  action_file    = "sonar_generic_action.yml"
  default_branch = data.github_repository.php_repos[each.value].default_branch
}

# Outputs of repos passed to module
output "php_repos" {
  description = "List of repos that use php"
  value       = data.github_repositories.php_repos.full_names
}

/*
output "php_repo_details" {
  description = "A list of objects containing details about the repos"
  value       = data.github_repository.php_repos[*]
}
*/
