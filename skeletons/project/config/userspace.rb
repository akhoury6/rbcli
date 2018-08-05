Rbcli::Configurate.me do
	####
	# USER CONFIGURATION MANAGEMENT
	###
	# RBCli allows you to create a configuration file that your users can modify.
	# Users will be able to generate their own file by running your tool with the `-g` option.
	# To disable this feature, comment out the `config_userfile` line below.
	###

	## Config Userfile -- (Optional) -- Set location of user's config file.
	#
	#   config_userfile <path>, merge_defaults: <optional: (true|false), default: true>, required: <optional: (true|false, default: false)
	#
	# If merge_defaults=true, user settings override default settings.
	# If false, defaults set here are not loaded at all, and the user is required to set them.
	# If required=true, application will not run if file does not exist.
	#
	# If the path is set to nil, the config file is disabled

	#config_userfile '~/.<%= @vars[:cmdname] %>', merge_defaults: true, required: false
	config_userfile nil

	## Config Defaults -- (Optional, Multiple) -- Load a YAML file as part of the default config.
	# This can be called multiple times, and the YAML files will be merged. User config is generated from these files.
	# RBCli's best practice is to leave this line commented, and instead, place all YAML files in
	# the `default_user_configs` directory where they are loaded automatically.
	#config_defaults 'defaults.yml'

	## Config Default -- (Optional, Multiple) -- Specify an individual configuration parameter and set a default value.
	# These will be included in generated user config.

	config_default :myopt, description: 'Testing this', default: true
end