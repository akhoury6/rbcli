###############################
## State Configuration Block ##
###############################
# The state-related componets
# are configured here.
###############################
Rbcli::Configurate.storage do
	###
	# Local State Storage -- (Optional)
	###
	# Local state storage creates a hash that is automatically saved to a file locally for state persistance.
	# It is accessible to all commands at:    Rbcli.localstate[:yourkeyhere]
	#
	# Note that every update to the top level of this hash will trigger a save, and updating nested hashes will not.
	# If you need to update nested hashes, you can trigger a save manually by calling `Rbcli.localstate.commit`.
	# It is accessible to all commands at: Rbcli.localstate[:yourkeyhere]
	# Please see the documentation for full usage details.
	###

	#local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true


	###
	# Remote State Storage -- (Optional)
	###
	# Remote state storage creates a hash that is automatically saved to a remote database for state persistence.
	# This state can be made unique to each user, or can be shared across different users of the tool.
	#
	# When sharing, locking should be set to `true` to prevent data corruption. Note that RBCli uses lazy-loaded,
	# meaning the lock will only be acquired when absolutely needed. This behavior can be overridden manually if desired.
	# For full usage details, see the documentation.
	###

	#remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: false
end