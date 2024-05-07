Contributing to RBCli is the same as most open source projects:

1. Fork the repository
2. Create your own branch
3. Submit a pull request when ready

That's all there is to it! We've also kept our acceptance criteria pretty simple, as you'll see below. Feel free to submit a pull request even if you don't meet it if you would like your code or feature to be reviewed first; we do want to be mindful of your time and will review submissions before they are polished.

# Develpment Mode

To allow for easy development, Rbcli has a development mode which allows applications generated from the Rbcli tool to include Rbcli from a local folder instead of the default gem path. To use it, add the following to your shell's profile (typically `~/.profile`):

```bash
export RBCLI_DEVELOPMENT='true'
alias rbcli='/path/to/rbcli/exe/rbcli'
```

# Code Acceptance Criteria

## Tests

All code changes and additions must have associated tests updated and/or added to test both the success and failure cases of the new code.

To run the suite of tests locally, just run `rake spec`

## Tabs, Not Spaces

Please, and thanks. We all like to use different indentation levels and styles, and this will keep us consistent between editors.

For filetypes where tabs are not supported (such as `yaml`), please stick to using two (2) spaces.

## Documentation for User Features

For any modification that alters the way RBCli is used -- additional features, options, keyword changes, behavioral changes, and the like -- the documentation will need to be updated as well. The process has been made as painless as possible.

RBCli's documentation is a collection of markdown files that have been compiled into a static site using [Hugo](https://gohugo.io) and the [Relearn Theme](https://mcshelby.github.io/hugo-theme-relearn/index.html).  You can install it by running:

```bash
brew install hugo 
```

All of the source files are in `docs-src/content`. If adding a new page, make sure that an appropriate weight is set in the header so that it shows up in the correct order on the site. You can preview your changes with:

```bash
rake docserver
```

When the changes are ready to be committed, compile the static site to be commited along with the code:

```bash
rake docs
```

Note: This command will also pull in and modify/add to some of the other documentation files (including `README.md`, `LICENSE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `CHANGELOG.md`) if there are any updates to them. If you are changing any of this documentation, make sure that your changes are not getting overwritten.

## Deprecations

If a feature needs to be deprecated, RBCli has a built-in deprecation message feature. Code/method removal should only happen on major version releases, as doing so will break backwards compatibility. You can leverage it by calling the following code when a deprecated command is called:

```ruby
Rbcli::DeprecationWarning.new offending_object, warn_at: nil, deprecate_at: nil, message: nil
```

So, for example:

```ruby
Rbcli::DeprecationWarning.new(
  'Rbcli::Configurate.me',  # This can also be an object -- 'self' is a good one
  warn_at: '0.4.0',
  deprecate_at: '0.5.0',
  message: 'Please use `Rbcli::Configurate.cli` instead.'
)
```

This will display a warning or error to the user (using the Logger) depending on the version they are using. The text is as follows (depending on log format):

```text
Warning:
WARN  || DEPR || DEPRECATION WARNING -- Rbcli::Configurate.me -- This method is scheduled to be removed on version 0.5.0. You are on version 0.4.0.
WARN  || DEPR || Please use `RBCli::Configurate.cli` as the Configurate block instead.

Error:
ERROR || DEPR || DEPRECATION ERROR -- Rbcli::Configurate.me -- The removal of this method is imminent. Please update your application accordingly.
ERROR || DEPR || Please use `RBCli::Configurate.cli` as the Configurate block instead.
```

## Versioning Scheme

Rbcli uses [Semantic Versioning](https://semver.org), following the `MAJOR.MINOR.PATCH` paradigm. This means that breaking changes will only happen on major version updates.