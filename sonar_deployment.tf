# Calling modules to deploy SonarQube as Github Action.
# The 'github_query' argument should match the syntax defined in the following document:
# https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories
# The module appends 'org:bigfishgames archived:false' to the github_query arguments.

# Apply the Terraform workspace after merging changes into the 'main' branch of this repo.
# https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/runs

# Implement SonarQube on repos based on their Java build tools
module "gradle_repos" {
  source             = "./tf-modules/sonarqube"
  java_build_tool    = "gradle"
  github_action_file = "sonar_java_action.yml"
  sonar_token        = var.sonar_token
  github_query       = "magento language:Java topic:gradle "
}

module "maven_repos" {
  source             = "./tf-modules/sonarqube"
  java_build_tool    = "maven"
  github_action_file = "sonar_java_action.yml"
  sonar_token        = var.sonar_token
  github_query       = "language:Java topic:maven "
}

# Implement SonarQube on PHP based repos.
module "php_repos" {
  source             = "./tf-modules/sonarqube"
  github_action_file = "sonar_generic_action.yml"
  sonar_token        = var.sonar_token
  github_query       = "magento language:PHP language:HTML "
}
