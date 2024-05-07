# Rbcli Changelog

## 0.4.0 (May 7, 2024)

This release is a major refactor! Nearly all of the codebase has been rewritten from the ground up. This brought lots of features and improvements, with a heavy focus on making the framework easier to understand and use. It's memory footprint has been reduced, and execution time has sped up too.

__NOTE__: The license for this version has been changed from GPLv3 to MIT.

### Features

* Console and Logfile Output 
  * The `Rbcli:msg` output and the Logger output have been combined into just the Logger
  * The logger now has more flexibility to be used as either console output or to format everything for a logfile
  * The logger has become a lot more powerful. It can now output in several different preconfigured formats, including `:display, :simple, :full, :standard, :json, :apache`, and just for fun, a `lolcat` format. Use `:display` for output meant to be viewed by a user on a command line.
  * Custom log formats can also be defined just by passing a proc.
  * Configuration for the logger has been simplified to one single line in the `Configurate` block, and subsequent calls to the block can change the parameters at any time
* Config Files & State Storage
  * Rather than these features having two separate features sets, they have been merged into a single feature with the capabilities of both
  * Config files can now be saved at any time, and support additional types. Supported types are now: `yaml`, `json`, `ini`, `toml`, and `null`.
  * A banner may be defined that gets written to the config file as a comment when using a backend that supports them
  * Config files have built-in validation when provided a [Json-Schema](https://json-schema.org). This validation works on all backends.
  * The primary config is accessed via the Configurate block, where defaults can be set, with options to generate the file automatically if it doesn't exist and save it if it gets modified
  * Additional configs may be created by instantiating the `Rbcli::Config` class directly
  * A config may have more than one location/path defined for a hierarchical search. For example, setting the locations to `['~/.config', '/etc/config']` will use the home folder one if available but fall back to the system-wide one if it isn't
  * A `env` backend was also added with its own unique integration, to enable automatic parsing of environment variables. This backend is given it's own config block in Rbcli to inject the environment variable data into commands.
* Component Architecture & Execution Engine
  * All features of Rbcli have been designed around a new modular architecture. This has simplified the codebase tremendously, making future work and expansion easier
  * The core of Rbcli is no longer lazy-loaded, allowing for a simpler code base without any detrement to 99% of users
  * Non-essential features remain lazy loaded to keep the memory footprint and startup times down
  * Components can now register methods to be run at any stage of execution within the engine, this way the engine does not need to be modified directly when features are added
* Commands & Shell Scripts
  * A command may now be specified as the default, executing it when no other command is specified on the command line. This enables the creation of tools without sub-commands
  * Shell script commands can now be defined inline in a command, rather than requiring a separate file
  * Shell script commands now have their outputs captured and send to the same log/stream that the rest of the program output goes to
  * Shell script commands now integrate tightly with the logger, where messages can be output in different log severities

### Improvements

* Tests
  * Tests have been added for much of Rbcli, and more are coming. Now that this project is growing, the goal is to have as much coverage as humanly possible.
* Performance
  * The engine has been rewritten to speed up execution. Rather than lots of checks and hooks to see which options need to be called, configured options can inject the functions that need to be executed when the engine runs. This significantly reduces execution time
* Developer Experience
  * Getting started has never been simpler, as the required configuration has been brought down to simply declaring a commmand
  * The projects generated are a lot simpler to use. In addition, the generator has been simplified and is a lot easier to use.
  * Built-in error types have now been created to help describe errors within the rbcli framework itself, along with vastly improved error handling
  * Lots of descriptive logs have been added throughout the framework, making it easy to track what your application is doing. Just set the log level to `:debug` when initializing the logger
  * Naming conventions are now more in line with the functions being performed
  * Deprecation warnings now get displayed as soon as the code reaches the declaration, as this is more reliable than attempting to aggregate them prior to execution
  * Checks have been added to better ensure that a declared configuration is valid, reducing unexpected errors during usage
* Documentation
  * The documentation site has been re-created with a fresh Hugo project and a modern, updated version of the theme
  * The code annotations when initializing a new project/executable have been made simpler and clearer
  * All of the documentation has been re-written for the new, updated Rbcli
  * Scripts have been added to help automatically pull in the Changelog and Readme into the site on release
  * The contribution guide and tooling has been updated to make contributing easier
* More stuff
  * The project initialization code has been simplified, making the resulting files a lot more consistent
  * The update check feature has sane and descriptive default messages that get displayed when an update is available
  * The parsing method has been changed to allow for more control over output. Helptext is now sent over the same stream as all other text, and CLI option parsing errors are captured and sent to logs
  * Options & parameters now use an enhanced version of the `ManageIQ/Optimist` gem as a backend. This allows for more options configurations than were previously possible
  * Autoupdates were aptly renamed to update checks since they did not perform the update automatically
  * Custom log formats can now be defined on the fly

### Bugfixes

* Under certain conditions, the update check would throw an exception rather than check the version numbers correctly. This has been fixed and the updater now fails silently when it can't perform a proper comparison.
* Rather than fail, the update checker now informs the developer when the configuration for update checks is invalid
* Commands can no longer combine "action", "extern", and "script" in the same command, as this could lead to unexpected behavior with remote execution
* The pre- and post- hooks used to get defined and executed twice under certain circumstances. This has been corrected.

### Deprecations

* The `Rbcli::msg` helper has been deprecated, as it was only making output more complex. Console output has now been integrated into `Rbcli.log` 
* The `Rbcli.Parse` call has been changed to `Rbcli.go!` as it now starts the execution engine
* The `Configurate::me` terminology has been changed to `Configurate::<component>`, where each component gets its own block.


## 0.3.3 (April 24, 2024)

### Improvements

* Tested with Ruby 3.3.0
* Updated dependencies for Ruby 3.3.0
* Updated dependnecies for Sekeleton projects
* Added a `bundler/inline` gemfile on mini and micro skeleton projects to simplify their use
* Replaced deprecated Trollop gem with its replacement, [ManageIQ/Optimist](https://github.com/ManageIQ/optimist)

### Bugfixes

* Updated deprecated ERB call for skeleton generation to use new format


## 0.3.2 (October 28, 2023)

### Bugfixes

* Replaced several calls to the deprecated `.exists?` method with `.exist?` for compatibility with Ruby 3.2.0
* Updated dependencies to latest versions
* Standardized on version locking to the latest Major version of dependencies rather than the latest Minor ones


## 0.3.1 (October 19, 2021)

### Bugfixes

* Fixed prompt for option value to ignore nil defaults instead of displaying an empty string
* Skeleton script command `script.sh` updated to function correctly when development mode is enabled
* Updated Github Pages links to point to `github.io` instead of `github.com` which are being deprecated
* Updated dependencies, closing the security hole of the gem `addressable <= 1.7.0`


## 0.3 (July 31, 2020)

### Improvements

* Deprecated Ruby code has been updated to be compatible with Ruby 2.7.x
* All depedencies have been updated to their latest versions and tested to ensure continued compatibility
* Old-style execution hooks have been fully deprecated in favor of declaring them in the `Rbcli::Configurate.hooks` block. To ensure compatibility, save your current hooks and generate new ones using the command `rbcli hook`
* Skeleton gemspec now includes `spec.required_ruby_version`, which matches Rbcli's requirement
* Documentation updated to support latest Hugo and theme versions (Hugo 0.74.3 and hugo-theme-learn 2.5.0)

### Features

* Rbcli Deprecation Warnings now show the offending line of code to ease updating
* The `$libdir` global variable is defined by default in the skeleton project, allwoing easy access to the project's `lib` folder


## 0.2.12 (July 29, 2019)

### Improvements

* The base project skeleton now includes an improved structure for the `lib/` folder
* Documentation now uses Hugo instead of MkDocs for site generation.
* Updated dependencies in project skeleton to latest versions

### Features

* Development mode can be enabled by setting the environment variables: `RBCLI_ENV=development` and `RBCLI_DEVPATH=[path to local Rbcli folder]` to simplify changes to Rbcli during development. Combined with setting `alias rbcli='/path/to/rbcli/exe/rbcli'`, gem installation is not required for development work


## 0.2.11 (Feb 27, 2019)

### Improvements

* Updated the dependent gem verions to use the latest available versions

### Bugfixes

* Fixed the nested triggers of the message I/O system


## 0.2.8 (Nov 7, 2018)

### Features

* Added a standardized message I/O system

### Improvements

* Enabled the safe usage of anchors in YAML config files
* Improved the method of determining the script name to be more portable across OS'es

### Bugfixes

* Fixed an error which caused RBCli to crash when using `local_state`
* Fixed a bug which caused the `rbcli init` command to occassionally fail for mini and micro projects

### Changes

* Changed the `rbcli init` helptext to match the order of complexity of projects (standard -> mini -> micro)


## 0.2.7 (Oct 17, 2018)

### Improvements

* Added a dev mode for scripts that allows using a local RBCli copy instead of requiring the gem to be installed

### Bugfixes

* Fixed a bug that caused the rbcli tool not to detect project folders correctly.
* Command parameter `prompt:` now works when `required` is set to `true`.

### Changes

* The `rbcli init` command now initializes into the current working directory instead of creating a new one.
* Fixed erroneous documentation about the 'merge' setting on userspace config.


## 0.2.5 (Oct 8, 2018)

### Improvements

* Added a useful error message when local or remote state is used but not initialized.

### Bugfixes

* Fixed a bug in the Github Updater where RBCli crashed when a version tag was not present in the repo.
* Fixed a bug where deleting a state key would crash Rbcli
* Fixed a bug where remote state crashed with certain configurations


## 0.2.4 (Sep 4, 2018)

* This is a dummy release required to update the License in the Gemspec file. The license has not changed (GPLv3).


## 0.2.3 (Sep 4, 2018)

### Features

* Interactive Commands -- Prompt the user for parameters with a given value

### Improvements

* Added documentation on logging


## 0.2.2 (Aug 22, 2018)

### Features

### Bugfixes

* Fixed a bug that caused the logger's target and level not to be configured properly via the Configurate block.

### Improvements

* Lazy-loading has been implemented in optional modules such as autoupdates, remote storage, etc. This means that if you do not enable them in the code, they will not be loaded into memory. This significantly improves loding times for applications.
* Abstraction system created for configuration. This has significantly simplified the existing codebase and makes future development easier.
* Deprecation warning system added. This allows for RBCli contributors to notify users of breaking changes that may impact their code.
* Folder structure has been simplified to ease development.
* Much of the code has been refactored.

### Deprecations/Changes

* The `Rbcli` module is now `RBCli` to better match the branding. The original `Rbcli` module will still work for this current release, with a warning, but future releases will require code changes.
* Hooks are now defined under the `RBCli.Configurate.hooks` block instead of `RBCli.Configurate.me`.
* The logger is now silent by default. To enable it, it must be configured either via the `Configurate` block or via the user's config file.


## 0.2.1 (Aug 8, 2018)

### Features

* Remote Execution added for Script and External commands

### Bugfixes

* Fixed a bug that caused RBCli to crash if a direct path mode script's environment variables were declared as symbols


## 0.2.0 (Aug 5, 2018)

### Features

* CLI tool Autoupdate Enabled; when an upgrade to RBCli is detected, the RBCli CLI tool will notify the developer.
* Official documentation created and hosted with Github Pages
* RBCli released under GPLv3
* Copyright/License notice displayed via RBCli tool with `rbcli license` in accordance with GPLv3 guidelines

### Bugfixes

* Fixed version number loading for projects
* Cleaned up command usage help output
* Fixed script and external command generation

### Improvements

* A quick reference guide can now be found in README.md
* Autoupdate feature now allows supplying a custom message
* Direct Path Mode for External Commands now
* Added support for a `lib` folder in projects, as a place for custom code, which is automatically added to `$LOAD_PATH` for developers
* Improved language regarding external commands: Documentation now differentiates between Standard, Scripted, and External Commands
* Improved language regarding user config files: Now called Userspace Config
* Options and Parameters now allow specifying the letter to be used for the short version, or to disable it altogether
* Userspace config can now be disabled by setting the path to nil or removing the declaration

### Deprecations/Changes

* Removed deprecated and broken examples from the examples folder