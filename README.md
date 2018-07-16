# dotfiles

[![Build Status](https://travis-ci.org/ahawker/dotfiles.svg?branch=master)](https://travis-ci.org/ahawker/dotfiles)

Easily manage/deploy dotfiles using [GNU Stow](https://www.gnu.org/software/stow/).

## Status

This repository is under active development although the core functionality is in place.

## Requirements

* `$HOME` environment variable is set.
* `command` executable is available.
* `docker` executable is available. **Test Only**

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

## Installation

Below are steps for installing in an existing shell environment, installing all packages or installing individual packages. Once you've performed the _appropriate_ installation, all files will be available upon creating a new shell or sourcing your shell-specific `.rc` file again.

### Adding to an Existing Shell Environment

By default, shell-specific `.rc` files will be symlinked into your home directory. If you have existing
`.rc` files that collide with these, installation will fail.

If you want to skip installation of these shell-specific files and use your own, you'll need to include the `IGNORE_SHELL_RC_FILES` flag when installing.

```bash
$ IGNORE_SHELL_RC_FILES=1 make install
```

After doing so, you'll need to source the dotfiles entrypoint yourself:

```bash
source "$HOME/.dotfiles"
```

### All Packages

If you wish to install all dotfile packages, you should use `make install`.

### Individual Packages

If you wish to install specific dotfile packages, you should use the pattern matching make targets. These
targets follow the pattern `<action>-<package>`, e.g. `make install-bash`.

## Uninstallation

### All Packages

If you wish to uninstall all dotfile packages, you should use `make uninstall`.

### Individual Packages

If you wish to uninstall specific dotfile packages, you should use the pattern matching make targets. These
targets follow the pattern `<action>-<package>`, e.g. `make uninstall-bash`.

## Reinstallation

Reinstallation should be used if your local `dotfiles` repository copy has been updated and contains new files that do not yet have symlinks.

### All Packages

If you wish to reinstall all dotfile packages, you should use `make reinstall`.

### Individual Packages

If you wish to reinstall specific dotfile packages, you should use the pattern matching make targets. These
targets follow the pattern `<action>-<package>`, e.g. `make reinstall-bash`.

## Testing

Running the `make test` target will run `shellcheck` against all scripts within all dotfile packages.

## How does it work?

The `Makefile` leverages [GNU Stow](https://www.gnu.org/software/stow/) to create symlinks from each subdirectory, "dotfile package", into your shell home directory.

By default, as part of the symlinking process, a shell-specific `.rc` file should also be symlinked, e.g. `.zshrc`. Each of these shell-specific `.rc` file should contain a line that sources the dotfiles repository. This commonly looks like:

```bash
source "$HOME/.dotfiles"
```

The `$HOME/.dotfiles` file is the `entrypoint` into the dotfiles repository and is responsible for loading/sourcing all necessary files from within. This file exists as a separation between shell-specific `.rc` files and all the content loaded by the `dotfiles` repository.

## Contributing

If you're looking to add a dotfile package, there's a few things you should know.

* Files should be located in a subdirectory of `dotfiles`.
* Files within these subdirectories will be symlinked into the home directory.
* Nested directories are supported (see `zsh` for an example).

## Related

* [Dockerfiles](https://github.com/ahawker/dockerfiles)

## License

[Apache 2.0](LICENSE)
