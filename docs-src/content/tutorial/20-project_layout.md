---
title: "The Project Layout"
date: 2019-06-20T15:07:21-04:00
draft: false
pre: "<b>2. </b>"
weight: 20
---

Now we will learn about what an RBCli project looks like and how to start using it.

## Project Initialization Types

RBCli can initialize a tool in three different modes:

- Project Mode (default)
- Mini Mode
- Micro Mode

### Project Mode

If you've been following along with the tutorial, you've already seen Project Mode. An RBCli Project consists of several folders, each of which has a specific function. The RBCli framework handles loading and parsing the code automatically. To generate a standard, full-featured RBCli project, run:

```bash
rbcli init -n mytool
```

where `mytool` can be replaced with any other command name you'd like. (We will continue using `mytool` in this tutorial though!)

Inside the newly created `mytool` folder you will see a bunch of files and folders related to your project. We will go over the structure later.

### Mini & Micro Modes

If you need to write a CLI tool but project mode feels a bit overkill for you -- if you think a single-file script is all that is needed -- that's where the Mini and Micro modes come in. Instead of generating a full directory tree, you get only a single file that contains most of the functionality of RBCli. To use it, run:

```bash
rbcli init -n mytool -t mini
# or
rbcli init -n mytool -t micro
```

The only difference between the two is that `mini` will show you all available options and some documentation to help you, while `micro` is for advanced users who just want the samllest file possible.

As far as documentation goes, every piece of code present in those files is identical to Project mode so it should be pretty easy to navigate.

## Project Mode Structure

An RBCli project has the following structure:

```text
<name>/
|--- application/
|   |--- commands/
|   |   |--- scripts/
|   |--- options.rb
|--- config/
|--- exe/
|   |--- <name>
|--- hooks/
|--- lib/
|   |--- <name>/
|   |--- <name>.rb
|--- spec/
|--- userconf/
|--- .gitignore
|--- .rbcli
|--- .rspec
|--- CODE_OF_CONDUCT.md
|--- Gemfile
|--- README.md
|--- Rakefile
|--- <name>.gemspec
```

## Git, RubyGems, and rspec

A few files aren't part of RBCli itself, but are provided for your convenience. If you're experienced in Ruby and Git you can skip over this.

* `.gitignore`
	* Specifies which files to ignore in git. If you don't use git you can delete this file
* `.rspec`
	* Configures Rspec for testing your code
* `Gemfile`
	* Allows declaring dependencies for when your users install your application
* `Gemspec`
	* Same as above, but also lets you fill in more information so that you can publish your application as a gem
* `README.md`
	* A skeleton README file that will appear as a front page documentation to your code in most source control systems (i.e. Github, Bitbucket)
* `CODE_OF_CONDUCT.md`
	* Taken directly from the [contributor covenant][contributor_covenant] for your convenience
* `Rakefile`
	* So you can run rspec tests as a rake task

There is a lot of controvesy online regarding using the `gemfile` vs the `gemspec`. If you are new to Ruby in general then I suggest declaring your dependencies in the gemspec and leaving the `gemfile` as-is. This keeps things simple and allows publishing and distributing your tool as a gem.

Additionally, note that a git repo is not created automatically. Using git is out of scope of this tutorial, but you can find tutorials [here][git_tutorials].

## RBCli Folders

* `application/`
	* This is where the core of your application will live. You will define CLI options, commands, scripts, and hooks within this folder.
* `config/`
	* This folder contains the configuration for RBCli's features; such as storage, logging, and automatic updates.
* `exe/`
	* This folder contains the executable for your tool. You should not edit it; doing so may lead to unexpected behavior.
* `hooks/`
	* RBCli has several hooks that can be used to run code at different times, such as the 'default' code that is run when no command is selected. This is where they are placed.
* `lib/`
	* This folder is for you to write any additional code as you see fit, for importing into your commands, scripts, and hooks. It is automatically added to the $LOAD_PATH for you, so you can just use require statements like `require 'abc.rb'`  without worrying about where they are located on the filesystem.
* `userconf/`
	* This folder is for you to place the layout and defaults of any userspace config file. Acceptable formats are yaml and json, though we recommend YAML since it is by far easier to read and supports comments.
* `spec/`
	* This folder is for your rspec tests.
* `.rbcli`
	* This file is for internal use by RBCli. It should not be modified or deleted.

## Next Steps

For the purposes of getting started right now, you don't actually need to edit any of the defaults already present.

We just finished going through what an RBCli project looks like. Now let's create our first application with it!

[contributor_covenant]: http://contributor-covenant.org
[git_tutorials]: https://www.tutorialspoint.com/git/
