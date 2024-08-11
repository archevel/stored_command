# Stored Command
This repo contains a small script for storing previously executed command as files along with all parameters etc. 

## Dependencies
- shfmt
- wordlist
- fc
- read / readarray 


## Usage
It is sometimes useful to be store a command in a shell script in order to easily re-run it. Especially if the command is long and takes a bunch of various parameters. For instance if you have a `curl` command that checks some api endpont:

```
$ curl -XGET -H 'Authorization: Bearer nunorna" https://example.com/api/endpoint
```

Now you might look this up in history, but sometimes history gets corrupted. So after running the above we can run `stc` (**st**ore **c**ommand) which will create a hidden folder in the current directory called `.stored_command` and if this is the first stored command it will be considered the `default` one and as such be stored in `.stored_command/default.sc.sh` (after prompting you to confirm the command).

Once the command is stored it can be invoked again with `rsc` (**r**un **s**tored **c**ommand). If run without parameters and with only a default command the `.stored_command/default.sc.sh` file will be passed to `source` executing the command in the current shell.

If `stc` is run once more a new file with a five letter word identifier will be generated for the new command. Subsequent runs of `rsc` without arguments will then prompt for which command to run. If the a name is provided to `rsc` e.g. `rsc happy` the `.stored_command/happy.sc.sh` file will be passed to `source`

It is also possible to store a command by passing it to `stc` eg. `stc echo hello` whould store `echo hello` as the contents of a file in `.stored_command`. One caveat to be aware of is if you use this to store a command that uses e.g. a subshell:

```
stc echo "Current time is $(date)"
```

In this case `$(date)` will be evaluated before it is passed to `stc` however first executing `echo "Current time is $(date)"` and then excuting `stc` without parameters will capture the command form the history and will then include the un-evaluated `$(date)` part. 

Additionally `lsc` can be used to list the currently stored commands in the current directory.

## Installation
Add the following line to e.g. your `.bashrc` file:

```
source <stored_command_directory>/stored_command.sh
```

This wll add the `stc`, `rsc` and `lsc` functions to new shells.
