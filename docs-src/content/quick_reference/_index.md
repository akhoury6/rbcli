+++
title = "Quick Reference"
date = 2019-06-20T15:49:49-04:00
weight = 1
chapter = false
draft = false
+++


## Installation

RBCli is available on rubygems.org. You can add it to your application's `Gemfile` or `gemspec`, or install it manually by running:

```bash
gem install rbcli
```

Then, `cd` to the folder you'd like to create your project under and run:

```bash
rbcli init -n mytool -d "A simple CLI tool"
```

Or, for a single-file tool without any folder/gem tructure, run `rbcli init -t mini -n <projectname>` or `rbcli init -t micro -n <projectname>`.


## Creating a command

There are three types of commands: standard, scripted, and external.

* __Standard__ commands let you code the command directly in Ruby
* __Scripted__ commands provide you with a bash script, where all of the parsed information (params, options, args, and config) is shared
* __External__ commands let you wrap 3rd party applications directly

### Standard Commands

To create a new command called `foo`, run:

```bash
rbcli command -n foo
```

You will now find the command code in `application/commands/list.rb`. Edit the `action` block to write your coode.

### Scripted Commands

To create a new scripted command called `bar`, run:

```bash
rbcli script -n bar
```

You will then find two new files:

* The command declaration under `application/commands/bar.rb`
* The script code under `application/commands/scripts/bar.sh`

Edit the script to write your code.

### External Commands

To create a new external command called `baz`, run:

```bash
rbcli extern -n baz
```

You will then find the command code in `application/commands/baz.rb`.

Use one of the two provided modes -- direct path mode or variable path mode -- to provide the path to the external program.


## Hooks

RBCli has several hooks that run at different points in the exectution chain. They can be created via the `rbcli` command line tool:

```bash
rbcli hook --default      # Runs when no command is provided
rbcli hook --pre          # Runs before any command
rbcli hook --post         # Runs after any command
rbcli hook --firstrun     # Runs the first time a user runs your application. Requires userspace config.
rbcli hook -dpof          # Create all hooks at once
```

## Storage

RBCli supports both local and remote state storage. This is done by synchronizing a Hash with either the local disk or a remote database.

### Local State

RBCli can provide you with a unique hash that can be persisted to disk on any change to a top-level value.

Enable local state in `config/storage.rb`.

Then access it in your Standard Commands with `Rbcli.local_state[:yourkeyhere]`.

### Remote State

Similar to the Local State above, RBCli can provide you with a unique hash that can be persisted to a remote storage location.

Currently only AWS DynamoDB is supported, and credentials will be required for each user.

Enable remote state in `config/storage.rb`.

Then access it in your Standard Commands with `Rbcli.remote_state[:yourkeyhere]`.


## Userspace Configuration Files

RBCli provides an easy mechanism to generate and read configuration files from your users. You set the default values and help text with the __defaults chain__, and leverage the __user chain__ to read them.

You can set defaults either by placing a YAML file in the `userconf/` folder or by specifying individual options in `application/options.rb` (global) or `application/command/*.rb` (command-specific).

Users can generate a config file, complete with help text, by running your tool with the `--generate-config` option.


## Logging

RBCli's logger is configured in `config/logging.rb`.

```ruby
log_level :info
log_target 'stderr'
```

Then it can be accessed when writing your commands via:

```ruby
Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }
```

The user will also be able to change the log level and target via their config file, if it is enabled.


## Automatic Update Check

RBCli can automatically notify users when an update is available. Two sources are currently supported: Github (including Enterprise) and RubyGems.

You can configure automatic updates in `config/autoupdate.rb` in your project.


## Remote Execution

RBCli can automatically execute script and extern commands on remote machines via SSH. Enable this feature in `config/general.rb` by changing the following line to `true`:

```ruby
remote_execution permitted: false
```

Then for each command you want to enable remote execution for, add the following directive:

```ruby
remote_permitted
```

Users can then execute commands remotly by specifying the connection string and credentials on the command line:

```bash
mytool --remote-exec [user@]host[:port] --identity (/path/to/private/ssh/key or password) <command> ...
```


## Development and Contributing

For more information about development and contributing, please see the [Official Development Documentation][documentation_development]

## License

The gem is available as open source under the terms of the [GPLv3][license_text].

## Full Documentation

[You can find the Official Documentation for RBCli Here.][documentation_home]


[documentation_home]: https://akhoury6.github.io/rbcli
[documentation_development]: https://akhoury6.github.io/rbcli/development/contributing/
[documentation_whoami]: https://akhoury6.github.io/rbcli/whoami/
[license_text]: https://github.com/akhoury6/rbcli/blob/master/LICENSE.txt
[changelog]: https://github.com/akhoury6/rbcli/blob/master/CHANGELOG.md
