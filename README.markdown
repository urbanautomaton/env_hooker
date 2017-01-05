# env_hooker

env_hooker is a shell environment switcher, similar to
[direnv](https://github.com/direnv/direnv),
[autoenv](https://github.com/kennethreitz/autoenv) and others.

It helps to solve problems of the following type:

> I've `cd`'d to a directory containing a node project. I'd like to add
> `.node_modules/bin` to my `PATH`.

or

> I've `cd`'d to a directory containing a ruby project. I'd like to
> switch to the correct ruby version for the project, and set up gems
> to install and run from a project-specific location.

In each case we want to modify the shell environment to support a
particular project type's workflow. When we enter the project directory,
some environment manipulation is performed, and when we leave, it's
usually desirable to tear it down again.

env_hooker does this by allowing you to define hook functions that
will run when a directory is entered or exited that contains a specified
project file - for example, I might want to perform custom ruby setup
based on the presence of a `.ruby-version` file.

## Installation

Installation is still pretty basic. First clone the repo:

```
$ git clone https://github.com/urbanautomaton/env_hooker
$ cd env_hooker
```

Then:

```
# installs to /usr/local/share/env_hooker/env_hooker.sh
$ make install
```

Optionally specify `PREFIX` (default: `/usr/local`) to control
installation location:

```
# installs to /opt/share/env_hooker/env_hooker.sh
$ PREFIX=/opt make install
```

Then source the file in your .bashrc (or wherever) and start defining
hooks:

```bash
# ~/.bashrc

. /usr/local/share/env_hooker/env_hooker.sh

function enter_some_project_type() {
  # ...
}

function exit_some_project_type() {
  # ...
}

register_env_hook .somehookfile some_project_type
```

## Usage

1. pick a hook file and function root name (e.g. `.ruby-version` and
   `ruby_project`)
2. define entry and exit functions:
  * `enter_<function_root>`
  * `exit_<function_root>`
3. Register the hook in your shell setup:
  `register_env_hook <hook_file> <function_root>`

This is easiest shown by example. The following uses
[chruby](https://github.com/postmodern/chruby) to switch to the version
specified in a `.ruby-version` file, if one is present, and resets
chruby on leaving the directory.

```bash
# ~/.bashrc

. /usr/local/share/env_hooker/env_hooker.sh

function enter_ruby_project() {
  local -r project_dir=$1
  local version
  read -r version < "${project_dir}/.ruby-version"

  [[ -n "${version}" ]] && chruby "${version}"
}

function exit_ruby_project() {
  chruby_reset
}

register_env_hook .ruby-version ruby_project
```

(Note: I've used chruby as an example here because the pattern I've used
is directly inspired by chruby's own
[auto-switching](https://github.com/postmodern/chruby#auto-switching),
and I found the testing for that project to be a fantastic learning
resource. You can test bash scripts! Who knew?)

## Similar projects

See my [rambly release
article](http://urbanautomaton.com/blog/2017/01/05/envhooker-a-tiny-shell-environment-switcher/)
for a discussion of alternative projects that you should almost
certainly prefer to this one.
