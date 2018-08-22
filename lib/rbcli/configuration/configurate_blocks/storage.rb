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

module Rbcli::Configurate::Storage
	include Rbcli::Configurable

	@data = {
			localstate: nil,
			remotestate: nil,
			remotestate_init_params: nil
	}

	def self.data; @data; end

	def self.local_state path, force_creation: false, halt_on_error: false
		require 'rbcli/state_storage/localstate'

		@data[:localstate] = Rbcli::State::LocalStorage.new(path, force_creation: force_creation, halt_on_error: halt_on_error)
	end

	def self.remote_state_dynamodb table_name: nil, region: nil, force_creation: false, halt_on_error: true, locking: false
		raise StandardError "Must decalre `table_name` and `region` to use remote_state_dynamodb" if table_name.nil? or region.nil?

		require 'rbcli/state_storage/remotestate_dynamodb'

		@data[:remotestate_init_params] = {
				dynamodb_table: table_name,
				region: region,
				locking: locking
		}
		@data[:remotestate] = Rbcli::State::DynamoDBStorage.new(table_name, force_creation: force_creation, halt_on_error: halt_on_error)
	end
end
