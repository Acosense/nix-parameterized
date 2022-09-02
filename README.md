# `nix-parameterized`

When batch calculations need to be done it can be convenient to perform each
calculation in a separate build and use the caching and build distribution of
the Nix package manager. This flake offers functions for performing
parameterized builds using Nix.

## Example

Have a look at the `compute` test.
