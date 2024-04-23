# Changelog

## 0.3.3 (TBD)

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
