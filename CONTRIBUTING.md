# Making Changes

* Create a topic branch for your changes.
  
  ```
  git checkout -b <my-awesome-feature>
  ```

* Make your change. Add tests for your change. Make the tests pass:
  
  ```
  bundle exec rake test
  ```

* Push your topic branch and [submit a pull request](https://github.com/inz/cloud-stove/compare). 

You should also periodically push your topic branches during development. That
way, there will always be a reasonably current backup of your work in the
upstream repository, and the whole team can get a feel on what others are
working on.