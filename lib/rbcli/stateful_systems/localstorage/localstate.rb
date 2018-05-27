require 'fileutils'
require 'json'

## Configuration Interface
module Rbcli::ConfigurateStorage
	@data[:localstate] = nil

	def self.local_state path, force_creation: false, ignore_file_errors: false
		@data[:localstate] = Rbcli::LocalState.new path, force_creation: force_creation, ignore_file_errors: ignore_file_errors
	end
end

## User Interface
module Rbcli
	def self.local_state
		Rbcli::ConfigurateStorage.data[:localstate]
	end
end


## Local State Class
class Rbcli::LocalState

	def initialize path, force_creation: false, ignore_file_errors: false
		@path = File.expand_path path
		@ignore_file_errors = ignore_file_errors

		base_data = {
				data: {},
				rbcli: {}
		}

		if File.exist? @path
			load
		elsif force_creation
			create_file
			@data = base_data
			save
		else
			error "File #{@path} does not exist." unless @ignore_file_errors
			@data = base_data
		end
	end

	def []= key, value
		@data[:data][key.to_sym] = value
		save
		@data[:data][key.to_sym]
	end

	def [] key
		@data[:data][key.to_sym]
	end

	def delete key, &block
		result = @data[:data].delete key.to_sym, block
		save
		result
	end

	def clear
		@data[:data] = {}
		save
	end

	def each &block
		@data[:data].each &block
		save
	end

	def key? key
		@data[:data].key? key.to_sym
	end

	def to_h
		@data[:data]
	end

	# For internal use

	def rbclidata key = nil
		return @data[:rbcli][key.to_sym] unless key.nil?
		@data[:rbcli]
	end

	def set_rbclidata key, value
		@data[:rbcli][key.to_sym] = value
		save
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
			@data = JSON.parse(File.read(@path)).deep_symbolize!
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
