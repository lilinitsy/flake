{ config, lib, modulesPath, nixpkgs, pkgs, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    cleanTmpDir = true;
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "ehci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernelParams = [ "boot.shell_on_fail" ];
    loader = {
      efi.efiSysMountPoint = "/boot/efi";
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "ext4" ];
  };

  environment.variables = {
    EDITOR = "nvim";
    nixpkgs = "${nixpkgs}";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/172e4afc-36ad-41be-81bb-d3f79e5aba4c";
    fsType = "ext4";
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    i2c.enable = true;
    pulseaudio.enable = true;
  };

  home-manager = {
    extraSpecialArgs = { inherit nixpkgs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.admin.imports = [ ./home.nix ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  swapDevices = [{
    device = "/swap";
    size = 1024;
  }];

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    firewall.enable = false;
    hostName = "cs-hmd16b-umh-nixos";
    hostId = "3bae02f7";
    networkmanager.enable = true;
  };

  nix = {
    extraOptions = ''
      # Enable flakes.
      experimental-features = flakes

      # Prevent direnv/nix-shell/nix develop environments from getting GC'd.
      keep-derivations = true
      keep-outputs = true
    '';
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };

  # Allow some proprietary programs.
  nixpkgs.config.allowUnfreePredicate = pkg:
    let name = pkgs.lib.getName pkg;
    in builtins.elem name [
      "discord"
      "nvidia-settings"
      "nvidia-x11"
      "slack"
      "zoom"
    ];

  programs = {
    git = {
      config = {
        alias.lg =
          "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        core.pager = "${pkgs.delta}/bin/delta --color-only";
        init.defaultBranch = "main";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        pull.ff = "only";
        user = {
          email = "lilinitsy@gmail.com";
          name = "Ville Cantory";
        };
      };
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;
    };

    systemtap.enable = true;

    wireshark = {
      enable = true;
      package = pkgs.wireshark; # Use the GUI package.
    };
  };

  security.sudo.extraConfig = ''
    Defaults !tty_tickets
  '';

  services = {
    locate = {
      enable = true;
      localuser = null;
      locate = pkgs.mlocate;
    };

    nginx = {
      enable = true;
      # Don't enable recommendedGzipSettings, in an abundance of caution about
      # compression oracle attacks (e.g. CRIME, BREACH).
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    openssh.enable = true;

    xserver = {
      enable = true;
      desktopManager = {
        xfce.enable = true;
        xterm.enable = false;
      };
      displayManager.defaultSession = "xfce";
      videoDrivers = [ "nvidia" "modesetting" ];
    };
  };

  sound.enable = true;

  time.timeZone = "America/Chicago";

  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups =
      [ "dialout" "i2c" "networkmanager" "video" "wheel" "wireshark" ];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
