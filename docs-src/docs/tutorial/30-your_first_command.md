# Your First Command

## Creating the Command

Creating the command is straightforward:

```bash
rbcli command --name=list
#or
rbcli command -n list
```

And there you have it! Now you can try out your command by typing:

```bash
./exe/mytool list
```

Congrats! You should now see a generic output listing the values of several variables. We'll get into what they mean in a bit, but first, let's make the tool's execution a bit easier.


Now that you know your way around a project, its time to create your first command! But before we do, let's make development just a little bit easier. Go to the base directory of the folder and type:

```bash
alias mytool="$(pwd)/exe/mytool"
```

And now you'll be able to execute your application as if it was already installed as a gem, without worrying about the working path. You can see this in action by running your application again, but without the path:

```bash
mytool list
```

So, now let's take a more in-dpeth look at what the command code looks like.

## The Command Declaration

As mentioned in the previous section, you can find your commands listed under the `application/commands/` directory. Each command will appear as its own unique file with some base code to work from. Let's take a look at that code a little more in-depth:

```ruby
class List < Rbcli::Command                                                           # Declare a new command by subclassing Rbcli::Command
	description 'TODO: Description goes here'                                           # (Required) Short description for the global help
	usage <<-EOF
TODO: Usage text goes here
EOF                                                                                   # (Required) Long description for the command-specific help
	parameter :force, 'Force testing', type: :boolean, default: false, required: false  # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

	config_default :myopt2, description: 'My Option #2', default: 'Default Value Here'  # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config.
                                                                                      # Alternatively, you can simply create a yaml file in the `default_user_configs` directory in your project that specifies the default values of all options

	action do |params, args, global_opts, config|                                       # (Required) Block to execute if the command is called.
		Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }              # Example log. Interface is identical to Ruby's logger
		puts "\nArgs:\n#{args}"                    # Arguments that came after the command on the CLI (i.e.: `mytool test bar baz` will yield args=['bar', 'baz'])
		puts "Params:\n#{params}"                  # Parameters, as described through the option statements above
		puts "Global opts:\n#{global_opts}"        # Global Parameters, as descirbed in the Configurate section
		puts "Config:\n#{config}"                  # Config file values
		puts "LocalState:\n#{Rbcli.local_state}"   # Local persistent state storage (when available) -- if unsure use Rbcli.local_state.nil?
		puts "RemoteState:\n#{Rbcli.remote_state}" # Remote persistent state storage (when available) -- if unsure use Rbcli.remote_state.nil?
		puts "\nDone!!!"
	end
end
```

Commands are declared to RBCli simply by subclassing them from `Rbcli::Command` as shown above. Then, you have a list of declarations that tell RBCli information about it. They are:

* `description`
	* A short description of the command, which will appear in the top-level help (when the user runs `mytool -h`).
* `usage`
	* A description of how the command is meant to be used. This description can be as long as you want, and can be as in-depth as you'd like. It will show up as a long, multi-line description when the user runs the command-sepcific help (`mytool list -h`).
* `parameter`
	* Command-line tags that the user can enter that are specific to only this command. We will get into these in the next section on [Options, Parameters, and Arguments][parameters_documentation]
* `config_default`
	* This sets a single item in the config file that will be made available to the user. More information can be found in the documentation on [User Config Files][user_config_documentation]
* `action`
	* This loads the block of code that will run when the command is called. It brings in all of the CLI and user config data as variables. We will also get into these in the next section [Options, Parameters, and Arguments][parameters_documentation]

There is an additional declaration not shown here, `extern`. You can find more information on it in the section on [Advanced Command Types][avanced_command_types_documentation]


## Creating the "list" Command

Now we're going to modify this command to list the contents of the current directory to the terminal. So let's change the code in that file to:

```ruby
class List < Rbcli::Command
	description %q{List files in current directory}
	usage <<-EOF
Ever wanted to see your files?
Now you can!
EOF

	action do |params, args, global_opts, config|
		filelist = []

		# We store a list of the files in an array, including dotfiles if specified
		Dir.glob "./*" do |filename|
			outname = filename.split('/')[1]
			outname += '/' if File.directory? filename
			filelist.append outname
		end
		
		# Apply color
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

Go ahead and test it out! The output doesn't show much obviously, just a list of names and nothing else. Don't worry though, we'll fix that in the next secion.

## Next Steps

Next we're going to take a look at options, parameters, and arguments, and we'll clean up our list command by using them. If you'd like to learn more about the additional command types in RBCli before continuing, see the [Advanced Command Types][avanced_command_types_documentation] documentation.

[parameters_documentation]: 40-options_parameters_and_arguments.md
[user_config_documentation]: ../advanced/user_config_files.md
[avanced_command_types_documentation]: ../advanced/command_types.md
