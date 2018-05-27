require 'fileutils'
require 'json'

class Rbcli::LocalState

	def initialize path, force_creation: false, ignore_file_errors: false
		@path = File.expand_path path
		@ignore_file_errors = ignore_file_errors

		if File.exist? @path
			load
		elsif force_creation
			create_file
			@data = {}
			save
		else
			error "File #{@path} does not exist." unless @ignore_file_errors
			@data = {}
		end
	end

	def []= key, value
		@data[key] = value
		save
		@data[key]
	end

	def [] key
		@data[key]
	end

	def delete key, &block
		result = @data.delete key, block
		save
		result
	end

	def each &block
		@data.each &block
		save
	end

	def to_h
		@data
	end

	private

	def create_file
		begin
			FileUtils.mkdir_p File.dirname(@path)
			FileUtils.touch @path
		rescue Errno::EACCES => e
			error "Can not create file #{@path}. Please make sure the directory is writeable." unless @ignore_file_errors
		end
	end

	def load
		begin
			@data = JSON.parse File.read @path
		rescue Errno::ENOENT, Errno::EACCES => e
			error "Can not read from file #{@path}. Please make sure the file exists and is readable." unless @ignore_file_errors
		end
	end

	def save
		begin
			File.write @path, JSON.dump(@data)
		rescue Errno::ENOENT, Errno::EACCES => e
			error "Can not write to file #{@path}. Please make sure the file exists and is writeable." unless @ignore_file_errors
		end
	end

	def error text
		raise Rbcli::LocalStateError.new "Error accessing local state: #{text}"
	end

end

class Rbcli::LocalStateError < StandardError; end
