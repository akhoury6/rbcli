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

module RBCliTool
	class Project

		def initialize path, template_vars = {}
			@skelpath = "#{File.dirname(__FILE__)}/../../skeletons/project"
			@minipath = "#{File.dirname(__FILE__)}/../../skeletons/mini/executable"
			@micropath = "#{File.dirname(__FILE__)}/../../skeletons/micro/executable"

			@dest = path
			@template_vars = template_vars
		end

		def create force = false
			return false if project_exists? and not force
			src = @skelpath

			# Create Top Level Folder (TLF)
			FileUtils.mkdir_p @dest

			# Create project structure
			%w(
				application/commands
				application/commands/scripts
				config
				userconf
				exe
				hooks
				spec
				lib
			).each do |folder|
				FileUtils.mkdir_p "#{@dest}/#{folder}"
				FileUtils.touch "#{@dest}/#{folder}/.keep"
			end

			# Create executable
			RBCliTool.cp_file "#{src}/exe/executable", "#{@dest}/exe/#{@template_vars[:cmdname]}", @template_vars
			FileUtils.chmod 0755, "#{@dest}/exe/#{@template_vars[:cmdname]}"

			# Create files for Gem package
			Dir.entries(src).each do |file|
				next if File.directory? "#{src}/#{file}"
				if file == "untitled.gemspec"
					RBCliTool.cp_file "#{src}/#{file}", "#{@dest}/#{@template_vars[:cmdname]}.gemspec", @template_vars
				else
					RBCliTool.cp_file "#{src}/#{file}", "#{@dest}/", @template_vars
				end
			end

			# Create default config
			Dir.glob "#{src}/config/*.rb" do |file|
				RBCliTool.cp_file file, "#{@dest}/config/", @template_vars
			end

			# Create application options
			RBCliTool.cp_file "#{src}/application/options.rb", "#{@dest}/application/options.rb", @template_vars

			true
		end

		def create_mini force = false
			return false if project_exists? and not force
			RBCliTool.cp_file @minipath, @dest, @template_vars
		end

		def create_micro force = false
			return false if project_exists? and not force
			RBCliTool.cp_file @micropath, @dest, @template_vars
		end

		def exists?
			Project::find_root(@dest)
		end

		def self.find_root path
			# We look for the .rbcli file in the current tree and return the root path
			searchpath = path
			while !searchpath.empty?
				return searchpath if File.directory? searchpath and File.exists? "#{searchpath}/.rbcli"
				spath = searchpath.split('/')
				searchpath = (spath.length == 2) ? '/' : spath[0..-2].join('/')
			end
			false
		end
	end

end