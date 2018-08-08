# Changelog

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
