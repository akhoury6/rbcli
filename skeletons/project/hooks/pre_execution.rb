Rbcli::Configurate.me do
	####
	# HOOKS
	###
	# Here you can set hooks that will be run at specified points in the execution chain.
	# Global CLI options are made available to many of the hooks, but command parameters and lineitems are not.
	###

	## Pre-Execution Hook -- (Optional) -- Allows providing a block of code that runs _before_ all commands

	pre_hook do |opts|
		puts 'This is a pre-command hook. It executes before the command.'
	end
end
