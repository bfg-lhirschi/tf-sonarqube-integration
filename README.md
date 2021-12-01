# tf-sonarqube-integration

## Description
This Terraform configuration manages repo settings that make  Sonarqube static code analysis available to included repos.  
The configurartion is dynamic in that it will deploy these configurations to new repos that match Github queries of the BFG repos.

## Requirements
--(Add Github service account requirements here)--  
--(Add Terraform requirements here)--  

## Resources
The Terraform workspace can be found at the following link-  
https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github

When a new repo is added the following resources will be created when Terraform is applied if it matches a Github query in the configuration:  
- Github Secret containing the token for accessing Sonarqube
- Github Secret containing the URL of the Sonarqube instance
- A branch containing commits for the following new files:
	- Github Action file for the main language in the repo
	- sonarqube properties file for configuring the Github Action
- A pull request for the created branch that the owning team will need to merge into the default branch

## Usage
Terraform files and the Github Actions they deploy are located in the root of the repo.  
These configurations call the root module and iterates over the matching repos of the data block.  
The data block returns a list of the repos and passes it to another data block which produces a list of maps containing details about the repo.  
The module is then called and iterates over each repo creating the resources mentioned in the previous section.  

## Adding to the configuration
Additions can be made to this configuration without the need to change the logic the module uses.
To do so modify the following code block appropriately and add it to a new Terraform file or to an existing configuration.  

```
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

#----------
module "php_repos" {
  source         = "./tf-modules/sonarqube"
  for_each       = { for php_repos in local.php_repos : php_repos => php_repos }
  repo           = each.value
  action_file    = "sonar_generic_action.yml"
  default_branch = data.github_repository.php_repos[each.value].default_branch
}
```
Additional Github Actions can also be added to the root of the repo and referenced in the calling module if needed.

## [WIP] Automating Terraform workspace runs
The Terraform workspace can regularly deploy to new repos as they are created by automatically triggering runs via the API with Google Cloud Scheduler.  
If this 'cron as a service' is used the Terraform workspace should be configured to automatically apply following a successful plan. Otherwise human intervention is needed to click the 'apply' button for the run.

## Notifications
The Terraform Cloud workspace can have email or Slack notifications configured to alert a group of users when the workspace takes an action and has a specific event outcome.  
https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/settings/notifications

