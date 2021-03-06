---
title: "Contribution Guide"
date: 2019-06-20T15:07:21-04:00
draft: false
weight: 10
---

Contributing to RBCli is the same as most open source projects:

1. Fork the repository
2. Create your own branch
3. Submit a pull request when ready

That's all there is to it! We've also kept our acceptance criteria pretty simple, as you'll see below. Feel free to submit a pull request even if you don't meet it if you would like your code or feature to be reviewed first; we do want to be mindful of your time and will review submissions before they are polished.

# Develpment Mode

 To allow for easy deveopment, Rbcli has a development mode which allows a project to include rbcli from a local folder instead of the default gem path. To use it, add the following to your shell's profile (typically `~/.bash_profile` or `~/.profile`):

 ```bash
export RBCLI_ENV='development'
export RBCLI_DEVPATH='/path/to/rbcli/lib/rbcli'
alias rbcli='/path/to/rbcli/exe/rbcli'
```

# Code Acceptance Criteria

## Tabs, Not Spaces

Please, and thanks. We all like to use different indentation levels and styles, and this will keep us consistent between editors.

For filetypes where tabs are not supported (such as YAML), please stick to using two (2) spaces.

## Documentation for User Features

For any modification that alters the way RBCli is used -- we're talking additional features, options, keyword changes, major behavioral changes, and the like -- the documentation will need to be updated as well. You'll be happy to know we designed it to make the process relatively painless.

RBCli's documentation is essentially a collection of markdown files that have been compiled into a static site using [MkDocs](https://www.mkdocs.org). If you already have python and pip on your system, you can install it by running:

```bash
pip install mkdocs mkdocs-material
```

You can find the source markdown files in the `docs-src/docs` folder, and the menu organization in `docs-src/mkdocs.yml`. To preview your changes on a live site, run:

```bash
mkdocs serve
```

Also, don't forget to update the __Quick Reference Guide__ in the `README.md` file (the main project one) with information about your changes.

Once you've completed your edits, run the `makesite.sh` command to build the actual HTML pages automatically in the `docs` folder, from where they will be served when live.

## Deprecations

If a feature needs to be deprecated, RBCli has a built-in deprecation message feature. You can leverage it by calling the following code when a deprecated command is called:

```ruby
Rbcli::DeprecationWarning.new deprecated_command, message, version_when_code_will_be_removed
```

So, for example:

```ruby
Rbcli::DeprecationWarning.new 'Rbcli::Configurate.me--first_run', 'Please use `RBCli::Configurate.hooks` as the parent block instead.', '0.3.0'
```

will display the following message to the user, in red, any any time the application is run:

```text
DEPRECATION WRNING: The feature `Rbcli::Configurate.me--post_hook` has been deprecated. Please use `RBCli::Configurate.hooks` as the parent block instead. This feature will be removed in version 0.3.0.
```

Additionally, it will place the same line in the logs using `Rbcli.logger.warn` if logging is enabled.

If a deprecation warning has been added, please remember to mention it in the pull request so that others can update it later.

# Maintainer's Notes

To install this gem onto your local machine from source, run `bundle exec rake install`.

To release a new version, follow theese steps:

1. Update the version number in `version.rb`
2. Run `bundle exec rake install`, which will update `gemfile.lock` with the correct version and all dependency changes
3. Run `docs-src/makesite.sh`, which re-compiles the documentation and pulls in the changelog and quick reference automatically
4. Commit the above changes to master with a commit message of "vX.X.X" (where X.X.X is the version number), but do not push
5. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
