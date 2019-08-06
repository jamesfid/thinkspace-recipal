# [TestCafe](https://devexpress.github.io/testcafe/documentation/using-testcafe/)

## Node Dependency
* TestCafe requires `node` version `>=8.0.0`.
* You will need a `node` version manager like `nvm` to run TestCafe since the *Thinkspace* `ember-cli` requires `node` version `0.12.18`.

##### Using `nvm`
* `nvm ls` will list your *installed* `node` versions.
* `nvm ls-remote` will list the available `node` versions you can install.
* `nvm install 8.16.0` installs the latest version (`Carbon`) *if you do not already have a version 8 installed*.

The documentation below assumes using `nvm` and `node` version `8.16.0` (replace with your version if different).

## Install TestCafe Globally

1. `nvm use 8.16.0`
1. `npm install -g testcafe`

## Custom Run-Time Environment Variables

* `tc_user` (default `read_1`)
  1. Makes a *login* test re-usable with a different user.
  1. With a comma separated list, supplies different users for *simple* concurrency tests (e.g. `-c 2`). For example `tc_user=read_1,read_2`. This is not intended for *stress testing* many users.
* `tc_debug` (default `false`)
  1. `tc_debug=true` provides the capability to have custom debug points that can be turned on/off per run (instead of using the testcafe `-d` option which debugs every page).

## Selecting Tests

```bash
testcafe --list-browsers #=> lists the installed browser aliases e.g. firefox

# Use one of the browsers listed above:
testcafe firefox sample-test.js            #=> specific test
testcafe firefox:headless sample-test.js   #=> specific test in healess mode
testcafe firefox *my-tests* *other-tests*  #=> tests matching globs
```

The file-or-[glob](https://github.com/isaacs/node-glob#glob-primer) argument selects the test *files* or *directories* (separated by a space) to run.

## Running Tests

:notebook: **When performing *login* tests, be sure the *database* is seeded and the API, oauth and client servers are running.**

```bash
nvm use 8.16.0
cd my-path-to/thinkspace/client/testcafe/specs

testcafe firefox nav/space-case-phase.js
testcafe firefox nav/space-case-phase.js -d           #=> debug mode
testcafe firefox nav/space-case-phase.js --speed .01  #=> run slowest

tc_user=owner_1 testcafe firefox nav/space-case-phase.js #=> run using owner_1

# 2 concurent tests (first: read_1; second: read_2)
tc_user=read_1,read_2 testcafe -c 2 firefox,firefox nav/space-case-phase.js
```
**Some TestCafe command line options:**
* `-d`, `--debug-mode`
* `--speed <n>` : *n* can range from `.01` to `1`; `.01` is slowest; `1` is fastest (default)
* `--debug-on-fail`
* `-e`, `--skip-js-errors`

[See here for all testcafe options](https://devexpress.github.io/testcafe/documentation/using-testcafe/command-line-interface.html).


> Concurrent tests.
* If the test does a `login` and `logout` be sure to use a different user in each test, otherwise the second+ test(s) may fail if the user is logged out.
* Not sure why the concurent `-c 2` tests require `firefox,firefox` and opens four windows (tests run ok).  Maybe there is a way to prevent it.

## Custom Test Helpers

Custom test helpers are located in `client/testcafe/helpers`.

Need to `import` the required functions and/or constants.

* `roles.js`
  * Provides functions for `login` and `logout`.
* `selectors.js`
  * Provides some common index page *selectors* for `space`, `case`, `phase`, etc. e.g. `select.space`.
  * Also includes selectors for `first` and `last` e.g. `first.space`.
* `util.js`
  * Provides utility functions such as `print` and `get_user`.


## Sample Navigation Test
> Source was originally from `client/testcafe/specs/nav/space-case-phase.js`.

```javascript
import Util              from '../../helpers/util'
import { first }         from '../../helpers/selectors';
import { login, logout } from '../../helpers/roles'

fixture `navigation test`

test('nav-to space-case-phase', async t => {
  const filename = Util.basename(__filename)
  const user     = Util.get_user()

  Util.print.cyanb(` ${filename}: ${user}`)

  await login(user)

  await t
    .click(first.space)
    .click(first.case)
    .click(first.phase)

  if (Util.is_debug()) {await t.debug()}

  await logout(t)
})
```

## Test Actions/Assertions and Selectors
Almost all tests will use a **selector** to identify a page element to perform some action such as:   
  * `t.click('#submit_button')`, `t.click('.submit-btn')`
  * `t.typeText('#email', 'read_1@sixthedge.com')`

The same is true for assertions such as:
  * `t.expect(Selector('.team-member').withText('read_1').exists).ok()`

Therefore, including a *selector* `id`, `class`, etc.  (unique or common in a list) will make writing tests easier.
