{
  description = "dev flake";
  inputs = {
    root.url = "path:../../";
    nixpkgs.follows = "root/nixpkgs";
    # devshell = {
    #   url = "github.com:numtide/devshell";
    #   inputs.nixpkgs.follows = "root/nixpkgs";
    # };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "root/nixpkgs";
      # inputs.nixpkgs.follows = "root/nixpkgs";
      # inputs.flake-compat.follows = "flake-compat";
    };
  };
  outputs = _inputs: { };
}
