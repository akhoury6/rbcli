Rbcli::Configurate.me do
	####
	# Command Line Options
	###
	# Here you can set global options for users on the command line.
	#
	# RBCli supports commands with syntax as follows:
	#   toolname [options] command [parameters] [lineitem]
	#
	# Here you are defining the [options]. The parameters and lineitms (subcommands) are
	# defined under their command blocks.
	#
	# The following types are supported: `:string`, `:boolean` or `:flag`, `:integer`, and `:float`
	#
	# If a default value is not set, it will default to `nil`.
	#
	# To specify multiple options, simply copy the line and modify as desired.
	#
	# Once parsed, option values will be placed in a hash where they can be accessed via their names as shown above where
	# they are made available to your hooks and commands.
	###

	## Description -- (Required) -- A description that will appear when the user looks at the help with -h.
	# This should describe what the application does, and if applicable, give some common usage examples.
	# It can be as long as needed. Use a heredoc if desired: <<-EOF TextGoesHere EOF
	description  %q{<%= @vars[:description] %>}

	## Option -- (Optional, Multiple) -- Add a global CLI Option
	option :name, 'Give me your name', type: :string, default: 'Foo', required: false, permitted: ['Jack', 'Jill']
end