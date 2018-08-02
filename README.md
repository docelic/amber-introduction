<p align="center">
  <img src="https://raw.githubusercontent.com/docelic/amber-introduction/master/support/amber.png">
  <h3 align="center"><strong>Introduction to the Amber Web Framework</strong><br>
  And its Out-of-the-Box Features</h3>
  <p align="center">
    <sup>
      <i>
        Amber makes building web applications easy, fast, and enjoyable.
      </i>
    </sup>
  </p>
  <p align="center">
  </p>
</p>

# Table of Contents

1. [Introduction](#introduction)
1. [Installation](#installation)
1. [Creating New Amber App](#creating_new_amber_app)
1. [Running the App](#running_the_app)
1. [Building the App and Build Troubleshooting](#building_the_app_and_build_troubleshooting)
1. [REPL](#repl)
1. [File Structure](#file_structure)
1. [Database Commands](#database_commands)
1. [Pipes and Pipelines](#pipes_and_pipelines)
1. [Routes, Controller Methods, and Responses](#routes__controller_methods__and_responses)
1. [Views](#views)
	1. [Template Languages](#template_languages)
		1. [Liquid Template Language](#liquid_template_language)
1. [Logging](#logging)
1. [Parameter Validation](#parameter_validation)
1. [Static Pages](#static_pages)
1. [Variables in Views](#variables_in_views)
1. [More on Database Commands](#more_on_database_commands)
	1. [Micrate](#micrate)
	1. [Custom Migrations Engine](#custom_migrations_engine)
1. [Internationalization (I18n)](#internationalization__i18n_)
1. [Responses](#responses)
	1. [Responses with Different Content-Type](#responses_with_different_content_type)
	1. [Error Responses](#error_responses)
		1. [Manual Error Responses](#manual_error_responses)
		1. [Error Responses via Error Pipe](#error_responses_via_error_pipe)
1. [Assets Pipeline](#assets_pipeline)
	1. [Adding jQuery and jQuery UI](#adding_jquery_and_jquery_ui)
	1. [Resource Aliases](#resource_aliases)
	1. [CSS Optimization / Minification](#css_optimization___minification)
	1. [File Copying](#file_copying)
	1. [Asset Management Alternatives](#asset_management_alternatives)
1. [Advanced Topics](#advanced_topics)
	1. [Amber::Controller::Base](#amber__controller__base)
	1. [Extensions](#extensions)
	1. [Shards](#shards)
	1. [Environments](#environments)
	1. [Starting the Server](#starting_the_server)
	1. [Serving Requests](#serving_requests)
	1. [Support Routines](#support_routines)
	1. [Amber behind a Load Balancer | Reverse Proxy | ADC](#amber_behind_a_load_balancer___reverse_proxy___adc)
1. [Ecommerce with Amber](#ecommerce_with_amber)
1. [Conclusion](#conclusion)


# Introduction<a name="introduction"></a>

**Amber** is a web application framework written in [Crystal](http://www.crystal-lang.org). Homepage can be found at [amberframework.org](https://amberframework.org/), docs at [Amber Docs](https://docs.amberframework.org), GitHub repository at [amberframework/amber](https://github.com/amberframework/amber), and the chat on [Gitter](https://gitter.im/amberframework/amber) or on the FreeNode IRC channel #amber.

Amber is inspired by Kemal, Rails, Phoenix, and other frameworks. It is simple to get used to, and much more intuitive than frameworks like Rails. (But it does inherit many concepts from Rails that are good.)

This document is here to describe everything that Amber offers out of the box, sorted in a logical order and easy to consult repeatedly over time. The Crystal level is not described; it is expected that the readers coming here have a formed understanding of [Crystal and its features](https://crystal-lang.org/docs/overview/).

# Installation<a name="installation"></a>

```shell
git clone https://github.com/amberframework/amber
cd amber
make # The result of 'make' will be one file -- command line tool bin/amber

# To install the file, or to symlink the system-wide executable to current directory, run one of:
make install # default PREFIX is /usr/local
make install PREFIX=/usr/local/stow/amber
make force_link # can also specify PREFIX=...
```

("stow" mentioned above is referring to [GNU Stow](https://www.gnu.org/software/stow/).)

After installation or linking, `amber` is the command you will be using for creating and managing Amber apps.

Please note that some users prefer (or must use for compatibility reasons) local Amber executables which match the version of Amber used in their project. For that, each Amber project's `shard.yml` ships with the build target named "amber":

```
targets:
  ...
  amber:
    main: lib/amber/src/amber/cli.cr

```

Thanks to it, running `shards build amber` will compile local Amber found in `lib/amber/` and place the executable into the project's local file `bin/amber`.

# Creating New Amber App<a name="creating_new_amber_app"></a>

```shell
amber new <app_name> [-d DATABASE] [-t TEMPLATE_LANG] [-m ORM_MODEL] [--deps]
```

Supported databases are [PostgreSQL](https://www.postgresql.org/) (pg, default), [MySQL](https://www.mysql.com/) (mysql), and [SQLite](https://sqlite.org/) (sqlite).

Supported template languages are [slang](https://github.com/jeromegn/slang) (default) and [ecr](https://crystal-lang.org/api/0.21.1/ECR.html). (But any languages can be used; more on that can be found below in [Template Languages](#template_languages).)

Slang is extremely elegant, but very different from the traditional perception of HTML.
ECR is HTML-like, very similar to Ruby ERB, and also much less efficient than slang, but it may be the best choice for your application if you intend to use some HTML site template (e.g. from [themeforest](https://themeforest.net/)) whose pages are in HTML + CSS or SCSS. (Or you could also try [html2slang](https://github.com/docelic/html2slang/) which converts the bulk of HTML pages into slang will relatively good accuracy.)

Supported ORM models are [granite](https://github.com/amberframework/granite-orm) (default) and [crecto](https://github.com/Crecto/crecto).

Granite is Amber's native, nice, and effective ORM model where you mostly write your own SQL. For example, all search queries typically look like `YourModel.all("WHERE field1 = ? AND field2 = ?", [value1, value2])`. But it also has belongs/has relations, and some other little things.

Supported migrations engine is [micrate](https://github.com/amberframework/micrate). (But any migrations engines can be used; more on that can be found below in [Custom Migrations Engine](#custom_migrations_engine).)

Micrate is very simple and you basically write raw SQL in your migrations. There are just two keywords in the migration files which give instructions whether the SQLs that follow pertain to migrating up or down. These keywords are "-- +micrate Up" and "-- +micrate Down". If you have complex SQL statements that contain semicolons then you also enclose each in "-- +micrate StatementBegin" and "-- +micrate StatementEnd".

Finally, if argument `--deps` is provided, Amber will automatically run `shards` in the new project's directory after creation to download the shards required by the project.

Please note that shards-related commands use the directory `.shards/` as local staging area before the contents are fully ready to replace shards in `lib/`.

# Running the App<a name="running_the_app"></a>

The app can be started as soon as you have created it and ran `shards` in the app directory.
(It is not necessary to run `shards` if you have invoked `amber new` with the argument `--deps`; in that case Amber did it for you.)

Please note that the application is always compiled, regardless of whether one is using the Crystal command 'run' (the default) or 'build'. It is just that in run mode, the resulting binary is typically compiled without optimizations (to improve build speed) and is not saved to a file, but is just compiled, executed, and then discarded.

To run the app, you could use a couple different approaches:

```shell
# For development, clean and simple - compiles and runs your app:
crystal src/<app_name>.cr

# Compiles and runs app in 'production' environment:
AMBER_ENV=production crystal src/<app_name>.cr

# For development, clean and simple - compiles and runs your app, but
# also watches for changes in files and rebuilds/re-runs automatically:
amber watch
```

Amber apps by default use a feature called "port reuse" available in newer Linux kernels. If you get an error "setsockopt: Protocol not available" upon running the app, it means your kernel does not support it. Please edit `config/environments/development.yml` and set "port_reuse" to false.

# Building the App and Build Troubleshooting<a name="building_the_app_and_build_troubleshooting"></a>

To build the application in a simple and effective way, you would run the following to produce executable file `bin/<app_name>`:

```shell
# For production, compiles app with optimizations and places it in bin/<app_name>.
shards build <app_name> --production
```

To build the application in a more manual way, skip dependency checking, and control more of the options, you would run:

```shell
# For production, compiles app with optimizations and places it in bin/<app_name>.
# Crystal by default compiles using 8 threads (tune if needed with --threads NUM)
crystal build --no-debug --release --verbose -t -s -p -o bin/<app_name> src/<app_name>.cr
```

As mentioned, for faster build speed, development versions are compiled without the `--release` flag. With the `--release` flag the compilation takes noticeably longer, but the resulting binary has incredible performance.

Thanks to Crystal's compiler implementation, only the parts actually used are added to the executable. Listing dependencies in `shard.yml` or even using `require`s in your program will generally not affect what is compiled in.

Crystal caches partial results of the compilation (*.o files etc.) under `~/.cache/crystal/` for faster subsequent builds. This directory is also where temporary binaries are placed when one runs programs with `crystal [run]` rather than `crystal build`.

Sometimes building the app will fail on the C level because of missing header files or libraries. If Crystal doesn't print the actual C error, it will at least print the compiler line that caused it.

The best way to see the actual error from there is to copy-paste the command printed and run it manually in the terminal. The error will be shown and from there the cause and solution will be determined easily. Usually some libraries or headers will be missing, such as those from package `libxml2-dev`. A typical set of packages you should install are `libevent-dev libgc-dev libxml2-dev libssl-dev libyaml-dev libcrypto++-dev libsqlite3-dev`.

There are some issues with the `libgc` library here and there. In my case the solution was to reinstall system's package `libgc-dev`.

# REPL<a name="repl"></a>

Often times, it is very useful to enter an interactive console (think of IRB shell) with all application classes initialized etc. In Ruby this would be done with IRB or with a command like `rails console`.

Crystal does not have a free-form [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop), but you can save and execute scripts in the context of the application. One way to do it is via command `amber x [filename]`. This command will allow you to type or edit the contents, and then execute the script.

Another, possibly more flexible way to do it is via standalone REPL-like tools [cry](https://github.com/elorest/cry) or [icr](https://github.com/crystal-community/icr). `cry` began as an experiment and a predecessor to `amber x`, but now offers additional functionality such as repeatedly editing and running the script if `cry -r` is invoked.

In any case, running a script "in application context" simply means requiring `config/application.cr` (and through it, `config/**`). Therefore, be sure to list all your requires in `config/application.cr` so that everything works as expected, and if you are using `cry` or `icr`, have `require "./config/application"` as the first line.

# File Structure<a name="file_structure"></a>

So, at this point you might be wanting to know what's placed where in an Amber application. The default structure looks like this:

```
./config/                  - All configuration, detailed in subsequent lines:
./config/initializers/     - Initializers (code you want executed at the very beginning)
./config/environments/     - Environment-specific YAML configurations (development, production, test)
./config/application.cr    - Main configuration file for the app. Generally not touched (apart
                             from adding "require"s to the top) because most of the config
                             settings are specified in YAML files in config/environments/
./config/webpack/          - Webpack (asset bundler) configuration
./config/routes.cr         - All routes

./db/migrations/           - All DB migration files (created with "amber g migration ...")

./public/                  - The "public" directory for static files
./public/dist/             - Directory inside "public" for generated files and bundles
./public/dist/images/

./src/                     - Main source directory, with <app_name>.cr being the main file
./src/controllers/         - All controllers
./src/models/              - All models
./src/views/layouts/       - All layouts
./src/views/               - All views
./src/views/home/          - Views for HomeController (the app's "/" path)
./src/locales/             - Toplevel directory for locale (translation) files named [lang].yml
./src/assets/              - Static assets which will be bundled and placed into ./public/dist/
./src/assets/fonts/
./src/assets/images/
./src/assets/javascripts/
./src/assets/stylesheets/

./spec/                    - Toplevel directory for test files named "*_spec.cr"
```

I prefer to have some of these directories accessible directly in the root directory of the application and to have the config directory aliased to `etc`, so I run:

```
ln -sf config etc
ln -sf src/assets
ln -sf src/controllers
ln -sf src/models
ln -sf src/views
ln -sf src/views/layouts

```

# Database Commands<a name="database_commands"></a>

Amber provides a group of subcommands under `amber db` to allow working with the database. The simple commands you will most probably want to run first just to see things working are:

```shell
amber db create
amber db status
amber db version
```

Before these commands will work, you will need to configure database
credentials as follows:

First, create a user to access the database. For PostgreSQL, this is done by invoking something like:

```shell
$ sudo su - postgres
$ createuser -dElPRS myuser
Enter password for new role:
Enter it again:
```

Then, edit `config/environments/development.yml` and configure "database_url:" to match your settings. If nothing else, the part that says "postgres:@" should be replaced with "yourusername:yourpassword@".

And then try the database commands from the beginning of this section.

Please note that for the database connection to succeed, everything must be set up correctly &mdash; hostname, port, username, password, and database name must be valid, the database server must be accessible, and the database must actually exist unless you are invoking `amber db create` to create it. In case of *any error in any of these requirements*, the error message will be terse and just say "Connection unsuccessful: <database_url>". The solution is simple, though - simply use the printed database_url to manually attempt a connection to the database with the same parameters, and the problem will most likely quickly reveal itself.

(If you are sure that the username and password are correct and that the database server is accessible, then the most common problem is that the database does not exist yet, so you should run `amber db create` as the first command to create it.)

Please note that the environment files for non-production environment are given in plain text. Environment file for the production environment is encrypted for additional security and can be seen or edited by invoking `amber encrypt`.

# Pipes and Pipelines<a name="pipes_and_pipelines"></a>

In very simple frameworks it could suffice to directly map incoming requests to methods in the application, call them, and return their output to the user.

More elaborate application frameworks like Amber provide many more features and flexibility, and allow pluggable components to be inserted and executed in the chosen order before the actual controller method is invoked to handle the request.

These components are in general terminology called "middleware". Crystal calls them "handlers", and Amber calls them "pipes". In any case, in Amber applications they all refer to the same thing &mdash; classes that `include` Crystal's module [HTTP::Handler](https://crystal-lang.org/api/0.24.2/HTTP/Handler.html) and that implement method `def call(context)`. (So in Amber, this functionality is based on Crystal's HTTP server's built-in support for handlers/pipes.)

Pipes work in such a way that invoking the pipes is not automatic, but each pipe must explicitly invoke `call_next(context)` to call the next pipe in a row. This is actually desirable because it makes it possible to call the next pipe at exactly the right place in the code where you want it and if you want it &mdash; at the beginning, in the middle, or at the end of your current pipe's code, or not at all.

The request and response data that pipes need in order to run and do anything meaningful is passed as the first argument to every pipe, and is by convention named "context".

Context persists for the duration of the request and is the place where data that should be shared/carried between pipes should be saved. Amber extends the default [HTTP::Server::Context](https://crystal-lang.org/api/0.24.2/HTTP/Server/Context.html) class with many additional fields and methods as can be seen in [router/context.cr](https://github.com/amberframework/amber/blob/master/src/amber/router/context.cr) and [extensions/http.cr](https://github.com/amberframework/amber/blob/master/src/amber/extensions/http.cr).

Handlers or pipes are not limited in what they can do. It is normal that they sometimes stop execution and return an error, or fulfil the request on their own without even passing the request through to the controller. Examples of such pipes are [CSRF](https://github.com/amberframework/amber/blob/master/src/amber/pipes/csrf.cr) which stops execution if CSRF token is incorrect, or [Static](https://github.com/amberframework/amber/blob/master/src/amber/pipes/static.cr) which autonomously handles delivery of static files.

Using pipes promotes code reuse and is a nice way to plug various standard or custom functionality in the request serving process without requiring developers to duplicate code or include certain parts of code in every controller action.

Additionally, in Amber there exists a concept of "pipelines". Pipelines are logical groups of pipes. The discussion about them continues in the next section.

# Routes, Controller Methods, and Responses<a name="routes__controller_methods__and_responses"></a>

Before expanding the information on pipes and pipelines, let's explain the concept of routes.

Routes connect incoming requests (HTTP methods and URL paths) to specific controllers and controller methods in your application. Routes are checked in the order they are defined and the first route that matches wins.

All routes belong to a certain pipeline (like "web", "api", or similar). When a route matches, Amber simply executes all pipes in the pipeline under which that route has been defined. The last pipe in every pipeline is implicitly the pipe named "[Controller](https://github.com/amberframework/amber/blob/master/src/amber/pipes/controller.cr)". That's the pipe which actually looks into the original route, instantiates the specified controller, and calls the specified method in it. Please note that this is currently non-configurable &mdash; the controller pipe is always automatically added as the last pipe in the pipeline and it is executed unless processing stops in one of the earlier pipes.

The configuration for pipes, pipelines, and routes is found in the file `config/routes.cr`. This file invokes the same `configure` block that `config/application.cr` does, but since routes configuration is important and can also be lengthy and complex, Amber keeps it in a separate file.

Amber includes commands `amber routes` and `amber pipelines` to display route and pipeline configurations. By default, the output for routes looks like the following:

```shell
$ amber routes


╔══════╦═══════════════════════════╦════════╦══════════╦═══════╦═════════════╗
║ Verb | Controller                | Action | Pipeline | Scope | URI Pattern ║
╠──────┼───────────────────────────┼────────┼──────────┼───────┼─────────────╣
║ get  | HomeController            | index  | web      |       | /           ║
╠──────┼───────────────────────────┼────────┼──────────┼───────┼─────────────╣
║ get  | Amber::Controller::Static | index  | static   |       | /*          ║
╚══════╩═══════════════════════════╩════════╩══════════╩═══════╩═════════════╝


```

From the first line of the output we see that a "GET /" request will cause all pipes in the pipeline "web" to be executed, and then
`HomeController.new.index` method will be called.

In the `config/routes.cr` code, this is simply achieved with the line:

```crystal
routes :web do
  get "/", HomeController, :index
end
```

The return value of the controller method is returned as response body to the client.

As another example, the following definition would cause a POST request to "/registration" to result in invoking `RegistrationController.new.create`:

```
post "/registration", RegistrationController, :create
```

By convention, standard HTTP verbs (GET/HEAD, POST, PUT/PATCH, and DELETE) should be routed to standard-named methods on the controllers &mdash; `show`, `create`, `update`, and `destroy`. However, there is nothing preventing you from routing URLs to any methods you want in the controllers, such as we've seen with `index` above.

Websocket routes are supported too.

The DSL language specific to `config/routes.cr` file is defined in [dsl/router.cr](https://github.com/amberframework/amber/blob/master/src/amber/dsl/router.cr) and [dsl/server.cr](https://github.com/amberframework/amber/blob/master/src/amber/dsl/server.cr).

It gives you the following top-level commands/blocks:

```
# Define a pipeline
pipeline :name do
  # ... list of pipes ...
end

# Group a set of routes
routes :pipeline_name, "/optional_path_prefix" do
  # ... list of routes ...
end
```

This is used in practice in the following way in `config/routes.cr`:

```crystal
Amber::Server.configure do |app|
  pipeline :web do
    # Plug is the method used to connect a pipe (middleware).
    # A plug accepts an instance of HTTP::Handler.
    plug Amber::Pipe::Logger.new
  end

  routes :web do
    get "/", HomeController, :index     # Routes "GET /" to HomeController.new.index
    post "/test", PageController, :test # Routes "POST /test" to PageController.new.test
  end
end
```

Within "routes" blocks the following commands are available:

```crystal
get, post, put (or patch), delete, options, head, trace, connect, websocket, resources
```

Most of these actions correspond to the respective HTTP methods; `websocket` defines websocket routes; and `resources` is a macro defined as:

```crystal
    macro resources(resource, controller, only = nil, except = nil)
```

Unless `resources` is confined with arguments `only` or `except`, it will automatically route `get`, `post`, `put/patch`, and `delete` HTTP methods to methods `index`, `show`, `new`, `edit`, `create`, `update`, and `destroy` on the controller.

Please note that it is not currently possible to define a different behavior for GET and HEAD HTTP methods on the same path. If a GET is defined, it will also automatically add the matching HEAD route. Specifying HEAD route manually would then result in two HEAD routes existing for the same path and trigger `Amber::Exceptions::DuplicateRouteError`.

# Views<a name="views"></a>

Information about views can be summarized in the following bullet points:

- Views in an Amber project are located under the toplevel directory `src/views/`
- Views are typically rendered using `render()`
- The first argument given to `render()` is the template name (e.g. `render("index.slang")`)
- `render("index.slang")` will look for a view named `src/views/<controller_name>/index.slang`
- `render("./abs/or/rel/path.slang")` will look for a template in that specific path
- There is no unnecessary magic applied to template names &mdash; names specified are the names that will be looked up on disk
- If you are not rendering a partial, by default the template will be wrapped in a layout
- If the layout name isn't specified, the default layout will be `views/layouts/application.slang`
- To render a partial, use `render( partial: "_name.ext")`
- Partials begin with "\_" by convention, but that is not required. If they are named with "\_", then the "\_" must be mentioned as part of the name
- Templates are read from disk and compiled into the application at compile time. This makes them fast to access and also read-only which is a useful side-benefit

The `render` macro is usually invoked at the end of the controller method. This makes its return value be the return value of the controller method as a whole, and as already mentioned, the controller method's return value is returned to the client as response body.

It is also important to know that `render` is a macro and that views are rendered directly (in-place) as part of the controller method.
This results in a very interesting property &mdash; since `render` executes directly in the controller method, it sees all local variables in it and view data does not have to be passed via instance variables. This particular aspect is explained in more detail further below under [Variables in Views](#variables_in_views).

## Template Languages<a name="template_languages"></a>

In the introduction we've mentioned that Amber supports two template languages &mdash; [slang](https://github.com/jeromegn/slang) (default) and [ecr](https://crystal-lang.org/api/0.21.1/ECR.html).

That's because Amber ships with a minimal working layout (a total of 3 files) in those languages, but there is nothing preventing you from using any other languages if you have your own templates or want to convert existing ones.

Amber's default rendering engine is [Kilt](https://github.com/jeromegn/kilt), so all languages supported by Kilt should be usable out of the box. Amber does not make assumptions about the template language used; the view file's extension will determine which parser will be invoked (e.g. ".ecr" for ecr, ".slang" for slang).

### Liquid Template Language<a name="liquid_template_language"></a>

The original [Kilt](https://github.com/jeromegn/kilt) repository now has support for the Liquid template language.

Please note, however, that Liquid as a template language comes with non-typical requirements &mdash; primarily, it requires a separate store ("context") for user data which is to be available in templates, and also it does not allow arbitrary functions, objects, object methods, and data types to be used in its templates.

As such, Amber's principle of rendering the templates directly inside controller methods (and thus making all local variables automatically available in views) cannot be used because Liquid's context is separate and local variables are not there.

Also, Liquid's implementation by default tries to be helpful and it automatically creates a new context. It copies all instance variables (@ivars) from the current object into the newly created context, which again cannot be used with Amber for two reasons.
First, because the copying does not work for data other than basic types (e.g. saying `@process = Process` does not make `{{ process.pid }}` usable in a Liquid template). Second, because Amber's controllers already contain various instance variables that should not or can not be serialized, so even simply saying `render("index.liquid")` would result in a compile-time error in Crystal even if the template itself was empty.

Also, Amber's `render` macro does not accept extra arguments, so a custom context can't be passed to Kilt and from there to Liquid.

Therefore, the best approach to work with Liquid in Amber is to create a custom context, populate it with desired values, and then invoke `Kilt.render` macro directly (without using Amber's `render` macro). The pull request [#610](https://github.com/amberframework/amber/pull/610) to make rendering engines includable/choosable at will was refused by the Amber project, so if you are bothered that the default `render` macro is present in your application even though you do not use it, simply comment the line `include Helpers::Render` in Amber's [controller/base.cr](https://github.com/amberframework/amber/blob/master/src/amber/controller/base.cr).

Please also keep in mind not to use the name "context" for the variable that will hold Liquid's context, because that would take precedence over the `context` getter that already exists on the controllers and is used to access `HTTP::Server::Context` object.

So, altogether, a working example for rendering Liquid templates in Amber would look like the following (showing the complete controller code for clarity):

```
class HomeController < ApplicationController
  def index
    ctx = Liquid::Context.new
    ctx.set "process", { "pid" => Process.pid }

    # The following would render src/views/[controller]/index.liquid
    Kilt.render "index.liquid", ctx

    # The following would render specified path, relative to app base directory
    Kilt.render "src/views/myview.liquid", ctx
  end
end
```

# Logging<a name="logging"></a>

Amber logger (based on standard Crystal's class `Logger`) is initialized as soon as `require "amber"` is called, as part of reading the settings and initializing the environment.

The variable containing the logger is `Amber.settings.logger`. For convenience, it is also available as `Amber.logger`. In the context of a Controller, it is also available as simply `logger`.

Controllers and views execute in the same class (the class of the controller), so calling the following anywhere in the controller or views will produce the expected log line:

```crystal
logger.info "Informational Message"
```

Log levels available are `debug`, `info`, `warn`, `error`, `fatal`, and `unknown`.

The second, optional parameter passed to the log method will affect the displayed name of the subsystem from which the message originated. For example:


```crystal
logger.warn "Starting up", "MySystem"
```

would result in the log line:

```
03:17:04 MySystem   | (WARN) Starting up
```

In you still need a customized logger for special cases or purposes, please create a separate `Logger.new` yourself.

# Parameter Validation<a name="parameter_validation"></a>

First of all, Amber framework considers query and body params equal and makes them available to the application in the same, uniform way.

Second of all, the params handling in Amber is not programmed in a truly clean and non-overlapping way, but the description here should be clear to understand.

There are just three important methods to have in mind &mdash; `params.validation {...}` which defines validation rules, `params.valid?` which returns whether parameters pass validation, and `params.validate!` which requires that parameters pass validation or raises an error.

A simple validation process in a controller could look like this (showing the whole Controller class for completeness):

```crystal
class HomeController < ApplicationController
  def index
    params.validation do
      required(:name) { |n| n.size > 6 } # Name must have at least 6 characters
      optional(:phone) { |n| n.phone? }  # Phone must look like a phone number
    end

    "Params valid: #{params.valid?.to_s}<br>Name is: #{params[:name]}"
  end
end
```

(Extensions to the String class such as `phone?` seen above come especially handy for writing validations. Please see [Extensions](#extensions) below for the complete list of built-in extensions available.)

With this foundation in place, let's take a step back to explain the underlying principles and also expand the full description:

As already mentioned above, for every incoming request, Amber uses data from `config/routes.cr` to determine which controller and method in it should handle the request. Then it instantiates that controller (calls `new` on it), and because all controllers inherit from `ApplicationController` (which in turn inherits from `Amber::Controller:Base`), the following code is executed as part of initialize:

```crystal
protected getter params : Amber::Validators::Params

def initialize(@context : HTTP::Server::Context)
  @params = Amber::Validators::Params.new(context.params)
end
```

In other words, `params` object is initialized using raw params passed with the user's request (i.e. `context.params`). From there, it is important to know that `params` object contains 4 important variables (getters):

1. `params.raw_params` - this is a reference to hash `context.params` created during initialize, and all methods invoked on `params` directly (such as `[]`, `[]?`, `[]=`, `add`, `delete`, `each`, `fetch`, etc.) are forwarded to this object. Please note that this is a reference and not a copy, so all modifications made there also affect `context.params`
1. `params.rules` - this is initially an empty list of validation rules. It is filled in as validation rules are defined using `params.validation {...}`
1. `params.params` - this is a hash of key=value parameters, but only those that were mentioned in the validation rules and that passed validation when `valid?` or `validate!` were called. This list is re-initialized on every call to `valid?` or `validate!`. Using this hash ensures that you only work with validated/valid parameters
1. `params.errors` - this is a list of all eventual errors that have ocurred during validation with `valid?` or `validate!`. This list is re-initialized on every call to `valid?` or `validate!`

And this is basically all there is to it. From here you should have a complete understanding how to work with params validation in Amber.

(TODO: Add info on model validations)

# Static Pages<a name="static_pages"></a>

It can be pretty much expected that a website will need a set of simple, "static" pages. Those pages are served by the application, but mostly don't use a database nor any complex code. Such pages might include About and Contact pages, Terms amd Conditions, and so on. Making this work is trivial and will serve as a great example.

Let's say that, for simplicity and logical grouping, we want all "static" pages to be served by a controller we will create, named "PageController". We will group all these "static" pages under a common web-accessible prefix of /page/, and finally we will route page requests to PageController's methods. Because these pages won't be backed by objects, we won't need models or anything else other than one controller method and one view per each page.

Let's create the controller:

```shell
amber g controller page
```

Then, we edit `config/routes.cr` to link e.g. URL "/page/about" to method about() in PageController. We do this inside the "routes :web" block:

```
routes :web, "/page" do
  ...
  get "/about", PageController, :about
  ...
end
```

Then, we edit the controller and actually add method about(). This method can just directly return a string in response, or it can render a view. In any case, the return value from the method will be returned as the response body to the client, as usual.

```shell
$ vi src/controllers/page_controller.cr

# Inside the file, we add:

def about
  # "return" can be omitted here. It is included for clarity.
  render "about.ecr"
end
```

Since this is happening in the "page" controller, the view directory for finding the templates will default to `src/views/page/`. We will create the directory and the file "about.ecr" in it:

```shell
$ mkdir -p src/views/page/
$ vi src/views/page/about.ecr

# Inside the file, we add:

Hello, World!
```

Because we have called render() without additional arguments, the template will default to being rendered within the default application layout, `views/layouts/application.cr`.

And that is it! The request for `/page/about` will reach the router, the router will invoke `PageController.new.about()`, that method will render template `src/views/page/about.ecr` in the context of layout `views/layouts/application.cr`, the result of rendering will be a full page with content `Hello, World!` in the body, and that result will be returned to the client as response body.

# Variables in Views<a name="variables_in_views"></a>

As mentioned, in Amber, templates are compiled and rendered directly in the context of the methods that call `render()`. Those are typically the controller methods themselves, and it means you generally do not need instance variables for passing the information from controllers to views.

Any variable you define in the controller method, instance or local, is directly visible in the template. For example, let's add the date and time and display them on our "About" page created in the previous step. The controller method and the corresponding view template would look like this:

```shell
$ vi src/controllers/page_controller.cr

def about
  time = Time.now
  render "about.ecr"
end

$ vi src/views/page/about.ecr

Hello, World! The time is now <%= time %>.
```

To further confirm that the templates also implicitly run in the same controller objectthat handled the request, you could place e.g. "<%= self.class %> in the above example; the response would be "PageController". So in addition to seeing the method's local variables, it means that all instance variables and methods existing on the controller object are readily available in the templates as well.

# More on Database Commands<a name="more_on_database_commands"></a>

## Micrate<a name="micrate"></a>

Amber relies on the shard "[micrate](https://github.com/amberframework/micrate)" to perform migrations. The command `amber db` uses "micrate" unconditionally. However, some of all the possible database operations are only available through `amber db` and some are only available through invoking `micrate` directly. Therefore, it is best to prepare the application for using both `amber db` and `micrate`.

Micrate is primarily a library so a small piece of custom code is required to provide the minimal `micrate` executable for a project. This is done by placing the following in `src/micrate.cr` (the example is for PostgreSQL but could be trivially adapted to MySQL or SQLite):

```crystal
#!/usr/bin/env crystal
require "amber"
require "micrate"
require "pg"

Micrate::DB.connection_url = Amber.settings.database_url
Micrate.logger = Amber.settings.logger.dup
Micrate.logger.progname = "Micrate"

Micrate::Cli.run
```

And by placing the following in `shard.yml` under `targets`:

```
targets:
  micrate:
    main: src/micrate.cr
```

From there, running `shards build micrate` would build `bin/micrate` which you could use as an executable to access micrate's functionality directly. Please run `bin/micrate -h` to see an overview of its commands.

Please note that the described procedure sets up `bin/micrate` and `amber db` in a compatible way so these commands can be used cooperatively and interchangeably.

To have your database migrations run with different credentials than your regular Amber app, simply create new environments in `config/environments/` and prefix your command lines with `AMBER_ENV=...`. For example, you could copy and modify `config/environments/development.yml` into `config/environments/development_admin.yml`, change the credentials as appropriate, and then run migrations as admin using `AMBER_ENV=development_admin ./bin/amber db migrate`.

## Custom Migrations Engine<a name="custom_migrations_engine"></a>

While `amber db` unconditionally depends on "micrate", that's the only place where it makes an assumption about the migrations engine used.

To use a different migrations engine, such as [migrate.cr](https://github.com/vladfaust/migrate.cr), simply perform all database migration work using the engine's native commands instead of using `amber db`. No other adjustments are necessary, and Amber won't get into your way.

# Internationalization (I18n)<a name="internationalization__i18n_"></a>

Amber uses Amber's native shard [citrine-18n](https://github.com/amberframework/citrine-i18n) to provide translation and localization. Even though the shard has been authored by the Amber Framework project, it is Amber-independent and can be used to initialize I18n and determine the visitor's preferred language in any application based on Crystal's HTTP::Server.

That shard in turn depends on the shard [i18n.cr](https://github.com/TechMagister/i18n.cr) to provide the actual translation and localization functionality.

The internationalization functionality in Amber is enabled by default. Its setup, initialization, and use basically consist of the following:

1. Initializer file `config/initializers/i18n.cr` where basic I18n settings are defined and `I18n.init` is invoked
1. Locale files in `src/locales/` and subdirectories where settings for both translation and localization are contained
1. Pipe named `Citrine::I18n::Handler` which is included in `config/routes.cr` and which detects the preferred language for every request based on the value of the request's HTTP header "Accept-Language"
1. Controller helpers named `t()` and `l()` which provide shorthand access for methods `::I18n.translate` and `::I18n.localize`

Once the pipe runs on the incoming request, the current request's locale is set in the variable `::I18n.locale`. The value is not stored or copied in any other location and it can be overriden in runtime in any way that the application would require.

For a locale to be used, it must be requested (or be the default) and exist anywhere under the directory `./src/locales/` with the name `[lang].yml`. If nothing can be found or matched, the locale value will default to "en".

From there, invoking `t()` and `l()` will perform translation and localization according to the chosen locale. Since these two methods are direct shorthands for methods `::I18n.translate` and `::I18n.localize`, all their usage information and help should be looked up in [i18n.cr's README](https://github.com/TechMagister/i18n.cr).

In a default Amber application there is a sample localization file `src/locales/en.yml` with one translated string ("Welcome to Amber Framework!") which is displayed as the title on the default project homepage.

In the future, the default/built-in I18n functionality in Amber might be expanded to automatically organize translations and localizations under subdirectories in `src/locales/` when generators are invoked, just like it is already done for e.g. files in `src/views/`. (This functionality already exists in i18n.cr as explained in [i18n.cr's README](https://github.com/TechMagister/i18n.cr), but is not yet used by Amber.)

# Responses<a name="responses"></a>

## Responses with Different Content-Type<a name="responses_with_different_content_type"></a>

If you want to provide a different format (or a different response altogether) from the controller methods based on accepted content types, you can use `respond_with` from `Amber::Helpers::Responders`.

Our `about` method from the previous example could be modified in the following way to respond with either HTML or JSON:

```crystal
def about
  respond_with do
    html render "about.ecr"
    json name: "John", surname: "Doe"
  end
end
```

Supported format types are `html`, `json`, `xml`, and `text`. For all the available methods and arguments, please see [controller/helpers/responders.cr](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/responders.cr).

## Error Responses<a name="error_responses"></a>

### Manual Error Responses<a name="manual_error_responses"></a>

In any pipe or controller action, you might want to manually return a simple error to the user. This typically means returning an HTTP error code and a short error message, even though you could just as easily print complete pages into the return buffer and return an error code.

To stop a request during execution and return an error, you would do it this way:

```
if some_condition_failed
  Amber.logger.error "Error! Returning Bad Request"

  # Status and any headers should be set before writing response body
  context.response.status_code = 400

  # Finally, write response body
  context.response.puts "Bad Request"


  # Another way to do the same and respond with a text/plain error
  # is to use Crystal's respond_with_error():
  context.response.respond_with_error("Bad Request", 400)

  return
end
```

Please note that you must use `context.response.puts` or `context.response<<` to print to the output buffer in case of errors. You cannot set the error code and then call `return "Bad Request"` because the return value will not be added to response body if HTTP code is not 2xx.

### Error Responses via Error Pipe<a name="error_responses_via_error_pipe"></a>

The above example for manually returning error responses does not involve raising any Exceptions &mdash; it simply consists of setting the status and response body and returning them to the client.

Another approach to returning errors consists in using Amber's error subsystem. It automatically provides you with a convenient way to raise Exceptions and return them to the client properly wrapped in application templates etc.

This method relies on the fact that pipes call next pipes in a row explicitly, and so the method call chain is properly established. In turn, this means that e.g. raising an exception in your controller can be rescued by an earlier pipe in a row that wrapped the call to `call_next(context)` inside a `begin...rescue` block.

Amber contains a generic pipe named "Errors" for handling errors. It is activated by using the line `plug Amber::Pipe::Error.new` in your `config/routes.cr`.

To be able to extend the list of errors or modify error templates yourself, you should first run `amber g error` to copy the relevant files to your application. In principle, running this command will get you the files `src/pipes/error.cr`, `src/controllers/error_controller.cr`, and `src/views/error/`, all of which can be modified to suit your needs.

To see the error subsystem at work, you could now do something as simple as:

```crystal
class HomeController < ApplicationController
  def index
    raise Exception.new "No pass!"
    render("index.slang")
  end
end
```

And then visit [http://localhost:3000/](http://localhost:3000/). You would see a HTTP 500 (Internal Server Error) containing the specified error message, but wrapped in an application template rather than printed plainly like the most basic HTTP errors.

# Assets Pipeline<a name="assets_pipeline"></a>

In an Amber project, raw assets are in `src/assets/`:

```shell
app/src/assets/
app/src/assets/fonts
app/src/assets/images
app/src/assets/images/logo.png
app/src/assets/javascripts
app/src/assets/javascripts/main.js
app/src/assets/stylesheets
app/src/assets/stylesheets/main.scss

```

At build time, all these are processed and placed under `public/dist/`.
The JS resources are bundled to `main.bundle.js` and CSS resources are bundled to `main.bundle.css`.

[Webpack](https://webpack.js.org/) is used for asset management.

To include additional .js or .css/.scss files you would generally add `import "../../file/path";` statements to `src/assets/javascripts/main.js`. You add both JS and CSS includes into `main.js` because webpack only processes import statements in .js files. So you must add the CSS import lines to a .js file, and as a result, this will produce a JS bundle that contains both JS and CSS data in it. Then, webpack's plugin named ExtractTextPlugin (part of default configuration) is used to extract CSS parts into their own bundle.

The base/common configuration for all this is in `config/webpack/common.js`.

## Adding jQuery and jQuery UI<a name="adding_jquery_and_jquery_ui"></a>

As an example, we can add the jQuery and jQuery UI libraries to an Amber project.

Please note that we are going to unpack the jQuery UI zip file directly into `src/assets/javascripts/` even though it contains some CSS and images. This is done because splitting the different asset types out to individual directories would be harder to do and maintain over time (e.g. paths in jQuery UI CSS files pointing to "images/" would no longer work, and updating the version later would be more complex).

The whole procedure would be as follows:

```bash
cd src/assets/javascripts

# Download jQuery
wget https://code.jquery.com/jquery-3.3.1.js

# Then download jQuery UI from http://jqueryui.com/download/ to the same/current directory
# and unpack it:
unzip jquery-ui-1.12.1.custom.zip

# Then edit main.js and add the import lines:
import './jquery-3.3.1.min.js'
import './jquery-ui-1.12.1.custom/jquery-ui.css'
import './jquery-ui-1.12.1.custom/jquery-ui.js'
import './jquery-ui-1.12.1.custom/jquery-ui.structure.css'
import './jquery-ui-1.12.1.custom/jquery-ui.theme.css'

# And finally, edit ../../../config/webpack/common.js to add jquery resource alias:
  resolve: {
    alias: {
      amber: path.resolve(__dirname, '../../lib/amber/assets/js/amber.js'),
      jquery: path.resolve(__dirname, '../../src/assets/javascripts/jquery-3.3.1.min.js')
    }
```

And that's it. At the next application build (e.g. with `amber watch`) all the mentioned resources and images will be compiled, placed to `public/dist/`, and included in the CSS/JS files.

## Resource Aliases<a name="resource_aliases"></a>

Sometimes, the code or libraries you include will in turn require other libraries by their generic name, e.g. "jquery". Since a file named "jquery" does not actually exist on disk (or at least not in the location that is searched), this could result in an error such as:

```
ERROR in ./src/assets/javascripts/jquery-ui-1.12.1.custom/jquery-ui.js
Module not found: Error: Can't resolve 'jquery' in '.../src/assets/javascripts/jquery-ui-1.12.1.custom'
 @ ./src/assets/javascripts/jquery-ui-1.12.1.custom/jquery-ui.js 5:0-26
  @ ./src/assets/javascripts/main.js
```

The solution is to add resource aliases to webpack's configuration which will instruct it where to find the real files if/when they are referenced by their alias.

For example, to resolve "jquery", you would add the following to the "resolve" section in `config/webpack/common.js`:

```
...
  resolve: {
    alias: {
      jquery: path.resolve(__dirname, '../../src/assets/javascripts/jquery-3.3.1.min.js')
    }
  }
...
```

## CSS Optimization / Minification<a name="css_optimization___minification"></a>

You might want to minimize the CSS that is output to the final CSS bundle.

To do so you need an entry under "devDependencies" in the project's file `package.json`:

```
    "optimize-css-assets-webpack-plugin": "^1.3.0",
```

And an entry at the top of `config/webpack/common.js`:

```
const OptimizeCSSPlugin = require('optimize-css-assets-webpack-plugin');
```

And you need to run `npm install` for the plugin to be installed (saved to "node_modules/" subdirectory).

## File Copying<a name="file_copying"></a>

You might also want to copy some of the files from their original location to `public/dist/` without doing any modifications in the process. This is done by adding the following under "devDependencies" in `package.json`:

```
    "copy-webpack-plugin": "^4.1.1",
```

To do so you need following at the top of `config/webpack/common.js`:

```
const CopyWebpackPlugin = require('copy-webpack-plugin');
```

And the following under "plugins" section down below in the file:

```
  new CopyWebPackPlugin([
    {
      from: path.resolve(__dirname, '../../vendor/images/'),
      to: path.resolve(__dirname, '../../public/dist/images/'),
      ignore: ['.*'],
    }
  ]),
```

And as usual, you need to run `npm install` for the plugin to be installed (saved to "node_modules/" subdirectory).

## Asset Management Alternatives<a name="asset_management_alternatives"></a>

Maybe it would be useful to replace Webpack with e.g. [Parcel](https://parceljs.org/). (Finding a non-js/non-node/non-npm application for this purpose would be even better; please let me know if you know one.)

In general it seems it shouldn't be much more complex than replacing the command to run and development dependencies in project's `package.json` file.

# Advanced Topics<a name="advanced_topics"></a>

What follows is a collection of advanced topics which can be read or skipped on an individual basis.

## Amber::Controller::Base<a name="amber__controller__base"></a>

This is the base controller from which all other controllers inherit. Source file is in [controller/base.cr](https://github.com/amberframework/amber/blob/master/src/amber/controller/base.cr).

On every request, the appropriate controller is instantiated and its initialize() runs. Since this is the base controller, this code runs on every request so you can understand what is available in the context of every controller.

The content of this controller and the methods it gets from including other modules are intuitive enough to be copied here and commented where necessary:

```crystal
require "http"

require "./filters"
require "./helpers/*"

module Amber::Controller
  class Base
    include Helpers::CSRF
    include Helpers::Redirect
    include Helpers::Render
    include Helpers::Responders
    include Helpers::Route
    include Helpers::I18n
    include Callbacks

    protected getter context : HTTP::Server::Context
    protected getter params : Amber::Validators::Params

    delegate :logger, to: Amber.settings

    delegate :client_ip,
      :cookies,
      :delete?,
      :flash,
      :format,
      :get?,
      :halt!,
      :head?,
      :patch?,
      :port,
      :post?,
      :put?,
      :request,
      :requested_url,
      :response,
      :route,
      :session,
      :valve,
      :websocket?,
      to: context

    def initialize(@context : HTTP::Server::Context)
      @params = Amber::Validators::Params.new(context.params)
    end
  end
end

```

[Helpers::CSRF](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/csrf.cr) module provides:

```crystal
    def csrf_token
    def csrf_tag
    def csrf_metatag
```

[Helpers::Redirect](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/redirect.cr) module provides:

```crystal
    def redirect_to(location : String, **args)
    def redirect_to(action : Symbol, **args)
    def redirect_to(controller : Symbol | Class, action : Symbol, **args)
    def redirect_back(**args)
```

[Helpers::Render](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/render.cr) module provides:

```crystal
    LAYOUT = "application.slang"
    macro render(template = nil, layout = true, partial = nil, path = "src/views", folder = __FILE__)
```

[Helpers::Responders](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/responders.cr) helps control what final status code, body, and content-type will be returned to the client.

[Helpers::Route](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/route.cr) module provides:

```crystal
    def action_name
    def route_resource
    def route_scope
    def controller_name
```

[Callbacks](https://github.com/amberframework/amber/blob/master/src/amber/dsl/callbacks.cr) module provides:

```crystal
    macro before_action
    macro after_action
```

## Extensions<a name="extensions"></a>

Amber adds some very convenient extensions to the existing String and Number classes. The extensions are in the [extensions/](https://github.com/amberframework/amber/tree/master/src/amber/extensions) directory. They are useful in general, but particularly so when writing param validation rules. Here's the listing of currently available extensions:

For String:

```crystal
      def str?
      def email?
      def domain?
      def url?
      def ipv4?
      def ipv6?
      def mac_address?
      def hex_color?
      def hex?
      def alpha?(locale = "en-US")
      def numeric?
      def alphanum?(locale = "en-US")
      def md5?
      def base64?
      def slug?
      def lower?
      def upper?
      def credit_card?
      def phone?(locale = "en-US")
      def excludes?(value)
      def time_string?

```

For Number:

```crystal
      def positive?
      def negative?
      def zero?
      def div?(n)
      def above?(n)
      def below?(n)
      def lt?(num)
      def self?(num)
      def lteq?(num)
      def between?(range)
      def gteq?(num)

```

## Shards<a name="shards"></a>

Amber and all of its components depend on the following shards:

```
--------SHARD--------------------SOURCE---DESCRIPTION------------------------------------------------------
------- Web, Routing, Templates, Mailers, Plugins ---------------------------------------------------------
require "amber"                  AMBER    Amber itself
require "amber_router"           AMBER    Request router implementation
require "citrine-18n"            AMBER    Translation and localization
require "http"                   CRYSTAL  Lower-level supporting HTTP functionality
require "http/client"            CRYSTAL  HTTP Client
require "http/headers"           CRYSTAL  HTTP Headers
require "http/params"            CRYSTAL  Collection of HTTP parameters and their values
require "http/server"            CRYSTAL  HTTP Server
require "http/server/handler"    CRYSTAL  HTTP Server's support for "handlers" (middleware)
require "quartz_mailer"          AMBER    Sending and receiving emails
require "email"                  EXTERNAL Simple email sending library
require "radix"                  EXTERNAL Radix Tree implementation
require "teeplate"               AMBER    Rendering multiple template files

------- Databases and ORM Models --------------------------------------------------------------------------
require "big"                    EXTERNAL BigRational for numeric. Retains precision, requires LibGMP
require "crecto"                 EXTERNAL Database wrapper for Crystal, inspired by Ecto
require "db"                     CRYSTAL  Common DB API
require "pool/connection"        CRYSTAL  Part of Crystal's common DB API
require "granite_orm/adapter/<%- @database %>" AMBER Granite's DB-specific adapter
require "micrate"                EXTERNAL Database migration tool
require "mysql"                  CRYSTAL  MySQL connector
require "pg"                     EXTERNAL PostgreSQL connector
require "redis"                  EXTERNAL Redis client
require "sqlite3"                EXTERNAL SQLite3 bindings

------- Template Rendering --------------------------------------------------------------------------------
require "crikey"                 EXTERNAL Template language, Data structure view, inspired by Hiccup
require "crustache"              EXTERNAL Template language, {{Mustache}} for Crystal
require "ecr"                    CRYSTAL  Template language, Embedded Crystal (ECR)
require "kilt"                   EXTERNAL Generic template interface
require "kilt/slang"             EXTERNAL Kilt support for Slang template language
require "liquid"                 EXTERNAL Template language, used by Amber for recipe templates
require "slang"                  EXTERNAL Template language, inspired by Slim
require "temel"                  EXTERNAL Template language, extensible Markup DSL

------- Command Line, Logs, and Output --------------------------------------------------------------------
require "cli"                    EXTERNAL Support for building command-line interface applications
require "colorize"               CRYSTAL  Changing colors and text decorations
require "logger"                 CRYSTAL  Simple but sophisticated logging utility
require "optarg"                 EXTERNAL Parsing command-line options and arguments
require "option_parser"          CRYSTAL  Command line options processing
require "shell-table"            EXTERNAL Creating text tables in command line terminal

------- Formats, Protocols, Digests, and Compression ------------------------------------------------------
require "digest/md5"             CRYSTAL  MD5 digest algorithm
require "html"                   CRYSTAL  HTML escaping and unescaping methods
require "jasper_helpers"         AMBER    Helper functions for working with HTML
require "json"                   CRYSTAL  Parsing and generating JSON documents
require "openssl"                CRYSTAL  OpenSSL integration
require "openssl/hmac"           CRYSTAL  Computing Hash-based Message Authentication Code (HMAC)
require "openssl/sha1"           CRYSTAL  OpenSSL SHA1 hash functions
require "yaml"                   CRYSTAL  Serialization and deserialization of YAML 1.1
require "zlib"                   CRYSTAL  Reading/writing Zlib compressed data as specified in RFC 1950

------- Supporting Functionality --------------------------------------------------------------------------
require "base64"                 CRYSTAL  Encoding and decoding of binary data using base64 representation
require "benchmark"              CRYSTAL  Benchmark routines for benchmarking Crystal code
require "bit_array"              CRYSTAL  Array data structure that compactly stores bits
require "callback"               EXTERNAL Defining and invoking callbacks
require "compiled_license"       EXTERNAL Compile in LICENSE files from project and dependencies
require "compiler/crystal/syntax/*" CRYSTAL Crystal syntax parser
require "crypto/bcrypt/password" CRYSTAL  Generating, reading, and verifying Crypto::Bcrypt hashes
require "crypto/subtle"          CRYSTAL
require "file_utils"             CRYSTAL  Supporting functions for files and directories
require "i18n"                   EXTERNAL Underlying I18N shard for Crystal
require "inflector"              EXTERNAL Inflector for Crystal (a port of Ruby's ActiveSupport::Inflector)
require "process"                CRYSTAL  Supporting functions for working with system processes
require "random/secure"          CRYSTAL  Generating random numbers from a secure source provided by system
require "selenium"               EXTERNAL Selenium Webdriver client
require "socket"                 CRYSTAL  Supporting functions for working with sockets
require "socket/tcp_socket"      CRYSTAL  Supporting functions for TCP sockets
require "socket/unix_socket"     CRYSTAL  Supporting functions for UNIX sockets
require "string_inflection/kebab"EXTERNAL Singular/plurals words in "kebab" style ("foo-bar")
require "string_inflection/snake"EXTERNAL Singular/plurals words in "snake" style ("foo_bar")
require "tempfile"               CRYSTAL  Managing temporary files
require "uri"                    CRYSTAL  Creating and parsing URI references as defined by RFC 3986
require "uuid"                   CRYSTAL  Functions related to Universally unique identifiers (UUIDs)
require "weak_ref"               CRYSTAL  Weak Reference class allowing referenced objects to be GC-ed
require "zip"                    EXTERNAL Zip compression library, used for fetching zipped recipes
```


Only the parts that are used end up in the compiled project.

## Environments<a name="environments"></a>

After "[amber](https://github.com/amberframework/amber/blob/master/src/amber.cr)" shard is loaded, `Amber` module automatically includes [Amber::Environment](https://github.com/amberframework/amber/blob/master/src/amber/environment.cr) which adds the following methods:

```
Amber.settings         # Singleton object, contains current settings
Amber.logger           # Alias for Amber.settings.logger
Amber.env, Amber.env=  # Env (environment) object (development, production, test)
```

The list of all available application settings is in [Amber::Environment::Settings](https://github.com/amberframework/amber/blob/master/src/amber/environment/settings.cr). These settings are loaded from the application's `config/environment/<name>.yml` file and are then overriden by any settings in `config/application.cr`'s `Amber::Server.configure` block.

[Env](https://github.com/amberframework/amber/blob/master/src/amber/environment/env.cr) (`amber.env`) also provides basic methods for querying the current environment:
```crystal
    def initialize(@env : String = ENV[AMBER_ENV]? || "development")
    def in?(env_list : Array(EnvType))
    def in?(*env_list : Object)
    def to_s(io)
    def ==(env2 : EnvType)

```

## Starting the Server<a name="starting_the_server"></a>

It is important to explain exactly what happens from the time you run the application til Amber starts serving user requests:

1. `crystal src/<app_name>.cr` - you or a script starts Amber
	1. `require "../config/*"` - as the first thing, `config/*` is required. Inclusion is in alphabetical order. Crystal only looks for *.cr files and only files in config/ are loaded (no subdirectories)
		1. `require "../config/application.cr"` - this is usually the first file in `config/`
			1. `require "./initializers/**"` - loads all initializers. There is only one initializer file by default, named `initializer/database.cr`. Here we have a double star ("**") meaning inclusion of all files including in subdirectories. Inclusion is always current-dir first, then depth
			1. `require "amber"` - Amber itself is loaded
				1. Loading Amber makes `Amber::Server` class available
				1. `include Amber::Environment` - already in this stage, environment is determined and settings are loaded from yml file (e.g. from `config/environments/development.yml`. Settings are later available as `settings`
			1. `require "../src/controllers/application_controller"` - main controller is required. This is the base class for all other controllers
				1. It defines `ApplicationController`, includes JasperHelpers in it, and sets default layout ("application.slang").
			1. `require "../src/controllers/**"` - all other controllers are loaded
			1. `Amber::Server.configure` block is invoked to override any config settings
		1. `require "config/routes.cr"` - this again invokes `Amber::Server.configure` block, but concerns itself with routes and feeds all the routes in
	1. `Amber::Server.start` is invoked
		1. `instance.run` - implicitly creates a singleton instance of server, saves it to `@@instance`, and calls `run` on it
		1. Consults variable `settings.process_count`
		1. If process count is 1, `instance.start` is called
		1. If process count is > 1, the desired number of processes is forked, while main process enters sleep
			1. Forks invoke Process.run() and start completely separate, individual processes which go through the same initialization procedure from the beginning. Forked processes have env variable "FORKED" set to "1", and a variable "id" set to their process number. IDs are assigned in reverse order (highest number == first forked).
		1. `instance.start` is called for every process
			1. It saves current time and prints startup info
			1. `@handler.prepare_pipelines` is called. @handler is Amber::Pipe::Pipeline, a subclass of Crystal's [HTTP::Handler](https://crystal-lang.org/api/0.24.1/HTTP/Handler.html). `prepare_pipelines` is called to connect the pipes so the processing can work, and implicitly adds Amber::Pipe::Controller (the pipe in which app's controller is invoked) as the last pipe. This pipe's duty is to call Amber::Router::Context.process_request, which actually dispatches the request to the controller.
			1. `server = HTTP::Server.new(host, port, @handler)`- Crystal's HTTP server is created
			1. `server.tls = Amber::SSL.new(...).generate_tls if ssl_enabled?`
			1. Signal::INT is trapped (calls `server.close` when received)
			1. `loop do server.listen(settings.port_reuse) end` - server enters main loop

## Serving Requests<a name="serving_requests"></a>

Similarly as with starting the server, is important to explain exactly what is happening when Amber is serving requests:

Amber's app serving model is based on Crystal's built-in, underlying functionality:

1. The server that is running is an instance of Crystal's
	 [HTTP::Server](https://crystal-lang.org/api/0.24.1/HTTP/Server.html)
2. On every incoming request, a "handler" is invoked. As supported by Crystal, handler can be a simple Proc or an instance of [HTTP::Handler](https://crystal-lang.org/api/0.24.1/HTTP/Handler.html). HTTP::Handlers have a concept of "next" and multiple ones can be connected in a row. In Amber, these individual handlers are called "pipes" and currently at least two of them are always pre-defined &mdash; pipes named "Pipeline" and "Controller". The pipe "Pipeline" always executes first; it determines which pipeline the request is meant for and runs the first pipe in that pipeline. The pipe "Controller" always executes last; it consults the routing table, instantiates the appropriate controller, and invokes the appropriate method on it
3. In the pipeline, every Pipe (Amber::Pipe::*, ultimately subclass of Crystal's [HTTP::Handler](https://crystal-lang.org/api/0.24.2/HTTP/Handler.html)) is invoked with one argument. That argument is
	 by convention called "context" and it is an instance of `HTTP::Server::Context`. By default it has two built-in methods &mdash; `request` and `response`, containing the request and response parts respectively. On top of that, Amber adds various other methods and variables, such as `router`, `flash`, `cookies`, `session`, `content`, `route`, `client_ip`, and others as seen in [router/context.cr](https://github.com/amberframework/amber/blob/master/src/amber/router/context.cr) and [extensions/http.cr](https://github.com/amberframework/amber/blob/master/src/amber/extensions/http.cr)
4. Please note that calling the chain of pipes is not automatic; every pipe needs to call `call_next(context)` at the appropriate point in its execution to call the next pipe in a row. It is not necessary to check whether the next pipe exists, because currently `Amber::Pipe::Controller` is always implicitly added as the last pipe, so in the context of your pipes the next one always exists. State between pipes is not passed via separate variables but via modifying `context` and the data contained in it. Context persists for the duration of the request. Context persists for the duration of the request

After that, pipelines, pipes, routes, and other Amber-specific parts come into play.

So, in detail, from the beginning:

1. `loop do server.listen(settings.port_reuse) end` - main loop is running
	1. `spawn handle_client(server.accept?)` - handle_client() is called in a new fiber after connection is accepted
		1. `io = OpenSSL::SSL::Socket::Server.new(io, tls, sync_close: true) if @tls`
		1. `@processor.process(io, io)`
			1. `if request.is_a?(HTTP::Request::BadRequest); response.respond_with_error("Bad Request", 400)`
			1. `response.version = request.version`
			1. `response.headers["Connection"] = "keep-alive" if request.keep_alive?`
			1. `context = Context.new(request, response)` - this context is already extended by Amber with additional properties and methods
			1. `@handler.call(context)` - `Amber::Pipe::Pipeline.call()` is called
				1. `raise ...error... if context.invalid_route?` - route validity is checked early
				1. `if context.websocket?; context.process_websocket_request` - if websocket, parse as such
				1. `elsif ...; ...pipeline.first...call(context)` - if regular HTTP request, call the first handler in the appropriate pipeline
					1. `call_next(context)` - each pipe calls call_next(context) somewhere during its execution, and all pipes are executed
						1. `context.process_request` - the always-last pipe (Amber::Pipe::Controller) calls `process_request` to dispatch the action to controller. After that last pipe, the stack of call_next()s is "unwound" back to the starting position
					1. `context.finalize_response` - minor final adjustments to response are made (headers are added, and response body is printed unless action was HEAD)

## Support Routines<a name="support_routines"></a>

In [support/](https://github.com/amberframework/amber/tree/master/src/amber/support) directory there is a number of various support files that provide additional, ready-made routines.

Currently, the following can be found there:

```
client_reload.cr      - Support for reloading developer's browser

file_encryptor.cr     - Support for storing/reading encrypted versions of files
message_encryptor.cr
message_verifier.cr

locale_formats.cr     - Very basic locate data for various manually-added locales

mime_types.cr         - List of MIME types and helper methods for working with them:

                        def self.mime_type(format, fallback = DEFAULT_MIME_TYPE)
                        def self.zip_types(path)
                        def self.format(accepts)
                        def self.default
                        def self.get_request_format(request)
```

## Amber behind a Load Balancer | Reverse Proxy | ADC<a name="amber_behind_a_load_balancer___reverse_proxy___adc"></a>

(In this section, the terms "Load Balancer", "Reverse Proxy", "Proxy", and "Application Delivery Controller" (ADC) are used interchangeably.)

By default, in development environment Amber listens on port 3000, and in production environment it listens on port 8080. This makes it very easy to run a load balancer on ports 80 (HTTP) and 443 (HTTPS) and proxy user requests to Amber.

There are three groups of benefits of running Amber behind a proxy:

On a basic level, a proxy will perform TCP and HTTP normalization &mdash; it will filter out invalid TCP packets, flags, window sizes, sequence numbers, and SYN floods. It will only pass valid HTTP requests through (protecting the application from protocol-based attacks) and smoothen out deviations which are tolerated by HTTP specification (such as multi-line HTTP headers). Finally, it will provide HTTP/2 support for your application and perform SSL and compression offloading so that these functions are done on the load balancers rather than on the application servers.

Also, as an important implementation-specific detail, Crystal currently does not provide applications with the information on the client IPs that are making HTTP requests. Therefore, Amber is by default unaware of them. With a proxy in front of Amber and using Amber's pipe `ClientIp`, the client IP information will be passed from the proxy to Amber and be available as `context.client_ip.address`.

On an intermediate level, a proxy will provide you with caching and scaling and serve as a versatile TCP and HTTP load balancer. It will cache static files, route your application and database traffic to multiple backend servers, balance multiple protocols based on any criteria, fix and rewrite HTTP traffic, and so on. The benefits of starting application development with acceleration and scaling in mind from the get-go are numerous.

On an advanced level, a proxy will allow you to keep track of arbitrary statistics and counters, perform GeoIP offloading and rate limiting, filter out bots and suspicious web clients, implement DDoS protection and web application firewall, troubleshoot network conditions, and so on.

[HAProxy](www.haproxy.org) is an excellent proxy to use and to run it you will only need the `haproxy` binary, two command line options, and a config file. A simple HAProxy config file that can be used out of the box is available in [support/haproxy.conf](https://github.com/docelic/amber-introduction/blob/master/support/haproxy.conf). This config file will be expanded over time into a full-featured configuration to demonstrate all of the above-mentioned points, but even by default the configuration should be good enough to get you started with practical results.

HAProxy comes pre-packaged for most GNU/Linux distributions and MacOS, but if you do not see version 1.8.x available, it is recommended to manually install the latest stable version.

<a name="install-haproxy"></a>To compile the latest stable HAProxy from source, you could use the following procedure:

```
git clone http://git.haproxy.org/git/haproxy-1.8.git/
cd haproxy-1.8
make -j4 TARGET=linux2628 USE_OPENSSL=1
```

The compilation will go trouble-free and you will end up with the binary named `haproxy` in the current directory.

To obtain the config file and set up the basic directory structure, please run the following in your Amber app directory:

```sh
cd config
wget https://raw.githubusercontent.com/docelic/amber-introduction/master/support/haproxy.conf
cd ..
mkdir -p var/{run,empty}
```

And finally, to start HAProxy in development/foreground mode, please run:

```sh
sudo ../haproxy-1.8/haproxy -f config/haproxy.conf -d
```

And then start `amber watch` and point your browser to [http://localhost/](http://localhost/) instead of [http://localhost:3000/](http://localhost:3000/)!

Please also note that this HAProxy configuration enables the built-in HAProxy status page at [http://localhost/server-status](http://localhost/server-status) and restricts access to it to localhost.

When you confirm everything is working, you can omit the `-d` flag and it will start HAProxy in background, returning the shell back to you. You can then forget about HAProxy until you modify its configuration and want to reload it. Then simply call `kill -USR2 var/run/haproxy.pid`.

Finally, now that we are behind a proxy, to get access to client IPs we can enable the following line in `config/routes.cr`:

```
    plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
```

And we can modify one of the views to display the user IP address. Assuming you are using slang, you could edit the default view file `src/views/home/index.slang` and add the following to the bottom to confirm the new behavior:

```
    a.list-group-item.list-group-item-action href="#" = "IP Address: " + ((ip = context.client_ip) ? ip.address : "Unknown")
```

# Ecommerce with Amber<a name="ecommerce_with_amber"></a>

I am working on [Jet](https://github.com/jetcommerce/jet), an ecommerce solution for Amber.

# Conclusion<a name="conclusion"></a>

We hope you have enjoyed this hands-on introduction to Amber!

Feel free to provide any feedback on content or additional areas you
would like to see covered in this guide. Thanks!

