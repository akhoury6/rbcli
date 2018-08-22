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
	@default_target = nil

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

	def self.make_logger
		if Rbcli::config[:logger][:log_target].nil?
			target = '/dev/null'
		elsif Rbcli::config[:logger][:log_target].downcase == 'stdout'
			target = STDOUT
		elsif Rbcli::config[:logger][:log_target].downcase == 'stderr'
			target = STDERR
		else
			target = Rbcli::config[:logger][:log_target]
		end
		@logger = Logger.new(target)
		@logger.level = Rbcli::config[:logger][:log_level]

		original_formatter = Logger::Formatter.new
		@logger.formatter = proc do |severity, datetime, progname, msg|
			original_formatter.call(severity, datetime, progname || caller_locations[3].path.split('/')[-1], msg.dump)
		end
		@logger
	end

	def self.log
		@logger || self.make_logger
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
