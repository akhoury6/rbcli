####
# Config Module
####
# The config module manages two distinct sets of config: one is the user's, and one is the application's default.
# This allows you to set default values for your configuration files, and can use the default values to generate a
# new user config file at any time by writing them to a file.
#
# Usage
#
# Rbcli::config[:key]
#   Provides access to config file hash values under :key.
#   Note the lowercase 'c' in config, which is different from the rest of the functions below.
#
# Rbcli::Config::set_file(filename, autoload:true, merge_defaults: false)
#   This function allows you to set the path for the user's config file (eg: /etc/myscript/config.yml).
#     autoload will load the file at the same time
#     merge_defaults will fill in missing values in the user's config with default ones
#
# Rbcli::Config::add_defaults(filename)
#   This function loads the contents of a YAML or JSON file into the default config. Used for custom configuration.
#
# Rbcli::Config::load
#   This forces a reload of the config file.
#
# Rbcli::Config::generate_userconf
#   This writes the config defaults to the filename set using the set_file command.
####

require 'yaml'
require 'fileutils'
require 'deep_merge'

module Rbcli
	def self.config
		Rbcli::Config::config
	end
end

module Rbcli::Config

	@config = nil
	@config_file = nil
	@config_defaults = nil
	@merge_defaults = false
	@categorized_defaults = nil
	@loaded = false

	def self.set_userfile filename, merge_defaults: false, required: false
		@config_file = filename
		@merge_defaults = merge_defaults
		@userfile_required = required
		@loaded = false
	end

	def self.add_categorized_defaults name, description, config
		@categorized_defaults ||= {}
		@categorized_defaults[name.to_sym] = {
				description: description,
				config: config
		}

		@config_defaults ||= {}
		@config_defaults[name.to_sym] = {}
		config.each do |k, v|
			@config_defaults[name.to_sym][k.to_sym] = v[:value]
		end
		@loaded = false
	end

	def self.add_default name, description: nil, value: nil
		@config_individual_lines ||= []
		text = "#{name.to_s}: #{value}".ljust(30) + " # #{description}"
		@config_individual_lines.push text unless @config_individual_lines.include? text
		@config_defaults[name.to_sym] = value
		@loaded = false
	end

	def self.add_defaults filename=nil, text: nil
		return unless filename and File.exists? filename
		@config_text ||= ''
		@config_text += "\n" unless @config_text.empty?
		File.readlines(filename).each do |line|
			if (line.start_with? '---' or line.start_with? '...')
				@config_text << "\n\n"
			else
				@config_text << line unless @config_text.include? line
			end
		end if filename and File.exists? filename
		@config_text << "\n\n" << text if text

		@config_defaults ||= {}
		@config_defaults.deep_merge! YAML::load(@config_text).deep_symbolize!
		@loaded = false
	end

	def self.load
		if (! @config_file.nil?) and File.exists? @config_file
			@config = YAML::load(File.read(@config_file)).deep_symbolize!
			@config.deep_merge! @config_defaults if @merge_defaults
		elsif @userfile_required
			puts "User's config file not found at #{@config_file}. Please run this tool with the -g option to generate it."
			exit 1
		else
			@config = @config_defaults
		end
		@loaded = true
		@config
	end

	def self.config
		self.load unless @loaded
		(@config.nil?) ? @config_defaults : @config
	end

	def self.generate_userconf filename
		filepath = "#{(filename) ? filename : "#{Dir.pwd}/config.yml"}"
		File.write filepath, @config_text
		File.open(filepath, 'a') do |f|
			f.puts "# Individual Settings"
			@config_individual_lines.each { |l| f.puts l }
		end if @config_individual_lines


		if @categorized_defaults
			text = ''
			@categorized_defaults.each do |name, opts|
				text += "\n# #{opts[:description]}\n"
				text += "#{name.to_s}:\n"
				opts[:config].each do |opt, v|
					text += "  #{opt.to_s}: #{v[:value]}".ljust(30) + " # #{v[:description]}\n"
				end
			end
			File.open(filepath, 'a') do |f|
				f.puts text
			end
		end
	end

end

