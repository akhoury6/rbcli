##################################################################################
#     RBCli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2018 Andrew Khoury                                           #
#                                                                                #
#     This program is free software: you can redistribute it and/or modify       #
#     it under the terms of the GNU General Public License as published by       #
#     the Free Software Foundation, either version 3 of the License, or          #
#     (at your option) any later version.                                        #
#                                                                                #
#     This program is distributed in the hope that it will be useful,            #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#     GNU General Public License for more details.                               #
#                                                                                #
#     You should have received a copy of the GNU General Public License          #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.     #
#                                                                                #
#     For questions regarding licensing, please contact andrew@blacknex.us        #
##################################################################################

require 'aws-sdk-dynamodb'
require 'macaddr'
require 'digest/sha2'
require 'rufus-scheduler'

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

		def initialize dynamodb_table, region, aws_access_key_id, aws_secret_access_key, locking: false, lock_timeout: 60
			@region = region
			@dynamo_table_name = dynamodb_table
			@item_name = Rbcli::configuration[:scriptname]
			@locking = locking
			@scheduler = nil
			@lock_timeout = lock_timeout
			@exit_code_set = false
			@should_unlock_at_exit = false

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
			lock_or_wait
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
			raise StandardError "DynamoDB has been locked by another user since the last change. Please try again later." if locked?
			lock_or_wait
			@dynamo_client.put_item(
					{
							table_name: @dynamo_table_name,
							item: datahash.merge({'Script Name' => @item_name})
					}
			)
		end

		def lock
			@dynamo_client.put_item(
					{
							table_name: @dynamo_table_name,
							item: {
									'Script Name' => "#{@item_name}_lock",
									'locked' => true,
									'locked_until' => (Time.now + @lock_timeout).getutc.strftime('%s'),
									'locked_by' => Digest::SHA2.hexdigest(Mac.addr)
							}
					}
			)
		end

		def unlock
			@dynamo_client.put_item(
					{
							table_name: @dynamo_table_name,
							item: {
									'Script Name' => "#{@item_name}_lock",
									'locked' => false,
									'locked_until' => Time.now.getutc.strftime('%s'),
									'locked_by' => false
							}
					}
			)
			@scheduler.shutdown :kill if @scheduler
			@should_unlock_at_exit = false
			@scheduler = nil
		end

		def locked?
			lockdata = get_lockdata
			(lockdata['locked']) and (lockdata['locked_until'].to_i > Time.now.getutc.to_i) and (lockdata['locked_by'] != Digest::SHA2.hexdigest(Mac.addr))
		end

		def lock_or_wait recursed = false
			return true unless @locking
			delay_in_seconds = 2
			lockdata = get_lockdata

			should_claim = false

			# First, we identify if the lock is active
			if lockdata['locked']
				# If the lock is not ours, we have to check the expiration
				if lockdata['locked_by'] != Digest::SHA2.hexdigest(Mac.addr)
					# If the lock is not ours, and it has expired, we claim it
					if lockdata['locked_until'].to_i < Time.now.getutc.to_i
						should_claim = true
						# If the lock data is not ours and has not expired, we wait and try again
					else
						print 'Acquiring lock on DynamoDB. Please wait..' unless recursed
						print '.'
						sleep delay_in_seconds
						lock_or_wait true
					end

					# If the lock is ours, we check the expiry
				else
					# If the lock is ours and is close to expiry or has expired, we refresh it
					if lockdata['locked_until'].to_i < (Time.now - (@lock_timeout / 10)).getutc.to_i
						should_claim = true
						# If the lock is ours and is not near expiry, do nothing
					else
						# Do nothing! But do finish the string that's shown to the user
						puts 'done!' if recursed
					end
				end
			else # If clearly unlocked, we claim it
				should_claim = true
			end


			if should_claim
				# We attempt to get a lock then validate our success
				lock
				# If we succeeded then we set up a scheduler to ensure we keep it
				lockdata = get_lockdata
				if (lockdata['locked_by'] == Digest::SHA2.hexdigest(Mac.addr)) and (lockdata['locked_until'].to_i > Time.now.getutc.to_i)
					# Of course, if the scheduler already exists, we don't bother
					unless @scheduler
						@scheduler ||= Rufus::Scheduler.new
						@scheduler.every "#{@lock_timeout - 2}s" do
							lock
						end
						# We also make sure we release the lock at exit. In case this doesn't happen, the lock will expire on its own
						@should_unlock_at_exit = true
						unless @exit_code_set
							at_exit {unlock if @should_unlock_at_exit}
							@exit_code_set = true
						end
					end
					puts 'done!' if recursed
					# If we failed locking then we need to try the process all over again
				else
					print 'Error: Failed to lock DynamoDB. Retrying...'
					sleep delay_in_seconds
					lock_or_wait true
				end

			end

		end

		# END lock_or_wait

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

		def get_lockdata
			item = @dynamo_client.get_item(
					{
							key: {'Script Name' => "#{@item_name}_lock"},
							table_name: @dynamo_table_name
					}
			).item
			if item.nil?
				lock
				return get_lockdata
			end
			item
		end

	end
end
