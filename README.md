# tf-sonarqube-integration

## Description
This Terraform configuration deploys Sonarqube static code analysis configurations to targeted repos in the 'bigfishgames' Github org.  
The configurartion is dynamic and can identify new repos that are not currently part of the configuration.  
New repos that match the repo query have a branch, files and a PR created when the Terraform workspace is applied.  
The code analysis then becomes available in the Sonarqube UI when the PR containing the changes is merged into the default.  
Currently Java repos that use Gradle and Maven build tools need to have additional code committed to the created branch before it is merged.

## Resources
The Terraform workspace can be found at the following link-  
https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github

When a new repo matches the Github query of a calling module, the following resources will be created when Terraform is applied:
- A branch with commits for the following new files:
	- Github Action file for the appropriate language of the codebase
	- sonarqube properties file for configuring the Github Action
- A pull request to merge these changes into the default branch

### Resource Templating
The body of the PR and the Java Github Actions are generated using Terraform template files.

### Resource Changes
Some resources that are managed by this Terraform are changed externally; such as PR state changing from open to merged or closed, changes to etags, shas and ids. To accomodate this and still manage the resources, the 'ignore changes' argument in the lifecycle block is used to prevent Terraform from reverting them to their previous state.
```
  lifecycle {
    ignore_changes = [
      head_sha,
      state,
      updated_at,
    ]
  }
  ```

You may also see these preceeding any changes when running `terraform plan`
```
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply":

  # module.gradle_repos.github_branch.sonar_branch["catalog-sync-service"] has been changed
  ~ resource "github_branch" "sonar_branch" {
      ~ etag          = "W/\"ff11dde567b5bcd4b5667cc1134dfa2b94e8c90d40ba381efb22b11a1ccc63d3\"" -> "W/\"795050a0dee5a03eba2dcbd4365b5e5fcb4b2cdfecbd43f215fcae69a66ad7c6\""
        id            = "catalog-sync-service:sonarqube-implementation-poc"
      ~ sha           = "8bbabd4d89af90701e912a39b5dcf1a98ef0080e" -> "1a04bb4030b6d8edf37da22bd050e2111c0068ea"
        # (5 unchanged attributes hidden)
    }
```

## Usage
Terraform files and the Github Actions they deploy are located in the root of the repo.  
The module blocks in the `sonar_deployment.tf` file call the Sonarqube module and iterates over the matching repos.  

### Adding to the configuration
Add a similar block to the `sonar_depoloyment.tf` file.
```
module "php_repos" {
  source       = "./tf-modules/sonarqube"
  action_file  = "sonar_generic_action.yml"
  github_query = "org:bigfishgames magento language:PHP language:HTML archived:false"
}
```
These 3 arguments are required.  
To target a set of repos construct the Github query using the syntax in the following doc-  
https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories
The config appends `org:bigfishgames archived:false` to the query for the following reasons:
- The org token can only manage repos in the 'bigfishgames.com' org.
- Archived repos should not have changes made to them and are considered to not be in use.

## Logins, Secrets and Tokens
The following credentials provide the needed access to resources.
They are accessed by Terraform as workspace variables.  
https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables

### Github service account and Personal Access Token (PAT)
Grants access to the 'bigfishgames' Github org from Terraform Enterprise. 
- This token belongs to the service account 'bfg-github-sonarqube'
- The Github account is a 'bigfishgames' org owner
- User profile: https://github.com/bfg-github-sonarqube
- AD/Okta username: bfg-github-sonarqube@bigfishgames.com
- Currently in 'Phoenix' namespace on vault.bigfishgames.com
- The PAT is stored as a sensitive env var in the TF workspace

### Sonarqube Token
Grants access to Sonarqube Enterprise by the Github Action performing the code scan
- This token is stored as a sensitive var in the TF workspace
- Created in `main.tf` as a Github organization secret

# Issues
- Currently Java repos that use Gradle and Maven build tools need to have additional code committed to the created branch before it is merged.
- A Github Action is needed to automatically apply topics to Java repo using Gradle and Maven. Otherwise the topics need to be manually added.
- Terraform can have problems with branch and PR resources after they are merged or deleted if changes are detected.  
They may need to be removed from the TF state if errors are encountered in the TF workspace.  
Adding arguments to the `ignore_chages` list of the `lifecycle` block may prevent occurrances of this.
Example: `terraform state rm 'module.gradle_repos.github_repository_pull_request.sonar_pr["catalog-sync-service"]'`

# To Do
- [ ] Investigate unintended use of these Github Org Secrets, security issue?
- [ ] Deal with this warning after updating the Github provider version:
```
Warning: Additional provider information from registry
The remote registry returned warnings for registry.terraform.io/hashicorp/github:
- For users on Terraform 0.13 or greater, this provider has moved to integrations/github. Please update your source in required_providers.
```
- [ ] The Github org secrets are currently limited to the repos this is developed against and can be made all available repos by removing arguments from the resource in `main.tf`
- [ ] Change Github secret TF resources to use encrypted values for additional protection.
- [ ] Change Github service account Personal Access Token to expire at a set interval and schedule rotation.  
     This token currently does not expire.
- [ ] Pass all credentials with project.
- [ ] Configure Terraform workspace notifications; either Slack channel or email.
  https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/settings/notifications

# Help
This configuration was written by BFG Core Platform Team member denna.solon@bigfishgames.com.
You may contact me for help as needed.