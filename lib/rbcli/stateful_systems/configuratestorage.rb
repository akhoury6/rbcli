module Rbcli::Configurate
	def self.storage &block
		Rbcli::ConfigurateStorage.configure &block
	end
end


module Rbcli::ConfigurateStorage
	@data = {
			localstate: nil
	}

	def self.configure &block
		@self_before_instance_eval = eval "self", block.binding
		instance_eval &block
	end

	##
	# Data Retrieval
	##
	def self.data
		@data
	end
end
