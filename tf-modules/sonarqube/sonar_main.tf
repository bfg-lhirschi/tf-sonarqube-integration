variable "github_query" {
  description = "The Github query that returns a list of repos"
}

data "github_repositories" "github_repos" {
  query = join(" ", [var.github_query, "org:bigfishgames", "archived:false"])
}

data "github_repository" "github_repos" {
  for_each  = toset(data.github_repositories.github_repos.names)
  full_name = "bigfishgames/${each.value}"
}

locals {
  github_cache_hash     = local.java_build_tool == "gradle" ? "$${{ hashFiles('**/*.gradle') }}" : (local.java_build_tool == "maven" ? "$${{ hashFiles('**/pom.xml') }}" : null)
  github_pr_message     = var.action_file == "sonar_generic_action.yml" ? "generic_pr_message.md" : "${local.java_build_tool}_pr_message.md"
  github_repo_ids       = data.github_repository.github_repos[*]
  github_repos          = { for github_repos in data.github_repositories.github_repos.names : github_repos => github_repos }
  java_build_cache_path = local.java_build_tool == "gradle" ? "~/.gradle/caches" : (local.java_build_tool == "maven" ? "~/.m2" : null)
  java_build_run        = local.java_build_tool == "gradle" ? "./gradlew sonarqube --info -Dsonar.host.url=$${{ secrets.SONAR_HOST_URL }} -Dsonar.login=$${{ secrets.SONAR_TOKEN }}" : (local.java_build_tool == "maven" ? "mvn -B verify sonar:sonar -Dsonar.projectKey=redemption-service -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_TOKEN -Denv.SHA=$${GITHUB_SHA::7} -Denv.TO=$NONPROD_CONTAINER_IMAGE" : null)
  java_build_tool       = lower(var.java_build_tool)
  java_permissions      = local.java_build_tool == "gradle" ? "chmod +x ./gradlew" : "echo No Maven file permission changes needed"
}

# Write Github secrets to repos
# This works but we should be able to use an organizational secret instead. It will reduce the amount of resources being managed.
/*
resource "github_actions_secret" "sonar_token" {
  for_each    = local.github_repos
  repository  = each.value
  secret_name = "SONAR_TOKEN"
  # Optionally use 'ecrypted_value' instead
  plaintext_value = var.sonar_token
}

resource "github_actions_secret" "sonar_host_url" {
  for_each    = local.github_repos
  repository  = each.value
  secret_name = "SONAR_HOST_URL"
  # Optionally use 'ecrypted_value' instead
  plaintext_value = var.sonar_host_url
}
*/
#----------
# Create, commit and open PR to merge on default branch
resource "github_branch" "sonar_branch" {
  for_each      = local.github_repos
  branch        = var.sonar_branch
  repository    = each.value
  source_branch = data.github_repository.github_repos[each.value].default_branch
  lifecycle {
    ignore_changes = [etag]
  }
}

resource "github_repository_file" "sonar_properties" {
  for_each   = local.github_repos
  repository = each.value
  branch     = github_branch.sonar_branch[each.value].branch
  file       = "sonar-project.properties"
  content = templatefile("${path.module}/sonar-properties.template", {
    project_name = each.value,
    project_key  = each.value,
  })
  commit_message      = "Create sonarqube.properties file, managed by Terraform"
  commit_author       = "BFG-TF"
  commit_email        = "bfg-tf@bigfishgames.com"
  overwrite_on_create = true
}

resource "github_repository_file" "sonar_action" {
  for_each   = local.github_repos
  repository = each.value
  branch     = github_branch.sonar_branch[each.value].branch
  file       = ".github/workflows/${var.action_file}"
  content = templatefile(var.action_file, {
    default_branch        = data.github_repository.github_repos[each.value].default_branch
    github_cache_hash     = local.github_cache_hash
    github_runner_os      = "$${{ runner.os }}"
    github_token          = "$${{ secrets.GITHUB_TOKEN }}"
    java_build_cache_path = local.java_build_cache_path
    java_build_run        = local.java_build_run
    java_build_tool       = local.java_build_tool
    java_permissions      = local.java_permissions
    sonar_host_url        = "$${{ secrets.SONAR_HOST_URL }}"
    sonar_token           = "$${{ secrets.SONAR_TOKEN }}"
  })
  commit_message      = "Create sonarqube GH Action file, managed by Terraform"
  commit_author       = "bfg-tf"
  commit_email        = "bfg-tf@bigfishgames.com"
  overwrite_on_create = true
}

resource "github_repository_pull_request" "sonar_pr" {
  for_each        = local.github_repos
  base_repository = each.value
  base_ref        = data.github_repository.github_repos[each.value].default_branch
  head_ref        = github_branch.sonar_branch[each.value].branch
  title           = "Sonarqube Static Code Analysis Implementation"
  body            = templatefile("${path.module}/${local.github_pr_message}", {
    github_action_file = var.action_file
    java_build_tool    = local.java_build_tool
  })

  # The following files must be created before the PR is created
  depends_on = [
    github_repository_file.sonar_properties,
    github_repository_file.sonar_action,
  ]

  lifecycle {
    ignore_changes = [
      #body, #Changes if the PR message is ever updated
      head_sha,
      state,      #Changes to 'merged' when PR is merged
      updated_at, #Changes if addional commits, etc are made.
    ]
  }
}

output "sonar_repo_ids" {
  value = local.github_repos
}
