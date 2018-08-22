# RBCli

RBCli is currently in Alpha stages of development. All releases can be considered stable, though breaking changes may be made between versions.

Latest Release: v0.2.2 (Aug 22, 2018) -- See the [changelog][changelog] for complete details.

* Lazy loading for improved startup time
* Hooks are now defined under `Rbcli.Configurate.hooks`.
* Logger is disabled by default, cleaning up output
* Code refactor and cleanup
* Many more improvements

Previous Release: v0.2.1 (Aug 8, 2018)

* Remote Execution Feature Added

[You can find the Official Documentation for RBCli Here.][documentation_home]

[If you want to support RBCli's development, please donate and help keep it going!][documentation_whoami]

## Introduction

As technologists today, we work with the command line a lot. We script a lot. We write tools to share with each other to make our lives easier. We even write applications to make up for missing features in the 3rd party software that we buy. Unfortunately, when writing CLI tools, this process has typically been very painful. We've been working with low-level frameworks for decades; frameworks like `getopt` (1980) and `curses` (1977). They fit their purpose well; they were both computationally lightweight for the computers of the day, and they gave engineers full control and flexibility when it came to how things were built. Over the years, we've used them to settle on several design patterns that we know work well. Patterns as to what a CLI command looks like, what a config file looks like, what remote execution looks like, and even how to use locks (mutexes, semaphores, etc) to control application flow and data atomicity. Yet we're stuck writing the same low-level code anytime we want to write our tooling. Not anymore.

Enter RBCli. RBCli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible. In RBCli, low-level code has been wrapped and/or replaced with higher-level methods. Much of the functionality has even been reduced to single methods: for example, it takes just one declaration to define, load, and generate a user's config file at the appropriate times. Many other features are automated and require no work by the engineer. These make RBCli a fundamental re-thining of how we develop CLI tools, enabling the rapid development of applications for everyone from hobbyists to enterprises.


Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, RBCli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.
  
* __Lazy Loading__: Even though RBCli is a heavyweight tool, it uses lazy loading to speed up application startup time. This means you don't have to worry about a large framework slowing your application down.

* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily piece together a default configuration even with declarations in different parts of the code. Then the user can generate their own configuration, and it gets stored in whatever location you'd like.

* __Multiple Hooks and Entry Points__: Define commands, pre-execution hooks, post-execution hooks, and first_run hooks to quickly and easily customize the flow of your application code.

* __Logging__: Keep track of all instances of your tool through logging. Logs can go to STDOUT, STDERR, or a given file, making them compatible with log aggregators such as Splunk, Logstash, and many others.

* __Local State Storage__: Easily manage a set of data that persists between runs. You get access to a hash that is automatically kept in-sync with a file on disk.

* __Remote State__: It works just like Local State Storage, but store the data on a remote server! It can be used in tandem with Local State Storage or on its own. Currently supports AWS DyanmoDB.  

* __State Locking and Sharing__: Share remote state safely between users with built-in locking! When enabled, it makes sure that only one user is accessing the data at any given time.

* __Automatic Update Notifications__: Just provide the gem name or git repo, and RBCli will take care of notifying users!

* __External Script Wrapping__: High-level wrapping for Bash scripts, or any other applcication you'd like to wrap into a command.

* __Project Structure and Generators__: Create a well-defined project directory structure which organizes your code and allows you to package and distribute your application as a Gem. Generators can also help speed up the process of creating new commands, scripts, and hooks!

* __Remote Execution__: Automatically execute commands on remote machines via SSH


For more information, take a look at the __[official documentation][documentation_home]__ or keep reading for a quick reference.


# Quick Reference

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


[documentation_home]: https://akhoury6.github.com/rbcli
[documentation_development]: https://akhoury6.github.com/rbcli/development/contributing/
[documentation_whoami]: https://akhoury6.github.io/rbcli/whoami/
[license_text]: https://github.com/akhoury6/rbcli/blob/master/LICENSE.txt
[changelog]: https://github.com/akhoury6/rbcli/blob/master/CHANGELOG.md
