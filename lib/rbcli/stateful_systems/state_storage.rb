require 'fileutils'
require 'json'


module Rbcli::State

	## Main State Class
	class StateStorage

		def initialize path, force_creation: false, halt_on_error: true
			@path = path
			@force_creation = force_creation
			@halt_on_error = halt_on_error

			state_subsystem_init

			base_data = {
					data: {},
					rbcli: {}
			}

			if state_exists?
				load_state
			elsif force_creation
				create_state
				@data = base_data
				save_state
			else
				raise StandardError "State location #{@path} does not exist or can not be accessed." if @halt_on_error
				@data = base_data
			end
		end

		def []= key, value
			@data[:data][key.to_sym] = value
			save_state
			@data[:data][key.to_sym]
		end

		def [] key
			@data[:data][key.to_sym]
		end

		def delete key, &block
			result = @data[:data].delete key.to_sym, block
			save_state
			result
		end

		def clear
			@data[:data] = {}
			save_state
		end

		def each &block
			@data[:data].each &block
			save_state
		end

		def key? key
			@data[:data].key? key.to_sym
		end

		def to_h
			@data[:data]
		end

		def to_s
			to_h.to_s
		end

		# For framework's internal use

		def rbclidata key = nil
			return @data[:rbcli][key.to_sym] unless key.nil?
			@data[:rbcli]
		end

		def set_rbclidata key, value
			@data[:rbcli][key.to_sym] = value
			save_state
		end

	end
end
