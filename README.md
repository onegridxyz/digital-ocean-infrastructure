# digital-ocean-infrastructure

Digital Ocean Infrastructure

## Getting started for Developer

- Install Terraform cli.
- Tips: always run terraform validate before create Pull Request

```bash
# Step 1a: Install terraform. Skip this step if terraform cli is already installed.
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/terraform
# Step 1b: Update terraform if it was already installed.
$ brew update
$ brew upgrade hashicorp/tap/terraform
# Step 1c: Install terraform autocomplete
$ terraform -install-autocomplete

# Step 2: Format terraform files
$ terraform fmt
$ terraform fmt -check # check terraform format
$ terraform validate -no-color
```
