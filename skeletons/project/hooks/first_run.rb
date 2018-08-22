Rbcli::Configurate.hooks do
	####
	# HOOKS
	###
	# Here you can set hooks that will be run at specified points in the execution chain.
	# Global CLI options are made available to many of the hooks, but command parameters and lineitems are not.
	###

	## First-Run Hook -- (Optional) -- Allows providing a block of code that executes the first time that the application is run on a given system.
	# If `halt_after_running` is set to `true` then parsing will not continue after this code is executed. All subsequent runs will not execute this code.
	# This feature is dependent on the Local State Storage system, and will not run without it.

	first_run halt_after_running: false do
		puts "This is the first time the mytool command is run! Don't forget to generate a config file with the `-g` option before continuing."
	end
end
