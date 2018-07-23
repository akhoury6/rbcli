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