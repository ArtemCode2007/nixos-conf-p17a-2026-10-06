{
  description = "NixOS 26.05 + Home Manager + Hyprland + local AI for Maibenben Perfectum P17A-R788UM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      hostname = "p17a";
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs system;
        };

        modules = [
          ./configuration.nix

          home-manager.nixosModules.default

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs system;
              };

              users.artem = ./home.nix;
            };
          }
        ];
      };
    };
}
