# Remote Execution

RBCli can be configured to execute commands on a remote machine via SSH instead of locally.

Currently, only `script` and `extern` commands are supported.

## Configuration

To allow remote execution, go to `config/general.rb` and change the following line to `true`:

```ruby
remote_execution permitted: false
```

Then, for each command that you would like to enable remote execution for, add the following directive to the command class declaration:

```ruby
remote_permitted
```

## Usage

Your end users can now execute a command remotely by specifying the connection string and credentials on the command line as follows:

```bash
mytool --remote-exec [user@]host[:port] --identity (/path/to/private/ssh/key or password) <command>
# or
mytool -r [user@]host[:port] -i (/path/to/private/ssh/key or password) <command>
```

Some valid examples are:

```bash
mytool -r example.com -i myPassword showuserfiles -u MyUser
mytool -r root@server.local -i ~/.ssh/id_rsa update
mytool -r admin@172.16.0.1:2202 -i ~/.ssh/mykey cleartemp
```

If the end user is unsure of which commands can or can not be executed remotely, they can check by running `mytool -h`. Commands that have remote execution enabled will have an asterisk (*) by their name:

```bash
$ mytool -h
A simple command line tool.
For more information on individual commands, run `mytool <command> -h`.

Usage:
      foo [options] command [parameters]

Commands:
      bar                  TODO: Description goes here
   *  baz                  TODO: Description goes here

...
```

In this example, the command `baz` is available for remote execution
