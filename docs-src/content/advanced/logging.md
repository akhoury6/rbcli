---
title: "Logging"
date: 2019-06-20T15:07:21-04:00
draft: false
---

Logging with RBCli is straightforward - it looks at the config file for logging settings, and instantiates a single, globally accessible [Logger][ruby_logger] object. You can access it within a standard command like this:

```ruby
Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }
```

## Enabling Logging

To enable logging, simply set the default values in the `config/logging.rb` file:

```ruby
log_level :info
log_target 'stderr'
```

* `log_level`
	* You can set the default log level using either numeric or standard Ruby logger levels: 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
* `log_target`
	* This specifies where the logs will be placed. Valid values are nil (disables logging), 'STDOUT', 'STDERR', or a file path (all as strings).

## Userspace Config Overrides

If [Userspace Configuration][userspace_configuration] is enabled, these options will also be present in the user's config file to override defaults: 

```yaml
# Log Settings
logger:
  log_level: warn              # 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  log_target: stderr           # STDOUT, STDERR, or a file path
```

[ruby_logger]: https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
[userspace_configuration]: /advanced/user_config_files
