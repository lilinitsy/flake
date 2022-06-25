{
  description = "remexre's personal flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { self, flake-utils, home-manager, nixpkgs }@inputs: {
    nixosConfigurations.cs-hmd16b-umh-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix home-manager.nixosModule ];
      specialArgs = inputs;
    };
  };
}
