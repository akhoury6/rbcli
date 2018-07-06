require 'erb'

module RBCliTool
	class ERBRenderer
		def initialize filename, varlist
			@filename = filename
			@vars = varlist
		end

		def render
			ERB.new(File.read(@filename)).result(binding)
		end
	end

	def self.cp_file src, dest, template_vars = nil
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
end