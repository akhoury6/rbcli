# Getting Started

Welcome to the RBCli getting started tutorial! In this tutorial we're going to cover the basics of RBCli and get a simple application up and running. It should take you between 30-60 minutes to complete, depending on your skill level with Ruby.

As you go throught the tutorial, you can either use the __Next__ and __Back__ buttons on the page to navigate, or use the menu directly.

## Supported Ruby Versions

You'll need Ruby installed before you can use RBCli. If you don't know how to install it, we recommend using either [rbenv][rbenv] (our favorite) or [rvm][rvm].

RBCli officially supports Ruby versions 2.5.0 and above. It may work on earlier releases even though we haven't tested them. If you do try it find any bugs that break compatibility, feel free to submit a github issue or pull request.

## Installation

RBCli is available on rubygems.org. You can add it to your application's `Gemfile` or `gemspec`, or install it manually by running:

```bash
gem install rbcli
```

Then, `cd` to the folder you'd like to create your project under and run:

```bash
rbcli init -n mytool -d "A simple CLI tool"
```

where `mytool` can be replaced with any other command name you'd like. You should then see some output about generating a bunch of files. Once it finishes, run:

```bash
cd mytool
ls -ahl
```

Congratulations! This is the beginning of your first project.

## Next Steps

Next, you will learn about the layout of an RBCli project and how to code with it.

[rbenv]: https://github.com/rbenv/rbenv
[rvm]: https://rvm.io
