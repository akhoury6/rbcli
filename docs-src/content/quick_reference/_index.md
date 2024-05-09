+++
title = "Quick Reference"
date = 2024-05-04T21:03:31-00:00
weight = 1
chapter = false
draft = false
+++

## Installation

Rbcli is available on rubygems.org. You can add it to your application's `Gemfile` or `gemspec`:

```ruby
spec.add_dependency 'rbcli', '~> {{% rbcli_version_minor %}}'
```

Or install it manually by running:

```bash
gem install rbcli
```

## Starting a Project

Rbcli includes a tool to quickly create either a gem or a portable executable. Creating either is simple.

```bash
rbcli gem mytool
```

```bash
rbcli portable mytool
rbcli portable -a mytool # Adds annotations
```

Or you can DIY

```ruby
#!/usr/bin/env ruby
require 'rbcli'

Rbcli::Configurate.cli do
  appname 'mytool'
  version '0.1.0'
  helptext "Something to tell your users about your application in --help"
  opt :verbose, 'Verbose output'
end

Rbcli.command "mycmd" do
  default
  action do |opts, _params, _args, _config, _env|
    Rbcli.log.info "Verbose!" if opts[:verbose]
    Rbcli.log.info "Hello, world!"
  end
end

Rbcli.go!
```

```shell
$ mytool -v
Verbose!
Hello, world!
```

## Creating a command

There are two types of commands in Rbcli:

* __Standard__ commands let you code the command directly in Ruby
* __Scripted__ commands provide you with a bash script, where all of the parsed information (params, options, args, config, and env) is shared

### Standard Commands

For gem-based projects, you can use the `rbcli` helper tool from within the project directory to create new command in the `lib/commands/` directory.

```bash
rbcli command mycmd
```

For portable executables, copy-paste this and edit as needed:

```ruby
Rbcli.command "mycmd" do
  #default  # The default command runs when no others are called 
  description 'Example command'
  usage "[--param|--otherparam] name"
  helptext "Text to show in --help"
  # Fields: name, description, (short, type, default, required, multi, permitted, prompt)
  parameter :myparam, 'Another Parameter', type: :string, default: "Default value", short: 'p'
  action do |opts, params, args, config, env|
    Rbcli.log.info "Top-level CLI Options: " + opts.to_s
    Rbcli.log.info "Parameters:            " + params.to_s
    Rbcli.log.info "Arguments on the CLI:  " + args.to_s
    Rbcli.log.info "The config:            " + config.to_s
    Rbcli.log.info "Environment variables: " + env.to_s
  end
end
```

This will let you run it by calling:

```bash
mytool mycmd (--myparam|-p)
```

### Scripted Commands

To create a new scripted command for a gem project, run:

```bash
rbcli command -s mycmd
```

You will then find two new files:

* The command declaration under `lib/commands/`
* The script code under `lib/commands/scripts/`

For portable executables, just use the command block above but replace the `action` block with either `inline_script` or `external_script`:

```ruby
Rbcli.command "mycmd" do
  description "example script command"
  # external_script vars: {}, path: "./test.sh"
  inline_script vars: { foo: 'bar!!!' }, inline: <<~INLINE 
    log "Top-level CLI Options: $(rbcli opts .)"
    log "Parameters: $(rbcli params .)"
    log "Arguments on the CLI: $(rbcli args .)"
    log "Config: $(rbcli config .)"
    log "Environment Variables: $(rbcli env .)"
    log "Custom Var from command: $(rbcli vars .foo)"
    log "Same variable, in environment: ${FOO}"
    log "Log levels can also be set", "warn"
  INLINE
```

Note that Rbcli will automatically inject a helper script into your script to allow the above integration. The `rbcli` shortcut in the script is a wrapper around [jq][jq] (which you must have istalled), and all of it's syntax applies.

## Top-Level Config

### Application Information

Declare some basic information about your application. This information is used by Rbcli for certain features, including generating `--help` documentation for your application, and for perofming autoupdate checks.

This is also where `opt` declarations go, for parsing options the command line.

```ruby
Rbcli::Configurate.cli do
  appname File.basename($0)
  author `Your Name`      # Can also be an %w(array of names)
  email your@email.com
  version Tester::VERSION
  copyright_year {{% current_year %}}
  license 'None'
  helptext "This text shows up in `#{File.basename($0)} --help`"
  opt :verbose, "Twice or more enables very-verbose output", multi: true
end
```

### CLI Options

```ruby
Rbcli::Configurate.cli do
  opt :myopttion, 'Description', long: 'myoption', short: 'm',
      type: :string, required: false, multi: false, permitted: nil
end
```

* __long__: The `--long-form` on the command line (Default: name)
* __short__: The `-s`hort form on the command line (Default: first letter of name)
* __type__: `:boolean`, `:float`, `:integer`, `:string`, `:io`, `:date` (Default: :boolean)
  * Can also be plural to accept a comma-deliminated list
* __required__: Stop execution if not provided (Default: false)
* __multi__: Opt can be provided multiple times on the command line, such as `-vvv`
  * If used with a `:boolean` type, it will count how many times the opt was provided
* __permitted__: Array of allowed values

#### Usage

```ruby
Rbcli.command "mycmd" do
  action do |opts, _params, _args, _config, _env|
    Rbcli.log.info "Top-level CLI Options: " + opts.to_s
  end
end
```

## Logger

### Configuration

```ruby
Rbcli::Configurate.logger do
  logger target: :stdout, level: :info, format: :display
  format :foo, Proc.new { |severity, datetime, progname, msg| "Foo! " + msg }
end
```

* Valid targets are: `:stdout`, `:stderr`, `/path/to/a/file`, or an `IO` or `StringIO` object
  * Default: :stdout
* Valid levels are: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown`, `:any`
  * Default: :info
* Valid formats are: `:display`, `:simple`, `:full`, `:ruby`, `:json`, `:apache`, `:lolcat`
  * Default: :display
  * Note: The `display` format is intended for on-screen use by end users, and don't appear as typical logs.

If a custom format is provided (like above) it will be the one selected.

### Usage

```ruby
# Rbcli.log.level "message", "module" -- The module is optional
Rbcli.log.debug "Example Debug Message (change your log level to see this!)", "MSGS"
Rbcli.log.info "Example Info Message", "MSGS"
Rbcli.log.warn "Example Warning Message", "MSGS"
Rbcli.log.error "Example Error Message", "MSGS"
Rbcli.log.fatal "Example Fatal Message", "MSGS"
Rbcli.log.unknown "Example Unknown Message", "MSGS"
Rbcli.log.target STDERR #
Rbcli.log.format :json  # Change settings mid-execution
Rbcli.log.level :debug  #
```

## Config Files

### Configuration

```ruby
Rbcli::Configurate.config do
  ##### Config (Optional) #####
  # The built-in config will automatically pull in a config file to a hash and vice versa
  # It can either be used immutably (as user-defined configuration) and/or to store application state
  #
  #   file:                 <string> or <array>            (Required) Provide either a specific config file location or a hierarchy to search. If creating a :null type of config this can be omitted.
  #   type:                 (:yaml|:json|:ini|:toml|:null) (Optional) Select which backend/file format to use. If the file has an associated extension (i.e. '.yaml') then this can be omitted.
  #   schema_location:      <string>                       (Optional) The file location of a JSON Schema (https://json-schema.org). If provided, the config will automatically be validated. (default: nil)
  #   save_on_exit:         (true|false)                   (Optional) Save changes to the config file on exit (default: false)
  #   create_if_not_exists: (true|false)                   (Optional) Create the file using default values if it is not found on the system (default: false)
  #   suppress_errors:      (true|false)                   (Optional) If set to false, the application will halt on any errors in loading the config. If set to true, defaults will be provided (default: true)
  #   banner:               <string>                       (Optional) Define a banner to be placed at the top of the config file on disk. Note that it will only be written to backends that support comments
  #   defaults:             <hash>                         (Optional) Defaults set here will be provided to your application if any values are missing in the config.
  #                                                                  They will also be used to create new config files when the flag `create_if_not_exists` is set to true.
  file ['./tester.yaml', '~/.tester.yaml', '/etc/tester.yaml']
  type :yaml
  schema_location nil
  save_on_exit
  create_if_not_exists false
  suppress_errors true
  banner <<~BANNER
    This text appears at the top of the config file when using a backend that supports comments.
    Tell the user a bit about what they're doing here.
  BANNER
  defaults({ setting_one: true, setting_two: false })
end
```

### Usage

```ruby
Rbcli.command "mycmd" do
  action do |_opts, _params, _args, config, _env|
    Rbcli.log.info "Config: " + config.to_s
  end
end
```

## Environment Variable Parsing

### Configuration

```ruby
Rbcli::Configurate.envvars do
  ##### Environment Variable Parsing (Optional) #####
  # The envvars module can pull in all environment variables with a given
  # prefix and organize them into a hash structure based on name.
  # It will also parse the string values and convert them to the proper type (Integer, Boolean, etc)
  # Any values set here will be treated as defaults and made available when a variable is missing
  #
  # For example, these two environment variables:
  #   TESTER_TERM_HEIGHT=40
  #   TESTER_TERM_WIDTH=120
  # Would be declared here as:
  #   prefix 'TESTER'
  #   envvar 'TERM_HEIGHT', 40
  #   envvar 'TERM_WIDTH', 120
  # And get loaded into the env hash as:
  #   { term: { height: 40, width: 120 } }
  #
  # If the prefix is unset or equal to nil, the environment variables specified here will
  # be loaded without one.
  prefix 'TESTER'
  envvar 'DEVELOPMENT', false
end
```

### Usage

```ruby
Rbcli.command "mycmd" do
  action do |_opts, _params, _args, _config, env|
    Rbcli.log.info "Environment Variables: " + env.to_s
  end
end
```

## Hooks

```ruby
Rbcli::Configurate.hooks do
  ##### Hooks (Optional) #####
  # These hooks are scheduled on the Rbcli execution engine to run
  # Pre- and Post- the command specified. They are executed after
  # everything else has been initialized, so the runtime configuration
  # values are all made available, as they will appear to the command.
  #
  # These are good for parsing and/or applying transformations on the
  # configuration before passing them to the command, and for cleaning
  # up your environment afterwards.
  pre_execute do |opts, params, args, config, env|
    Rbcli.log.info "I'm about to run a command..."
  end

  post_execute do |opts, params, args, config, env|
    Rbcli.log.info "I'm done running the command!"
  end
end
```

## Update Checker

```ruby
Rbcli::Configurate.updatechecker do
  ##### Update Check (Optional) #####
  # The application can warn users when a new version is released
  # Checks can be done either by rubygems or by a Github repo
  # Private servers for Github (enterprise) are supported
  #
  # Setting force_update to true will halt execution until it is updated
  #
  # For Github, an access_token is required for private repos. See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
  gem 'tester', force_update: false, message: 'Please run `gem update tester` to upgrade to the latest version.'
  github 'repo/name', access_token: nil, enterprise_hostname: nil, force_update: false, message: 'Please download the latest version from Github'
end
```


## Development and Contributing

For more information about development and contributing, please see the [Official Development Documentation][documentation_development]

## License

The gem is available as open source under the terms of the [MIT][license_text] license.

## Full Documentation

[You can find the Official Documentation for Rbcli Here.][documentation_home]


[documentation_home]: {{% ref "/index" %}}
[documentation_development]: {{% ref "/development" %}}
[license_text]: {{% ref "/development/license" %}}
[jq]: https://jqlang.github.io/jq/