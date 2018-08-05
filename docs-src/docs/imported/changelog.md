# Changelog

## 0.2.0 (Aug 5, 2018)

### Features

* Official documentation created and hosted with Github Pages
* RBCli released under GPLv3

### Bugfixes

* Fixed version number loading for projects
* Cleaned up command usage help output
* Fixed script and external command generation

### Improvements

* A quick reference guide can now be found in README.md
* CLI tool Autoupdate Enabled; when an upgrade to RBCli is detected, the RBCli CLI tool will notify the developer.
* Autoupdate feature now allows supplying a custom message
* Direct Path Mode for External Commands now
* Added support for a `lib` folder in projects, as a place for custom code, which is automatically added to `$LOAD_PATH` for developers
* Improved language regarding external commands: Documentation now differentiates between Standard, Scripted, and External Commands
* Improved language regarding user config files: Now called Userspace Config
* Options and Parameters now allow specifying the letter to be used for the short version, or to disable it altogether
* Userspace config can now be disabled by setting the path to nil or removing the declaration

### Deprecations/Changes

* Removed deprecated and broken examples from the examples folder
