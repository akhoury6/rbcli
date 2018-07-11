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
				default_user_configs
				exe
				hooks
				spec
			).each do |folder|
				FileUtils.mkdir_p "#{@dest}/#{folder}"
				FileUtils.touch "#{@dest}/#{folder}/.keep"
			end

			# Create executable
			RBCliTool.cp_file "#{src}/exe/executable", "#{@dest}/exe/#{@template_vars[:cmdname]}", @template_vars

			# Create files for Gem package
			Dir.entries(src).each do |file|
				next if File.directory? "#{src}/#{file}"
				RBCliTool.cp_file "#{src}/#{file}", "#{@dest}/", @template_vars
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

		private

		def project_exists?
			# If the specified file already exists...
			return true if File.exists? @dest

			# Or if the .rbcli file exists anywhere in the tree...
			searchpath = @dest
			while !searchpath.empty?
				return searchpath if File.directory? searchpath and File.exists? "#{searchpath}/.rbcli"
				spath = searchpath.split('/')
				searchpath = (spath.length == 2) ? '/' : spath[0..-2].join('/')
			end

			# Otherwise we say the project does not exist
			false
		end
	end

end