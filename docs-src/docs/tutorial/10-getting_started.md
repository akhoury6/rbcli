# Getting Started

As technologists today, we work with the command line a lot. We script a lot. We write tools to share with each other to make our lives easier. We even write applications to make up for missing features in the 3rd party software that we buy. Unfortunately, when writing CLI tools, this process has typically been very painful. We've been working with low-level frameworks for decades; frameworks like `getopt` (1980) and `curses` (1977). They fit their purpose well; they were both computationally lightweight for the computers of the day, and they gave engineers full control and flexibility when it came to how things were built. Unfortunately, these libraries no longer fit the needs of the modern technologist.

Over the years, we've settled on several design patterns that we know work well. Patterns as to what a CLI command looks like, what a config file looks like, what remote execution looks like, and even how to use locks (mutexes, semaphores, etc) to control application flow and data atomicity. Yet we're stuck writing the same low-level code every time we want to write a CLI tool for ourselves. Not anymore.

Enter RBCli. RBCli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible. In RBCli, low-level code has been wrapped and/or replaced with higher-level methods. Much of the functionality has even been reduced to single methods: for example, it takes just one declaration to define, load, and generate a user's config file at the appropriate times. Many other features are automated and require no work by the engineer. These make RBCli a fundamental re-thining of how we develop CLI tools, enabling the rapid development of applications for everyone from hobbyists to enterprises.

## Installation & Prerequisites

You'll need Ruby installed before you can use RBCli. If you don't know how to install it, we recommend using either [rbenv][rbenv] (our favorite) or [rvm][rvm].

### Supported Ruby Versions

RBCli officially supports Ruby versions 2.5.0 and above. It may work on earlier releases even though we haven't tested them. If you do try it find any bugs that break compatibility, feel free to submit a github issue or pull request.

### Installation

RBCli is available on rubygems.org. You can add it to your application's `Gemfile` or `gemspec`, or install it manually by running:

```bash
gem install rbcli
```

Then, `cd` to the folder you'd like to create your project under and run:

```bash
rbcli init -n mytool
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
