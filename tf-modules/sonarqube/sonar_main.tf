# data "github_repositories" "github_repos" {
#   query = join(" ", [var.github_query, "org:bigfishgames", "archived:false"])
# }

# data "github_repository" "github_repos" {
#   for_each  = toset(data.github_repositories.github_repos.names)
#   full_name = "bigfishgames/${each.value}"
# }

# locals {
#   github_cache_hash       = local.java_build_tool == "gradle" ? "$${{ hashFiles('**/*.gradle') }}" : (local.java_build_tool == "maven" ? "$${{ hashFiles('**/pom.xml') }}" : null)
#   github_repos            = { for github_repos in data.github_repositories.github_repos.names : github_repos => github_repos }
#   java_build_cache_path   = local.java_build_tool == "gradle" ? "~/.gradle/caches" : (local.java_build_tool == "maven" ? "~/.m2" : null)
#   java_build_run          = local.java_build_tool == "gradle" ? "./gradlew sonarqube --info -Dsonar.host.url=$${{ secrets.SONAR_HOST_URL }} -Dsonar.login=$${{ secrets.SONAR_TOKEN }}" : (local.java_build_tool == "maven" ? "mvn -B verify sonar:sonar -Dsonar.projectKey=redemption-service -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_TOKEN -Denv.SHA=$${GITHUB_SHA::7} -Denv.TO=$NONPROD_CONTAINER_IMAGE" : null)
#   java_build_tool         = lower(var.java_build_tool)
#   java_permissions        = local.java_build_tool == "gradle" ? "chmod +x ./gradlew" : "echo No Maven file permission changes needed"
#   sonar_additional_config = var.github_action_file == "sonar_generic_action.yml" ? var.sonar_requirements_generic : (local.java_build_tool == "gradle" ? var.sonar_requirements_gradle : var.sonar_requirements_maven)
# }

#----------
# Create, commit and open PR to merge on default branch
resource "github_branch" "sonar_branch" {
  # for_each      = local.github_repos
  branch        = var.sonar_branch
  repository    = "levi-test02"
  # source_branch = data.github_repository.github_repos[each.value].default_branch
  source_branch = main
  lifecycle {
    ignore_changes = all
  }
}

resource "github_repository_file" "sonar_properties" {
  # for_each       = local.github_repos
  # repository     = each.value
  # branch         = github_branch.sonar_branch[each.value].branch
  repository     = "levi-test15"
  file           = "sonar-project.properties"
  commit_message = "Create sonarqube.properties file, managed by Terraform"
  commit_author  = "bfg-lhirschi"
  commit_email   = "levi.hirschi@bigfishgames.com"
  content        = templatefile("${path.module}/sonar-properties.template", {
    project_name = each.value,
    project_key  = each.value,
  })
  overwrite_on_create = true
  lifecycle {
    ignore_changes = all
  }
}

resource "github_repository_file" "sonar_action" {
  # for_each        = local.github_repos
  # repository      = each.value
  # branch          = github_branch.sonar_branch[each.value].branch
  branch          = github_branch.sonar_branch
  repository      = "levi-test02ß"
  file            = ".github/workflows/${var.github_action_file}"
  commit_message  = "Create sonarqube GH Action file, managed by Terraform"
  commit_author   = "bfg-github-sonarqube"
  # commit_email    = "bfg-github-sonarqube@bigfishgames.com"
  content         = templatefile(var.github_action_file, {
    github_default_branch = data.github_repository.github_repos[each.value].default_branch
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
  lifecycle {
    ignore_changes = all
  }
  overwrite_on_create = true
}

resource "github_repository_pull_request" "sonar_pr" {
  # for_each        = local.github_repos
  # base_repository = each.value
  base_repository = main
  base_ref        = data.github_repository.github_repos[each.value].default_branch
  head_ref        = github_branch.sonar_branch[each.value].branch
  title           = "Sonarqube Static Code Analysis Implementation"
  body            = replace(templatefile("${path.module}/sonar_pr_message.md", {
    additional_configuration = local.sonar_additional_config
    github_action_file       = var.github_action_file
    github_repo_name         = each.value
    java_build_tool          = local.java_build_tool
  }), "$${github_repo_name}", each.value)

  # The following files must be created before the PR
  depends_on = [
    github_repository_file.sonar_properties,
    github_repository_file.sonar_action,
  ]

  lifecycle {
    ignore_changes = [
      #body, #Changes if the PR message is ever updated
      head_sha,
      state,      #Changes when PR is merged or closed
      updated_at, #Changes if addional commits, etc are made.
    ]
  }
}

/*
output "sonar_repo_ids" {
  value = local.github_repos
}
*/

