<Micrate p align="center">
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

{{{TOC}}}

# Introduction

**Amber** is a web application framework written in [Crystal](http://www.crystal-lang.org). Homepage can be found at [amberframework.org](https://amberframework.org/), docs at [Amber Docs](https://docs.amberframework.org), GitHub repository at [amberframework/amber](https://github.com/amberframework/amber), and the chat on [Gitter](https://gitter.im/amberframework/amber) or on the FreeNode IRC channel #amber.

Amber is inspired by Kemal, Rails, Phoenix and other frameworks. It is simple to get used to, and much more intuitive than frameworks like Rails. (But it does inherit some concepts from Rails that are good.)

This document is here to describe everything that Amber offers out of the box, sorted in a logical order and easy to consult repeatedly over time. The Crystal level is not described; it is expected that the readers coming here have a formed understanding of [Crystal and its features](https://crystal-lang.org/docs/overview/).

# Installation

```shell
git clone https://github.com/amberframework/amber
cd amber
make # The result of 'make' is one file -- command line tool bin/amber

#: To install the file, or to symlink the system-wide executable to current directory, run one of:
make install # default PREFIX is /usr/local
make install PREFIX=/usr/local/stow/
make force_link # can also specify PREFIX=...
```

("stow" mentioned above is referring to [GNU Stow](https://www.gnu.org/software/stow/).)

After installation or linking, `amber` is the command you will be using for creating and managing Amber apps.

Please note that some users prefer (or must use for compatibility reasons) local Amber executables which match the version of Amber used in their project. For that, project's `shard.yml` ships with the build target "amber":

```
targets:
  ...
  amber:
    main: lib/amber/src/amber/cli.cr

```

Running `crystal deps build amber` will compile Amber located in `lib/amber/` and place the executable to project's local file `bin/amber`.

# Creating New Amber App

```shell
amber new <app_name> [-d DATABASE] [-t TEMPLATE_LANG] [-m ORM_MODEL] [--deps]
```

Supported databases are [PostgreSQL](https://www.postgresql.org/) (pg, default), [MySQL](https://www.mysql.com/) (mysql), and [SQLite](https://sqlite.org/) (sqlite).

Supported template languages are [slang](https://github.com/jeromegn/slang) (default) and [ecr](https://crystal-lang.org/api/0.21.1/ECR.html). (But any languages can be used; more on that can be found below in [Template Languages](#template_languages).)

Slang is extremely elegant, but very different from the traditional perception of HTML.
ECR is HTML-like, very similar to Ruby ERB, and more than mediocre when compared to slang, but it may be the best choice for your application if you intend to use some HTML site template (from e.g. [themeforest](https://themeforest.net/)) whose pages are in HTML + CSS or SCSS. (Or you could also try [html2slang](https://github.com/docelic/html2slang/) which converts HTML pages into slang.)

Supported ORM models are [granite](https://github.com/amberframework/granite-orm) (default) and [crecto](https://github.com/Crecto/crecto).

Granite is Amber's native very nice and simple, effective ORM model where you mostly write your own SQL (i.e. all search queries typically look like `YourModel.all("WHERE field1 = ? AND field2 = ?", [value1, value2])`). But it also has belongs/has relations, and some other little things. (If you have by chance known and loved [Class::DBI](http://search.cpan.org/~tmtm/Class-DBI-v3.0.17/lib/Class/DBI.pm) for Perl, it might remind you of it in some ways.)

Supported migrations engine is [micrate](https://github.com/amberframework/micrate). Micrate is very simple and you basically write raw SQL in your migrations. There are just two keywords in the migration file which give instructions whether the SQLs that follow pertain to migrating up or down. These keywords are "-- +micrate Up" and "-- +micrate Down".

If argument --deps is provided, Amber will automatically run `crystal deps` in the new directory to install shards.

Please note that shards-related commands use the directory `.shards/` as local staging area before contents are fully ready to replace shards in `lib/`.

# Running the App

The app can be started as soon as you have created it and ran `crystal deps` in the app directory.
(It is not necessary to run deps if you have invoked `amber new` with the argument --deps; in that case Amber did it for you.)

To run it, you can use a couple different approaches. Some are of course suitable for development, some for production, etc.:

```shell
#: For development, clean and simple - compiles and runs your app:
crystal src/<app_name>.cr

#: For development, clean and simple - compiles and runs your app, but
#: also watches for changes in files and rebuilds/re-runs automatically.
amber watch

#: For production, compiles app with optimizations and places it in bin/app.
#: Crystal by default compiles using 8 threads (tune if needed with --threads NUM)
crystal build --no-debug --release --verbose -t -s -p -o bin/<app_name> src/<app_name>.cr
```

Amber by default uses a feature called "port reuse" available in newer Linux kernels. If you get an error "setsockopt: Protocol not available", it means your kernel does not have it. Please edit `config/environments/development.yml` and set "port_reuse" to false.

# Building the App and Troubleshooting

The application is always built, regardless of whether one is using the Crystal command 'run' (the default) or 'build'. It is just that in run mode, the resulting binary won't be saved to a file, but will be executed and later discarded.

Thanks to Crystal's compiler implementation, only the parts actually used are added to the executable. Listing dependencies in `shard.yml` or using `require`s in your program will generally not affect what is compiled in.

For faster build speed, development versions are compiled without the --release flag. With the --release flag, the compilation takes noticeably longer, but the resulting binary has incredible performance.

Crystal caches partial results of the compilation (*.o files etc.) under `~/.cache/crystal/` for faster subsequent builds. This directory is also where temporary binaries are placed when one runs programs with `crystal [run]` rather than `crystal build`.

Sometimes building the app will fail on the C level because of missing header files or libraries. If Crystal doesn't print the actual C error, it will at least print the compiler line that caused it.

The best way to see the actual error from there is to copy-paste the command printed and run it manually in the terminal. The error will be shown and from there the cause will be determined easily.

There are some issues with the `libgc` library here and there. In my case the solution was to reinstall the package `libgc-dev`.

# REPL

Often times, it is very useful to enter an interactive console (think of IRB shell) with all application classes initialized etc. In Ruby this would be done with IRB or with a command like `rails console`.

Due to its nature, Crystal does not have a free-form [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop), but you can save and execute scripts in the context of the application. One way to do it is via command `amber x [filename]`. This command will allow you to type or edit the contents, and then execute the script.

Another, possibly more flexible way to do it is via standalone REPL-like tools [cry](https://github.com/elorest/cry) and [icr](https://github.com/crystal-community/icr). `cry` began as an experiment and a predecessor to `amber x`, but now offers additional functionality such as repeatedly editing and running the script if `cry -r` is invoked.

In any case, running a script "in application context" simply means requiring `config/application.cr` (and through it, `config/**`). Therefore, be sure to list all your requires in `config/application.cr` so that everything works as expected, and if you are using `cry` or `icr`, have `require "./config/application"` as the first command.

# File Structure

So, at this point you might be wanting to know what's placed where in an Amber application. The default structure looks like this:

```
./config/                  - All configuration
./config/initializers/     - Initializers (files you want loaded at the very beginning)
./config/environments/     - Environment-specific YAML configurations
./config/application.cr    - Main configuration file for the app. Generally not touched (apart
                             from adding "require"s to the top) because most of the config
                             settings are specified in YAML files in config/environments/
./config/webpack/          - Webpack (asset bundler) configuration
./config/routes.cr         - All routes
./db/migrations/           - All DB migration files (created with 'amber g migration ...')
./public/                  - The "public" directory for static files
./public/dist/             - Directory inside "public" for generated files and bundles
./public/dist/images/
./src/                     - Main source directory, with <app_name>.cr being the main/entry file
./src/controllers/         - All controllers
./src/models/              - All models
./src/views/layouts/       - All layouts
./src/views/               - All views
./src/views/home/          - Views for HomeController (path "/")
./src/locales/             - Toplevel directory for locale (translation) files named [lang].yml
./src/assets/              - Static assets which will be bundled and placed into ./public/dist/
./src/assets/stylesheets/
./src/assets/fonts/
./src/assets/images/
./src/assets/javascripts/
./spec/                    - Tests (named *_spec.cr)
```

I prefer to have some of these directories accessible directly in the root directory of the application and to have the config directory named `etc`, so I run:

```
[[[cat ln-sfs]]]
```

# Amber Database Commands

Amber provides a group of subcommands under `amber db` to allow working with the database. The simple commands you will most probably want to run just to see basic things working are:

```shell
amber db create
amber db status
amber db version
```

Before these commands will work, you will need to configure database
credentials:

First, create a user to access the database. For PostgreSQL, this is done by invoking something like:

```shell
$ sudo su - postgres
$ createuser -dElPRS myuser
Enter password for new role: 
Enter it again: 
```

Then, edit `config/environments/development.yml` and configure "database_url:" to match your settings. If nothing else, the part that says "postgres:@" should be replaced with "yourusername:yourpassword@".

And then try the database commands from the beginning of this section.

Please note that for the database connection to succeed, all parameters must be correct &mdash; the hostname, port, username, password, and database name must be valid, the database server must be accessible, and the database must actually exist (unless you are invoking 'amber db create' to create it). In case of *any error in any of these*, the error message will be very terse and just say "Connection unsuccessful: <database_url>". The solution is simple, though - simply use the printed database_url to manually attempt a connection to the database with the same parameters, and the problem will most likely quickly reveal itself.

(If you are sure that the username and password are correct, then the most common problem is that the database does not exist yet, so you should run `amber db create` as the first command.)

Please note that the environment files for non-production environment are given in plain text. Environment file for the production environment is encrypted for additional security and can be seen or edited by invoking `amber encrypt`.

# Routes

Routes are very easy to understand. Routes connect HTTP methods (and the paths with which they were invoked) to controllers and methods on the Amber side.

Amber includes a wonderful command `amber routes` to display current routes. By default, the routes table looks like the following:

```shell
$ amber routes

[[[cd app && amber routes --no-color]]]
```

From this example, we see that a "GET /" request will instantiate
HomeController and then call method index() in it. The return value of
the method will be returned as response body to the client.

Similarly, here's an example of a route that would route POST "/registration" to RegistrationController.new.create():

```
post "/registration", RegistrationController, :create
```

By convention, standard HTTP verbs (GET, HEAD, POST, PUT, PATCH, DELETE) should be routed to standard-named methods on the controllers (show, new, create, edit, update, destroy). However, there is nothing preventing you from routing URLs to any methods you want in the controllers, such as we've done with "index" above.

Websocket routes are supported too.

The DSL language specific to `config/routes.cr` file is defined in [dsl/router.cr](https://github.com/amberframework/amber/blob/master/src/amber/dsl/router.cr) and [dsl/server.cr](https://github.com/amberframework/amber/blob/master/src/amber/dsl/server.cr).

It gives you the following top-level commands/blocks:

```
#: Define a pipeline
pipeline :name do
  ...
end

#: Group a set of routes
routes :name, "path" do
  ...
end
```

Such as:

```crystal
Amber::Server.configure do |app|
  pipeline :web do
    # Plug is the method used to connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    plug Amber::Pipe::Logger.new
  end

  routes :web do
    get "/", HomeController, :index    # Routes to HomeController::index()
    get "/test", PageController, :test # Routes to PageController::test()
  end
end
```

Within 'routes', the following commands are available:

```crystal
get, post, put, patch, delete, options, head, trace, connect, websocket, resources
```

`resources` is a macro defined as:

```crystal
    macro resources(resource, controller, only = nil, except = nil)
```

And unless it is confined with arguments `only` or `except`, it will automatically define get, post, put, patch, and delete routes for your resource and route them to the following methods in the controller:

```crystal
index, new, create, show, edit, update, destroy
```

Please note that it is not currently possible to define a different behavior for HEAD and GET methods on the same path, because if a GET is defined it will also automatically add the matching HEAD route. That will result in two HEAD routes existing for the same path and trigger error `Amber::Exceptions::DuplicateRouteError`.

# Views

Information about views can be summarized in bullet points:

- Views in Amber are located in `src/views/`
- They are rendered using `render()`
- The first argument given to `render()` is the template name (e.g. `render("index.slang")`)
- If we are in the context of a controller, `render("index.slang")` will look for view using the path `src/views/<controller_name>/index.slang`
- If we are not rendering a partial, by default the template will be wrapped in a layout
- If the layout name isn't given, the default layout will be `views/layouts/application.slang`
- There is no unnecessary magic applied to template names &mdash; name given is the name that is looked up on disk
- Partials begin with "_" by convention, but that is not required
- To render a partial, use `render( partial: "_name.ext")`

## Variables in Views

In Amber, templates are compiled in the same scope as controller methods. This means you do not need instance variables for passing the information from controllers to views.

Any variable you define in the controller method is automagically visible in the template. For example, let's add the current date and time display to our /about page:

```shell
$ vi src/controllers/page_controller.cr

def about
	time = Time.now
	render "about.ecr"
end

$ vi src/views/page/about.ecr

Hello, World! The time is now <%= time %>.
```

Templates are actually executing in the controller class. If you do "<%= self.class %> in the above example, the response will be "PageController". So all the methods and variables you have on the controller are also available in views rendered from it.

## Template Languages

In the introduction we've mentioned that Amber supports two template languages &mdash; [slang](https://github.com/jeromegn/slang) (default) and [ecr](https://crystal-lang.org/api/0.21.1/ECR.html).

That's because Amber ships with the minimal working layout (a total of 3 files) in those languages, but there is nothing preventing you from using any other languages if you have your own templates or want to convert existing ones.

Amber's default rendering model is based on [Kilt](https://github.com/jeromegn/kilt), so all languages supported by Kilt should be usable out of the box. Amber does not make assumptions about the template language used; the view file's extension will determine which parser will be invoked (e.g. ".ecr" for ecr, ".slang" for slang).

### Liquid Template Language

The original [Kilt](https://github.com/jeromegn/kilt) repository now has support for the Liquid template language.

Please note, however, that Liquid as a template language comes with non-typical requirements &mdash; primarily, it requires a separate store ("context") for user data which is to be available in templates, and also it does not support using arbitrary functions, objects, object methods, and data types in its templates.

As such, Amber's principle of rendering the templates directly inside controller methods (and thus making all local variables automatically available in views) does not apply here because Liquid's context is separate and local variables are not there.

Also, Liquid's implementation by default tries to be helpful and it automatically creates a new context. It copies all instance variables (@ivars) from the current object into the newly created context, which can't be used with Amber for two reasons.
First, it does not work for data other than basic types (e.g. saying `@process = Process` does not make `{{ process.pid }}` usable in a Liquid template). Second, because Amber's controllers already contain various instance variables that should not or can not be serialized, so simply saying `render("index.liquid")` will result in a compile-time error in Amber even if the template was empty.

Also, Amber's `render` macro does not accept extra arguments, so a custom context can't be passed to Kilt and from there to Liquid.

Therefore, the best approach to work with Liquid in Amber is to create a custom context, populate it with desired values, and then invoke `Kilt.render` directly. For example:

```
context = Liquid::Context.new
context.set "process", { "pid" => Process.pid }

#: This will default to src/views/[controller]/index.liquid
Kilt.render "index.liquid", context

#: This will render specific path relative to app base directory
Kilt.render "src/views/myview.liquid", context
```

# Logging

Amber logger (based on standard Crystal's class `Logger`) is initialized as soon as `require "amber"` is called, as part of reading the settings and initializing the environment.

The variable containing the logger is `Amber.settings.logger` and, for convenience, it is also available as `Amber.logger`. In the context of a Controller, logger is also available as simply `logger`.

Controllers and views execute in the same class (the class of the controller), so calling the following anywhere in the controller or views will produce the expected log line:

```crystal
logger.info "Informational Message"
```

Log levels available are `debug`, `info`, `warn`, `error`, `fatal`, and `unknown`.

The second, optional parameter passed to the log method will affect the displayed name of the subsystem in which the message originated. For example:


```crystal
logger.warn "Starting up", "MySystem"
```

Will result in the log line:

```
03:17:04 MySystem   | (WARN) Starting up
```

In you still need a customized logger for special cases or purposes, please create a separate `Logger.new` yourself.

# Starting the Server

It is important to explain exactly what is happening from when you run the application til Amber starts serving the application:

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

# Serving Requests

Similarly as with starting the server, is important to explain exactly what is happening when Amber is serving requests:

Amber's app serving model is based on Crystal's built-in, underlying functionality:

1. The server that is running is an instance of Crystal's
	 [HTTP::Server](https://crystal-lang.org/api/0.24.1/HTTP/Server.html)
2. On every incoming request, a "handler" is invoked. As supported by Crystal, handler can be a simple Proc or an instance of [HTTP::Handler](https://crystal-lang.org/api/0.24.1/HTTP/Handler.html). HTTP::Handlers have a concept of "next" and multiple ones can be connected in a row. In Amber, these individual handlers are called "pipes" and currently two of them are pre-defined: the first and last pipe. The first pipe is called "Pipeline" (Amber::Pipe::Pipeline); it determines which pipeline the request is meant for, and runs the next pipe in that pipeline. The last pipeline is called "Controller" (Amber::Pipe::Controller); its duty is to consult the routing table and call the appropriate controller and method in response to a request
3. In the pipeline, every Pipe (Amber::Pipe::*, ultimately subclass of Handler) is invoked, with one argument. That argument is
	 by convention called "context" and it is an instance of `HTTP::Server::Context`, which has two built-in methods &mdash; `request` and `response`, to access the request and response parts respectively. On top of that, Amber adds various other methods and variables, such as `router`, `flash`, `cookies`, `session`, `content`, `route`, and others as seen in [src/amber/router/context.cr](https://github.com/amberframework/amber/blob/master/src/amber/router/context.cr)
4. Please note that calling the chain of pipes is not automatic; every pipe needs to call `call_next(context)` at the appropriate point in its execution to call the next pipe in a row. It is not necessary to check whether the next pipe exists, because currently `Amber::Pipe::Controller` is always implicitly added as the last pipe, so at least one does exist. State between pipes is not passed via variables but via modifying `context` and the data contained in it

After that, pipelines, pipes, routes, and other Amber-specific parts come into play.

So, in detail, from the beginning:

1. `loop do server.listen(settings.port_reuse) end` - main loop is running
	1. `spawn handle_client(server.accept?)` - handle_client() is called in a new fiber after connection is accepted
		1. `io = OpenSSL::SSL::Socket::Server.new(io, tls, sync_close: true) if @tls`
		1. `@processor.process(io, io)`
			1. `if request.is_a?(HTTP::Request::BadRequest); response.respond_with_error("Bad Request", 400)`
			1. `response.version = request.version`
			1. `response.headers["Connection"] = "keep-alive" if request.keep_alive?`
			1. `context = Context.new(request, response)` - this context is already extended with Amber's extensions in [src/amber/router/context.cr](https://github.com/amberframework/amber/blob/master/src/amber/router/context.cr)
			1. `@handler.call(context)` - `Amber::Pipe::Pipeline.call()` is called
				1. `raise ...error... if context.invalid_route?` - route validity is checked early
				1. `if context.websocket?; context.process_websocket_request` - if websocket, parse as such
				1. `elsif ...; ...pipeline.first...call(context)` - if regular HTTP request, call the first handler in the appropriate pipeline
					1. `call_next(context)` - each pipe calls call_next(context) somewhere during its execution, and all pipes are executed
						1. `context.process_request` - the always-last pipe (Amber::Pipe::Controller) calls `process_request` to dispatch the action to controller. After that last pipe, the stack of call_next()s is "unwound" back to the starting position
					1. `context.finalize_response` - minor final adjustments to response are made (headers are added, and response body is printed unless action was HEAD)

# Useful Classes and Methods

This section provides an overview of various contexts where classes and modules come into play and the methods they make available:

After "[amber](https://github.com/amberframework/amber/blob/master/src/amber.cr)" is loaded, `Amber` module includes [Amber::Environment](https://github.com/amberframework/amber/blob/master/src/amber/environment.cr) which adds the following methods:

```
Amber.settings         # Singleton object, contains current settings
Amber.logger           # Alias for Amber.settings.logger
Amber.env, Amber.env=  # Environment (development, production, test)
```

[Env](https://github.com/amberframework/amber/blob/master/src/amber/environment/env.cr) provides basic methods for querying the current environment:
```crystal
[[[grep 'def ' amber/src/amber/environment/env.cr]]]
```

The list of all available application settings is in [Amber::Environment::Settings](https://github.com/amberframework/amber/blob/master/src/amber/environment/settings.cr). These settings are loaded from the application's `config/environment/<name>.yml` file and then overriden by any settings in `config/application.cr`'s "Amber::Server.configure" block.

# Parameter Validation

On each request, an appropriate Controller is instantiated to handle it. The params are kept in a number of places, going from lowest to highest level:

```
request.params     - raw params
context.params     - parsed request params
route.params       - parameters parsed from route/URL
@raw_params        - pointer to context.params
@params            - copy of parameters that passed validation
```

This will be simplified/streamlined in Amber in the future, but for now:

There are three important methods &mdash; `params.validation {...}` defines validation rules, `valid?` returns whether parameters pass validation, and `validate!` requires the parameters to be valid or raises an error.

A complete validation process in a controller looks like this (showing the whole Controller class for completeness):

```crystal
class HomeController < ApplicationController
  def index
    params.validation do
      required(:name) { |n| n.size > 6 }
      optional(:phone) { |n| n.phone? }
    end
    "Params valid: #{params.valid?.to_s}<br>
    Name is: #{params[:name]}"
  end
end
```

Please note that the extensions to the String class (such as `phone?` seen above) come especially handy for writing validations. Please search for "phone?" in this guide to find the complete list.

# Static Pages

It can be pretty much expected that a website will need a set of simple, "static" pages. Those pages are served by the application, but mostly don't use a database nor any complex code. Such pages might include About and Contact pages, Terms of Conditions, etc. Making this work is trivial.

Let's say that, for simplicity and grouping, we want all "static" pages to be served by PageController. We will group all these pages under a common web-accessible prefix of /page/, and finally we will route page requests to PageController's methods. (Because these pages won't be objects, we won't need a model or anything else other than one controller method and one view per each page.)

Let's start by creating a controller:

```shell
amber g controller page
```

Afterwards, we edit `config/routes.cr` to link URL "/about" to method about() in PageController. We do this inside the "routes :web" block:

```
routes :web do
  ...
  get "/about", PageController, :about
  ...
end
```

Then, we edit the controller and actually add method about(). This method can just directly return some string in response, or it can render a view, and then the expanded view contents will be returned as the response.

```shell
$ vi src/controllers/page_controller.cr

#: Inside the file, we add:

def about
  # "return" can be omitted here. It is included only for clarity.
  return render "about.ecr"
end
```

Since this is happening in the "page" controller, the view directory for finding the templates defaults to `src/views/page/`. We will create the directory and the file "about.ecr" in it:

```shell
$ mkdir -p src/views/page/
$ vi src/views/page/about.ecr

#: Inside the file, we add:

Hello, World!
```

Because we have called render() without additional arguments, the template will default to being rendered within the default application layout, `views/layouts/application.cr`.

And that's it! Visiting `/about` will go to the router, router will invoke `PageController::about()`, that method will render template `src/views/page/about.ecr` in the context of layout `views/layouts/application.cr`, and the result of rendering will be a full page with content `Hello, World!` in the body. That result will be returned to the controller, and from there it will be returned to the client.

# Responses

## Responses with Different Content-Type

If you want to provide a different format (or different response altogether) from the controller methods based on accepted content types, you can use `respond_with` from `Amber::Helpers::Responders`.

Our `about` method on the controller from the previous example can be modified in the following way:

```crystal
def about
  respond_with do
    html render "about.ecr"
    json name: "John", surname: "Doe"
  end
end
```

Supported format types are `html`, `json`, `xml`, and `text`. For all the available methods and arguments, please see [src/amber/controller/helpers/responders.cr](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/responders.cr).

## Error Responses

In any pipe or controller action, you might need to return an error to the user. That typically means returning an HTTP error code and a shorter error message (even though you could just as easily print complete pages into the return buffer and return an error code).

To stop a request during execution and return an error, you would do it this way:

```
if some_condition_failed
  Amber.logger.error "Error! Returning Bad Request"
  context.response.puts "Bad Request"
  context.response.status_code = 400
  return
end
```

Please note that you must use `context.response.puts` or `context.response<<` to print to the output buffer in case of errors. (You cannot set the error code and then call `return "Bad Request"` because the return value will not be added to response body if HTTP code is not 2xx.)

# Assets Pipeline

In an Amber project, raw assets are in `src/assets/`:

```shell
[[[find app/src/assets/|grep -v gitkeep|sort]]]
```

At build time, all these are processed and placed under `public/dist/`.
The JS resources are bundled to `main.bundle.js` and CSS resources are bundled to `main.bundle.css`.

[Webpack](https://webpack.js.org/) is used for asset management.

To include additional .js or .css/.scss files you would generally add `import "../../file/path";` statements to `src/assets/javascripts/main.js`. The packer being webpack, it processes import statements in .js, but not in .css/.scss files. As a result, this produces a JS bundle which has both JS and CSS data in it. Then, webpack's plugin named ExtractTextPlugin (part of default configuration) is used to extract CSS parts into their own bundle.

The base/common configuration for all this is in `config/webpack/common.js`.

## Resource Aliases

Sometimes, the code or libraries you include will in turn require libraries by generic name, e.g. "jquery". Since the files on disk are named in a different way, you would use webpack's configuration to instruct it how to resolve those paths to real locations. You would add the following to the "resolve" section in `config/webpack/common.js`:

```
...
  resolve: {
    alias: {
      jquery: path.resolve(__dirname, '../../vendor/mylibs/jquery-3.2.1.min.js'),
    }
  }
...
```

## CSS Optimization / Minification

You might want to minimize the CSS that is output to the final CSS bundle.

To do so you need an entry under "devDependencies" in the file `package.json`:

```
    "optimize-css-assets-webpack-plugin": "^1.3.0",
```

And an entry at the top of `config/webpack/common.js`:

```
const OptimizeCSSPlugin = require('optimize-css-assets-webpack-plugin');
```

And you need to run `npm install` for the plugin to be installed (saved to "node_modules/" subdirectory).

## File Copying

You might also want to copy some of the files from their original location to `public/dist/`, without doing any modifications in the process. This is done by adding the following under "devDependencies" in `package.json`:

```
    "copy-webpack-plugin": "^4.1.1",
```

The following at the top of `config/webpack/common.js`:

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

## Asset Management Alternatives

Maybe it would be useful to replace Webpack with e.g. [Parcel](https://parceljs.org/). (Finding a non-js/non-node/non-npm application for this purpose would be even better; please let me know if you know one.)

In general it seems it shouldn't be much more complex than replacing the command to run and development dependencies in project's `package.json` file.

# Micrate Database Commands

Amber relies on the shard "[micrate](https://github.com/amberframework/micrate)" to perform migrations. The command `amber db` uses "micrate" unconditionally. However, some of all the possible database operations are only available through `amber db` and some are only available through invoking `micrate` directly. Therefore, it is best to prepare the application for using both `amber db` and `micrate`.

Micrate is primarily a library so a small piece of custom code is required to provide a minimal `micrate` executable for a project. This is done by placing the following in `src/micrate.cr` (the example is for PostgreSQL but can trivially be adapted to MySQL or SQLite):

```crystal
#!/usr/bin/env crystal
require "amber"
require "micrate"
require "pg"

Micrate::DB.connection_url = Amber.settings.database_url
Micrate::Cli.run
```

And the following in `shard.yml` under `targets`:

```
targets:
  micrate:
    main: src/micrate.cr
```

From there, running `crystal deps build micrate` will build `bin/micrate` which you can use as an executable to access micrate's functionality directly. Please note that this sets up `bin/micrate` and `amber db` in a compatible way so these commands can be used interchangeably. Run `bin/micrate -h` to see an overview of micrate's own commands.

The setup with a standalone `bin/micrate` command should also be used if you want your migrations to run with different credentials or a different database URL than your regular Amber application.

In that case, `src/micrate.cr` could look like the following:

```crystal
#!/usr/bin/env crystal
require "amber"
require "micrate"
require "pg"

env_name = ENV["AMBER_ENV"]? || "development"
suffix = if env_name == "production"; "" else "_#{env_name}" end
Micrate::DB.connection_url = "postgres://USERNAME:PASSWORD@localhost:5432/DBNAME#{suffix}"
Micrate::Cli.run
```

Please also note that in that case you would probably use a combination of direct database commands and `bin/micrate`, and avoid using `amber db` because `amber db` would run with Amber's (application's) regular credentials which you do not want.

(The professional implementation here would probably consist of creating a separate environment named e.g. "admin" and defining specific database credentials for it in `config/environments/admin.yml`. Then, after setting environment variable `AMBER_ENV=admin`, both `amber db` and `bin/micrate` could again be used interchangeably in the expected "admin mode".)

# Shards

Amber and all of its components depend on the following shards:

[[[cat shards.txt]]]

Only the parts that are used end up in the compiled project.

Now let's take a tour of all the important classes that exist in the Amber application and are useful for understanding the flow.

# Extensions

Amber adds some very convenient extensions to existing String and Number classes. The extensions are in the [extensions/](https://github.com/amberframework/amber/tree/master/src/amber/extensions) directory, but here's a listing of the current ones:

For String:

```crystal
[[[grep 'def ' amber/src/amber/extensions/string.cr]]]
```

For Number:

```crystal
[[[grep 'def ' amber/src/amber/extensions/number.cr]]]
```

# Support Routines

In [support/](https://github.com/amberframework/amber/tree/master/src/amber/support) directory there is a number of various support files that provide additional, ready made routines.

Currently, the following can be found there:

```
client_reload.cr      - Support for reloading developer's browser

file_encryptor.cr     - Support for storing/reading encrypted versions of files
message_encryptor.cr
message_verifier.cr

locale_formats.cr     - Very basic locate data for various, manually-added locales

mime_types.cr         - List of MIME types and helper methods for working with them:
                        def self.mime_type(format, fallback = DEFAULT_MIME_TYPE)
                        def self.zip_types(path)
                        def self.format(accepts)
                        def self.default
                        def self.get_request_format(request)
```

# Amber::Controller::Base

This is the base controller from which all other controllers inherit. Source file is in [src/amber/controller/base.cr](https://github.com/amberframework/amber/blob/master/src/amber/controller/base.cr).

On every request, the appropriate controller is instantiated and its initialize() runs. Since this is the base controller, this code runs on every request so you can understand what is available in the context of every controller.

The content of this controller and the methods it gets from including other modules are intuitive enough to be copied here and commented where necessary:

```crystal
[[[cat amber/src/amber/controller/base.cr]]]
```

[Helpers::CSRF](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/csrf.cr) provides these methods:

```crystal
    def csrf_token
    def csrf_tag
    def csrf_metatag
```

[Helpers::Redirect](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/redirect.cr) provides:

```crystal
    def redirect_to(location : String, **args)
    def redirect_to(action : Symbol, **args)
    def redirect_to(controller : Symbol | Class, action : Symbol, **args)
    def redirect_back(**args)
```

[Helpers::Render](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/render.cr) provides:

```crystal
    LAYOUT = "application.slang"
    macro render(template = nil, layout = true, partial = nil, path = "src/views", folder = __FILE__)
```

[Helpers::Responders](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/responders.cr) helps control what final status code, body, and content-type will be returned to the client.

[Helpers::Route](https://github.com/amberframework/amber/blob/master/src/amber/controller/helpers/route.cr) provides:

```crystal
    def action_name
    def route_resource
    def route_scope
    def controller_name
```

[Callbacks](https://github.com/amberframework/amber/blob/master/src/amber/dsl/callbacks.cr) provide:

```crystal
    macro before_action
    macro after_action
```

# Amber behind a Load Balancer | Reverse Proxy | ADC

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

The compilation will go trouble-free and you will end up with the binary `haproxy` in the current directory.

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

And we can modify one of the views to display the user IP address. Assuming you are using slang, you could edit the default view file `src/views/home/index.slang` and add the following to the bottom:

```
    a.list-group-item.list-group-item-action href="#" = "IP Address: " + ((ip = context.client_ip) ? ip.address : "Unknown")
```

# Ecommerce with Amber

I am working on [Jet](https://github.com/jetcommerce/jet), an ecommerce solution for Amber.

# Conclusion

We hope you have enjoyed this hands-on introduction to Amber!

Feel free to provide any feedback on content or additional areas you
would like to see covered in this guide. Thanks!
