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

require 'json'
class Rbcli::Scriptwrapper
	def initialize path, envvars = nil, block = nil, script = false
		@path = path
		@envvars = envvars || {}
		@block = block
		@script = script
	end

	attr_reader :path

	def execute params, args, global_opts, config
		####
		#### The following code will flatten one level of the hashes into separate variables
		#### It is deprecated in favor of passing along json to be parsed with JQ
		####
		# env_hash = {}
		# {
		# 		'__PARAMS' => params,
		# 		'__ARGS' => args,
		# 		'__GLOBAL' => global_opts,
		# 		'__CONFIG' => config
		# }.each do |name, hsh|
		# 	hsh.each do |k, v|
		# 		env_hash["#{name}_#{k.upcase}"] = v.to_json
		# 	end
		# end
		# env_hash.merge!(@envvars.deep_stringify!) unless @envvars.nil?

		if @block || @script
			env_hash = {
					'__RBCLI_PARAMS' => params.to_json,
					'__RBCLI_ARGS' => args.to_json,
					'__RBCLI_GLOBAL' => global_opts.to_json,
					'__RBCLI_CONFIG' => config.to_json,
					'__RBCLI_MYVARS' => @envvars.to_json
			}
			if @block
				path = @block.call params, args, global_opts, config
			else
				path = @path
			end
			system(env_hash, path)
		else
			system(@envvars.collect{|k,v| [k.to_s, v]}.to_h, @path)
		end

		# IO.popen(env_hash, path) do |io|
		# 	while (line = io.gets) do
		# 		puts line
		# 	end
		# end
	end

end
