<p align="center">
  <img src="https://github.com/amberframework/site-assets/raw/master/images/amber.png" width="200">
  <p align="center"><strong>Introduction to the Amber Web Framework</strong><br>
  And its Out-of-the-Box Features<p>
  <p align="center">
    <sup>
      <i>
        Amber is Rails-like to an extent, but simpler, reasonable, and easy to understand and use.
      </i>
    </sup>
  </p>
  <p align="center">
  </p>
</p>

# Introduction

**Amber** is a web application framework written in [Crystal](http://www.crystal-lang.org). Homepage is at [amberframework.org](https://amberframework.org/), docs are on [Amber Docs](https://docs.amberframework.org). Github repository is at [amberframework/amber](https://github.com/amberframework/amber), and the chat is on FreeNode IRC (channel #amber) or on [Gitter](https://gitter.im/amberframework/amber).

Amber is simple to get used to, and much more intuitive than frameworks like Rails. (But it does inherit the concepts from Rails that are good.)

This document is here to describe everything that Amber offers out of the box, sorted in a logical order and easy to consult repeatedly over time. The Crystal level is not described; it is expected that the readers coming here have a formed understanding of Crystal and its features.

# Installation

```shell
git clone https://github.com/amberframework/amber
cd amber
make
# The result of 'make' is just one file -- bin/amber

# To install it, or to symlink the system-wide executable to current directory, run one of:
make install # default PREFIX is /usr/local
make install PREFIX=/usr/local/stow/
make force_link # can also specify PREFIX=...
```

# Creating New Amber App

```shell
amber new <app_name> [-d DATABASE] [-t TEMPLATE_LANG] [-m ORM_MODEL]
```

Supported databases: [PostgreSQL](https://www.postgresql.org/) (pg, default), [MySQL](https://www.mysql.com/) (mysql), and [SQLite](https://sqlite.org/) (sqlite).

Supported template languages: [slang](https://github.com/jeromegn/slang) (default) and [ecr](https://crystal-lang.org/api/0.21.1/ECR.html). (ecr is very similar to Ruby's erb.)

Slang is extremely elegant, but very different from the traditional perception of HTML.
ECR is HTML-like and beyond mediocre when compared to slang, but may be the best choice for your application if you intend to use some HTML site template (from e.g. [themeforest](https://themeforest.net/)) whose pages are in HTML + CSS or SCSS.

In any case, regardless of the templating language, have in mind that the templates are compiled along with the application. This makes them extremely fast, as well as read-only which is a very welcome side-benefit!

Supported ORM models: [granite](https://github.com/amberframework/granite-orm) (default) and [crecto](https://github.com/Crecto/crecto).

Granite is a very nice and simple, effective ORM model, where you mostly write your own SQL (i.e. all search queries typically look like YourModel.all("WHERE field1 = ? AND field2 = ?", [value1, value2])). But it also has belongs/has relations, and some other little things. (If you have by chance known and loved [Class::DBI](http://search.cpan.org/~tmtm/Class-DBI-v3.0.17/lib/Class/DBI.pm) for Perl, it might remind you of it in some ways.)

Supported migrations engines: [micrate](https://github.com/juanedi/micrate). Micrate is very, very simple and you basically write raw SQL in your migrations. There are just two keywords in the migration file which give instructions whether the SQLs that follow pertain to migrating up or down. These keywords are "-- +micrate Up" and "-- +micrate Down".

# Running the App

The app can be started as soon as you have created it.

To run it, you can use a couple different approaches. Some are of course suitable for development, some for production, etc.:

```shell
# For development, clean and simple - compiles and runs your app:
crystal src/<app_name>.cr

# For development, clean and simple - compiles and runs your app, but
# also watches for changes in files and rebuilds/re-runs automatically.
amber watch

# For production, compiles app with optimizations and places it in bin/app.
crystal build --no-debug --release --verbose --threads 4 -t -s -p -o bin/app src/app.cr
```

The watch command currently has some issues in edge cases. For example, it may try to run things even if some steps fail ([#499](https://github.com/amberframework/amber/issues/499)) or start re-building the application twice concurrently ([#507](https://github.com/amberframework/amber/issues/507)), and it is generally non-configurable ([#476](https://github.com/amberframework/amber/issues/476)).

Amber itself also currently has problems in edge cases. For example, if you create a new model but do not specify any fields for it, then until you add at least one field, Amber won't start due to a compile error in Granite ([#112](https://github.com/amberframework/granite-orm/issues/112)).

Please ignore these temporary problems until they are solved.

Amber by default uses a feature called "port reuse" available in newer Linux kernels. If you get an error "setsockopt: Protocol not available", it means your kernel does not have it. Please edit `config/environments/development.yml` and set "port_reuse" to false.

# REPL

Often times, it is very useful to enter an interactive console (think of IRB shell) with all applications lasses initialized etc. In Ruby this would be done with IRB or with a command like `rails console`.

As you might know, Crystal does not have a free-form [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop), but you can save and execute scripts in the context of the application. One way to do it is via command `amber x [filename]`. This command will allow you to type or edit the contents, and will then execute the script.

Another, more professional way to do it is via REPL-like script tools [cry](https://github.com/elorest/cry) and [icr](https://github.com/crystal-community/icr). `cry` began as an experiment and a predecessor to `amber x`, but now offers additional functionality such as repeatedly editing and running the script if `cry -r` is invoked.

In any case, running a script "in application context" simply means requiring `config/application.cr` (or more generally, `config/**`), Therefore, be sure to list all your requires in `config/application.cr` so that everything would work as expected.

# File Structure

So, at this point you might be wanting to know what's placed where in an Amber application. The default structure looks like this:

```
./spec                     - Tests (named *_spec.cr)
./config                   - All configuration, with config/application.cr being the main file
./config/environments      - Environment-specific YAML configurations
./config/webpack           - Webpack (asset bundler) configuration
./config/initializers      - Initializers
./src                      - Main source directory, with <app_name>.cr being the main/entry file
./src/controllers          - All controllers
./src/models               - All models
./src/views                - All views
./src/views/layouts        - All layouts
./src/views/home           - Views for HomeController (path "/")
./src/assets               - Static assets which will be bundled and placed into ./public/dist/
./src/assets/stylesheets
./src/assets/fonts
./src/assets/images
./src/assets/javascripts
./public                   - The "public" directory for static files
./public/dist              - Directory inside "public" for generated files and bundles
./public/dist/images
```

I prefer to have some of these directories accessible directly in the root directory of the application and to have the config directory named `etc`, so I run:

```
ln -sf config etc
ln -sf src/assets
ln -sf src/controllers
ln -sf src/models
ln -sf src/views
ln -sf src/views/layouts
```

# Database Commands

Amber provides a group of commands under the 'db' group to allow working with the database. The simple commands you will most probably want to run just to see basic things working are:

```shell
amber db create
amber db status
amber db version
```

However, please note that none of the database commands will work until you create anything that involves a migration ([#519](https://github.com/amberframework/amber/issues/519)). If you want to fix this manually, assuming that you are using Granite ORM, please run:

```shell
echo "Granite::ORM.settings.database_url = Amber.settings.database_url" >> config/initializers/granite.cr
```

And then try the above commands.

# Routes

# Static Pages

# Pipelines

# Database Access with User Privileges



