class Rbcli::Command
	def self.extern path: nil, envvars: nil, &block
		if path == :default
			callerscript = caller_locations.first.absolute_path
			path = "#{File.dirname(callerscript)}/scripts/#{File.basename(callerscript, ".*")}.sh"
		end
		block = nil unless block_given?
		@extern = Rbcli::Scriptwrapper.new path, envvars, block
	end

	def extern;
		@extern ||= nil
		self.class.instance_variable_get :@extern
	end
end

require 'json'
class Rbcli::Scriptwrapper
	def initialize path, envvars = nil, block = nil
		@path = path
		@envvars = envvars || {}
		@block = block
	end

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

		# IO.popen(env_hash, path) do |io|
		# 	while (line = io.gets) do
		# 		puts line
		# 	end
		# end
		system(env_hash, path)
	end

end
