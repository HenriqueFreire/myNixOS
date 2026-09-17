{ self, inputs, ... }: {
  flake.nixosModules.myMachineHardware = {config, lib, pkgs, modulesPath, ...}: {
     imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" "snd-hda-intel" ];
  boot.extraModulePackages = [ ];

  # Forçar driver de áudio HDA legado se necessário e garantir carregamento limpo
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/778e8913-60eb-4893-9667-62ad96a017f5";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/778e8913-60eb-4893-9667-62ad96a017f5";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4E16-CE79";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d44b1dac-09ee-4555-b056-606c640a881b";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  swapDevices =
    [ {
        device = "/dev/disk/by-uuid/44da5798-6009-4ff9-a422-6785306f3d37";
        priority = 5;
      }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = with pkgs; [
    sof-firmware
    alsa-firmware
  ];
};
}

  
