Rbcli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible. In Rbcli, low-level code has been wrapped and/or replaced with higher-level methods. Much of the functionality has even been reduced to single methods: for example, it takes just one declaration to define, load, and generate a user's config file at the appropriate times. Many other features are automated and require no work by the engineer. These make Rbcli a fundamental re-thining of how we develop CLI tools, enabling the rapid development of applications for everyone from hobbyists to enterprises.

Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, Rbcli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.

* __Portable Executable__: Jump-start using Rbcli by creating a simple portable executable! Just fill in the blanks and you're good to go.

* __Full Gem Structure__: Alternatively, Rbcli can piggyback off of `bundler` to create a full Gem project structure with custom folders to make using the framework easier. This makes using Rbcli to create larger applications a breeze.

* __Lazy Loading__: Even though Rbcli is a heavyweight tool, it uses lazy loading with its optional features to speed up application startup time. This means you don't have to worry about a large framework slowing your application down, no matter how big it gets.

* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily define a configuration file in code, complete with annotations, and have it automatically generated for your users in the format of your choice (yaml, toml, json, or ini).

* __Config File Validation__: Apply a [schema](https://json-schema.org) to validate the format of the config file when it is loaded, no matter which file format you choose.

* __Environment Variable Parsing__: Simply define a prefix and all of the environment variables with that prefix will be parsed into their respective types and put into a Hash for convenient, along with any optional defaults you'd like to set

* __Shell Script Integration__: Integrate with shell scripts to pass along everything from command-line options to parsed config values, and even to allow the script to output logs through Rbcli directly

* __Multiple Hooks and Entry Points__: Define pre- and post- execution hooks to quickly and easily customize the flow of your application code. Parse all of the config, options, and environment variables before they reach your commands, or clean up your environment afterwards.

* __Logging__: Logs can go to your standard output, a file, or any custom stream of your choice, and can even be redirected or reformatted mid-execution. In additional, Multiple common log formats have been pre-defined to make it easy to get started, and you can even define custom ones.

* __Automatic Update Checks__: Just provide the gem name or git repo, and Rbcli will take care of notifying users when you have an update ready for them
