# Automatic Updates

RBCli can automatically notify users when an update is available. If `force_update` is set (see below), RBCli can halt execution until the user updates their application.

Two sources are currently supported: __Github__ (including Enterprise) and __RubyGems__.

## GitHub Update Check

The GitHub update check works best when paired with GitHub's best practices on releases, where new releases are tagged on master with the format __vX.X.X__. See [Github's release documentation][github_release_documentation] to learn more.

RBCli will check your github repo's tags and compare that version number with one specified in your application at `config/version.rb`.

```ruby
autoupdate github_repo: '<your_user>/<your_repo>', access_token: nil, enterprise_hostname: nil, force_update: false, message: nil
``` 
The `github_repo` should point to the repo using the `user/repo` syntax. 

The `access_token` can be overridden by the user via their config file, so it can be left as `nil` if you enable [Userspace Configuration][userspace_configuration]. The token is not needed at all if using a public repo. For instructions on generating a new access token, see [here][github_generate_token]. 

The `enterprise_hostname` setting allows you to point RBCli at a local GitHub Enterprise server.

Setting `force_update: true` will halt execution if an update is available, forcing the user to update.

The `message` parameter allows setting a custom message that will be displayed when an update is available. Leaving it as `nil` will use the default message provided by RBCli.

## Rubygems.org Update Check

The Rubygems update check will check if there is a new published version of the gem on Rubygems.org. The latest published version is compared to the version number you configured RBCli with.

```ruby
autoupdate gem: '<your_gem>', force_update: false, message: nil
```

The `gem` parameter should simply state the name of the gem.
 
Setting `force_update: true` will halt execution if an update is available, forcing the user to update.

The `message` parameter allows setting a custom message that will be displayed when an update is available. Leaving it as `nil` will use the default message provided by RBCli.

[github_release_documentation]: https://help.github.com/articles/creating-releases/
[userspace_configuration]: user_config_files.md
[github_generate_token]: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
