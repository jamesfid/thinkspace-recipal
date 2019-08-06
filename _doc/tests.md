## Overview
* The `totem-test` and `thinkspace-test` engines are used to test Totem and Thinkspace.
* Other engines do not have a `test` folder.
* The rake command must include `RAILS_ENV=test` (run in the test environment).
* Tests are located in `totem-test/test` and `thinkspace-test/test`.
* For Thinkspace tests, need to `source .env-test` since the tests typically require using the database.

## `rake thinkspace:test RAILS_ENV=test`

> **If is a *new* test database or the schema has changed, first ensure you have sourced the `.env-test` then run a `rake db:reset RAILS_ENV=test`.**

* `rake thinkspace:test RAILS_ENV=test SEED=true` : run all tests
* `rake thinkspace:test[directory] RAILS_ENV=test SEED=true` : only run tests in the directory
* `rake thinkspace:test[directory-glob] RAILS_ENV=test SEED=true` : only run tests matching the directory glob

> * NOTE: The task arguments (string between the `[]`) can be a comma separated list that includes a *directory*, *directory-glob* or both.
* NOTE: After running tests with `SEED=true`, can re-run the *same* tests without doing a seed by removing the `SEED=true` or setting to a non-true string e.g. `SEED=truex`.  This is possible since the testing database changes are rolled-back after each test.
* NOTE: `SEED=true` *resets* the database (delete records but does not do a schema load).  The test seed process will only run a test seed config **once** during a test run.

## `rake totem:test RAILS_ENV=test`
> Currently none of the totem tests use the database (they use fixtures).

* `rake totem:test RAILS_ENV=test` : run all tests
* `rake totem:test[directory] RAILS_ENV=test` : only run tests in the directory
* `rake totem:test[directory-glob] RAILS_ENV=test` : only run tests matching the directory glob

## Directory Examples
>* Adding `VIEW_ONLY=true` or `VO=true`, the task will list the tests selected but not run them.
* Adding `BACKTRACE=1` will print a ruby backtrace on all test errors.

All test paths are relative to `thinkspace-test/test`.

* `rake thinkspace:test RAILS_ENV=test SEED=true`
  * *run all tests*
* `rake thinkspace:test[clone] RAILS_ENV=test SEED=true`
  * *run all tests in the `clone` directory*
* `rake thinkspace:test[clone,timetable] RAILS_ENV=test SEED=true`
  * *run all tests in the `clone` and `timetable` directories*
* `rake thinkspace:test[clone/phase] RAILS_ENV=test SEED=true`
  * *run the `clone/phase_test.rb` test*
* `rake thinkspace:test[phase_actions/**/unlock] RAILS_ENV=test SEED=true`
  * *run the `phase_actions/action/submit/unlock_test.rb`*
* `rake thinkspace:test[phase_actions/**/phase*] RAILS_ENV=test SEED=true`
  * *run any test that starts with `phase` e.g. `phase_actions/action/submit/phase_scores_test.rb`, `phase_actions/action/submit/phase_states_test.rb`, etc.*
* `rake thinkspace:test[clone,timetable/model/assignment] RAILS_ENV=test SEED=true`
  * *run all test in the `clone` directory and the test `timetable/model/assignment_test.rb`*
