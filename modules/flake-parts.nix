# Flake-level setup. Every other file in modules/ is a flake-parts module too;
# features publish NixOS / home-manager modules under flake.modules.<class>.<name>
# and hosts (modules/hosts/*) pick the features they want.
{ inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
