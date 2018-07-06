#########################
## Command Declaration ##
#########################
# With rbcli, commands are declared by subclassing
# from Rbcli::Command. The name of the class will be
# the command that is available to the user.
#########################
class Test < Rbcli::Command                                                          # Declare a new command by subclassing Rbcli::Command
	description 'This is a short description.'                                         # (Required) Short description for the global help
	usage 'This is some really long usage text description!'                           # (Required) Long description for the command-specific help
	parameter :force, 'Force testing', type: :boolean, default: false, required: false # (Optional, Multiple) Add a command-specific CLI parameter. Can be called multiple times

	config_defaults 'defaults.yml'                                                     # (Optional, Multiple) Load a YAML file as part of the default config. This can be called multiple times, and the YAML files will be merged. User config is generated from these
	config_default :myopt2, description: 'Testing this again', default: true           # (Optional, Multiple) Specify an individual configuration parameter and set a default value. These will also be included in generated user config

	extern path: 'env | grep "^__PARAMS\|^__ARGS\|^__GLOBAL\|^__CONFIG"', envvars: {MYVAR: 'some_value'}     # (Required unless `action` defined) Runs a given application, with optional environment variables, when the user runs the command.
	extern envvars: {MY_OTHER_VAR: 'another_value'} do |params, args, global_opts, config|                   # Alternate usage. Supplying a block instead of a path allows us to modify the command based on the arguments and configuration supplied by the user.
		"echo #{params[:force].to_s}__YESSS!!!"
	end

	action do |params, args, global_opts, config|                                        # (Required unless `extern` defined) Block to execute if the command is called.
		Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }                       # Example log. Interface is identical to Ruby's logger
		puts "\nArgs:\n#{args}"                    # Arguments that came after the command on the CLI (i.e.: `mytool test bar baz` will yield args=['bar', 'baz'])
		puts "Params:\n#{params}"                  # Parameters, as described through the option statements above
		puts "Global opts:\n#{global_opts}"        # Global Parameters, as descirbed in the Configurate section
		puts "Config:\n#{config}"                  # Config file values
		puts "LocalState:\n#{Rbcli.local_state}"   # Local persistent state storage (when available) -- if unsure use Rbcli.local_state.nil?
		puts "RemoteState:\n#{Rbcli.remote_state}" # Remote persistent state storage (when available) -- if unsure use Rbcli.remote_state.nil?
		puts "\nDone!!!"
	end
end