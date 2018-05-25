require 'trollop'

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
				opt name.to_sym, opts[:description], type: opts[:type], default: opts[:default], required: opts[:required]
			end
			opt :json_output, 'Output result in machine-friendly JSON format', :type => :boolean, :default => false if data[:allow_json]
			opt :config_file, 'Specify a config file manually', :type => :string, :default => data[:config_userfile]
			opt :generate_config, 'Generate a new config file' #defaults to false
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
			Rbcli.configuration[:post_hook].call @cliopts unless Rbcli.configuration[:pre_hook].nil?
		else
			Trollop::die "Unknown subcommand #{@cmd[0].inspect}"
		end

	end

	def self.opts
		@cliopts
	end

	def self.cmd
		@cmd
	end

end

module Rbcli
	def self.parse
		Rbcli::Parser::parse
	end
end