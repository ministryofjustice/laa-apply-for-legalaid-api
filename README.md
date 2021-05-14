
[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid.svg?style=shield)](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid/tree/master)
[![codecov](https://codecov.io/gh/ministryofjustice/laa-apply-for-legal-aid/branch/master/graph/badge.svg?token=DIINMJT9O9)](https://codecov.io/gh/ministryofjustice/laa-apply-for-legal-aid)

# LAA Apply for legal aid

The laa-apply-for-legal-aid system is a web service by use for solicitors providing legal aid services to enter applications for legal aid on-line.

## Table of Contents
- [**Architecture Diagram**](#architecture-diagram)
- [**Documentation for developers**](#documentation-for-developers)
- [**Dependencies**](#dependencies)
- [**Initial setup**](#initial-setup)
    - [Encrypting sensitive data](#encrypting-sensitive-data)
        - [Adding a new encrypted file](#adding-a-new-encrypted-file)
- [**Deployment**](#deployment)
    - [UAT Deployments](#uat-deployments)
- [**Dev: running locally**](#dev-running-locally)
    - [LAA Portal Authentication dev setup](#laa-portal-authentication-dev-setup)
    - [Authentication](#authentication)
        - [Live](#live)
        - [Development](#development)
    - [Post-authentication provider details retrieval](#post-authentication-provider-details-retrieval)
    - [Signing out of the application](#signing-out-of-the-application)
    - [How to set up localhost to use the portal](#how-to-set-up-localhost-to-use-the-portal)
    - [Benefits checker](#benefits-checker)
    - [Mock TrueLayer Data](#mock-trueLayer-data)
- [**Admin Portal**](#admin-portal)
- [**Monitoring & Debugging**](#monitoring--debugging)
- [**Databases**](#databases)
    - [Staging and Production](#staging-and-production)
- [**3rd party integrations**](#3rd-party-integrations)
    - [True Layer](#true-layer)
- [**Check Financial Eligibility Service**](#check-financial-eligibility-service)
- [**Legal Framework API Service**](#legal-framework-api-service)
- [**Geckoboard Dashboard**](#geckoboard-dashboard)
    - [1. Create a widget data provider](#1-create-a-widget-data-provider)
    - [2. Add a cronjob to run it](#2-add-a-cronjob-to-run-it)
    - [3. Add the widget to the Geckoboard dashboard](#3-add-the-widget-to-the-geckoboard-dashboard)
- [**Troubleshooting**](#troubleshooting)


## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#apply-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/Apply.kt) by anyone.

## Documentation for developers.

Documentation of certain parts of the system which are particularly complex can be found [here](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3020752222/Application+Development+Documentation)
* [GOVUK Notify and sending emails from Apply](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3028877542/Sending+emails+from+Apply)
* [ProceedingType Full Text search](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3028811988/Proceeding+Type+Full+Text+Search)
* [Legal Framework model associations](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/3024847884/Legal+Framework+model+associations)

## Dependencies

* Ruby version
    * Ruby version 3.0.1
    * Rails 6.0.3

* System dependencies
    * postgres 10.13
    * redis
    * yarn
    * wkhtmltopdf
    * libreoffice
    * clamav

Install dependencies with homebrew:
```
brew bundle
```

## Initial setup
This requires your gpg key to have been added to git-crypt.  Liaise with another developer to action the steps in [git-crypt.md](docs/git-crypt.md)

Once the pull request has been merged, re-pull master and run

```
git-crypt unlock
```
Copy the `.env.sample` file and name the new file `.env.development`

To get the tests running you will need to obtain and set values for the following:
```bash
GOVUK_NOTIFY_API_KEY=
CHECK_FINANCIAL_ELIGIBILITY_HOST=
LEGAL_FRAMEWORK_API_HOST=
```

To get the app in a usable state you will need to provide an admin password before running set up as seeding the admin user requires this value
```bash
ADMIN_PASSWORD=
```

From the root of the project execute the following command:
```
bin/setup
```

### Webpack Error

When localhost is returning ```Webpacker can't find styles.css in /Users/...```
(and ```rake webpack: compile``` may be returning
```Compilation failed: ModuleNotFoundError: Error: Can't resolve 'sass-loader' in /User...```)

on *master* run:
```
git pull
bundle install
rails db:migrate
rm -rf node_modules
rm -rf public/packs/
rm -rf public/packs-test/
yarn
rake webpacker:compile
RAILS_ENV=test rake webpacker:compile
```

Localhost should now be working.

### Encrypting sensitive data
We use git-crypt to encrypt sensitive data so that it can be stored in the same repo as all the other code,
yet still be inaccessible to unauthorised users.

#### Adding a new encrypted file
This can be a bit tricky, so follow these steps:
- ```git-crypt unlock <PATH_TO_FILE_CONTAINING_KEY>```
- Add a new line to `.gitattributes` to ensure the new file is encrypted

  ```<path_to_file_to_be_encrypted> filter=git-crypt diff=git-crypt```
- Add the file you want to be encrypted
- Add the new file to git, and commit it
  ```git add .```

  ```git comit -m '<message>```

- Lock the repo
  ```git-crypt lock```

You should now check by looking at the file either in your editor or on the command line to ensure the
file you've just added is in fact encrypted.


### Malware check of uploaded files

ClamAV is used to make sure uploaded files do not contain any malware.
If you are on Mac, ClamAV would have been installed by running `bin/setup`

On Ubuntu you can install it with:
```
sudo apt-get install clamav clamav-daemon -y
sudo freshclam
sudo /etc/init.d/clamav-daemon start
```

You may also need to run:
```
sudo apt install clamdscan
```

### Overcommit

Overcommit is a gem which adds git pre-commit hooks to your project. Pre-commit hooks run various
lint checks before making a commit. Checks are configured on a project-wide basis in .overcommit.yml.

To install the git hooks locally, run `overcommit --install`. If you don't want the git hooks installed, just don't run this command.

Once the hooks are installed, if you need to you can skip them with the `-n` flag: `git commit -n`

### Run the application server

```
bin/rails s
```

NOTE: You also need to start sidekiq and redis in separate terminal windows:

```
bundle exec sidekiq
```

```
redis-server
```

You can also use foreman to start the application server, sidekiq and redis with one command:

```
gem install foreman
foreman start -f Procfile
```

### Running tests

Ensure you have an .env.test file. This can be the same as your .env.development file

Set `BC_USE_DEV_MOCK=true`. This mocks the call to the benefits checker.

Runs Rubocop, RSpec specs and Cucumber features

```
bin/rake
```

**NOTE:** To ensure the recorded VCRs used in the specs are up to date, run the tests as such:

```
VCR_RECORD_MODE=all bin/rake
```

#### Guard

The repo also includes a Guardfile, this can be run in a terminal window
```sh
bundle exec guard
```

When changes to test files are made it will run the tests in that file
When changes are made to objects it will attempt to pattern match the appropriate tests and run them, e.g. changes to `app/models/applicant.rb` will run `spec/models/applicant_sepc.rb`
Ensuring your test files match the folder structure and naming convention will help guard monitor your file changes

#### pry-rescue

The repo also includes `pry-rescue`, a gem to allow faster debugging. Running
```
bundle exec rescue rspec
```
will cause any failing tests or unhandled exceptions to automatically open a `pry` prompt for immediate investigation.

## Deployment

The deployment is triggered on all builds in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-apply-for-legal-aid) but requires approval to the desired environment.

A build is only triggered by Circle CI when a pull request is opened in GitHub, this also applies to `Draft` pull requests.

**NOTE:** **git-crypt** is required to store secrets required for **uat**, **staging** and **production** environments.
To be able to modify those secrets, **git-crypt** needs to be set up according to the following
[guide](https://user-guide.cloud-platform.service.justice.gov.uk/tasks.html#git-crypt).

* For more information on howto setup **Helm** in your local environment refer to the following [guide](https://ministryofjustice.github.io/cloud-platform-user-docs/02-deploying-an-app/002-app-deploy-helm/#installing-and-configuring-helm-and-tiller).
* For more deployment information refer to the specific [README](./helm_deploy/apply-for-legal-aid/README.md)

### UAT Deployments

UAT deployments are automatically created and deleted as part of the Circle CI process. Once a pull request has been created on GitHub, Circle CI will create a deployment under the new branch name.
Once the branch has been merged with `master` the UAT deployment is deleted as part of the Circle CI process to deploy production.

In some cases a deployed branch will not be merged with `master` in which case the following commands can be used to manually delete the UAT deployment:

```
# list the availables releases:
helm list --namespace=laa-apply-for-legalaid-uat --debug --all

# delete a specific release
helm delete --namespace=laa-apply-for-legalaid-uat <name-of-the-release>
```

## Dev: running locally

### LAA Portal Authentication dev setup

Add the following to .env.development
```
LAA_PORTAL_IDP_SSO_TARGET_URL=https://portal.tst.legalservices.gov.uk/oamfed/idp/samlv20
LAA_PORTAL_IDP_CERT=< LAA_PORTAL_IDP_CERT (dev)>
LAA_PORTAL_CERTIFICATE=< LAA_PORTAL_CERTIFICATE (dev)>
LAA_PORTAL_SECRET_KEY=< LAA_PORTAL_SECRET_KEY(dev)>
LAA_PORTAL_MOCK_SAML=false
```
** Note the above keys can be found in LastPass

### Authentication

#### Live

Authentication is made to the LAA portal, which sends back a packet of data like this:

```
{
  "USER_EMAIL"=>[“a.user@example.com”],
  "LAA_APP_ROLES"=>["CWA_XXLSC_EM_ACT_REP,EMI,CCMS_Apply"],
  "LAA_ACCOUNTS"=>[“9X999X”]
}
```

These are translated by the devise_saml_authenticatable module to the appropriate fields on the provider using the mapping specified in `config/attribute-map.yml`.

#### Development

User login on dev can be mocked out by adding the the following settings

```
LAA_PORTAL_IDP_SSO_TARGET_URL=http://localhost:3002/saml/auth
LAA_PORTAL_MOCK_SAML=true
```

This will enable you to login as a provider with the usernames specified in `config/initializers/mock_saml.rb`.
Not that the provider firm_id is the same for `firm1-user1` and `firm1-user2`; all other users will belong to
different firms.  The password for all users is `password`.


### Post-authentication provider details retrieval
Once the provider has been authenticated, either by the portal or by the mock-saml mechanism described above,
an after_action method `#update_provider_details` on the `SamlSsessionsController` is executed. This will call
the `update_details` method on the current_provider (a Provider object supplied by Devise) whch generates
a background job to query the
provider details API and updates any details that have changed on the provider record.


### Signing out of the application

When using the mock-saml in development or on UAT, sign out works in the way you'd expect: Clicking signout takes you
to a page confirming your're signed out, and going to the start url will redirect you to the sign-in page.

When using the portal for authentication, (on staging or live, or if configured as described below, on localhost), the
sign out link takes you to a feedback page, but doesn't really sign you out.  This is an side effect of using the
portal Single Sign On system. You're not signed out until you tell the portal you've signed out, and when you do that,
you are signed out of all other applications at the same time. (Behind the scenes, the Devise `authenticate_provider!`
method contacts the portal to see if your signed in, and if so, repopulates the session with the required data).

You can sign out of the portal by going to https://portal.stg.legalservices.gov.uk/oam/server/logout

### How to set up localhost to use the portal

Setting up localhost to use the portal staging environment for signing in rather than the mock is fairly straightforward:

* change the values of the following environment variables in your .env file to the same values as in the Staging environment:
    * LAA_PORTAL_MOCK_SAML=false
    * LAA_PORTAL_IDP_CERT=<value from staging>
    * LAA_PORTAL_IDP_SLO_TARGET_URL=https://portal.stg.legalservices.gov.uk/oam/server/logout
    * LAA_PORTAL_SECRET_KEY=<value from staging>
    * LAA_PORTAL_IDP_SSO_TARGET_URL=https://portal.stg.legalservices.gov.uk/oamfed/idp/samlv20
    * LAA_PORTAL_CERTIFICATE=<value from staging>
    * LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM=<idp-cert-fingerprint-alg-goes-here>

  Note that the value for LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM is <idp-cert-fingerprint-alg-goes-here> and not replaced with anything else.

* Use the BENREID credientials from staging to log in (This use is set up as part of the `db:seed` rake task)

### Benefits checker

To mock the benefits check in development and testing add the following environment
variable:

```
BC_USE_DEV_MOCK=true
```

This will enable `MockBenefitCheckService`. See `MockBenefitCheckService::KNOWN for
credentials that will return 'Yes' for has qualifying benefits.

This environment variable should be set to ```false``` when recording new vcr cassettes otherwise the test will pass locally and fail on CircleCI.

### Mock TrueLayer Data

TrueLayer test data can be replaced by mock data from db/sample_data/bank_transactions.csv. This can be toggled in the Admin Portal at `/admin/settings`.

This mock data allows for testing with more meaningful bank transactions, including benefits data tagged with correct DWP codes.

## Admin Portal

The admin portal is at `/admin`. To access it in UAT, there must be an `AdminUser` defined.

If `ENV['ADMIN_PASSWORD']` returns a password, running `rake db:seed` will create an
admin user with username `apply_maintenance`, and that password, in all UAT deployments.

The admin portal is only accessible in Staging and Production using Google login for authorised accounts.

To allow reset mode within the admin portal, `ENV['ADMIN_ALLOW_RESET']` must return "true"

To allow the creation of test applications at different stages, for each provider,
`ENV['ADMIN_ALLOW_CREATE_TEST_APPLICATIONS']` must return "true". This is only available in the
Staging and UAT environments.

## Monitoring & Debugging

- To monitor the worker jobs execution you can access `/sidekiq`:
    - User: `sidekiq`
    - Password: `worker: webUiPassword` in the secrets.
- To access to the Site Administration Dashboard you need to point to `/support`.
  Credentials are the same as in the Admin Portal.

- To monitor Slack alerts from our service:
    - [UAT](https://mojdt.slack.com/messages/GGW4FCZBL)
    - [Staging](https://mojdt.slack.com/messages/GGWMW7M0F)
    - [Production](https://mojdt.slack.com/messages/GGWE9V9BP)

## Logging

To enable full logs in the test environment, `ENV['RAILS_ENABLE_TEST_LOG']` must return "true".

`ENV['RAILS_ENABLE_TEST_LOG']` defaults to nil (falsey) in order to reduce log pollution during testing.

## Databases

### Staging and Production

Staging and production databases are RDS instances on the MOJ Cloud Platform. Connection details are held in LastPass.

These databases are within the AWS VPC and are not publicly available. In order to connect
to an RDS database from a local client, first run:

`kubectl -n laa-apply-for-legalaid-staging port-forward port-forward-rds 5433:80`

This will then allow you to connect to the database, eg:

`psql --host=localhost --port=5433 --username=<username> --password --dbname=apply_for_legal_aid_staging`

- Change `staging` to `production` in the above commands to access production.
- Port 5433 is used in the above examples instead of the usual 5432 for postgres, as 5432 will not work if postgres

### Backups

Backups are taken daily at 5:40am and stored for 7 days, these are automated backups and cannot be deleted. The retention date can be changed.

A Cron Job takes hourly snapshots of the production database between 6am and 9pm. The previous days hourly backups are deleted at 7am each day, as these are superseded by the daily back up taken at 5.40am.

## Anonymised database export and restore

In order to create an anonymised dump of an environments database you can:

```bash
$ ./scripts/db_export.sh [environment]
```
Where environment is `production`, `staging` or a branch name from uat, e.g. `ap-1234`

It requires that you have kubectl authenticated and your context set to the current live context

It will connect to the required kubernetes namespace and pod and run the `rake db:export` task this will generate a filename of `[environment].anon.sql`

It will then copy the compressed restore file to the `tmp` folder in the project and de-compress it

If a file from the same environment exists, it will prompt you to overwrite the local copy

It will then output a restore command to enable you to restore it to your local psql instance at your convenience

A typical output for uat should resemble:
```
Finding pod for uat
Connecting to apply-ap-1234-apply-for-legal-aid-1234567890abc, anonymizing, compressing and exporting DB
Success
You can restore this locally by running:
 psql -q -P pager=off -d apply_for_legal_aid_dev -f ./tmp/uat.anon.sql
```

## 3rd party integrations

### True Layer

To connect the True Layer API, a client ID and client SECRET must be supplied. They can be
set via the environment variables `TRUE_LAYER_CLIENT_ID` and `TRUE_LAYER_CLIENT_SECRET`
respectively. Visit https://console.truelayer.com to get a client ID and client SECRET.

True Layer offer a Mock Bank option (see https://docs.truelayer.com/#mock-users). To enable
this functionality, set the environment variable `TRUE_LAYER_ENABLE_MOCK` to `"true"`.


## Check Financial Eligibility Service

The URL for this service should be set using the environment variable `CHECK_FINANCIAL_ELIGIBILITY_HOST`

## Legal Framework API Service

The URL for this service should be set using the environment variable  
`LEGAL_FRAMEWORK_API_HOST`

---

## Geckoboard Dashboard

Several sets of statistics are exported to Geckoboard for displaying on an application dashboard.

### How to add a new widget to the dashboard

There are three steps to creating a new widget for the Geckoboard dashboard

### 1. Create a widget data provider

Create a new class in the `app/models/dashboard/widget_data_providers` directory. This should define three class methods:

* `.handle` - the name of the widget, which will be qualified with a project name and environment.  For example `my_widget` would become `apply_for_legal_aid.production.my_widget` in the list of datasets on Geckoboard
* `.dataset_defintion` - the list of fields that will be in the dataset (see https://developer.geckoboard.com/hc/en-us/sections/360002865451-Getting-started for details on how to define and provide data for a dataset.)
* `.data` - the actual data that will be sent to Geckoboard every time it is run.

This data provider will be used by the `Dashboard::Widget` class when called with the name of the data provider as a parameter.

### 2. Add a cronjob to run it

Create a yaml configuration file for each cronjob under `./helm_deploy/apply_for_legal_aid/templates` by copying the `.dashboard_template_cron.yaml.sample` file and configure it to run the command `rake job:dashboard:update[the WidgetDataProvider class name here]` with
your chosen cron job schedule.

### 3. Add the widget to the Geckoboard dashboard

Once the job has been run at least once, you will be able to select the dataset as a data source when adding a new widget.

----



## Troubleshooting

Refer to the specific [README](./docs/troubleshooting.md)
