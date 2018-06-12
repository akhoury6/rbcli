class Rbcli::Command
	def self.extern path: nil, envvars: nil, &block
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
		@envvars = envvars
		@block = block
	end

	def execute params, args, global_opts, config
		env_hash = {}
		{
				'__PARAMS' => params,
				'__ARGS' => args,
				'__GLOBAL' => global_opts,
				'__CONFIG' => config
		}.each do |name, hsh|
			hsh.each do |k, v|
				env_hash["#{name}_#{k.upcase}"] = v.to_json
			end
		end

		env_hash.merge!(@envvars.deep_stringify!) unless @envvars.nil?

		if @block
			path = @block.call params, args, global_opts, config
		else
			path = @path
		end

		system(env_hash, path)
	end

end
