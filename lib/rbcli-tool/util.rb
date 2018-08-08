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

require 'erb'

module RBCliTool
	class ERBRenderer
		def initialize filename, varlist
			@filename = filename
			@vars = varlist
		end

		def render
			ERB.new(File.read(@filename), nil, '-').result(binding)
		end
	end

	def self.cp_file src, dest, template_vars = nil
		dest = "#{dest}#{src.split('/')[-1]}" if dest.end_with? '/'
		if File.exists? dest
			puts "File #{dest} already exists. Please delete it and try again."
		else
			print "Generating file " + dest + " ... "

			if template_vars
				renderer = ERBRenderer.new src, template_vars
				File.open(dest, 'w') {|file| file.write renderer.render}
			else
				FileUtils.cp src, dest
			end

			FileUtils.rm_f "#{File.dirname(dest)}/.keep" if File.exists? "#{File.dirname(dest)}/.keep"
			puts "Done!"
		end
	end

	def self.continue_confirmation text
		puts text
		print "Continue? (Y/n):  "
		input = gets
		unless input[0].downcase == 'y'
			puts "\n Aborting..."
			exit 0
		end
	end

	def self.exit_with_error text
		puts text
		exit 1
	end
end