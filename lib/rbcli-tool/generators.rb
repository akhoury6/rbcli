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
	class Generator
		def self.inherited(subklass)
			@@types ||= {}
			@@types[subklass.name.downcase.split('::')[1]] = subklass
		end

		def initialize type = nil, root_path = nil, template_vars = {}
			@generator = @@types[type.to_s.downcase].new root_path, template_vars
		end

		def run *args
			@generator.run *args
		end
	end

	class Command < Generator
		def initialize root_path, template_vars
			@srcpath = "#{File.dirname(__FILE__)}/../../skeletons/project/application/commands/command.erb"
			@dest = "#{root_path}/application/commands/#{template_vars[:name]}.rb"
			@template_vars = template_vars
		end

		def run
			if File.exists? @dest
				RBCliTool.continue_confirmation "The command #{@template_vars[:name]} already exists; contents will be overwritten."
				FileUtils.rm_rf @dest
			end
			RBCliTool.cp_file @srcpath, @dest, @template_vars
		end
	end

	class Extern < Generator
		def initialize root_path, template_vars
			@filepaths = [
					{
							src: "#{File.dirname(__FILE__)}/../../skeletons/project/application/commands/script.erb",
							dest: "#{root_path}/application/commands/#{template_vars[:name]}.rb"
					}, {
							src: "#{File.dirname(__FILE__)}/../../skeletons/project/application/commands/scripts/script.sh",
							dest: "#{root_path}/application/commands/scripts/#{template_vars[:name]}.sh",
							perms: 0755
					}
			]
			@template_vars = template_vars
			#@template_vars[:libsh_path] = Pathname.new("#{File.dirname(__FILE__)}/../../lib-sh/lib-rbcli.sh").cleanpath.to_s  # We clean this path because it will be visible to the user
		end

		def run
			confirmed = false
			@filepaths.each do |file|
				next if file[:dest].end_with? '.sh' and @template_vars[:no_script]
				if File.exists? file[:dest]
					RBCliTool.continue_confirmation "The script command #{@template_vars[:name]} already exists; contents will be overwritten." unless confirmed
					confirmed = true
					FileUtils.rm_rf file[:dest]
				end
				RBCliTool.cp_file file[:src], file[:dest], @template_vars
				File.chmod file[:perms], file[:dest] if file.key? :perms
			end
		end
	end

	class Hook < Generator
		def initialize root_path, hook_type
			@typename = {
					default: 'default_action',
					pre: 'pre_execution',
					post: 'post_execution',
					firstrun: 'first_run'
			}[hook_type]
			@src = "#{File.dirname(__FILE__)}/../../skeletons/project/hooks/#{@typename}.rb"
			@dest = "#{root_path}/hooks/#{@typename}.rb"
		end

		def run
			if File.exists? @dest
				RBCliTool.continue_confirmation "The #{@typename} hook already exists; contents will be overwritten."
				FileUtils.rm_rf @dest
			end
			RBCliTool.cp_file @src, @dest
		end
	end

end