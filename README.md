# Rbcli

Rbcli is currently in the late Beta stages of development. The current release can be considered stable, and the interface has been ironed out and finalized, so if there are any breaking changes between here and v1.0 they should be minor. It is currently being used in production.

Latest Release: [![Gem Version](https://badge.fury.io/rb/rbcli.svg)](https://badge.fury.io/rb/rbcli) -- See the [changelog][changelog] for complete details.

[You can find the Official Documentation for Rbcli Here.][documentation_home]

[If you want to support Rbcli's development, please donate and help keep it going!][documentation_whoami]

## About Rbcli

Rbcli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible. In Rbcli, low-level code has been wrapped and/or replaced with higher-level methods. Much of the functionality has even been reduced to single methods: for example, it takes just one declaration to define, load, and generate a user's config file at the appropriate times. Many other features are automated and require no work by the engineer. These make Rbcli a fundamental re-thining of how we develop CLI tools, enabling the rapid development of applications for everyone from hobbyists to enterprises.

Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, Rbcli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.

* __Portable Executable__: Jump-start using Rbcli by creating a simple portable executable! Just fill in the blanks and you're good to go.

* __Full Gem Structure__: Alternatively, Rbcli can piggyback off of `bundler` to create a full Gem project structure with custom folders to make using the framework easier. This makes using Rbcli to create larger applications a breeze.

* __Lazy Loading__: Even though Rbcli is a heavyweight tool, it uses lazy loading with its optional features to speed up application startup time. This means you don't have to worry about a large framework slowing your application down, no matter how big it gets.

* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily define a configuration file in code, complete with annotations, and have it automatically generated for your users in the format of your choice (yaml, toml, json, or ini).

* __Config File Validation__: Apply a [schema](https://json-schema.org) to validate the format of the config file when it is loaded, no matter which file format you choose.

* __Environment Variable Parsing__: Simply define a prefix and all of the environment variables with that prefix will be parsed into their respective types and put into a Hash for convenient, along with any optional defaults you'd like to set

* __Shell Script Integration__: Integrate with shell scripts to pass along everything from command-line options to parsed config values, and even to allow the script to output logs through Rbcli directly

* __Multiple Hooks and Entry Points__: Define pre- and post- execution hooks to quickly and easily customize the flow of your application code. Parse all of the config, options, and environment variables before they reach your commands, or clean up your environment afterwards.

* __Logging__: Logs can go to your standard output, a file, or any custom stream of your choice, and can even be redirected or reformatted mid-execution. In additional, Multiple common log formats have been pre-defined to make it easy to get started, and you can even define custom ones.

* __Automatic Update Checks__: Just provide the gem name or git repo, and Rbcli will take care of notifying users when you have an update ready for them

For more information, take a look at the __[official documentation][documentation_home]__ or keep reading for a quick reference.

# Getting Started

## Installation

Rbcli is available on rubygems.org. You can add it to your application's `Gemfile` or `gemspec`:

```ruby
spec.add_dependency 'rbcli', '~> 0.4'
```

Or install it manually by running:

```bash
gem install rbcli
```

## Quick Start

### Rbcli generators (the easy way)

Simply `cd` to the folder you'd like to create your project under and run:

```bash
rbcli gem mytool
```

Or, if you'd just like a single-file executable, run:

```bash
rbcli portable mytool
rbcli portable -a mytool # Adds annotations
```

### Write it yourself (the hard way)

The generators are generally the easiest way to get up and running, but here's an example of a simple application.

```ruby
#!/usr/bin/env ruby
require 'rbcli'

Rbcli::Configurate.cli do
  appname 'mytool'
  version '0.1.0'
  helptext <<~HELPTEXT
    Something to tell your users about your application in --help
  HELPTEXT
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

## Full Documentation

[You can find the Official Documentation for Rbcli here.][documentation_home]

## Development and Contributing

For more information about development and contributing, please see the [Official Contribution Guide][documentation_development]

## License

The gem is available as open source under the terms of the [MIT License][license_text].

[documentation_home]: https://akhoury6.github.io/rbcli
[documentation_quickref]: https://akhoury6.github.io/rbcli/quick_reference
[documentation_development]: https://akhoury6.github.io/rbcli/development/contributing/
[documentation_whoami]: https://akhoury6.github.io/rbcli/whoami/
[license_text]: https://github.com/akhoury6/rbcli/blob/master/LICENSE.txt
[changelog]: https://github.com/akhoury6/rbcli/blob/master/CHANGELOG.md