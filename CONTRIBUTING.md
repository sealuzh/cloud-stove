# Making Changes

* Pick a story from the backlog in the [List of issues](https://github.com/inz/cloud-stove/issues) and assign yourself to it

* Create a topic branch for your changes.
  
  ```
  git checkout -b <feature/my-awesome-feature>
  ```

  Namespaces: `feature/*`, `fix/*`, `hotfix/*`, `support/*`

* Make your change. Add tests for your change. Make the tests pass:
  
  ```
  bundle exec rake test
  ```
  
  * If tests fail with `sh: minizinc: command not found` make sure that your
    *or-tools* MiniZinc installation is in your `PATH`. If your `PATH` is set correctly
    and you still get the error, make sure that `spring` starts with the correct `PATH`:
  
    ```
    bin/spring stop
    PATH=<path/to/minizinc/bin>/:$PATH bundle exec rake test
    ```
    This should set the correct environment for the newly started `spring`
    process.

  * If tests fail with `Cannot access include directory .../share/minizinc/or-tools/`,
    make sure that the first MiniZinc binary in the `PATH` points to the *or-tools* distribution
    and not to any other MiniZinc implementation.
  * The wiki has further [troubleshooting tips](https://github.com/inz/cloud-stove/wiki#troubleshooting).

* Make sure that your code always has appropriate test coverage.

* Push your topic branch and [submit a pull request](https://github.com/inz/cloud-stove/compare). To keep our project history clean, always rebase your changes onto master.

You should also periodically push your topic branches during development. That
way, there will always be a reasonably current backup of your work in the
upstream repository, and the whole team can get a feel on what others are
working on.

## Tips and Tricks

* Continuous test execution and live reload:

  ```
  bundle exec guard
  ```

  * Automatically runs affected tests on file edit. Type `all` to manually run all tests.
  * Automatically reloads a page on asset modification via the following browser plugin: http://livereload.com/extensions/

* Lint factories

    ```
    rake factory_girl:lint
    ```

* Test Wercker CI build locally

  ```
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
