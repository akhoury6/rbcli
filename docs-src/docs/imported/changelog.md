# Changelog

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
