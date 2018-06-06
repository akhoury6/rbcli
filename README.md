# RBCli

RBCli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible.

Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, RBCli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.
  
* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily piece together a default configuration even with declarations in different parts of the code. Then the user can generate their own configuration, and it gets stored in whatever location you'd like.

* __Multiple Hooks and Entry Points__: Define commands, pre-execution hooks, post-execution hooks, and first_run hooks to quickly and easily customize the flow of your application code.

* __Logging__: Keep track of all instances of your tool through logging. Logs can go to STDOUT, STDERR, or a given file, making them compatible with log aggregators such as Splunk, Logstash, and many others.

* __Local State Storage__: Easily manage a set of data that persists between runs. You get access to a hash that is automatically kept in-sync with a file on disk.

* __Remote State__: It works just like Local State Storage, but store the data on a remote server! It can be used in tandem with Local State Storage or on its own. Currently supports AWS DyanmoDB.  

* __State Locking and Sharing__: Share remote state safely between users with built-in locking! When enabled, it makes sure that only one user is accessing the data at any given time.

* __Automatic Update Notifications__: Just provide the gem name or git repo, and RBCli will take care of notifying users!

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

Creating a new skeleton command is as easy as running `rbcli init <filename>`. It will have these key items:

* The configuration
* Storage subsystem configuration (optional)
* A command declaration
* The parse command


### Configuration

```ruby
require 'rbcli'

Rbcli::Configurate.me do
	scriptname __FILE__.split('/')[-1]                                     # (Required) This line identifies the tool's executable. You can change it if needed, but this should work for most cases.
	version '0.1.0'                                                        # (Required) The version number
	description 'This is my test CLI tool.'                                # (Requierd) A description that will appear when the user looks at the help with -h. This can be as long as needed.
	
	log_level :info                                                        # (Optional) Set the default log_level for users. 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  log_target 'stderr'                                                    # (Optional) Set the target for logs. Valid values are STDOUT, STDERR, or a file path (as strings)

	config_userfile '/etc/mytool/config.yml', merge_defaults: true, required: false  # (Optional) Set location of user's config file. If merge_defaults=true, user settings override default settings, and if false, defaults are not loaded at all. If required=true, application will not run if file does not exist.
	config_defaults 'defaults.yml'                                         # (Optional, Multiple) Load a YAML file as part of the default config. This can be called multiple times, and the YAML files will be merged. User config is generated from these
	config_default :myopt, description: 'Testing this', value: true        # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config

	option :name, 'Give me your name', type: :string, default: 'Foo', required: false, permitted: ['Jack', 'Jill']  # (Optional, Multiple) Add a global CLI parameter. Supported types are :string, :boolean, :integer, :float, :date, and :io. Can be called multiple times.

	autoupdate github_repo: 'akhoury6/rbcli', access_token: nil, enterprise_hostname: nil, force_update: false    # (Optional) Check for updates to this application at a GitHub repo. The repo must use version number tags in accordance to best practices: https://help.github.com/articles/creating-releases/
	autoupdate gem: 'rbcli', force_update: false                                                                  # (Optional) Check for updates to this application through RubyGems.org.

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

	first_run halt_after_running: true do                                  # (Optional) Allows providing a block of code that executes the first time that the application is run on a given system. If `halt_after_running` is set to `true` then parsing will not continue after this code is executed. All subsequent runs will not execute this code.
		puts "This is the first time the mytool command is run! Don't forget to generate a config file with the `-g` option before continuing."
	end
end
```

#### CLI Option Declarations

For the `option` parameters that you want to create, the following types are supported:

* `:string`
* `:boolean` or `:flag`
* `:integer`
* `:float`

If a default value is not set, it will default to `nil`.

If you want to declare more than one option, you can call it multiple times. The same goes for other items tagged with _Multiple_ in the description above.

Once parsed, options will be placed in a hash where they can be accessed via their names as shown above. You can see this demonstrated in the `default_action`, `pre_hook`, and `post_hook` blocks.


### Storage Configuration (optional)

```ruby
Rbcli::Configurate.storage do
	local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true                                                     # (Optional) Creates a hash that is automatically saved to a file locally for state persistance. It is accessible to all commands at  Rbcli.local_state[:yourkeyhere]
	remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: true          # (Optional) Creates a hash that is automatically saved to a DynamoDB table. It is recommended to keep halt_on_error=true when using a shared state.
end
```

This block configures different storage interfaces. For more details please see the [Storage Subsystems](#storage_subsystems) section below.

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
		puts "\nArgs:\n#{args}"                    # Arguments that came after the command on the CLI
		puts "Params:\n#{params}"                  # Parameters, as described through the option statements above
		puts "Global opts:\n#{global_opts}"        # Global Parameters, as descirbed in the Configurate section
		puts "Config:\n#{config}"                  # Config file values
		puts "LocalState:\n#{Rbcli.local_state}"   # Local persistent state storage (when available) -- if unsure use Rbcli.local_state.nil?
		puts "RemoteState:\n#{Rbcli.remote_state}" # Remote persistent state storage (when available) -- if unsure use Rbcli.remote_state.nil?
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

## <a name="storage_subsystems"></a>Storage Subsystems

```ruby
Rbcli::Configurate.storage do
	local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true                                                   # (Optional) Creates a hash that is automatically saved to a file locally for state persistance. It is accessible to all commands at  Rbcli.local_state[:yourkeyhere]
	remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: true        # (Optional) Creates a hash that is automatically saved to a DynamoDB table. It is recommended to keep halt_on_error=true when using a shared state.
end
```

### <a name="local_state"></a> Local State

RBCli's local state storage gives you access to a hash that is automatically persisted to disk when changes are made.

Once configured you can access it with a standard hash syntax:

```ruby
Rbcli.local_state[:yourkeyhere]
```

For performance reasons, the only methods available for use are:

Hash native methods:

* `[]` (Regular hash syntax. Keys are accessed via either symbols or strings indifferently.)
* `[]=` (Assignment operator)
* `delete`
* `each`
* `key?`

Additional methods:

* `clear`
	* Resets the data back to an empty hash.
* `refresh`
	* Loads the most current version of the data from the disk
* `disconnect`
	* Removes the data from memory and sets `Rbcli.local_state = nil`. Data will be read from disk again on next access.


Every assignment will result in a write to disk, so if an operation will require a large number of assignments/writes it should be performed to a different hash before beign assigned to this one.

#### Configuration Parameters

```ruby
Rbcli::Configurate.storage do
	local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true                                   # (Optional) Creates a hash that is automatically saved to a file locally for state persistance. It is accessible to all commands at  Rbcli.local_state[:yourkeyhere]
end
```

There are three parameters to configure it with:
* The `path` as a string (self-explanatory)
* `force_creation`
	* This will attempt to create the path and file if it does not exist (equivalent to an `mkdir -p` and `touch` in linux)
* `halt_on_error`
	* RBCli's default behavior is to raise an exception if the file can not be created, read, or updated at any point in time
	* If this is set to `false`, RBCli will silence any errors pertaining to file access and will fall back to whatever data is available. Note that if this is enabled, changes made to the state may not be persisted to disk.
		* If creation fails and file does not exist, you start with an empty hash
		* If file exists but can't be read, you will have an empty hash
		* If file can be read but not written, the hash will be populated with the data. Writes will be stored in memory while the application is running, but will not be persisted to disk.

### <a name="remote_state">Remote State

RBCli's remote state storage gives you access to a hash that is automatically persisted to a remote storage location when changes are made. It has locking built-in, meaning that multiple users may share remote state without any data consistency issues!

Once configured you can access it with a standard hash syntax:

```ruby
Rbcli.remote_state[:yourkeyhere]
```

This works the same way that [Local State](#local_state) does, with the same performance caveats (try not to do many writes!).

Note that all state in Rbcli is __lazy-loaded__, so no connections will be made until your code attempts to access the data.

#### DynamoDB Configuration

Before DynamoDB can be used, AWS API credentials have to be created and made available. RBCli will attempt to find credentials from the following locations in order:

1. User's config file
2. Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. User's AWSCLI configuration at `~/.aws/credentials`

For more information about generating and storing AWS credentials, see [Configuring the AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

```ruby
Rbcli::Configurate.storage do
	remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: true        # (Optional) Creates a hash that is automatically saved to a DynamoDB table. It is recommended to keep halt_on_error=true when using a shared state.
end
```

These are the parameters:
* `table_name`
	* The name of the DynamoDB table to use.
* `region`
	* The AWS region that the database is located
* `force_creation`
	* Creates the DynamoDB table if it does not already exist
* `halt_on_error`
	* Similar to the way [Local State](#local_state) works, setting this to `false` will silence any errors in connecting to the DynamoDB table. Instead, your application will simply have access to an empty hash that does not get persisted anywhere.
	* This is good for use cases that involve using this storage as a cache to "pick up where you left off in case of failure", where a connection error might mean the feature doesn't work but its not important enough to interrupt the user.
* `locking`
	* This enables locking, for when you are sharing state between different instances of the application. For more information see the [section below](#distributed_locking).

#### <a name="distributed_locking">Distributed Locking and State Sharing

Distributed Locking allows a remote state to be shared among multiple users of the application without risk of data corruption. To use it, simply set the  `locking:` parameter to `true` when enabling remote state (see above).

This is how locking works:

1. The application attempts to acquire a lock on the remote state when you first access it
2. If the backend is locked by a different application, wait and try again
3. If it succeeds, the lock is held and refreshed periodically
4. When the application exits, the lock is released
5. If the application does not refresh its lock, or fails to release it when it exits, the lock will automatically expire within 60 seconds
6. If another application steals the lock (unlikely but possible), and the application tries to save data, a `StandardError` will be thrown
7. You can manually attempt to lock/unlock by calling `Rbcli.remote_state.lock` or `Rbcli.remote_state.unlock`, respectively.

##### Auto-locking vs Manual Locking

Remember: all state in Rbcli is lazy-loaded. Therefore, RBCli wll only attempt to lock the data when you first try to access it. If you need to make sure that the data is locked before executing a block of code, use:

```ruby
Rbcli.remote_state.refresh
```

to force the lock and retrieve the latest data. You can force an unlock by calling:

```ruby
Rbcli.remote_state.disconnect
```

## Automatic Update Check

RBCli can automatically notify users when an update is available. If `force_update` is set (see below), RBCli can halt execution until the user updates their application.

Two sources are currently supported: Github (including Enterprise) and RubyGems.

### GitHub Update Check

The GitHub update check works best when paired with GitHub's best practices on releases. See here: https://help.github.com/articles/creating-releases/

RBCli will check your github repo's tags and compare that version number with one you configured Rbcli with.

```ruby
autoupdate github_repo: 'akhoury6/rbcli', access_token: nil, enterprise_hostname: nil, force_update: false    # (Optional) Check for updates to this application at a GitHub repo. The repo must use version number tags in accordance to best practices: https://help.github.com/articles/creating-releases/
``` 
The `github_repo` should point to the repo using the `user/repo` syntax. 

The `access_token` can be overridden by the user via their configuration file, so it can be left as `nil`. The token is not needed at all if using a public repo. For instructions on generating a new access token, see [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). 

The `enterprise_hostname` setting allows you to point RBCli at a local GitHub Enterprise server.

Setting `force_update: true` will halt execution if an update is available, forcing the user to update.

### Rubygems.org Update Check

The Rubygems update check will check if there is a new published version of the gem on Rubygems.org. The latest published version is compared to the version number you configured RBCli with.

```ruby
autoupdate gem: 'rbcli', force_update: false   # (Optional) Check for updates to this application through RubyGems.org.
```

The `gem` parameter should simply state the name of the gem.
 
Setting `force_update: true` will halt execution if an update is available, forcing the user to update.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine from source, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akhoury6/rbcli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rbcli project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/akhoury6/rbcli/blob/master/CODE_OF_CONDUCT.md).
