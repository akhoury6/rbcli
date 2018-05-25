# RBCli

RBCli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible.

Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, RBCli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.
  
* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily piece together a default configuration even with declarations in different parts of the code. Then the user can generate their own configuration, and it gets stored in whatever location you'd like.

* __Logging__: Keep track of all instances of your tool through logging. Logs can go to STDOUT, STDERR, or a given file, making them compatible with log aggregators such as Splunk, Logstash, and many others.


## Installation

RBCli is available on rubygems.org. You can add it to your application's `Gemrile` or `gemspec`, or install it manually via `gem install rbcli`.

## The Basics

RBCli enforces a general command-line structure:

```
toolname [options] command [parameters] [lineitem]
```

* __Options__ are command line parameters such as `-f`, or `--force`. These are available globally to every command. You can create your own, but several options are already built-in:
	* `-c <filename> / --config-file=<filename>` allows specifying a config file manually
	* `-g / --generate-config` generates a config file by writing out the defaults to a YAML file (location is configurable, more on that below)
	* `-v / --version` shows the version`
	* `-h / --help` shows the help
* __Command__ represents the subcommands that you will create, such as `test` or `apply`
* __Parameters__ are the same as options, but only apply to the specific subcommand being executed. In this case only the `-h / --help` parameter is provided.
* __Lineitems__ are strings that don't begin with a '-', and are passed to the command's code. These can be used as subcommands or additional parameters for your code. 

So a valid command could look something like these:

```shell
mytool -n load --filename=foo.txt
mytool parse foo.txt
mytool show -l
```

Note that all options and parameters will have both a short and long version of the parameter available for use.

## Getting Started

Creating a new skeleton command is as easy as running `rbcli init <filename>`. It will have three key items:

* The configuration
* A command declaration
* The parse command


### Configuration

```ruby
require 'rbcli'

Rbcli::configurate do
	scriptname __FILE__.split('/')[-1]                                     # (Required) This line identifies the tool's executable. You can change it if needed, but this should work for most cases.
	version '0.1.0'                                                        # (Required) The version number
	description 'This is my test CLI tool.'                                # (Requierd) A description that will appear when the user looks at the help with -h. This can be as long as needed.
	
	log_level :info                                                        # (Optional) Set the default log_level for users. 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  log_target 'stderr'                                                    # (Optional) Set the target for logs. Valid values are STDOUT, STDERR, or a file path (as strings)

	config_userfile '/etc/mytool/config.yml', merge_defaults: true, required: false  # (Optional) Set location of user's config file. If merge_defaults=true, user settings override default settings, and if false, defaults are not loaded at all. If required=true, application will not run if file does not exist.
	config_defaults 'defaults.yml'                                         # (Optional, Multiple) Load a YAML file as part of the default config. This can be called multiple times, and the YAML files will be merged. User config is generated from these
	config_default :myopt, description: 'Testing this', value: true        # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config

	option :name, 'Give me your name', type: :string, default: 'Stranger', required: false  # (Optional, Multiple) Add a global CLI parameter. Supported types are :string, :boolean, :integer, :float, :date, and :io. Can be called multiple times.

	default_action do |opts|                                               # (Optional) The default code to execute when no subcommand is given. If not present, the help is shown (same as -h)
		puts "Hello, #{opts[:name]}."
		puts "To see the help, use -h"
	end

	pre_hook do |opts|                                                     # (Optional) Allows providing a block of code that runs before any command
		puts 'This is a pre-command hook. It executes before the command.'
	end

	post_hook do |opts|                                                    # (Optional) Allows providing a block of code that runs after any command
		puts 'This is a post-command hook. It executes after the command.'
	end
end
```

#### CLI Option Declarations

For the `option` parameters that you want to create, the following types are supported:

* :string
* :boolean or :flag
* :integer
* :float

If a default value is not set, it will default to `nil`.

If you want to declare more than one option, you can call it multiple times. The same goes for other items tagged with _Multiple_ in the description above.

Once parsed, options will be placed in a hash where they can be accessed via their names as shown above. You can see this demonstrated in the `default_action`, `pre_hook`, and `post_hook` blocks.


### Command Declaration

Commands are added by subclassing `Rbcli::Command`. There are a few parameters to set for it, which get used by the different components of Rbcli.

```ruby
class Test < Rbcli::Command                                                          # Declare a new command by subclassing Rbcli::Command
	description 'This is a short description.'                                         # (Required) Short description for the global help
	usage 'This is some really long usage text description!'                           # (Required) Long description for the command-specific help
	parameter :force, 'Force testing', type: :boolean, default: false, required: false # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

	config_defaults 'defaults.yml'                                                     # (Optional, Multiple) Load a YAML file as part of the default config. This can be called multiple times, and the YAML files will be merged. User config is generated from these
	config_default :myopt2, description: 'Testing this again', value: true             # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config

	action do |params, args, global_opts, config|                                      # (Required) Block to execute if the command is called.
		Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }               # Example log. Interface is identical to Ruby's logger
		puts "\nArgs:\n#{args}"                # Arguments that came after the command on the CLI
		puts "Params:\n#{params}"              # Parameters, as described through the option statements above
		puts "Global opts:\n#{global_opts}"    # Global Parameters, as descirbed in the Configurate section
		puts "Config:\n#{config}"              # Config file values
		puts "\nDone!!!"
	end
end

```

### Parse Command

```ruby
Rbcli.parse       # Parse CLI and execute
```

## Execution Chain

RBCli takes actions in a specific order when `parse` is run.

1. The default config is loaded
2. The user config is loaded if present
3. CLI is parsed for global options, which are then stored in a hash and passed on to the other parts of the code. Built-in options, however, may cause the code to branch and exit.
4. The CLI is parsed for a command.
	a. If no command is entered, RBCLI will check if a `default_acction` block has been provided.
		i. If the block is defined, execute it
		ii. Otherwise, show the help
	b. If a command has been entered, the rest of the CLI is parsed for parameters and lineitems, and the code block for the command is called

## Configuration Files

RBCli has two chains to manage configuration: the __defaults chain__ and the __user chain__.

### Defaults chain

The defaults chain allows you to specify sane defaults for your CLI tool throughout your code. This gives you the ability to declare configuration alongside the code, and allows RBCli to generate a user config automatically given your defaults. There are two ways to set them:

* YAML Files
	* You can store your defaults in one or more YAML files and RBCli will import and combine them. Note that when generating the user config, RBCli will use the YAML text as-is, so comments are transferred as well. This allows you to write descriptions for the options directly in the file that the user can see.
	* This is good for tools with large or complex configuration that needs user documentation written inline
	* `config_defaults "<filename>"` in the DSL
* DSL Statements
	* In the DSL, you can specify options individually by providing a name, description, and default value
	* This is good for simpler configuration, as the descriptions provided are written out as comments in the generated user config
	* `config_default :name, description: '<description_text>', value: <default_value>` in the DSL
	
Users can generate configs by running `yourclitool -g`. This will generate a config file at the tool's default location specified in the DSL. A specific location can be used via the `-c` parameter. You can test how this works by running `examples/mytool -c test.yml -g`.
 
### User chain

The user chain has two functions: generating and loading configuration from a YAML file.

Rbcli will determine the correct location to locate the user configuration based on two factors:

1. The default location set in the configurate DSL
	a. `config_userfile '/etc/mytool/config.yml', merge_defaults: true, required: false  # (Optional) Set location of user's config file. If merge_defaults=true, user settings override default settings, and if false, defaults are not loaded at all. If required=true, application will not run if file does not exist.`
2. The location specified on the command line using the `-c <filename>` option
	b. `yourclitool -c localfile.yml`

Users can generate configs by running `yourclitool -g`. This will generate a config file at the tool's default location specified in the DSL. A specific location can be used via the `-c` parameter. You can test how this works by running `examples/mytool -c test.yml -g`.

## Logging

Logging with RBCli is straightforward - it looks at the config file for logging settings, and instantiates a single, globally accessible [Logger](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html)` object. You can access it as such:

```ruby
Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }
```

Default values can be set in the configurate DSL:

```ruby
log_level :info                                                        # (Optional) Set the default log_level for users. 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
log_target 'stderr'                                                    # (Optional) Set the target for logs. Valid values are STDOUT, STDERR, or a file path (as strings)
```

Two configuration options will always be placed in a user's YAML file to override defaults: 

```yaml
# Log Settings
logger:
  log_level: warn              # 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  log_target: stderr           # STDOUT, STDERR, or a file path
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine from source, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akhoury6/rbcli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rbcli project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/akhoury6/rbcli/blob/master/CODE_OF_CONDUCT.md).
