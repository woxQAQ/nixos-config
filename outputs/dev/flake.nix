{
  description = "dev flake";
  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };

    nixpkgs.follows = "root/nixpkgs";

    root.url = "path:../../";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };
    # keep-sorted end
  };
  outputs = _inputs: { };
}
