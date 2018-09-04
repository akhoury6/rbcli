# Interactive Commands

## Why interactive commands?

When catering to an audience of users who are not accustomed to scripting, you may want to prompt them for the information directly (the typical CS-101 'puts' and 'gets' pattern). This can be a lot more straightforward than having to read the help texts of your tool, and trying multiple times to enter all of the required data.

Of course, we want to make sure that scripting with the tool still works well (headless interaction). We accomplish this by extending our parameters with a `prompt` option; RBCli will continue to accept the parameter as usual, but if the parameter is omitted then it will prompt the user with the given text.

## How to do it with Rbcli

There is an option when declaring a command's parameters to prompt the user for a value if not entered on the command line. This can be done with the `prompt:` keyword. For example:

```ruby
class Mycmd < Rbcli::Command
	parameter :sort, 'Sort output alphabetically', type: :boolean, default: false, prompt: "Sort output alphabetically?"
	action do |params, args, global_opts, config|
		puts params[:sort]
	end
end
```

Now, if we run the command while omitting the `--sort` parameter, as such:

```bash
mytool mycmd
```

That should give you the prompt:

```
Sort output alphabetically? (y/N):
```

Because we set the parameter to default to `false` the default here is `N`, which is used if the user hits enter without entering a letter. If the default was set to `true`, then the `Y` would be capitalized and be the default.

String parameters behave similarly, but default to the string defined instead of a boolean value.
 