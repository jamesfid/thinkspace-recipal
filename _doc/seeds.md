## Overview
* The `totem-seed` and `thinkspace-seed` engines are used to seed the Thinkspace database.
* Other engines do not have a `db/seed_data` folder nor a `db/seeds.rb` file.
* Database records are *defined* using `.yml` config file(s) in `thinkspace-seed/db/seed_data`.
* Database records are *created* by helpers in `thinkspace-seed/app/helpers/thinkspace/seed`.
* The Thinkspace seed loader is located at `thinkspace-seed/app/loader/thinkspace/seed/seed.rb`.

## `rake totem:db:reset`
* Invokes tasks:
  1. `db:reset` (Rails task)
  1. `totem:db:domain:load`
  1. `totem:db:seed`
  1. `thinkspace:db:seed`
* Task `thinkspace:db:seed` does the work of seeding the database. Typically is it run via `totem:db:reset` but it can be run by itself `rake thinkspace:db:seed` (e.g to test configs).
* Environment variables are typically added to `rake totem:db:reset`.

##### The environment variables used by `thinkspace:db:seed`:
> * Note: The `df` in folder `db/seed_data/df` is short for *default*.
* If an envrionment variable is *not* added on the command line, its action is not performed (with the exception of `CONFIG` which uses a default config defined in `thinkspace-seed/app/concerns/thinkspace/seed/options.rb`).

| Env Variable | Short | Action | Examples |
| ------------ | ------| ------ | -------- |
| CONFIG | | One or more configs to process (comma separated list); relative path(s) to `db/seed_data`. | CONFIG=df/html<br>CONFIG=df/html,pe/all |
| AUTO_INPUT | AI | Process the `auto_input:` section in each config. | AI=true |
| TEST_ONLY| TO | Processes configs (create records) then raise an error to rollback the database changes. | TO=true |
| DEBUG_CONFIG |DC | Collect all config(s) and print them on the console; does not process them (no records created).  Used to test and view final config values. | DC=true |
| DEBUG | | Print the models created as they are created. | DEBUG=true |
| PRINT_MODELS |PM | Print the models created after all the configs are run. Uses model *class-name* case-insensitive matching (comman separated list). | PM=true (all models)<br> PM=html<br>PM=html::content<br>PM=html,phase |
| PRINT_CONFIG_MODELS | PCM | Print the models created by specific configs after all configs are run. Uses *config-name* case-insensitive matching  (comman separated list). | PCM=html<br>PCM=html,pe |
| RESET | | Reset the database for testing. Truncates the tables and resets the identity number (does not do a schema load). | RESET=true |

> NOTE: PM and PCM can both be provided, however, if PM=true, PCM is ignored.

## Seed Examples

> Default config defined in `thinkspace-seed/app/concerns/thinkspace/seed/options.rb`).

| Rake Command | Description |
| ------------ | ----------- |
| `rake totem:db:reset` | seed default config |
| `rake totem:db:reset PM=true` | seed default config, print **_all_** the models |
| `rake totem:db:reset PM=html` | seed default config, print the *html* class models |
| `rake totem:db:reset CONFIG=ms/all` | seed `ms/all` (instead of the default config) |
| `rake totem:db:reset CONFIG=ms/test,pe/all` | seed `ms/test` and `pe/all` |
| `rake thinkspace:db:seed CONFIG=ms/all,df/all DC=true` | collect config(s), print collected config(s) to console, exit  |
| `rake thinkspace:db:seed CONFIG=ms/all PM=true TO=true` | seed `ms/all`, print the models, raise error to rollback database;<br>add `RESET=true` on the *first* run to clear the database (if needed) |


## Seed Data YAML (`.yml`) files
* See the [Yaml Cookbook](https://yaml.org/YAML_for_ruby.html) for the syntax.
* The `CONFIG` files are collected and the helpers are run to create the records.
* The config processing has two distinct steps:
  1. Pre `YAML.load` - changes made to the file's text *before* running `YAML.load`.
  1. Post `YAML.load` - changes made to the resulting Hash *after* `YAML.load`.
* The config processing step determines what can be contained in an *imported* YAML file.

##### Config hash values can be modified using custom `totem-seed` extensions:
* `import_text[file]` or `import_text[file@key]`
* `import[file]` or `import[file@key]`
* `include_configs: <array>`
* `prereq_configs: <string> | <array>`
* `prefix: <string>`

> * For the `import` and `import_text` extensions:
  * The *key* defaults to `import:` when used without a key (e.g. `import[file]`).
  * The imported value should be of the same type (e.g. string, array, hash) or will have an unexpected result or will fail.
  * The *file* is relative to config directory and defaults to `./imports` if a file does not contain a `/`.
    * Examples:
      * A config `pe/case` containing an `import[users]`, references the file `pe/imports/user.yml`
      * The `df/html` config uses `import_text[../common_imports/phase_settings]`.

##### `totem-seed` extensions.
* `import_text`
  * A pre-load extension to replace the string `import-text` with the string from the referenced file.
  * The *imported* string can reference the parent's configs variables since it is inserted into the text of the original file.
  * The `import-text` must be at the proper *indent* level to insert the imported strings.
* `import`
  * A post-load extension to replace a key's value in the parent's Hash with a value from the referenced file YAML value.
  * The *imported* file will only have access to the parent config's variables if they are defined in the parent under a `variables:` key , otherwise, it can only use the variables defined in the imported file itself.
    * Parent `variables:` are added to the top of the imported file's text (like an `import_text`) before loading.  The parent variables can be overridden in the imported file.
    * Alternatively, the imported file can change where the parent variables are inserted by adding a comment line `# replace_with_parent_variables` (below the imported file's variables) and allow the parent to override the imported file's variables.
    * The parent variables must start with a root key `variables:` and will stop at the **first** blank line (or out-indented line).
* `include_configs`
  * A separate YAML file to include multiple other configs.
  * A common use-case is using an `all.yml` to include multiple other configs.
* `prereq_configs`
  * A list of configs that should be run before this config when order matters.
  * For example, using a `prereq_configs: space` to ensure a common space config is run before creating assignments and phases.  Multiple configs can reference the same prereq as it will only be run once.
* `prefix`
  * Typically used in *test* YAML files to make the titles of records unique.
  * A post-load extension that currently will prefix the string values in the following keys:
    * `spaces:` title
    * `spaceusers:` spaces
    * `assignments:` title, space
    * `phases:` title, assignment, template_name
    * `phase_templates:` title, name
    * `teams[:team_sets]` title, space
    * `teams[:team_set_teams]` title, team_set, space
    * `teams[:teams]` title, space, assignment, team_sets

## Seed Process Steps

1. Get an ordered array of config hashes to use in the seed process.
  1. Collect config names from environment variable `CONFIG=` (or use default config name).
  1. Add `include_configs` config names.
  1. Process `import_text` extensions.
  1. Recursively include configs in `prereq_config` extensions.
  1. Process `imports` extensions.
  1. Process `prefix` extensions.
1. Get an ordered array of *seed-helper* instances (classes that *extend* `Totem::Seed::BaseHelper` or one of its descendants).  Helper class names matching `::Base` or `::AutoInput` will not be included.
  * The order of the *seed-helpers* is defined in `thinkspace-seed/app/concerns/thinkspace/seed/options.rb` with any helpers not listed run last.
1. Call the *seed-helper* instance methods.
  1. Call method `pre_process` once (no params).
  1. Call method `process` with each config, passing in the config.
  1. Call method `post_process` once (no params).

The **phase** *seed-helper* adds a `phase_component` record for each `phase_template` **_section_**. At this stage, the `phase_component` record's `componentable_id` and `componentable_type` are blank unless it is directly related to the phase e.g. `casespace-phase-header`, `casespace-phase-submit`, etc.

## Seed-Helpers
* There are two main type of *seed-helpers*.
  1. *Helpers that create records based on a root config key e.g. `space:`, `assignment:` `phase:`, etc.*
    * The helper's config keys are defined in a `config_keys` method.
  1. *Helpers that create records based on a `phase_component` e.g. `html`, `indented_list`, `observation_list`, etc.*
    * *Currently*, a helper's `phase_component` records are selected based on the `phase_template` **title** (case insensitive, spaces ingored).
      * The helper's titles matches are defined in a `common_component_titles` method.
      * :warning: When a config includes a `phase_template:` key, be sure its title matches what the helper selects.
    * Each helper determines the records to create and populates the `componentable_id` and `componentable_type`.
    * If the environment variable `AUTO_INPUT` is `true` and the config has an `auto_input:` key, the helper also creates user-based response records (assuming the helper's key is included in `auto_input:`).  The helper's key(s) required and the related keys are defined by each helper.
      * Within the helpers *auto input* key, it typically accepts an array of hashes e.g. add different records for different phases.
* Each config tracks the records created so when the `base_helper` methods are used, they will only return records created by that config.
  * Helpers must use the `totem-seed/app/lib/totem/seed/finder_helpers.rb` methods (that will find or create a record) to allow the config to collect the models created.
* To add a new *seed-helper*, it is recommended to copy a similar type of helper and modify as required.
