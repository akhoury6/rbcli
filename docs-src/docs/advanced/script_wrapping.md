# External Script Wrapping

RBCli has the ability to run an external application as a CLI command, passing CLI parameters and environment variables as desired. It provides two modes -- __direct path__ and __variable path__ -- which work similarly through the `extern` keyword.

When an external script is defined in a command, an `action` is no longer required.

To quickly generate a script that shows the environment variables passed to it, you can use RBCli's own tool: `rbcli script`


## Direct Path Mode

 ```ruby
 class Test < Rbcli::Command                                                          # Declare a new command by subclassing Rbcli::Command
 	description 'This is a short description.'                                         # (Required) Short description for the global help
 	usage 'This is some really long usage text description!'                           # (Required) Long description for the command-specific help
 	parameter :force, 'Force testing', type: :boolean, default: false, required: false # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

 	extern path: 'env | grep "^__PARAMS\|^__ARGS\|^__GLOBAL\|^__CONFIG\|^MYVAR"', envvars: {MYVAR: 'some_value'}     # (Required unless `action` defined) Runs a given application, with optional environment variables, when the user runs the command.
end
 ```

Here, we supply a string to run the command. We can optioanlly provide environment variables which will be available for the script to use.

RBCli will automatically set several environment variables as well. As you may have guessed by the example above, they are prefixed with:

* `__PARAMS`
* `__ARGS`
* `__GLOBAL`
* `__CONFIG`

These prefixes are applied to their respective properties in RBCli, similar to what you would see when using an `action`.

The command in the example above will show you a list of variables, which should look something like this:

```bash
__GLOBAL_VERSION=false
__GLOBAL_HELP=false
__GLOBAL_GENERATE_CONFIG=false
__GLOBAL_CONFIG_FILE="/etc/mytool/config.yml"
__CONFIG_LOGGER={"log_level":"info","log_target":"stderr"}
__CONFIG_MYOPT=true
__CONFIG_GITHUB_UPDATE={"access_token":null,"enterprise_hostname":null}
__PARAMS_FORCE=false
__PARAMS_HELP=false
MYVAR=some_value
```

As you can see above, items which have nested values they are passed in as JSON. If you need to parse them, [JQ](https://stedolan.github.io/jq/) is recommended.

## Variable Path Mode

Variable Path Mode works the same as Direct Path Mode, only instead of providing a string we provide a block that returns a string. This allows us to generate different commands based on the CLI parameters that the user passed, or pass configuration as CLI parameters to the external application:

```ruby
class Test < Rbcli::Command                                                          # Declare a new command by subclassing Rbcli::Command
	description 'This is a short description.'                                         # (Required) Short description for the global help
	usage 'This is some really long usage text description!'                           # (Required) Long description for the command-specific help
	parameter :force, 'Force testing', type: :boolean, default: false, required: false # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

	extern envvars: {MY_OTHER_VAR: 'another_value'} do |params, args, global_opts, config|                   # Alternate usage. Supplying a block instead of a path allows us to modify the command based on the arguments and configuration supplied by the user.
		if params[:force]
			"externalapp --test-script foo --ignore-errors"
		else
			"externalapp"
		end
	end
end
```
