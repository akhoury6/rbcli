## Logging

Logging with RBCli is straightforward - it looks at the config file for logging settings, and instantiates a single, globally accessible [Logger](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html)` object. You can access it as such:

```ruby
Rbcli::log.info { 'These logs can go to STDERR, STDOUT, or a file' }
```

Default values can be set in the configurate DSL:

```ruby
log_level :info                                                        # (Optional) Set the default log_level for users. 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
log_target 'stderr'                                                    # (Optional) Set the target for logs. Valid values are STDOUT, STDERR, or a file path (as strings)
```

Two configuration options will always be placed in a user's YAML file to override defaults: 

```yaml
# Log Settings
logger:
  log_level: warn              # 0-5, or DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  log_target: stderr           # STDOUT, STDERR, or a file path
```
