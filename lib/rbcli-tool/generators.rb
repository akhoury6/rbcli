module RBCliTool
	class Generator
		def self.inherited(subklass)
			@@types ||= {}
			@@types[subklass.name.downcase.split('::')[1]] = subklass
		end

		def initialize type = nil, root_path = nil, template_vars = {}
			@generator = @@types[type.to_s.downcase].new root_path, template_vars
		end

		def run
			@generator.run
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


end