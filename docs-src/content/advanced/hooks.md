---
title: "Execution Hooks"
date: 2019-06-20T15:07:21-04:00
draft: false
---

RBCli provides you with hooks that can be used to have code execute at certain places in the execution chain. These hooks are optional, and do not have to be defined for your application to run.

All hooks will be created in the `hooks/` folder in your project.

## The Defailt Action Hook

The Default hook is called when a user calls your application without providing a command. If the hook is not provided, the application will automatically display the help text (the same as running it with `-h`).

To create it in your project, run:

```bash
rbcli hook --default
# or
rbcli hook -d
```

You will then find the hook under `hooks/default_action.rb`.


## The Pre-Execution Hook

The Pre-Execution hook is called after the global command line options are parsed and before a command is executed.

To create it in your project, run:

```bash
rbcli hook --pre
# or
rbcli hook -p
```

You will then find the hook under `hooks/pre_execution.rb`.

## The Post-Execution Hook

The Pre-Execution hook is called after a command is executed.

To create it in your project, run:

```bash
rbcli hook --post
# or
rbcli hook -o
```

You will then find the hook under `hooks/post_execution.rb`.

## The First-Run Hook

The First-Run hook is called the first time a user executes your application. Using the first-run hook requires enabling [Local State Storage][state_storage] for persistence.

To create it in your project, run:

```bash
rbcli hook --firstrun
# or
rbcli hook -f
```

You will then find the hook under `hooks/first_run.rb`.


[state_storage]: /advanced/state_storage
