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
#     For questions regarding licensing, please contact andrew@bluenex.us        #
##################################################################################

require 'net/http'
require 'json'

module Rbcli::Autoupdate
	class GemUpdater
		include Common

		def initialize gemname, force_update, message
			@gemname = gemname
			@uri = URI.parse "https://rubygems.org/api/v1/versions/#{gemname}/latest.json"
			@force_update = force_update
			@message = message
		end

		def get_latest_version
			begin
				response = Net::HTTP.get(@uri)
				JSON.parse(response)['version']
			rescue SocketError => e
				# Capture connection errors
			end
		end

		def update_message
			"Please run `gem update #{@gemname}` to upgrade to the latest version. You can see it at: https://rubygems.org/gems/#{@gemname}/versions/#{@latest_version}"
		end

		# def self.save_defaults
		# 	Rbcli::Config::add_categorized_defaults :gem_update, 'Automatically Check for Updates from RubyGems', {
		# 			access_token: {
		# 					description: 'Access token for GitHub API. This is only required for private repos. For help, see: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/',
		# 					value: nil
		# 			},
		# 			enterprise_hostname: {
		# 					description: 'Hostname for GitHub Enterprise. Leave as null (~) for public GitHub.',
		# 					value: nil
		# 			}
		# 	}
		# end
	end
end