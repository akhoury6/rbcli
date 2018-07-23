Rbcli::Configurate.me do
	####
	# HOOKS
	###
	# Here you can set hooks that will be run at specified points in the execution chain.
	# Global CLI options are made available to many of the hooks, but command parameters and lineitems are not.
	###

	## Default Action -- (Optional) -- The default code to execute when no subcommand is given.
	# If not present, the help is shown (same as -h)

	default_action do |opts|
		puts "Hello, sir."
		puts "To see the help, use -h"
	end
end
