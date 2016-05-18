# Making Changes

* Pick a story from the backlog in the [Development Board](https://trello.com/b/UC8jBtDg/cloud-stove-development) and assign yourself to it

* Create a topic branch for your changes.
  
  ```
  git checkout -b <feature/my-awesome-feature>
  ```

  Namespaces: `feature/*`, `fix/*`, `hotfix/*`, `support/*`

* Make your change. Add tests for your change. Make the tests pass:
  
  ```
  bundle exec rake test
  ```

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

* Save a snapshot of the page during an integration test:

  ```
  show_page
  ```

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
