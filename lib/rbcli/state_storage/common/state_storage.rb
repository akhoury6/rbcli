##################################################################################
#     RBCli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2018 Andrew Khoury                                           #
#                                                                                #
#     This program is free software: you can redistribute it and/or modify       #
#     it under the terms of the GNU General Public License as published by       #
#     the Free Software Foundation, either version 3 of the License, or          #
#     (at your option) any later version.                                        #
#                                                                                #
#     This program is distributed in the hope that it will be useful,            #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#     GNU General Public License for more details.                               #
#                                                                                #
#     You should have received a copy of the GNU General Public License          #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.     #
#                                                                                #
#     For questions regarding licensing, please contact andrew@blacknex.us       #
##################################################################################

require 'fileutils'
require 'json'


module Rbcli::State

	## Main State Class
	class StateStorage

		def initialize path, force_creation: false, halt_on_error: true, lazy_load: true
			@path = path
			@force_creation = force_creation
			@halt_on_error = halt_on_error

			state_subsystem_init

			# Lazy load option
			@loaded = false
			state_create unless lazy_load
		end

		def []= key, value
			state_create unless @loaded
			@data[:data][key.to_sym] = value
			save_state
			@data[:data][key.to_sym]
		end

		def [] key
			state_create unless @loaded
			@data[:data][key.to_sym]
		end

		def delete key, &block
			state_create unless @loaded
			result = @data[:data].delete key.to_sym, &block
			save_state
			result
		end

		def refresh
			if @loaded
				load_state
			else
				state_create
			end
		end

		def commit
			save_state if @loaded
		end

		def clear
			state_create unless @loaded
			@data[:data] = {}
			save_state
		end

		def disconnect
			unlock if self.class.method_defined? :unlock
			@loaded = false
			@data[:data] = nil
		end

		def each &block
			state_create unless @loaded
			@data[:data].each &block
			save_state
		end

		def key? key
			state_create unless @loaded
			@data[:data].key? key.to_sym
		end

		def to_h
			state_create unless @loaded
			@data[:data]
		end

		def to_s
			state_create unless @loaded
			to_h.to_s
		end

		# For framework's internal use

		def rbclidata key = nil
			state_create unless @loaded
			return @data[:rbcli][key.to_sym] unless key.nil?
			@data[:rbcli]
		end

		def set_rbclidata key, value
			state_create unless @loaded
			@data[:rbcli][key.to_sym] = value
			save_state
		end

		private

		def state_create
			base_data = {data: {}, rbcli: {}}
			if state_exists?
				load_state
			elsif @force_creation
				create_state
				@data = base_data
				save_state
			else
				raise StandardError "State location #{@path} does not exist or can not be accessed." if @halt_on_error
				@data = base_data
			end
			@loaded = true
		end

	end
end
