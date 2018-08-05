# Options, Paramters, and Arguments

If you're already an experienced coder, you can jump to the last section of this document, the [Simplified Reference (TLDR)](#simplified-reference-tldr)

## Command Line Structure

In the previous section, you saw two parts of the RBCli command line structure - the executable followed by the command. However, RBCli is capable of more complex interaction. The structure is as follows:

```
toolname [options] command [parameters] argument1 argument2...
```

* __Options__ are command line parameters such as `-f`, or `--force`. These are available globally to every command. You can create your own, though several are already built-in and reserved for RBCli:
	* `--config-file=<filename>` allows specifying a config file location manually.
	* `--generate-config` generates a config file for the user by writing out the defaults to a YAML file. This option will only appear if a config file has been set. The location is configurable, with more on that in the documentation on [User Config Files][user_config_documentation]).
	* `-v / --version` shows the version.
	* `-h / --help` shows the help.
* __Command__ represents the subcommands that you will create, such as `list`, `test`, or `apply`.
* __Parameters__ are the same as options, but only apply to the specific subcommand being executed. In this case only the `-h / --help` parameter is provided automatically.
* __Arguments__ are strings that don't begin with a '-', and are passed to the command's code as an array. These can be used as subcommands or additional parameters for your command. 

So a valid command could look something like these:

```shell
mytool -n load --filename=foo.txt
mytool parse foo.txt
mytool show -l
```

Note that all options and parameters will have both a short and long version of the parameter available for use.

So let's take a look at how we define them.


## Options

You can find the options declarations under `application/options.rb`.  You'll see the example in the code:

```ruby
option :name, 'Give me your name', short: 'n', type: :string, default: 'Jack', required: false, permitted: ['Jack', 'Jill']
```

This won't do for our tool, so let's change it. Remember that these options will be applicable to all of our commands, so lets make it something appropriate:

```ruby
option :color, 'Enable color output', short: 'c', type: :boolean, default: false
```

So now, let's take advantage of this flag in our `list` command. Let's change our block to:

```ruby
	action do |params, args, global_opts, config|
		Dir.glob "./*" do |filename|
			outname = filename.split('/')[1]
			outname += '/' if File.directory? filename

			# We change the color based on the kind of file shown
			if global_opts[:color]
				if File.directory? filename
					outname = outname.light_blue
				elsif File.executable? filename
					outname = outname.light_green
				end
			end
			
			puts outname
		end
	end
```

Notice how we referenced the value by using `global_opts[:color]`. It's that simple. To see it in action, run:

```bash
mytool -c list
```

## Parameters

Parameters work the same way as options, but they are localized to only the selected command. They are declared - as you probably guessed by now - in the command's class. So let's add the following lines to our list command within the class declaration:

```ruby
parameter :sort, 'Sort output alphabetically', type: :boolean, default: false
parameter :all, 'Show hidden files', type: :boolean, default: false
parameter :directoriesfirst, 'Show directories on top', type: :boolean, default: false
```

And let's modify our action block to utilize them:

```ruby
	action do |params, args, global_opts, config|
		filelist = []

		# We include dotfiles if specified
		include_dotfiles = (params[:all]) ? File::FNM_DOTMATCH : 0
		
		# We store a list of the files in an array, including dotfiles if specified
		Dir.glob "./*", include_dotfiles do |filename|
			outname = filename.split('/')[1]
			outname += '/' if File.directory? filename
			filelist.append outname
		end

		# Sort alphabetically if specified
		filelist.sort! if params[:sort]

		# Put directories first if specified
		if params[:directoriesfirst]
			files = []; dirs = []
			filelist.each do |filename|
				if File.directory? filename
					dirs.append(filename)
				else
					files.append(filename)
				end
			end
			filelist = dirs + files
		end
		
		# Apply color. We do this at the end now because color codes can alter the sorting.
		filelist.map! do |filename|
			if File.directory? filename
				filename.light_blue
			elsif File.executable? filename
				filename.light_green
			else
				filename
			end
		end if global_opts[:color]

		puts filelist
	end
```

You should be able to run it now:

```bash
mytool -c list -asd
```

Note how the parameters come after the `list` command in the syntax above. As you create more commands, each will have its own unique set of parameters, while the options remain _before_ the command and are available to all of them.

## Arguments

Lastly on the command line, there are arguments. Arguments are simply strings without the `-` character in front, and automatically get passed into an array in your applicaiton. Let's take a look at how we can use them.

Unlike options and parameters, arguments require no setup. So let's assume that we want any arguments passed to the `list` command to be filenames that you want to display, and that you can pass multiple ones. Since arguments aren't listed automatically by the help function, this is a good example of what to put in your usage text. Let's take a look at what our class looks like now:

```ruby
class List < Rbcli::Command
	description %q{List files in current directory}
	usage <<-EOF
To list only specific files, you can enter filenames as arguments

	mytool list filename1 filename2...
EOF
	parameter :sort, 'Sort output alphabetically', type: :boolean, default: false
	parameter :all, 'Show hidden files', type: :boolean, default: false
	parameter :directoriesfirst, 'Show directories on top', type: :boolean, default: false

	action do |params, args, global_opts, config|
		filelist = []

		# We include dotfiles if specified
		include_dotfiles = (params[:all]) ? File::FNM_DOTMATCH : 0
		
		# We store a list of the files in an array, including dotfiles if specified
		Dir.glob "./*", include_dotfiles do |filename|
			outname = filename.split('/')[1]
			next unless args.include? outname if args.length > 0
			outname += '/' if File.directory? filename
			filelist.append outname
		end

		# Sort alphabetically if specified
		filelist.sort! if params[:sort]

		# Put directories first if specified
		if params[:directoriesfirst]
			files = []; dirs = []
			filelist.each do |filename|
				if File.directory? filename
					dirs.append(filename)
				else
					files.append(filename)
				end
			end
			filelist = dirs + files
		end
		
		# Apply color. We do this at the end because color codes can alter the sorting
		filelist.map! do |filename|
			if File.directory? filename
				filename.light_blue
			elsif File.executable? filename
				filename.light_green
			else
				filename
			end
		end if global_opts[:color]

		puts filelist
	end
end
```



## Simplified Reference (TLDR)

RBCli enforces a CLI structure of:

```
toolname [options] command [parameters] argument1 argument2...
```

__Options__ are declared in `application/options.rb` file.

__Parameters__ are declared in the respective command's class declaration.

__Arguments__ don't need to be declared, and are passed in as an array to your commands. It is helpful to describe the argument purpose in the `usage` text declaration so that the user can see what to do in the help.

__Options__ and __parameters__ both use the same format:

```ruby
option    :<name>, "<description_string>", short: '<character>', type: <variable_type>, default: <default_value>, permitted: [<array_of_permitted_values]

parameter :<name>, "<description_string>", short: '<character>', type: <variable_type>, default: <default_value>, permitted: [<array_of_permitted_values]
```

* `name`
	* (Required) The long name of the option, as a symbol. This will be represented as `--name` on the command line
* `description_string`
	* (Required) A short description of the command that will appear in the help text for the user
* `type`
	* (Required) The following types are supported: `:string`, `:boolean` or `:flag`, `:integer`, and `:float`
* `default`
	* (Optional) A default value for the option if one isn't entered (default: nil)
* `short`
	* (Optional) A letter that acts as a shortcut for the option. This will allow users to apply the command as `-n`
	* To not have a short value, set this to :none (default: the first letter of the long name)
* `required`
	* (Optional) Specify whether the option is required from the user (default: false)
* `permitted`
	* (Optional) An array of whitelisted values for the option (default: nil)

## Next Steps

Next, we're going to take a quick look at how to publish and distribute your application, both publicly and within your organization.

[user_config_documentation]: ../advanced/user_config_files.md
[regex_explanation]: https://medium.com/factory-mind/regex-tutorial-a-simple-cheatsheet-by-examples-649dc1c3f285
