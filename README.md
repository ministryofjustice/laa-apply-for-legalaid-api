# LAA Apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master)

* Ruby version
    * Ruby version 2.5.1
    * Rails 5

* System dependencies
    * postgres 10.5
    * npm

Install dependencies with homebrew:
```
brew bundle
```

## Initial setup

```
# From the root of the project execute the following command:
bin/setup
```

### Run the application server

```
bin/rails s
```

### Running tests

Runs Rubocop, RSpec specs and Cucumber features

```
bin/rake
```

**NOTE:** To ensure the recorded VCRs used in the specs are up to date, run the tests as such (this requires the a local API server to be up and running):

```
VCR_RECORD_MODE=all bin/rake
```
[There is an alternative setup procedure, using the makefile, which can be found here](README_alt.md)

## Deployment

The deployment is triggered on all builds in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid) but requires approval to the desired environment.

**NOTE:** **git-crypt** is required to store secrets required for **uat**, **staging** and **production** environments. To be able to modify those secrets, **git-crypt** needs to be set up according to the following [guide](https://ministryofjustice.github.io/cloud-platform-user-docs/03-other-topics/001-git-crypt-setup/#git-crypt).

For more deployment information refer to the specific [README](./helm_deploy/apply-for-legal-aid/README.md)

### UAT Deployments

**NOTE: Until an automated process is put in place to deal with this issue, once a branch has been merged into master or deleted, for which there's an associated release, the following commands should be executed to ensure those releases are deleted, as they're no longer necessary:**

```
# list the availables releases:
helm list --tiller-namespace=laa-apply-for-legalaid-uat --namespace=laa-apply-for-legalaid-uat --debug --all

# delete a specific release
helm delete <name-of-the-release> --tiller-namespace=laa-apply-for-legalaid-uat --purge
```
