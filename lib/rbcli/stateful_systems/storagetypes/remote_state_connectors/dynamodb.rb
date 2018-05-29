require 'aws-sdk-dynamodb'

module Rbcli::State::RemoteConnectors
	class DynamoDB

		def self.save_defaults aws_access_key_id: nil, aws_secret_access_key: nil
			Rbcli::Config::add_categorized_defaults :dynamodb_remote_state, 'Remote State Settings - requires DynamoDB', {
					access_key_id: {
							description: 'AWS Access Key ID -- leave as null to look for AWS credentials on system. See: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html',
							value: aws_access_key_id
					},
					secret_access_key: {
							description: 'AWS Secret Access Key -- leave as null to look for AWS credentials on system.',
							value: aws_secret_access_key
					}
			}
		end

		def initialize dynamodb_table, region, aws_access_key_id, aws_secret_access_key
			@region = region
			@dynamo_table_name = dynamodb_table
			@item_name = Rbcli::configuration[:scriptname]

			@dynamo_client = Aws::DynamoDB::Client.new(
					region: @region,
					access_key_id: aws_access_key_id,
					secret_access_key: aws_secret_access_key
			)
		end

		def create_table
			# We only need to create the table
			unless table_exists?
				print "Creating DynmoDB Table. Please wait..."
				@dynamo_client.create_table(
						{
								attribute_definitions: [
										{
												attribute_name: "Script Name",
												attribute_type: "S"
										}
								],
								key_schema: [
										{
												attribute_name: "Script Name",
												key_type: "HASH"
										}
								],
								provisioned_throughput: {
										read_capacity_units: 5,
										write_capacity_units: 5,
								},
								table_name: @dynamo_table_name,
						}
				)
				wait_for_table_creation
			end
		end

		def table_exists?
			@dynamo_client.list_tables.table_names.to_a.include? @dynamo_table_name
		end

		def object_exists?
			begin
				item = @dynamo_client.get_item(
						{
								key: {'Script Name' => @item_name},
								table_name: @dynamo_table_name,
						}
				)
				return (!item.item.nil?)
			rescue Aws::DynamoDB::Errors::ResourceNotFoundException
				return false
			end
		end

		def get_object
			item = @dynamo_client.get_item(
					{
							key: {'Script Name' => @item_name},
							table_name: @dynamo_table_name,
					}
			).item
			item.delete 'Script Name'
			item
		end

		def save_object datahash
			@dynamo_client.put_item(
					{
							table_name: @dynamo_table_name,
							item: datahash.merge({'Script Name' => @item_name})
					}
			)
		end

		private

		def wait_for_table_creation
			delay_in_seconds = 2
			active = false
			while not active
				sleep delay_in_seconds
				print '.'
				#@dynamo_table = @dynamo_db.table @dynamo_table_name
				begin
					result = @dynamo_client.describe_table({table_name: @dynamo_table_name})
					active = (result.table.table_status == "ACTIVE")
						#active = (@dynamo_table.table_status == "ACTIVE")
				rescue Aws::DynamoDB::Errors::ResourceNotFoundException
					# We want to ignore this exception since we expect the table to be created at some point.
					# In real usage this error likely won't occur, and instead we will see table_status == "CREATING"
				end
			end
			puts "done!"
		end

	end
end
