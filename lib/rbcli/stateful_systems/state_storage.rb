require 'fileutils'
require 'json'


module Rbcli::State

	## Main State Class
	class StateStorage

		def initialize path, force_creation: false, halt_on_error: true
			@path = File.expand_path path
			@halt_on_error = halt_on_error

			base_data = {
					data: {},
					rbcli: {}
			}

			if file_exists?
				load
			elsif force_creation
				create_file
				@data = base_data
				save
			else
				raise StandardError "State path #{@path} does not exist or can not be accessed." if @halt_on_error
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

		def to_s
			to_h.to_s
		end

		# For framework's internal use

		def rbclidata key = nil
			return @data[:rbcli][key.to_sym] unless key.nil?
			@data[:rbcli]
		end

		def set_rbclidata key, value
			@data[:rbcli][key.to_sym] = value
			save
		end

		private

		def include_correct_module
			if @path
			end

		end

	end
end
