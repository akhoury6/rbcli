####
# Logging Module
####
# The logging module automatically initializes and formats the Ruby logger, and makes it available for the application.
# Note that all of the built-in log commands are available.
#
# Additionally, a convenience function Rbcli::debug is available, which does not log, but prints an object.to_s
# in red so that it is easily identifiable in the coutput.
#
# Usage
#
# Rbcli::log.info {'Some Message'}
#
# Rbcli::debug myobj
#
####

require 'logger'
require 'colorize'

module Rbcli::Logger

	@default_level = 'info'
	@default_target = 'stderr'

	def self.save_defaults level: nil, target: nil
		@default_level = level if level
		@default_target = target if target

		Rbcli::Config::add_categorized_defaults :logger, 'Log Settings', {
				log_level: {
						description: '0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN. Set to null (~) to disable logging.',
						value: @default_level || nil
				},
				log_target: {
						description: 'STDOUT, STDERR, or a file path. Set to null (~) to disable logging.',
						value: @default_target || nil
				}
		}
	end
	self.save_defaults


	if Rbcli::config[:logger][:log_target].downcase == 'stdout'
		target = STDOUT
	elsif Rbcli::config[:logger][:log_target].downcase == 'stderr'
		target = STDERR
	elsif Rbcli::config[:logger][:log_target].nil?
		target = '/dev/null'
	else
		target = Rbcli::config[:logger][:log_target]
	end
	target = '/dev/null' if Rbcli::config[:logger][:log_level].nil?
	@logger = Logger.new(target)
	@logger.level = Rbcli::config[:logger][:log_level]

	original_formatter = Logger::Formatter.new
	@logger.formatter = proc do |severity, datetime, progname, msg|
		original_formatter.call(severity, datetime, progname || caller_locations[3].path.split('/')[-1], msg.dump)
	end

	def self.log
		@logger
	end

end

module Rbcli
	def self.log
		Rbcli::Logger::log
	end

	def self.debug obj
		puts obj.to_s.red
	end
end