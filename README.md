# flake

## Notes

### Apply changes to the configuration

- Run `nixos-rebuild build --flake . --print-build-logs` to try building the configuration
- Assuming it succeeds, run `sudo nixos-rebuild switch --flake .` to switch to the configuration you built
  - If you skip the build step, it'll build it automatically
  - If you want it to take effect next boot (which you might, if you're making invasive changes), you can run `sudo nixos-rebuild boot --flake .`

### Update the repos

- Run `nix flake update`

### Install a package system-wide

- Go to `home.nix` and find the `packages` option (attribute) under the `home` section (attrset).
- Find the package on https://search.nixos.org
- Add it to the `home.packages` list with a `pkgs.` on front, e.g. `pkgs.discord`
- *If* it's proprietary, you may need to mark the license as agreed-to
  - Find the list in the `nixpkgs.config.allowUnfreePredicate` setting in `configuration.nix`
  - Add the package name to there as a string, e.g. `"discord"`
  - (The error that you get from the next step will tell you the right name if you skip this step)
- Do the "Update the configuration" steps above

### Add a package to a flake devShell

(This doesn't apply to this repo, but it applies to some other projects set up with Nix+direnv.)

- Go to the `flake.nix` for the project
- Find the list of dependencies under `nativeBuildInputs`
- Add the dependency there, starting with `pkgs.` (like above)

In more complicated projects, this might not apply, but in simple ones only using Nix to fetch development dependencies (rather than building the project itself using Nix), this should generally work
