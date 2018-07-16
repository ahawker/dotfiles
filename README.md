# dotfiles

[![Build Status](https://travis-ci.org/ahawker/dotfiles.svg?branch=master)](https://travis-ci.org/ahawker/dotfiles)

Easily manage/deploy dotfiles using [GNU Stow](https://www.gnu.org/software/stow/).

## Status

This repository is under active development although the core functionality is in place.

## Requirements

* `$HOME` environment variable is set.
* `command` executable is available.
* `docker` executable is available. **Test Only**

## How does it work?

The `Makefile` leverages [GNU Stow](https://www.gnu.org/software/stow/) to create symlinks from each subdirectory, "dotfile package", into your shell home directory.

As part of the symlinking process, a shell-specific `.rc` file should also be symlinked, e.g. `.zshrc`. Each of these shell-specific `.rc` file should contain a line that sources the dotfiles repository. This commonly looks like:

```bash
source "$HOME/.dotfiles"
```

The `$HOME/.dotfiles` file is the `entrypoint` into the dotfiles repository and is responsible for loading/sourcing all necessary files from within. This file exists as a separation between shell-specific `.rc` files and all the content loaded by the `dotfiles` repository.

## Add to Existing Shell Environment

Installing these into an existing shell environment is not currently supported. Installation will fail if an existing shell `.rc` file already exists in its place, e.g. `.bashrc`.

## Usage

All functionality of this repository is exposed through the `Makefile`. You can see the available commands by running `make` or `make help`.

```bash
$ make help
install                        Install all dotfile packages.
reinstall                      Reinstall all dotfile packages.
uninstall                      Uninstall all dotfiles packages.
test                           Run 'shellcheck' tests against dotfile packages.
help                           Print Makefile usage.
```

### All Packages

If you wish to manage all dotfile packages, you should use `make [install|reinstall|uninstall]`.

### Individual Packages

If you wish to manage specific dotfile packages, you should use the pattern matching make targets. These
targets follow the pattern `<action>-<package>`, e.g. `make install-bash`.

### Testing

Running the `make test` target will run `shellcheck` against all scripts within all dotfile packages.

### Cleanup

Running `make uninstall` should remove all dotfile package symlinks on your machine.

## Contributing

If you're looking to add a dotfile package, there's a few things you should know.

* Files should be located in a subdirectory of `dotfiles`.
* Files within these subdirectories will be symlinked into the home directory.
* Nested directories are supported (see `zsh` for an example).

## Related

* [Dockerfiles](https://github.com/ahawker/dockerfiles)

## License

[Apache 2.0](LICENSE)
