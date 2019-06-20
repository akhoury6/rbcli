# This is RBCli


As technologists today, we work with the command line a lot. We script a lot. We write tools to share with each other to make our lives easier. We even write applications to make up for missing features in the 3rd party software that we buy. Unfortunately, when writing CLI tools, this process has typically been very painful. We've been working with low-level frameworks for decades; frameworks like `getopt` (1980) and `curses` (1977). They fit their purpose well; they were both computationally lightweight for the computers of the day, and they gave engineers full control and flexibility when it came to how things were built. Over the years, we've used them to settle on several design patterns that we know work well. Patterns as to what a CLI command looks like, what a config file looks like, what remote execution looks like, and even how to use locks (mutexes, semaphores, etc) to control application flow and data atomicity. Yet we're stuck writing the same low-level code anytime we want to write our tooling. Not anymore.

Enter RBCli. RBCli is a framework to quickly develop advanced command-line tools in Ruby. It has been written from the ground up with the needs of the modern technologist in mind, designed to make advanced CLI tool development as painless as possible. In RBCli, low-level code has been wrapped and/or replaced with higher-level methods. Much of the functionality has even been reduced to single methods: for example, it takes just one declaration to define, load, and generate a user's config file at the appropriate times. Many other features are automated and require no work by the engineer. These make RBCli a fundamental re-thining of how we develop CLI tools, enabling the rapid development of applications for everyone from hobbyists to enterprises.


Some of its key features include:

* __Simple DSL Interface__: To cut down on the amount of code that needs to be written, RBCli has a DSL that is designed to cut to the chase. This makes the work a lot less tedious.
  
* __Multiple Levels of Parameters and Arguments__: Forget about writing parsers for command-line options, or about having to differentiate between parameters and arguments. All of that work is taken care of.

* __Config File Generation__: Easily piece together a default configuration even with declarations in different parts of the code. Then the user can generate their own configuration, and it gets stored in whatever location you'd like.

* __Multiple Hooks and Entry Points__: Define commands, pre-execution hooks, post-execution hooks, and first_run hooks to quickly and easily customize the flow of your application code.

* __Logging__: Keep track of all instances of your tool through logging. Logs can go to STDOUT, STDERR, or a given file, making them compatible with log aggregators such as Splunk, Logstash, and many others.

* __Local State Storage__: Easily manage a set of data that persists between runs. You get access to a hash that is automatically kept in-sync with a file on disk.

* __Remote State__: It works just like Local State Storage, but store the data on a remote server! It can be used in tandem with Local State Storage or on its own. Currently supports AWS DyanmoDB.  

* __State Locking and Sharing__: Share remote state safely between users with built-in locking! When enabled, it makes sure that only one user is accessing the data at any given time.

* __Automatic Update Notifications__: Just provide the gem name or git repo, and RBCli will take care of notifying users!

* __External Script Wrapping__: High-level wrapping for Bash scripts, or any other applcication you'd like to wrap into a command.

* __Project Structure and Generators__: Create a well-defined project directory structure which organizes your code and allows you to package and distribute your application as a Gem. Generators can also help speed up the process of creating new commands, scripts, and hooks!

* __Remote Execution__: Automatically execute commands on remote machines via SSH

* __Interactive Commands__: Automatically prompt users for paramter values if not given on the command line. This pattern allows for easy user interaction while still allowing scripting without the use of _expect_.

If you're just getting started with RBCli, take a look at the [Tutorial][tutorial]. Or take a look at the [Advanced] menu to look through RBCli's additional featureset.

[tutorial]: /tutorial
[advanced]: /advanced
