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


module Rbcli::Configurate::Me
	include Rbcli::Configurable

	@data = {
			scriptname: nil,
			version: nil,
			description: nil,
			config_userfile: nil,
			options: {},
			default_action: nil,
			pre_hook: nil,
			post_hook: nil,
			first_run: nil,
			halt_after_first_run: false,
			remote_execution: false,
			autoupdater: nil
	}
	def self.data; @data; end

	def self.scriptname name
		@data[:scriptname] = name
	end

	def self.version vsn
		@data[:version] = vsn
	end

	def self.description desc
		@data[:description] = desc
	end

	def self.log_level level
		Rbcli::Logger::save_defaults level: level
	end

	def self.log_target target
		Rbcli::Logger::save_defaults target: target
	end

	def self.config_userfile *params
		Rbcli::Config::set_userfile *params
		@data[:config_userfile] = params[0]
	end

	def self.config_defaults filename
		Rbcli::Config::add_defaults filename
	end

	def self.config_default *params
		Rbcli::Config::add_default *params
	end

	def self.option name, description, short: nil, type: :boolean, default: nil, required: false, permitted: nil
		default ||= false if (type == :boolean || type == :bool || type == :flag)
		@data[:options][name.to_sym] = {
				description: description,
				type: type,
				default: default,
				required: required,
				permitted: permitted,
				short: short
		}
	end

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

	def self.remote_execution permitted: true
		@data[:remote_execution] = permitted
		require 'rbcli/remote_exec/remote_exec' if permitted
	end

	def self.autoupdate gem: nil, github_repo: nil, access_token: nil, enterprise_hostname: nil, force_update: false, message: nil
		raise StandardError.new "Autoupdater can not have both a gem and git target defined. Please pick one." if gem and github_repo
		raise StandardError.new "Only one autoupdater can be defined." if @data[:autoupdater]
		if gem
			require 'rbcli/autoupdate/gem_updater'
			#Rbcli::Autoupdate::GemUpdater.save_defaults
			@data[:autoupdater] = Rbcli::Autoupdate::GemUpdater.new gem, force_update, message
		else
			require 'rbcli/autoupdate/github_updater'
			Rbcli::Autoupdate::GithubUpdater.save_defaults
			@data[:autoupdater] = Rbcli::Autoupdate::GithubUpdater.new github_repo, access_token, enterprise_hostname, force_update, message
		end
		@data[:autoupdater].show_message if @data[:autoupdater].update_available?
	end

end
