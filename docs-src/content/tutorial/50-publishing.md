---
title: "Publishing Your Application"
date: 2019-06-20T15:07:21-04:00
draft: false
pre: "<b>5. </b>"
weight: 50
---

RBCli creates projects designed to be easily distributed via either source control or as a gem. We'll go over both methods.

## Common Tasks

Regardless of where you are publishing, certain tasks need to be accomplished. Namely, preparing the gemspec and the README.

In both files the items that need changing are pretty obvious -- you'll need to fill out your name, email, etc, and replace the placeholder text in the README with something useful to your users.

Then, for every release, you'll need to update the version number in `config/version.rb`. This number is automatically used by the `gemspec` when versioning the gem in the system, and by RBCli when displaying help to the user and checking for automatic updates if you enable that feature (see [Automatic Updates][automatic_update_documentation] for more information).

## Source Control Distribution

With Source Control distribution your users will be cloning the source code directly from your repository, and building and installing the gem locally. Thankfully, the process is pretty simple:

```bash
git clone <your_repo_here>
gem build mytool.gemspec
gem install mytool-*.gem
```

Note that he README's placeholder text has these commands already listed for your users, which you can leave as instructions.

When using this method, we highly recommend using a git flow where you only merge to master when you are ready to release, this way your users don't inadvertently download a buggy commit.

## Rubygems.org Distribution

If you're distributing as a gem via Rubygems.org, you'll need to follow a specific release process.

1. Update the version number in `config/version.rb`
2. Commit the change locally
3. Run `bundle exec rake release`

This will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Recommended Platforms

As far as RBCli is concerned, all Git hosts and gem platforms work equally well, and as long as the code reaches your users in one piece it's all the same. That said, if you'd like to take advantage of automatic update notifications for your users, please see the documentation for [Automatic Updates][automatic_update_documentation] for a list of supported platforms for that feature. 

## Next Steps

Congratulations! You've completed the tutorial on RBCli and should be able to make all sorts of CLI applications and tools with what you learned. That said, there are still many features in RBCli that we didn't explore, which you can find in the __Advanced__ section of this site. If you aren't sure where to start, we recommend looking at [User Config Files][user_config_files_documentation] and going from there.


[automatic_update_documentation]: /advanced/automatic_updates
[user_config_files_documentation]: /advanced/user_config_files
