# Configuration Files

RBCli provides built-in support for creating and managing userspace configuration files. It does this through two chains: the __defaults chain__ and the __user chain__.

## Defaults chain

The defaults chain allows you to specify sane defaults for your CLI tool throughout your code. This gives you the ability to declare configuration alongside the code, and allows RBCli to generate a user config automatically given your defaults. There are two ways to set them:

* YAML Files
	* You can store your defaults in one or more YAML files and RBCli will import and combine them. Note that when generating the user config, RBCli will use the YAML text as-is, so comments are transferred as well. This allows you to write descriptions for the options directly in the file that the user can see.
	* This is good for tools with large or complex configuration that needs user documentation written inline
	* These YAML files should be placed in the `userconf/` directory in your project and they will automatically be loaded
* DSL Statements
	* In the DSL, you can specify options individually by providing a name, description, and default value
	* This is good for simpler configuration, as the descriptions provided are written out as comments in the generated user config
	* You can put global configuration options in `config/userspace.rb`
	* Command-specific confiugration can be placed in the command declarations in `application/commands/*.rb`

DSL statements appear in both of the above locations as the following:

```ruby
config_default :name, description: '<description_help_text>', default: '<default_value>'
```
## User chain

The user chain has two functions: generating and loading configuration from a YAML file on the end user's machine.

Rbcli will determine the correct location to locate the user configuration based on two factors:

1. The default location set in `config/userspace.rb`
2. The location specified on the command line using the `--config-file=<filename>` option (overrides #1)

To configure the default location, edit `config/userspace.rb`:

```ruby
config_userfile '~/.mytool', merge_defaults: true, required: false
```

* `path/to/config/file`
	* Self explanatory. Recommended locations are a dotfile in the user's home directory, or a file under `/etc` such as `/etc/mytool/userconf.yaml`
* `merge_defaults`
	* If set to `true`, default settings override user settings. If set to `false`, default settings are not loaded at all and the user is required to have all values specified in their config.
* `required`
	* If set to `true` the application will not run if the file does not exist. A message will be displayed to the user to run your application with the `--generate-config` option to generate the file given your specified defaults.


Users can generate configs by running `yourclitool --generate-config`. This will generate a config file at the tool's default location specified in the DSL. This location can be overridden via the `--config-file=<filename>` option.
