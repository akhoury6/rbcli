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
			project_exists?
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

		private

		def project_exists?
			# If the specified file already exists...
			return true if File.exists? @dest

			# Or if the .rbcli file exists anywhere in the tree, we know that we are in a subdirectory of a project
			Project::find_root(@dest)
		end
	end

end