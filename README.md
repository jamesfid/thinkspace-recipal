# ThinkSpace documentation
## Repositories
  * https://github.com/sixthedge/thinkspace.
  * https://github.com/sixthedge/totem-oauth

## Environment

| Software    | Version         | System |
| ----------- | --------------- | ------ |
| node        | 0.12.18         | client |
| ember-cli   | 0.2.3           | client |
| ember       | 1.11.1          | client |
| ember-data  | 1.0.0-beta.16.1 | client |
| rails       | 4.2.11.1        | api    |
| rails       | 5.0.1           | oauth  |
| ruby        | 2.5.5           | api, oauth  |

In addition, you will need the follow core packages installed:

| Software   | Version    | Description        |
| ---------- | ---------- | ------------------ |
| PostgreSQL | ~> 10.6    | database           |
| `rvm`      | latest     | version management |
| `nvm`      | latest     | version management |

## Core installation
### PostgreSQL
Install via `apt` from the guide at https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04.

Note: if you get the `dpkg status database is locked` error, delete it with: `sudo rm /var/lib/dpkg/lock`.  For `apt` lock issues, see: https://itsfoss.com/fix-ubuntu-install-error/.

```
psql --version
psql (PostgreSQL) 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)
```

Once the install is verified, setup the `postgres` role password via:
  * `sudo -u postgres psql`
  * `\password postgres`
  * Set the password to "password"
  * `\q`

Next, to resolve peer authentication issues:
  * `sudo gedit /etc/postgresql/10/main/pg_hba.conf `
  * Change the first instruction by replacing "peer" with "md5".
  * `sudo service postgresql restart`

Lastly, ensure you have the proper heads required for the `pg` gem via `sudo apt-get install libpq-dev`.

### NVM
Install `nvm` via the instructions at https://github.com/creationix/nvm#install-script.  Note that you may need to restart your terminal after install, to ensure your `PATH` is sourced correctly and `nvm` is a command.

Once installed, verify with:

```
node -v
v0.12.18
```

### RVM
Install RVM as shown in the documentation at https://github.com/rvm/ubuntu_rvm#install. After RVM is installed and you've modified the GNOME shell and restarted, install ruby via `rvm install ruby-2.5.5`.  This is likely not the Ruby version we will be using for ThinkSpace, but it ensures that RVM is setup correctly.

```
ruby -v

ruby 2.5.5p157 (2019-04-16 revision 67580) [x86_64-linux]
```
### Git
Install via `sudo apt install git`.

## Client
### Setup
```bash
nvm install 0.12.18
nvm alias default 0.12.18
nvm use 0.12.18
npm install -g ember-cli@0.2.3
npm install -g bower

cd thinkspace/client
npm install
```

### Start

```bash
cd thinkspace/client
# Verify the correct node version 0.12.18 is being used:
#   nvm ls  #=> if not, run 'nvm use 0.12.18'
source .env-development && ember s
```

### Notes
> The `npm install` command will:
  * run the `package.json` script `"preinstall": "node preinstall.js"`
    1. delete `client/node_modules` (if exists)
    1. delete `client/bower_components` (if exists)
    1. make directory `client/node_modules`
    1. *symlink* the packages in `client/packages` to `client/node_modules`
  * install the `package.json` dependencies into `client/node_modules`
  * run the `package.json` script `"postinstall": "node postinstall.js"`
    1. install the bower packages in `bower.json` into `client/bower_components`
    1. patch the `client/node_modules/ember-cli-coffees6/index.js`
    1. ember generate `ember-colpick`
    1. delete the file `client/bower_components/pickadate/lib/translations/fa_ir.js` (is dupicate of `fa_IR.js`)

---
---

## API
### Setup
:notebook: The use of separate *gemsets* is optional.

```bash
rvm gemset create thinkspace
rvm gemset use thinkspace

cd thinkspace/api
bundle install
rake db:create
# rake db:migrate #=> Only run if the 'db/schema.rb' does NOT exist.
```

### Start

```bash
cd thinkspace/api
# Verify the correct rvm gemset is being used:
#   rvm gemset list  #=> if not, run 'rvm gemset use rails4.2'
# Seed the database if needed:
#   rake totem:db:reset
source .env-development && rails s -p 3000 --binding 0.0.0.0
```
---
---

## OAuth
### Setup
Follow the instructions from the `master` branch at https://github.com/sixthedge/totem-oauth#setup

### Start
Follow the start instructions from the `master` branch at https://github.com/sixthedge/totem-oauth#start

---
---
## Comments

1. Removed all `api/engines/.../db/migrate` folders as all migrations are now in `api/db/migrate`.
    * Did **not** remove the `api/engines/.../db/domain_data` folders.
1. The `client/package.json` scripts `preinstall` and `postinstall` are used instead of an `install.sh` bash script.
    * :warning: Need to verify a `deploy` works with these scripts.
1. After testing the app, should consider setting the exact version numbers in the `api` and `oauth` `Gemfile` for repoducability.
    * :warning: Have only tried the main index pages.
1. If *need* to run an `ember new appname` need to *first* update the global `ember-cli` `bower` repository.
    * Bower moved their repository to `https://registry.bower.io`.
    * Update the global `ember-cli` file `.bowerrc` by adding `"registry": "https://registry.bower.io"` (as included in the current `client/.bowerrc`).
    * `~/.nvm/versions/node/v0.12.18/lib/node_modules/ember-cli/blueprints/app/files/.bowerrc`:
    ```bash
    {
      "registry": "https://registry.bower.io",
      "directory": "bower_components",
      "analytics": false
    }
    ```
---
---
