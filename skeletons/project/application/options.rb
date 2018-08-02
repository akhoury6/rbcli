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
	# Options are defined in the follwoing format:
	#     option :<name>, "<description_string>", short: '<character>', type: <variable_type>, default: <default_value>, permitted: [<array_of_permitted_values]
	#
	#       name:               (Required) The long name of the option, as a symbol. This will be represented as `--name` on the command line
	#       description_string: (Required) A short description of the command that will appear in the help text for the user
	#       type:               (Required) The following types are supported: `:string`, `:boolean` or `:flag`, `:integer`, and `:float`
	#       default:            (Optional) A default value for the option if one isn't entered (default: nil)
	#       short:              (Optional) A letter that acts as a shortcut for the option. This will allow users to apply the command as `-n`
	#                                       To not have a short value, set this to :none
	#                                       (default: the first letter of the long name)
	#       required:           (Optional) Specify whether the option is required from the user (default: false)
	#       permitted:          (Optional) An array of whitelisted values for the option (default: nil)
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
	option :name, 'Give me your name', short: 'n', type: :string, default: 'Jack', required: false, permitted: ['Jack', 'Jill']
end