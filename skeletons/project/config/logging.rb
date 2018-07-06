Rbcli::Configurate.me do
	####
	# LOGGING
	###
	# These parameters set the default logging parameters for your applicaiton. Note that a user
	# can override these settings by modifying their local configuration.
	# If either option is set to nil, or they are not provided, logging is disabled.
	###

	## Log Target -- (Optional) -- Set the target for logs.
	# Valid values are nil, 'STDOUT', 'STDERR', or a file path (as strings).
	# Default is disabled (nil).
	log_target nil

	## Log Level -- (Optional) -- Set the default log_level for users.
	# Valid values are nil, 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN.
	# Default is disabled (nil).
	log_level nil
end