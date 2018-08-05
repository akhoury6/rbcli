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


class Rbcli::Command

	#include InheritableTraits
	#traits :description

	@commands = {}

	def self.inherited subklass
		@commands[subklass.name.downcase] = subklass.new
	end

	def self.add_command name, klass
		@commands[name.downcase] = klass.new
	end

	def self.commands
		@commands
	end

	##
	# Interface Functions
	##
	def self.description desc;     @desc = desc end
	def      description;          self.class.instance_variable_get :@desc end

	def self.usage usage;          @usage = usage end
	def      usage;                self.class.instance_variable_get :@usage end

	def self.action &block;        @action = block end
	def      action;               self.class.instance_variable_get :@action end

	def self.parameter name, description, short: nil, type: :boolean, default: nil, required: false, permitted: nil
		default ||= false if (type == :boolean || type == :bool || type == :flag)
		@paramlist ||= {}
		@paramlist[name.to_sym] = {
				description: description,
				type: type,
				default: default,
				required: required,
				permitted: permitted,
				short: short
		}
	end
	def      paramlist;               self.class.instance_variable_get :@paramlist end

	def self.config_defaults filename
		Rbcli::Config::add_defaults filename
	end

	def self.config_default *params
		Rbcli::Config::add_default *params
	end

	##
	# END Interface Functions
	##

	##
	# Run a given command
	##
	def self.runcmd cmd, local_params, cliopts
		args = local_params.delete :args
		params = local_params
		global_opts = cliopts
		config = Rbcli::config

		raise Exception.new("Command #{cmd} has both an extern and action defined. Usage is limiated to one at a time.") if @commands[cmd].extern and @commands[cmd].action
		@commands[cmd].extern.execute params, args, global_opts, config unless @commands[cmd].extern.nil?
		@commands[cmd].action.call params, args, global_opts, config unless @commands[cmd].action.nil?
	end

	##
	# Returns all descriptions for display in CLI help
	##
	def self.descriptions indent_size, justification
		#descmap = @commands.map { |name, klass| [name, klass.description] }.to_h
		@commands.map do |name, cmdobj|
			desc = ''
			indent_size.times { desc << ' ' }
			desc << name.ljust(justification)
			desc << cmdobj.description
		end.join("\n")
	end

	##
	# This method reads the parameters provided by the class and parses them from the CLI
	##
	def parseopts *args
		params = paramlist
		command_name = self.class.name.split('::')[-1].downcase
		command_desc = description
		command_usage = usage
		optx = Trollop::options do
			data = Rbcli.configuration
			banner <<-EOS
#{data[:description]}
Selected Command:
      #{command_name.ljust(21)}#{command_desc}

Usage:
      #{data[:scriptname]} [options] #{command_name} [parameters]
#{if command_usage then "\n" + command_usage + "\n" end}
Command-specific Parameters:
			EOS
			params.each do |name, opts|
				opt name, opts[:description], type: opts[:type], default: opts[:default], required: opts[:required], permitted: opts[:permitted], short: opts[:short]
			end if params.is_a? Hash
		end
		optx[:args] = ARGV
		optx
	end

	##
	# Inject metadata into response
	##
	# def self.wrap_metadata resp
	# 	{
	# 			meta: {
	# 					status: 'ok',
	# 					timestamp: (Time.now.to_f * 1000).floor
	# 			},
	# 			response: resp
	# 	}.deep_stringify!
	# end

	####
	### DEPRECATED
	####
	# Now we automatically pull in the plugins and register them as commands.
	# Note that filenames must be the same as the class name and are case
	# sensitive. Only one class per file.
	##
	# This is commented out as this functionality is deprecated. Instead we rely on subclassing to
	# add the commands.
	###
	# Dir.glob("#{File.dirname(__FILE__)}/commands/*.rb") do |f|
	# 	Rbcli::log.debug {"Loading CLI command #{f.split('commands/')[1].split('.')[0]}"}
	# 	require f
	# 	klassname = "Rbcli::Command::#{f.match(/.*\/([^\/]+)\.rb$/i)[1].capitalize}"
	# 	klass = Object.const_get(klassname)
	# 	klass.send :include, Rbcli::Command
	# 	self.add_command klassname.split('::')[-1], klass
	# end

end


# module InheritableTraits
#
# 	def self.included(base)
# 		base.extend ClassMethods
# 	end
#
# 	module ClassMethods
# 		def traits(*attrs)
# 			@traits ||= []
# 			@traits += attrs
# 			attrs.each do |attr|
# 				class_eval %{
#           def self.#{attr}(string = nil)
#             @#{attr} = string || @#{attr}
#           end
#           def self.#{attr}=(string = nil)
#             #{attr}(string)
#           end
#         }
# 			end
# 			@traits
# 		end
#
# 		def inherited(subclass)
# 			(["traits"] + traits).each do |t|
# 				ivar = "@#{t}"
# 				subclass.instance_variable_set(
# 						ivar,
# 						instance_variable_get(ivar)
# 				)
# 			end
# 		end
# 	end
#
# end