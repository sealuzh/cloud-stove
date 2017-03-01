# Contribution Guide

Thank you for your interest in contributing to the Cloud Stove. Please note that the project adheres to the Contributor Covenant [code of conduct](./CODE_OF_CONDUCT.md). By participating in this project you are expected to uphold its terms.

Currently, the Cloud Stove is split across two repositories: the backend Rails app, and the frontend AngularJS application. This guide focuses on the backend Rails app.

## Setting Up a Development Environment

* Clone the Cloud Stove repository

  ```shell
  git clone git@github.com:inz/cloud-stove.git
  cd cloud-stove
  ```

- Install an appropriate Ruby version (the currently required version is specified in [.ruby-version](.ruby-version)). Install Ruby using [rbenv](http://rbenv.org) or [RVM](https://rvm.io).

  - If you're using rbenv, run  `rbenv install $(cat .ruby-version)`.
  - For RVM, run `rvm install $(cat .ruby-version)`.

- Install `phantomjs` for headless UI tests: http://phantomjs.org/download.html (`brew install phantomjs`)

- Set up dependencies and database for the Rails app:

  ```shell
  bin/setup
  ```

- Install the [or-tools MiniZinc distribution](https://github.com/inz/minizinc-dist/releases). There are pre-packaged binaries for macOS, Linux, and Windows (64 bit):

  macOS:
  ```shell
  curl -sSL https://github.com/inz/minizinc-dist/releases/download/minizinc-2.0.13_or-tools-v2016-06/minizinc-2.0.13_or-tools-v2016-06-darwin-vendor.tar.gz | tar xz -
  ```

  Linux:
  ```shell
  curl -sSL https://github.com/inz/minizinc-dist/releases/download/minizinc-2.0.13_or-tools-v2016-06/minizinc-2.0.13_or-tools-v2016-06-linux64-vendor.tar.gz | tar xz -
  ```

  Windows (64 bit only):
  ```shell
  curl -sSL https://github.com/inz/minizinc-dist/releases/download/minizinc-2.0.13_or-tools-v2016-06/minizinc-2.0.13_or-tools-v2016-06-win64-vendor.tar.gz | tar xz -
  ```

  Add `vendor/minizinc/bin` to your `PATH`:

  ```shell
  export PATH=$PWD/cloud-stove/vendor/minizinc/bin:$PATH
  ```

- Start the Rails server and job worker

  ```shell
  # Start the app server
  rails s -p 5000
  # In another terminal, start the worker job
  rake jobs:work

  # Alternatively, you can launch the app using foreman
  gem install foreman
  foreman start # Foreman will start both, the Rails app and the workers.
  ```

- You should now be able to access the backend at http://localhost:5000

- To set up the front check out the front end [contribution guide](https://github.com/sealuzh/cloud-stove-ui/blob/master/CONTRIBUTING.md)

## Making Changes

* [Fork](https://github.com/sealuzh/cloud-stove/fork) the project

* Pick a story from the backlog in the [List of issues](https://github.com/sealuzh/cloud-stove/issues) and assign it to yourself.

* Create a topic branch for your changes.

  ```shell
  git checkout -b <feature/my-awesome-feature>
  ```

  Namespaces: `feature/*`, `fix/*`, `hotfix/*`, `support/*`

* Make your change. Add tests for your change. Make the tests pass:

  ```shell
  bundle exec rake test
  ```

  * If tests fail with `sh: minizinc: command not found` make sure that your
    *or-tools* MiniZinc installation is in your `PATH`. If your `PATH` is set correctly
    and you still get the error, make sure that `spring` starts with the correct `PATH`:

    ```
    bin/spring stop
    PATH=vendor/minizinc/bin/:$PATH bundle exec rake test
    ```
    This should set the correct environment for the newly started `spring` process.

  * If tests fail with `Cannot access include directory .../share/minizinc/or-tools/`, make sure that the first MiniZinc binary in the `PATH` points to the *or-tools* distribution and not to any other MiniZinc implementation.
  * The wiki has further [troubleshooting tips](https://github.com/sealuzh/cloud-stove/wiki#troubleshooting).

* Make sure that your code always has good test coverage.

* Push your topic branch and [submit a pull request](https://github.com/sealuzh/cloud-stove/compare). To keep our project history clean, always rebase your changes onto master.

You should also periodically push your topic branches during development. That
way, there will always be a reasonably current backup of your work in the
upstream repository, and the whole team can get a feel on what others are
working on.

### Gemfile on Windows

Heroku ignores Gemfiles that are created on Windows. This might lead to unpredictable build failures. So far, we only committed `Gemfile.lock` changes on non-Windows machines. Refer to [Heroku Dev Center](https://devcenter.heroku.com/articles/bundler-windows-gemfile) for other options how to mitigate this problem.

## Tips and Tricks

* Continuous test execution and live reload:

  ```shell
  bundle exec guard
  ```

  * Automatically runs affected tests on file edit. Type `all` to manually run all tests.
  * Automatically reloads a page on asset modification via the following browser plugin: http://livereload.com/extensions/

* Lint factories

  ```shell
  rake factory_girl:lint
  ```

* Test Wercker CI build locally

  ```shell
  wercker build
  ```

  * Requires wercker CLI: http://wercker.com/cli/
  * Use `--attach-on-error` to debug failing builds
  * Use `--docker-local` to use locally cached containers

## Writing Tests

### Authentication

* Controller tests using `ActionController::TestCase` automatically create the `@user` and
  set the authentication headers for each request
* Integration tests can use the `sign_in(user)` helper method

### Controller Tests

* Access response as parsed JSON (e.g., `json_response['num_simultaneous_users']`)

   ```
   json_response
   ```

### Integration Tests

* Login a certain user:

   ```
   sign_in(user)
   ```

* Save a snapshot of the page during an integration test:

  ```
  show_page
  ```

  This will even sideload assets if a Rails server is running.

* Reload the current page:

  ```
  reload_page(page)
  ```
