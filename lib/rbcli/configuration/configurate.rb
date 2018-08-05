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


module Rbcli::Configurate

	@data = {
			scriptname: nil,
			version: nil,
			description: nil,
			config_userfile: nil,
			allow_json: false,
			options: {},
			default_action: nil,
			pre_hook: nil,
			post_hook: nil,
			first_run: nil,
			halt_after_first_run: false
	}

	def self.me &block
		@self_before_instance_eval = eval "self", block.binding
		instance_eval &block
	end

	# def self.method_missing(method, *args, &block)
	# 	@self_before_instance_eval.send method, *args, &block
	# end

	##
	# DSL Functions
	##
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

	def self.allow_json_output allow_json
		@data[:allow_json] = allow_json
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

	##
	# Data Retrieval
	##
	def self.configuration
		@data
	end

end

module Rbcli
	def self.configuration
		Rbcli::Configurate::configuration
	end
end