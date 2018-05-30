## Configuration Interface
module Rbcli::ConfigurateStorage
	@data[:remotestate] = nil
	@data[:remotestate_init_params] = nil

	def self.remote_state_dynamodb table_name: nil, region: nil, force_creation: false, halt_on_error: true, locking: false
		raise StandardError "Must decalre `table_name` and `region` to use remote_state_dynamodb" if table_name.nil? or region.nil?
		@data[:remotestate_init_params] = {
				dynamodb_table: table_name,
				region: region,
				locking: locking
		}
		@data[:remotestate] = Rbcli::State::DynamoDBStorage.new(table_name, force_creation: force_creation, halt_on_error: halt_on_error)
	end
end

## User Interface
module Rbcli
	def self.remote_state
		Rbcli::ConfigurateStorage.data[:remotestate]
	end
end

## Remote State Module
module Rbcli::State

	class DynamoDBStorage < StateStorage

		# def initialize dynamodb_table, region, force_creation: false, halt_on_error: true
		#
		# 	# Set defaults in Rbcli's config
		# 	Rbcli::State::RemoteStorage::Connectors::DynamoDB.save_defaults
		#
		# 	# Create DynamoDB Connector
		# 	@dynamodb = Rbcli::State::RemoteStorage::Connectors::DynamoDB.new dynamodb_table, region, Rbcli::config[:aws_access_key_id], Rbcli::config[:aws_secret_access_key]
		#
		# 	super dynamodb_table, force_creation: force_creation, halt_on_error: halt_on_error
		# end

		def state_subsystem_init
			@locking = Rbcli::ConfigurateStorage::data[:remotestate_init_params][:locking]
			dynamodb_table = Rbcli::ConfigurateStorage::data[:remotestate_init_params][:dynamodb_table]
			region = Rbcli::ConfigurateStorage::data[:remotestate_init_params][:region]

			# Set defaults in Rbcli's config
			Rbcli::State::RemoteConnectors::DynamoDB.save_defaults

			# Create DynamoDB Connector
			@dynamodb = Rbcli::State::RemoteConnectors::DynamoDB.new dynamodb_table, region, Rbcli::config[:aws_access_key_id], Rbcli::config[:aws_secret_access_key], locking: Rbcli::ConfigurateStorage::data[:remotestate_init_params][:locking]
		end

		def state_exists?
			return false unless make_dynamo_call { @dynamodb.table_exists? }
			make_dynamo_call { @dynamodb.object_exists? }
		end

		def create_state
			make_dynamo_call do
				@dynamodb.create_table
			end
		end

		def load_state
			make_dynamo_call do
				@data = @dynamodb.get_object.deep_symbolize!
			end
		end

		def save_state
			make_dynamo_call do
				@dynamodb.save_object @data
			end
		end

		def lock
			@dynamodb.lock_or_wait if @locking
		end

		def unlock
			@dynamodb.unlock if @locking
		end

		def error text
			raise RemoteStateError.new "Error accessing remote state: #{text}"
		end

		class RemoteStateError < StandardError;
		end

		private

		def make_dynamo_call &block
			begin
				yield
			rescue Aws::Errors::MissingCredentialsError
				error "Missing AWS Credentials: unable to sign in. Please put the credentials in your config file or update them on the local system." if @halt_on_error
			rescue Aws::DynamoDB::Errors::UnrecognizedClientException
				error "Unauthorized AWS Credentials: unable to sign in. Please check the credentials that you are using to make sure they are valid." if @halt_on_error
			rescue
				raise if @halt_on_error
			end
		end

	end

end


require 'rbcli/stateful_systems/storagetypes/remote_state_connectors/dynamodb'
