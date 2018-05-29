require 'fileutils'
require 'json'

## Configuration Interface
module Rbcli::ConfigurateStorage
	@data[:localstate] = nil

	def self.local_state path, force_creation: false, halt_on_error: false
		#@data[:localstate] = Rbcli::LocalState.new path, force_creation: force_creation, halt_on_error: halt_on_error
		@data[:localstate] = Rbcli::State::StateStorage.include(Rbcli::State::LocalStorage).new(path, force_creation: force_creation, halt_on_error: halt_on_error)
	end
end

## User Interface
module Rbcli
	def self.local_state
		Rbcli::ConfigurateStorage.data[:localstate]
	end
end

## Local State Module
module Rbcli::State

	module LocalStorage

		def file_exists?
			File.exists? @path
		end

		def create_file
			begin
				FileUtils.mkdir_p File.dirname(@path)
				FileUtils.touch @path
			rescue Errno::EACCES => e
				error "Can not create file #{@path}. Please make sure the directory is writeable." if @halt_on_error
			end
		end

		def load
			begin
				@data = JSON.parse(File.read(@path)).deep_symbolize!
			rescue Errno::ENOENT, Errno::EACCES => e
				error "Can not read from file #{@path}. Please make sure the file exists and is readable." if @halt_on_error
			end
		end

		def save
			begin
				File.write @path, JSON.dump(@data)
			rescue Errno::ENOENT, Errno::EACCES => e
				error "Can not write to file #{@path}. Please make sure the file exists and is writeable." if @halt_on_error
			end
		end

		def error text
			raise LocalStateError.new "Error accessing local state: #{text}"
		end

		class LocalStateError < StandardError; end
	end



end
