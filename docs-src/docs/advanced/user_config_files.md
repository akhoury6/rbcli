# Configuration Files

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
	* `config_default :name, description: '<description_text>', default: <default_value>` in the DSL
 
### User chain

The user chain has two functions: generating and loading configuration from a YAML file.

Rbcli will determine the correct location to locate the user configuration based on two factors:

1. The default location set in the configurate DSL
	a. `config_userfile '/etc/mytool/config.yml', merge_defaults: true, required: false`
	b. (Optional) Set location of user's config file. If `merge_defaults=true`, user settings override default settings, and if `false`, defaults are not loaded at all. If `required=true`, application will not run if file does not exist.
2. The location specified on the command line using the `--config-file=<filename>` option
	b. `yourclitool --config-file=localfile.yml`

Users can generate configs by running `yourclitool --generate-config`. This will generate a config file at the tool's default location specified in the DSL. A specific location can be used via the `--config-file=<filename>` parameter. You can test how this works by running `examples/mytool --config-file=test.yml --generate-config`.
