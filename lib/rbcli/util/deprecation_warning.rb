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


class Rbcli::DeprecationWarning

	@@warnings = []
	@@errors_exist = false

	def initialize original_feature_name, message_text, change_by_version, caller
		#@caller = caller_locations(2,1)[0].label
		@original_feature_name = original_feature_name
		@message_text = message_text
		@change_by_version = change_by_version
		@caller = caller
		@@warnings.append self
	end

	def display
		deprecated_version_parts = @change_by_version.split('.').map { |i| i.to_i }
		current_version_parts = Rbcli::VERSION.split('.').map { |i| i.to_i }

		if deprecated_version_parts[0] > current_version_parts[0] or
				deprecated_version_parts[1] > current_version_parts[1] or
				deprecated_version_parts[2] >= current_version_parts[2]

			message = "DEPRECATION ERROR: The feature `#{@original_feature_name}` has been deprecated as of Rbcli version #{@change_by_version}. #{@message_text} Please update the relevant code to continue using Rbcli."
			Rbcli::log.error { message }
			puts message.red
			@@errors_exist = true
		else
			message = "DEPRECATION WARNING: The feature `#{@original_feature_name}` has been deprecated. #{@message_text} This feature will be removed in version #{@change_by_version}."
			Rbcli::log.warn { message }
			puts message.yellow
		end
		puts @caller[0], ""
	end

	def self.display_warnings
		@@warnings.each { |w| w.display }
		exit(1) if @@errors_exist
	end
end