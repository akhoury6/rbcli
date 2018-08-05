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
#     For questions regarding licensing, please contact andrew@blacknex.us        #
##################################################################################

require 'octokit'

module Rbcli::Autoupdate
	class GithubUpdater
		include Common

		def initialize reponame, access_token, enterprise_hostname, force_update, message
			@reponame = reponame
			@force_update = force_update
			@message = message

			access_token = Rbcli.config.key?(:github_updatecheck) ? (Rbcli.config[:github_updatecheck][:access_token] || access_token) : access_token
			enterprise_hostname = Rbcli.config.key?(:github_updatecheck) ? (Rbcli.config[:github_updatecheck][:enterprise_hostname] || enterprise_hostname) : enterprise_hostname

			# Enterprise Connection
			if enterprise_hostname
				Octokit.configure do |c|
					c.api_endpoint = "https://#{enterprise_hostname}/api/v3/"
				end
				# Public Github Connection
			end
			#OAuth connection - not used
			#@client = Octokit::Client.new :client_id => client_id, :client_secret => client_secret
			@client = Octokit::Client.new(:access_token => access_token)
		end

		def get_latest_version
			begin
				@client.repo(@reponame).rels[:tags].get.data.map{ |t| t[:name] }[0].sub(/^[v]*/,"")
			rescue Faraday::ConnectionFailed => e
				# This is to capture connection errors without bothering the user.
			end

		end

		def update_message
			"Please check the github repo #{@reponame} for instructions."
		end

		def self.save_defaults
			Rbcli::Config::add_categorized_defaults :github_update, 'Automatically Check for Updates from GitHub', {
					access_token: {
							description: 'Access token for GitHub API. This is only required for private repos. For help, see: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/',
							value: nil
					},
					enterprise_hostname: {
							description: 'Hostname for GitHub Enterprise. Leave as null (~) for public GitHub.',
							value: nil
					}
			}
		end
	end
end