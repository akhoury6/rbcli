Rbcli::Configurate.hooks do
	####
	# HOOKS
	###
	# Here you can set hooks that will be run at specified points in the execution chain.
	# Global CLI options are made available to many of the hooks, but command parameters and lineitems are not.
	###

	## Post-Execution Hook -- (Optional) -- Allows providing a block of code that runs _after_ all commands

	post_hook do |opts|
		puts 'This is a post-command hook. It executes after the command.'
	end
end
