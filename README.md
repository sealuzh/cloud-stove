![Cloud Stove](docs/images/logo.png)

# The Cloud Stove

[![wercker status](https://app.wercker.com/status/b08c91369210358a613023e743954dcb/s)](https://app.wercker.com/project/bykey/b08c91369210358a613023e743954dcb)

The [Cloud Stove](https://thestove.io) gives users deployment recommendations for their cloud applications. Application instances are derived from generic blueprints and enriched with the specific characteristics and requirements of the application to be deployed. Blueprints are generic application scaffolds that represent different application architectures to capture relevant differences in overall deployment strategies. Deployment recommendations are created by optimizing the use of available provider offerings with respect to the captured application specifications and requirements.

Frontend: <https://github.com/inz/cloud-stove-ui>

## Getting Started

You can access the current stable Cloud Stove release at [app.thestove.io](https://app.thestove.io/) and sign up for a free account. Check out the [user guide](./docs/User_Guide.md) for more information.

## Contributing to the Cloud Stove

Want to help make Cloud Stove better with your contribution? Great! Check out the [contribution guide](./CONTRIBUTING.md) for information on how to get your development environment up and running, and start contributing to the Stove.

## CI & Deployment

Since the Cloud Stove is largely follows 12factor app guidelines, deployment is relatively easy. We host a public deployment of the Cloud Stove on Heroku. You can also easily run your very own Cloud Stove deployment either on other buildpack-based PaaS like Cloud Foundry. For deployments on bare infrastructure, refer to the [contribution guide](./CONTRIBUTING.md) for steps necessary to get the application up and running.

### The Public Cloud Stove

Every push to the GitHub repository will initiate a CI build on [wercker](https://app.wercker.com/applications/5696592e29aa0a563912fe58). The current status of our CI builds is shown below.

[![wercker status](https://app.wercker.com/status/b08c91369210358a613023e743954dcb/m)](https://app.wercker.com/project/bykey/b08c91369210358a613023e743954dcb)

Successful CI builds are then deployed to a [Heroku pipeline](https://dashboard.heroku.com/pipelines/1296b077-f98d-4095-8352-09b35444cc15) with a staging application at <https://staging.backend.thestove.io>. To inspect and modify the staging app's configuration use the [application dashboard](https://dashboard.heroku.com/apps/fathomless-escarpment-2251-eu/).

The app uses the [rake-deploy-tasks](https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks) buildpack to automatically run pending migrations on deploy, as well as the [vendorbinaries](https://github.com/peterkeen/heroku-buildpack-vendorbinaries) buildpack to pull in a custom [MiniZinc release](https://github.com/inz/minizinc-dist) for generating recommendations.

### Self-hosted Deployment

The recommended way to deploy Cloud Stove is with [Heroku](https://heroku.com). You can deploy the app using their `free` dynos and the free PostgreSQL plan for test installations. To run the application, you will need one `web` dyno for the Rails application, a `worker` dyno to run background jobs, and an additional `web` dyno (probably deployed as separate application) for the AngularJS [frontend](https://github.com/inz/cloud-stove-ui). For production deployments, you should move to paid dynos to prevent your application from sleeping once your free dyno hours are spent.

To get started quickly, deploy the Cloud Stove using the button below:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

The application requires a set of config variables to successfully enable all features. You will need to configure the `rake-deploy-tasks` buildpack to execute migrations on deploy, as well as provide access tokens for Azure, Digital Ocean and Atlantic.net.

```shell
heroku config:set \
  DEPLOY_TASKS=db:migrate \
  DIGITALOCEAN_TOKEN=XXXXX \
  AZURE_SUBSCRIPTION_ID=XXXX \
  AZURE_TENANT_ID=XXXXX \
  AZURE_CLIENT_ID=XXXXX \
  AZURE_CLIENT_SECRET=XXXXX \
  ANC_ACCESS_KEY_ID=XXXXXX \
  ANC_PRIVATE_KEY=XXXXXX
```

As you can see, you will need API keys for Digital Ocean, Microsoft Azure, and Atlantic.net to successfully retrieve pricing data from these providers.

### Change admin password

An admin user with the email `admin@thestove.io` and the password `admin` is created while seeding the database.
Change the default password with the rake task:
```shell
rake user:update_admin[new_password]
```

## Communication & Organization

Planning and development of the Cloud Stove is coordinated using GitHub [wiki](https://github.com/inz/cloud-stove/wiki), [issues](https://github.com/inz/cloud-stove/issues), [milestones](https://github.com/inz/cloud-stove/milestones), and [pull requests](https://github.com/inz/cloud-stove/pulls). 

In the [Cloud Stove Roadmap](https://github.com/inz/cloud-stove/wiki/Roadmap), we discuss upcoming features and define milestones and issues to implement them.

Daily communication and coordination happens in our [Slack team](https://slack.thestove.io/).
