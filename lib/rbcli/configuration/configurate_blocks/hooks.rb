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


module Rbcli::Configurate::Hooks
	include Rbcli::Configurable

	@data = {
			default_action: nil,
			pre_hook: nil,
			post_hook: nil,
			first_run: nil,
			halt_after_first_run: false
	}
	def self.data; @data; end


	def self.default_action &block
		@data[:default_action] = block
	end

	def self.pre_hook &block
		@data[:pre_hook] = block
	end

	def self.post_hook &block
		@data[:post_hook] = block
	end

	def self.first_run halt_after_running: false, &block
		@data[:halt_after_first_run] = halt_after_running
		@data[:first_run] = block
	end

end
