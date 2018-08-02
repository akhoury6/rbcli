# <a name="storage_subsystems"></a>Storage Subsystems

```ruby
Rbcli::Configurate.storage do
	local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true                                                   # (Optional) Creates a hash that is automatically saved to a file locally for state persistance. It is accessible to all commands at  Rbcli.local_state[:yourkeyhere]
	remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: true        # (Optional) Creates a hash that is automatically saved to a DynamoDB table. It is recommended to keep halt_on_error=true when using a shared state.
end
```

## <a name="local_state"></a> Local State

RBCli's local state storage gives you access to a hash that is automatically persisted to disk when changes are made.

Once configured you can access it with a standard hash syntax:

```ruby
Rbcli.local_state[:yourkeyhere]
```

For performance reasons, the only methods available for use are:

Hash native methods:

* `[]` (Regular hash syntax. Keys are accessed via either symbols or strings indifferently.)
* `[]=` (Assignment operator)
* `delete`
* `each`
* `key?`

Additional methods:

* `commit`
	* Every assignment to the top level of the hash will result in a write to disk (for example: `Rbcli.local_state[:yourkey] = 'foo'`). If you are manipulating nested hashes, you can trigger a save manually by calling `commit`.
* `clear`
	* Resets the data back to an empty hash.
* `refresh`
	* Loads the most current version of the data from the disk
* `disconnect`
	* Removes the data from memory and sets `Rbcli.local_state = nil`. Data will be read from disk again on next access.


Every assignment will result in a write to disk, so if an operation will require a large number of assignments/writes it should be performed to a different hash before beign assigned to this one.


### Configuration Parameters

```ruby
Rbcli::Configurate.storage do
	local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true                                   # (Optional) Creates a hash that is automatically saved to a file locally for state persistance. It is accessible to all commands at  Rbcli.local_state[:yourkeyhere]
end
```

There are three parameters to configure it with:
* The `path` as a string (self-explanatory)
* `force_creation`
	* This will attempt to create the path and file if it does not exist (equivalent to an `mkdir -p` and `touch` in linux)
* `halt_on_error`
	* RBCli's default behavior is to raise an exception if the file can not be created, read, or updated at any point in time
	* If this is set to `false`, RBCli will silence any errors pertaining to file access and will fall back to whatever data is available. Note that if this is enabled, changes made to the state may not be persisted to disk.
		* If creation fails and file does not exist, you start with an empty hash
		* If file exists but can't be read, you will have an empty hash
		* If file can be read but not written, the hash will be populated with the data. Writes will be stored in memory while the application is running, but will not be persisted to disk.

## <a name="remote_state">Remote State

RBCli's remote state storage gives you access to a hash that is automatically persisted to a remote storage location when changes are made. It has locking built-in, meaning that multiple users may share remote state without any data consistency issues!

Once configured you can access it with a standard hash syntax:

```ruby
Rbcli.remote_state[:yourkeyhere]
```

This works the same way that [Local State](#local_state) does, with the same performance caveats (try not to do many writes!).

Note that all state in Rbcli is __lazy-loaded__, so no connections will be made until your code attempts to access the data.

### DynamoDB Configuration

Before DynamoDB can be used, AWS API credentials have to be created and made available. RBCli will attempt to find credentials from the following locations in order:

1. User's config file
2. Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. User's AWSCLI configuration at `~/.aws/credentials`

For more information about generating and storing AWS credentials, see [Configuring the AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

```ruby
Rbcli::Configurate.storage do
	remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: true        # (Optional) Creates a hash that is automatically saved to a DynamoDB table. It is recommended to keep halt_on_error=true when using a shared state.
end
```

These are the parameters:
* `table_name`
	* The name of the DynamoDB table to use.
* `region`
	* The AWS region that the database is located
* `force_creation`
	* Creates the DynamoDB table if it does not already exist
* `halt_on_error`
	* Similar to the way [Local State](#local_state) works, setting this to `false` will silence any errors in connecting to the DynamoDB table. Instead, your application will simply have access to an empty hash that does not get persisted anywhere.
	* This is good for use cases that involve using this storage as a cache to "pick up where you left off in case of failure", where a connection error might mean the feature doesn't work but its not important enough to interrupt the user.
* `locking`
	* This enables locking, for when you are sharing state between different instances of the application. For more information see the [section below](#distributed_locking).

### <a name="distributed_locking">Distributed Locking and State Sharing

Distributed Locking allows a remote state to be shared among multiple users of the application without risk of data corruption. To use it, simply set the  `locking:` parameter to `true` when enabling remote state (see above).

This is how locking works:

1. The application attempts to acquire a lock on the remote state when you first access it
2. If the backend is locked by a different application, wait and try again
3. If it succeeds, the lock is held and refreshed periodically
4. When the application exits, the lock is released
5. If the application does not refresh its lock, or fails to release it when it exits, the lock will automatically expire within 60 seconds
6. If another application steals the lock (unlikely but possible), and the application tries to save data, a `StandardError` will be thrown
7. You can manually attempt to lock/unlock by calling `Rbcli.remote_state.lock` or `Rbcli.remote_state.unlock`, respectively.

#### Auto-locking vs Manual Locking

Remember: all state in Rbcli is lazy-loaded. Therefore, RBCli wll only attempt to lock the data when you first try to access it. If you need to make sure that the data is locked before executing a block of code, use:

```ruby
Rbcli.remote_state.refresh
```

to force the lock and retrieve the latest data. You can force an unlock by calling:

```ruby
Rbcli.remote_state.disconnect
```
