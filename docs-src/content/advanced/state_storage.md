---
title: "State Storage"
date: 2019-06-20T15:07:21-04:00
draft: false
---

RBCli supports both local and remote state storage. This is done by synchronizing a Hash with either the local disk or a remote database.

## Local State

RBCli's local state storage gives you access to a hash that is automatically persisted to disk when changes are made.

### Configuration

You can configure it in `config/storage.rb`.

```ruby
local_state '/var/mytool/localstate', force_creation: true, halt_on_error: true
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


### Access and Usage

Once configured you can access it with a standard hash syntax in your Standard Commands:

```ruby
Rbcli.local_state[:yourkeyhere]
```

The methods available for use at the top level are as follows:

Hash native methods:

* `[]` (Regular hash syntax. Keys are accessed via either symbols or strings indifferently.)
* `[]=` (Assignment operator)
* `delete`
* `each`
* `key?`

Additional methods:

* `commit`
	* Every assignment to the top level of the hash will result in a write to disk (for example: `Rbcli.local_state[:yourkey] = 'foo'`). However, if you are manipulating nested hashes, these saves will not be triggered. You can trigger them manually by calling `commit`.
* `clear`
	* Resets the data back to an empty hash.
* `refresh`
	* Loads the most current version of the data from the disk
* `disconnect`
	* Removes the data from memory and sets `Rbcli.local_state = nil`. Data will be read from disk again on next access.


Every assignment will result in a write to disk, so if an operation will require a large number of assignments/writes it should be performed to a different hash before beign assigned to this one.


## Remote State

RBCli's remote state storage gives you access to a hash that is automatically persisted to a remote storage location when changes are made. It has optional locking built-in, meaning that multiple users may share remote state without any data consistency issues.

Currently, this feature requires AWS DynamoDB, though other backend systems will be added in the future.

### Configuration

Before DynamoDB can be used, AWS API credentials have to be created and made available. RBCli will attempt to find credentials from the following locations in order:

1. User's config file
2. Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. User's AWSCLI configuration at `~/.aws/credentials`

For more information about generating and storing AWS credentials, see [Configuring the AWS SDK for Ruby][aws_sdk_credentials]. Please make sure that your users are aware that they will need to provide their own credentials to use this feature.

You can configure it in `config/storage.rb`.

```ruby
remote_state_dynamodb table_name: 'mytable', region: 'us-east-1', force_creation: true, halt_on_error: true, locking: false
```

These are the parameters:

* `table_name`
	* The name of the DynamoDB table to use.
* `region`
	* The AWS region that the database is located
* `force_creation`
	* Creates the DynamoDB table if it does not already exist
* `halt_on_error`
	* Similar to the way [Local State](#local-state) works, setting this to `false` will silence any errors in connecting to the DynamoDB table. Instead, your application will simply have access to an empty hash that does not get persisted anywhere.
	* This is good for use cases that involve using this storage as a cache, where a connection error might mean the feature doesn't work but its not important enough to interrupt the user.
* `locking`
	* Setting this to `true` enables locking, meaning only one instance of your application can access the shared data at any given time. For more information see [Distributed State Locking][distributed_state_locking].


### Access and Usage

Once configured you can access it with a standard hash syntax:

```ruby
Rbcli.remote_state[:yourkeyhere]
```

This works the same way that [Local State](#local-state) does, with the same performance caveats (try not to write too frequently).

Note that all state in Rbcli is __lazy-loaded__, so no connections will be made until your code attempts to access the data even if the feature is enabled.

For more information on the available commands, see the documentation on [Local State](#local-state)


[aws_sdk_credentials]: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html
[distributed_state_locking]: {{< ref "advanced/distributed_state_locking" >}}
