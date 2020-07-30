Rbcli::Configurate.me do
	####
	# General Configuration
	###
	# Here you will find the general configuration options for RBCli.
	###

	## Description -- (Required) -- A description that will appear when the user looks at the help with -h.
	# This should describe what the application does, and if applicable, give some common usage examples.
	# It can be as long as needed. Use a heredoc if desired: <<-EOF TextGoesHere EOF
	description %q{<%= @vars[:description] %>}

	## Remote Exection -- (Optional) -- Enables executing commands on remote machines via SSH
	# For any command that you would like to enable remote_execution for, you shoud also
	# put the 'remote_permitted' directive in its declaration.
	remote_execution permitted: false
end
