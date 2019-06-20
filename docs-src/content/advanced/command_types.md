---
title: "Command Types"
date: 2019-06-20T15:07:21-04:00
draft: false
---

RBCli has three different command types:

* __Standard Commands__ (Ruby-based)
* __Scripted Commands__ (Ruby+Bash based)
* __External Commands__ (Wrapping a 3rd party application)


This document is provided to be a reference. If you would like an in-depth tutorial, please see [Your First Command][your_first_command].


## General Command Structure

Commands in RBCli are created by subclassing `Rbcli::Command`. All commands share a certain common structure:

```ruby
class List < Rbcli::Command                                                           # Declare a new command by subclassing Rbcli::Command
	description 'TODO: Description goes here'                                           # (Required) Short description for the global help
	usage <<-EOF
TODO: Usage text goes here
EOF                                                                                   # (Required) Long description for the command-specific help
	parameter :force, 'Force testing', type: :boolean, default: false, required: false  # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

	config_default :myopt2, description: 'My Option #2', default: 'Default Value Here'  # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config.
                                                                                      # Alternatively, you can simply create a yaml file in the `default_user_configs` directory in your project that specifies the default values of all options
end
```

* `description`
	* A short description of the command, which will appear in the top-level help (when the user runs `mytool -h`).
* `usage`
	* A description of how the command is meant to be used. This description can be as long as you want, and can be as in-depth as you'd like. It will show up as a long, multi-line description when the user runs the command-sepcific help (`mytool list -h`).
* `parameter`
	* Command-line tags that the user can enter that are specific to only this command. We will get into these in the next section on [Options, Parameters, and Arguments][parameters_documentation]
* `config_default`
	* This sets a single item in the config file that will be made available to the user. More information can be found in the documentation on [User Config Files][user_config_documentation]

## Standard Commands

Standard commands are written as ruby code. To create a standard command called `list`, run:

```bash
rbcli command --name=list
#or
rbcli command -n list
```

A standard command can be identified by the presence of an `action` block in the definition:

```ruby
class List < Rbcli::Command
	action do |params, args, global_opts, config|
		# Code goes here
	end
end
```

Your application's __parameters__, __arguments__, __options__, and __config__ are available in the variables passed into the block. For more information on these, see [Options, Parameters, and Arguments][parameters_documentation].


## Scripted Commands

Scripted commands are part Ruby, part Bash scripting. They are a good choice to use if you feel something might be easier or more performant to script with Bash, or if you already have a Bash script you'd like to use in your project. You can create one with:

```bash
rbcli script -n list
```

This will create two files in your RBCli project: a Ruby file with the common command declaration (see [General Command Structure](#general-command-structure)), and a bash script in the folder `application/commands/scripts/`.

You can tell a command is a script by the line:

```ruby
class List < Rbcli::Command
	script
end
```

RBCli will pass along your applications config and CLI parameters through JSON environment variables. To make things easy, a Bash library is provided that makes retrieving and parsing these variables easy. It is already imported when you generate the command, with the line:

```bash
source $(echo $(cd "$(dirname $(gem which rbcli))/../lib-sh" && pwd)/lib-rbcli.sh)
``` 

This will find the library which is stored on the system as part of the RBCli gem.

You can then retrieve the values present in your variables like such:

```bash
rbcli params
rbcli args
rbcli global_opts
rbcli config
rbcli myvars

echo "Usage Examples:"
echo "Log Level:  $(rbcli config .logger.log_level)"
echo "Log Target: $(rbcli config .logger.log_target)"
echo "First Argument (if passed): $(rbcli args .[0])"
```

For your convenience, the script will have all the instructions needed there. For more instructions on how to use JQ syntax to parse values, see the [JQ documentation][jq_documentation].

## External Commands

External Commands are used to wrap 3rd party applications. RBCli accomplishes this by allowing you to set environment variables and command line parameters based on your input variables.

RBCli provides this feature through the `extern` keyword. It provides two modes -- __direct path__ and __variable path__ -- which work similarly.


### Direct Path Mode

Direct path mode is the simpler mode of the two External Command modes. It allows you to provide a specific command with environment variables set, though it does not allow using RBCli parameters, arguments, options, and config.

 ```ruby
class List < Rbcli::Command
 	extern path: 'path/to/application', envvars: {MYVAR: 'some_value'}                               # (Required) Runs a given application, with optional environment variables, when the user runs the command.
end
 ```

Here, we supply a string to run the command. We can optioanlly provide environment variables which will be set for the external application.

### Variable Path Mode

Variable Path mode works the same as Direct Path Mode, only instead of providing a string we provide a block that returns a string (which will be the command executed). This allows us to generate different commands based on the CLI parameters that the user passed, or pass configuration as CLI parameters to the external application:

```ruby
class Test < Rbcli::Command
	extern envvars: {MY_OTHER_VAR: 'another_value'} do |params, args, global_opts, config|          # Alternate usage. Supplying a block instead of a path allows us to modify the command based on the arguments and configuration supplied by the user. This allows passing config settings as command line arguments to external applications. The block must return a string, which is the command to be executed.
		cmd = '/path/to/application'
		cmd += ' --test-script foo --ignore-errors' if params[:force]
		cmd
	end
end
```

__NOTE__: Passing user-supplied data as part of the command string may be a security risk (example: `/path/to/application --name #{params[:name]}`). It is highly recommended to provide the fixed strings yourself, and only select which strings are used based on the variables provided. This is demonstrated in the example above.


[your_first_command]: {{< ref "tutorial/30-your_first_command" >}}
[parameters_documentation]: {{< ref "tutorial/40-options_parameters_and_arguments" >}}
[user_config_documentation]: {{< ref "advanced/user_config_files" >}}
[jq_documentation]: https://stedolan.github.io/jq/manual/
