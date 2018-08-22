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

	def initialize original_feature_name, message_text, change_by_version
		#@caller = caller_locations(2,1)[0].label
		@original_feature_name = original_feature_name
		@message_text = message_text
		@change_by_version = change_by_version
		@@warnings.append self
	end

	def display
		message = "DEPRECATION WRNING: The feature `#{@original_feature_name}` has been deprecated. #{@message_text} This feature will be removed in version #{@change_by_version}."
		Rbcli::log.warn { message }
		puts message.red
	end

	def self.display_warnings
		@@warnings.each { |w| w.display }
	end
end