#TODO: Change this once the changes have been merged into trollop gem proper
require "rbcli/util/trollop"

module Rbcli::Parser

	@cliopts = nil

	def self.parse
		@cliopts = Trollop::options do
			data = Rbcli.configuration
			version "#{data[:scriptname]} version: #{data[:version]}"
			banner <<-EOS
#{data[:description]}
For more information on individual commands, run `#{data[:scriptname]} <command> -h`.

Usage:
      #{data[:scriptname]} [options] command [parameters]

Commands:
#{Rbcli::Command.descriptions 6, 21}

[options]:
			EOS
			data[:options].each do |name, opts|
				opts[:default] = nil unless opts.key? :default
				opts[:required] = false unless opts.key? :required
				opts[:permitted] = nil unless opts.key? :permitted
				opt name.to_sym, opts[:description], type: opts[:type], default: opts[:default], required: opts[:required], permitted: opts[:permitted]
			end
			opt :json_output, 'Output result in machine-friendly JSON format', :type => :boolean, :default => false if data[:allow_json]
			opt :config_file, 'Specify a config file manually', :type => :string, :default => data[:config_userfile] unless data[:config_userfile].nil?
			opt :generate_config, 'Generate a new config file' unless data[:config_userfile].nil? #defaults to false
			stop_on Rbcli::Command.commands.keys
		end

		@cmd = [ARGV.shift] # get the subcommand
		if @cliopts[:generate_config]
			Rbcli::Config::generate_userconf @cliopts[:config_file]
			puts "User config generated at #{@cliopts[:config_file]} using default values."
		elsif @cmd[0].nil?
			if Rbcli.configuration[:default_action].nil?
				Trollop::educate
			else
				Rbcli.configuration[:default_action].call @cliopts
			end
		elsif Rbcli::Command.commands.key? @cmd[0]
			@cmd << Rbcli::Command.commands[@cmd[0]].parseopts

			Rbcli.configuration[:pre_hook].call @cliopts unless Rbcli.configuration[:pre_hook].nil?
			Rbcli::Command.runcmd(@cmd.shift, @cmd[0], @cliopts)
			Rbcli.configuration[:post_hook].call @cliopts unless Rbcli.configuration[:post_hook].nil?
		else
			Trollop::die "Unknown subcommand #{@cmd[0].inspect}"
		end

	end

end

module Rbcli
	def self.parse
		if Rbcli.configuration[:first_run]
			if Rbcli.local_state
				if Rbcli.local_state.rbclidata.key? :first_run
					Rbcli::Parser::parse
				else
					Rbcli.configuration[:first_run].call
					Rbcli.local_state.set_rbclidata :first_run, true
					Rbcli::Parser::parse unless Rbcli.configuration[:halt_after_first_run]
				end
			else
				raise StandardError.new "Error: Can not use `first_run` without also configuring `local_state`."
			end
		else
			Rbcli::Parser::parse
		end
	end
end