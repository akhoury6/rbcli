# <%= @vars[:cmdname] %>

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem.

You'll find your gem's Command Line entrypoint under the file `exe/<%= @vars[:cmdname] %>`, although you shouldn't need to edit this file. Instead, follow these steps to get up and running quickly:

* Review the configuration under the `config` directory
* Modify global CLI options under the `application/options.rb` file
* Generate a new command by running `rbcli generate -t command -n <name>`
* Modify the command's code under `application/commands/<name>.rb`
* Repeat the previous two steps until complete!

For more details, including advanced usage, please see the [RBCli documentation](https://github.com/akhoury6/rbcli). 

TODO: Delete the text above and write your README!

## About

<%= @vars[:description] %>

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `config/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/untitled. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Untitled project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/untitled/blob/master/CODE_OF_CONDUCT.md).
