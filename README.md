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

When a new repo is added the following resources will be created when Terraform is applied if it matches a Github query in the configuration:  
- Github Secret containing the token for accessing Sonarqube
- Github Secret containing the URL of the Sonarqube instance
- A branch which will contain commits for the following new files:
	- Github Action file for the main language in the repo
	- sonarqube properties file for configuring the Github Action
- A pull request for the created branch that the owning team will need to merge into the default branch

Some resources that are managed by this Terraform are changed externally such as PR state going from open to merged and changes to etags, shas and ids. To accomodate this and still manage them some resources use the 'ignore changes' argument in the lifecycle block to prevent Terraform attempting to revert these changes.
```
  lifecycle {
    ignore_changes = [
      head_sha,
      state,
      updated_at,
    ]
  }
  ```

You will also see these preceeding the TF plan changes like so:
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
These configurations call the root module and iterates over the matching repos of the data block.  
The data block returns a list of the repos and passes it to another data block which produces a list of maps containing details about the repo.  
The module is then called and iterates over each repo creating the resources mentioned in the previous section.  

## Adding to the configuration
Add a block similar to the one below to the file `sonar_depoloyment.tf`
```
module "php_repos" {
  source       = "./tf-modules/sonarqube"
  action_file  = "sonar_generic_action.yml"
  sonar_token  = var.sonar_token
  github_query = "org:bigfishgames magento language:PHP language:HTML archived:false"
}
```
These 4 arguments are required.  
To target a set of repos construct the Github query using the syntax in the following doc-  
https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories
You must exclude archived repos from your search. They cannot be modified and will cause TF failures.
Additional Github Actions can also be added to the repo and referenced in the calling module.

## Logins, Secrets and Tokens
The following credentials provide the needed access to resources.
They are accessed by Terraform as workspace variables.  
https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/variables

### Github service account and Personal Access Token (PAT)
Grants access to the 'bigfishgames' Github org from Terraform Enterprise.  
- This token belongs to the service account 'bfg-github-sonarqube'
- User profile: https://github.com/bfg-github-sonarqube
- AD/Okta username: bfg-github-sonarqube@bigfishgames.com
- Currently in Phoenix namespace on vault.bigfishgames.com
- The PAT is stored as a sensitive env var in the TF workspace

### Sonarqube Token
Grants access to Sonarqube Enterprise by the Github Action performing the code scan
- This token is stored as a sensitive var in the TF workspace
- Written to Github repos as a Github Secret

## [WIP] Automating Terraform workspace runs
The Terraform workspace can regularly deploy to new repos as they are created by automatically triggering runs via the API with Google Cloud Scheduler.  
If this 'cron as a service' is used the Terraform workspace should be configured to automatically apply following a successful plan. Otherwise human intervention is needed to click the 'apply' button for the run.

# Issues  
- Currently Java repos that use Gradle and Maven build tools need to have additional code committed to the created branch before it is merged.
- [ ] A Github Action is needed to automatically apply topics to Java repo using Gradle and Maven.

# To Do
- [ ] Change Github secret on repos to a 'bigfishgames' org secret.
- [ ] Change Github secret TF resources to use encrypted values for additional protection.
- [ ] Change Github service account Personal Access Token to expire at a set interval and schedule rotation.  
     This token currently does not expire.
- [ ] Pass all credentials with project.
- [ ] Configure Terraform workspace notifications; either Slack channel or email.
  https://app.terraform.io/app/bfg/workspaces/gis_sonarqube_github/settings/notifications
