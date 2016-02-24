# Making Changes

* Pick a story from the backlog in the [Development Board](https://trello.com/b/UC8jBtDg/cloud-stove-development) and assign yourself to it

* Create a topic branch for your changes.
  
  ```
  git checkout -b <my-awesome-feature>
  ```

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