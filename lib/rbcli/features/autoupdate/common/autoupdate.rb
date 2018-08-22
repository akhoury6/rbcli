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


require 'rubygems'
module Rbcli::Autoupdate
	module Common
		def get_latest_version
			raise Exception.new "Autoupdater type #{self.class.name} must define a 'check_for_updates' method."
		end

		def update_message
			raise Exception.new "Autoupdater type #{self.class.name} must define an 'update_message' method."
		end

		def update_available?
			@latest_version = get_latest_version
			Gem::Version.new(@latest_version) > Gem::Version.new(Rbcli.configuration(:me, :version))
		end

		def show_message
			puts "WARNING: An update is available to #{Rbcli.configuration(:me, :scriptname)}. You are currently running version #{Rbcli.configuration(:me, :version)}; the latest is #{@latest_version || get_latest_version}."
			puts @message || update_message
			puts "\n"
			if @force_update
				puts "This application requires that you update to the latest version to continue using it. It will now exit."
				exit 0
			end
		end
	end
end
