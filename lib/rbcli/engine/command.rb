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


module Rbcli::CmdLibrary
	def self.extended klass
		klass.instance_variable_set :@commands, {}
	end

	def inherited subklass
		subklass.instance_variable_set :@data, {
				description: nil,
				usage: nil,
				action: nil,
				paramlist: {},
				remote_permitted: false
		}
		@commands[subklass.name.downcase] = subklass.new
	end

	def data; self.instance_variable_get :@data; end

	def commands
		@commands
	end

end


class Rbcli::Command

	#include InheritableTraits
	#traits :description
	extend Rbcli::CmdLibrary

	def data; self.class.data; end

	##
	# Interface Functions
	##
	def self.description desc;                @data[:description] = desc; end
	def self.usage usage;                     @data[:usage] = usage; end
	def self.action &block;                   @data[:action] = block; end
	def self.remote_permitted;                @data[:remote_permitted] = true; end
	def self.remote_permitted?;               @data[:remote_permitted]; end
	def self.config_defaults filename;        Rbcli::Config::add_defaults(filename); end
	def self.config_default *params;          Rbcli::Config::add_default *params; end
	def self.parameter name, description, short: nil, type: :boolean, default: nil, required: false, permitted: nil, prompt: nil
		default ||= false if (type == :boolean || type == :bool || type == :flag)
		@data[:paramlist][name.to_sym] = {
				description: description,
				type: type,
				default: default,
				required: required,
				permitted: permitted,
				short: short,
				prompt: prompt
		}
	end

	def self.extern path: nil, envvars: nil, &block
		if path == :default
			callerscript = caller_locations.first.absolute_path
			path = "#{File.dirname(callerscript)}/scripts/#{File.basename(callerscript, ".*")}.sh"
		end
		block = nil unless block_given?
		require 'rbcli/features/scriptwrapper'
		@data[:extern] = Rbcli::Scriptwrapper.new path, envvars, block
	end

	def self.script path: nil, envvars: nil
		if path == :default or path.nil?
			callerscript = caller_locations.first.absolute_path
			path = "#{File.dirname(callerscript)}/scripts/#{File.basename(callerscript, ".*")}.sh"
		end
		require 'rbcli/features/scriptwrapper'
		@data[:script] = Rbcli::Scriptwrapper.new path, envvars, nil, true
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

		raise Exception.new("Command #{cmd} can only have one of `action`, `script`, or `extern` defined.") if (@commands[cmd].data[:extern] or @commands[cmd].data[:script]) and @commands[cmd].data[:action]

		if cliopts[:remote_exec]
			Rbcli::RemoteExec.new(@commands[cmd], cliopts[:remote_exec], cliopts[:identity], params, args, global_opts, config).run
			#remote_exec @commands[cmd], params, args, global_opts, config
			return
		end

		@commands[cmd].data[:extern].execute params, args, global_opts, config unless @commands[cmd].data[:extern].nil?
		@commands[cmd].data[:script].execute params, args, global_opts, config unless @commands[cmd].data[:script].nil?
		@commands[cmd].data[:action].call params, args, global_opts, config unless @commands[cmd].data[:action].nil?
	end

	##
	# Returns all descriptions for display in CLI help
	##
	def self.descriptions indent_size, justification
		#descmap = @commands.map { |name, klass| [name, klass.description] }.to_h
		@commands.map do |name, cmdobj|
			desc = ''
			if Rbcli.configuration(:me, :remote_execution) and cmdobj.remote_permitted?
				indent_size -= 3
				indent_size.times { desc << ' ' }
				desc << '*  '
			else
				indent_size.times { desc << ' ' }
			end
			desc << name.ljust(justification)
			desc << cmdobj.class.data[:description]
		end.join("\n")
	end

	##
	# This method reads the parameters provided by the class and parses them from the CLI
	##
	def self.parseopts *args
		params = @data[:paramlist]
		command_name = self.name.split('::')[-1].downcase
		command_desc = @data[:description]
		command_usage = @data[:usage]
		optx = Trollop::options do
			data = Rbcli.configuration(:me)
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
				opt name, opts[:description], type: opts[:type], default: opts[:default], required: (opts[:prompt].nil? and opts[:required]), permitted: opts[:permitted], short: opts[:short]
			end if params.is_a? Hash
		end
		optx[:args] = ARGV
		params.each do |name, data|
			given_symbol = (name.to_s + '_given').to_sym
			if data[:prompt] and not (optx.key?(given_symbol) and optx[given_symbol])
				if data[:type] == :bool or data[:type] == :boolean or data[:type] == :flag
					answer = 'INVALID_STRING'
					while answer.downcase != 'y' and answer.downcase != 'n' and answer.downcase != ''
						print 'Invalid entry. '.red unless answer == 'INVALID_STRING'
						print data[:prompt] + " (#{(data[:default]) ? 'Y/n' : 'y/N'}): "
						answer = gets.chomp
						if answer.downcase == 'y'
							optx[name] = true
						elsif answer.downcase == 'n'
							optx[name] = false
						elsif answer.downcase == ''
							optx[name] = data[:default]
						end
					end
				elsif data[:type] == :string
					print data[:prompt]
					print " (default: \"#{data[:default]}\"): " unless data[:default].nil?
					answer = gets.chomp
					answer = data[:default] if answer.empty?
					optx[name] = answer
				end
			end
		end
		optx
	end

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