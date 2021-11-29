# Write Github secrets to Java repos
/* NOT FUNCTIONAL
resource "github_actions_organization_secret" "sonar_token" {
  secret_name             = "SONAR_TOKEN"
  visibility              = "selected"
  plaintext_value         = var.sonar_token #This value is a protected TFC var
  selected_repository_ids = local.java_repo_ids[*].*.repo_id
}
*/

# This works but we should be able to use an organizational secret instead. It will reduce the amount of resources being managed.
resource "github_actions_secret" "sonar_token" {
  repository  = var.repo
  secret_name = "SONAR_TOKEN"
  # Optionally use 'ecrypted_value' instead
  plaintext_value = var.sonar_token
}

resource "github_actions_secret" "sonar_host_url" {
  repository  = var.repo
  secret_name = "SONAR_HOST_URL"
  # Optionally use 'ecrypted_value' instead
  plaintext_value = var.sonar_host_url
}

#----------
# Create, commit and open PR to merge on default branch
resource "github_branch" "sonar_branch" {
  #count      = local.action_has_changes ? 0 : 1
  repository = var.repo
  branch     = var.sonar_branch
  source_branch = var.default_branch
  lifecycle {
    ignore_changes = all
  }
}

resource "github_repository_file" "sonar_properties" {
  repository = var.repo
  branch     = github_branch.sonar_branch.branch
  file       = "sonar-project.properties"
  content = templatefile("${path.module}/sonar-properties.template", {
    project_name = var.repo, project_key = var.repo
  })
  commit_message      = "Create sonarqube.properties file, managed by Terraform"
  commit_author       = "BFG-TF"
  commit_email        = "bfg-tf@bigfishgames.com"
  overwrite_on_create = true
}

resource "github_repository_file" "sonar_action" {
  repository          = var.repo
  branch              = github_branch.sonar_branch.branch
  file                = ".github/workflows/${var.action_file}"
  content             = file("./${var.action_file}")
  commit_message      = "Create sonarqube GH Action file, managed by Terraform"
  commit_author       = "bfg-tf"
  commit_email        = "bfg-tf@bigfishgames.com"
  overwrite_on_create = true
}

# There is currently a cyclical dep. problem when determining if the files have changes
locals {
  #properties_has_changes = base64sha256(github_repository_file.sonar_properties.content) != filebase64sha256("./.github/workflows/sonar-properties.template") ? true : false
  #action_has_changes     = base64sha256(github_repository_file.sonar_action.content) != filebase64sha256("./${var.action_file}") ? true : false
}

resource "github_repository_pull_request" "sonar_pr" {
  #count           = local.action_has_changes ? 0 : 1
  base_repository = var.repo
  base_ref        = var.default_branch 
  head_ref        = github_branch.sonar_branch.branch
  title           = "Sonarqube Static Code Analysis Implementation"
  body            = "PR message to teams here"

  depends_on = [
    github_repository_file.sonar_properties,
    github_repository_file.sonar_action,
  ]

  lifecycle {
    ignore_changes = all
  }
}
