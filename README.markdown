# env_hooker

env_hooker is a shell environment switcher, similar to
[direnv](https://github.com/direnv/direnv),
[autoenv](https://github.com/kennethreitz/autoenv) and others.

It helps to solve problems of the following type:

* I enter a ruby project directory. I want to switch to a
  project-specific ruby version, and set up a custom gem installation
  location.
* I enter a golang project directory. I want `GOPATH` and `PATH` set up
  to reflect this location.
* I enter a node project directory. I want
  `/path/to/project/.node_modules/bin` added to my `PATH`.

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

### direnv

[direnv](https://github.com/direnv/direnv) is very similar to
env_hooker, but works by executing the contents of a `.envrc` file, if
one is present.

env_hooker only ever directly executes code you control - direnv, by
contrast, maintains a whitelist of known `.envrc` files to protect
against malicious code execution, e.g. when cloning a repo containing an
unknown `.envrc` file.

direnv hooks in by adding a function call to `$PROMPT_COMMAND` - this is
a special bash variable whose contents are executed every time the
prompt is rendered. This means that direnv hooks will only work in
interactive shells.

direnv provides a lot of convenience functions and has some built-in
project layouts for various languages, whereas with env_hooker it's up
to you to write your own "prepend to path" helpers, for example.

Really these projects are very similar - I like mine because:

* I know how it works
* It hooks in via a DEBUG trap, so works in non-interactive shells
* I already had a bunch of shell helpers
* I didn't have to learn a new DSL

Reasons you might prefer direnv:

* a bunch of people use it
* the project layouts match your needs
* the DSL saves you doing a bunch of shell scripting
* the automated teardown saves you some time

All of which are very reasonable reasons.

### autoenv

[autoenv](https://github.com/kennethreitz/autoenv) is another very
similar project allowing the execution of custom hook code during setup.
It doesn't support teardown.

The hook code is stored in a `.env` file within the project, and it has
a whitelist-based security mechanism like direnv.

It hooks in by overriding `cd`, which I have no strong opinion about. If
you'd like a strong opinion about this, I believe the internet contains
several.

### Environment modules

Apparently [this is a similar thing](http://modules.sourceforge.net/). I
don't know exactly what sort of thing.
