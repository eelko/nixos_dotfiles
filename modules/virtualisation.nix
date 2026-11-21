# VM host: KVM/QEMU via libvirt, managed with virt-manager.
# GPU: guests get paravirtualized OpenGL (virtio-gpu + virgl) through the host
# GPU. Per VM in virt-manager: Video = Virtio + "3D acceleration",
# Display Spice = Listen "None" + "OpenGL" (render node /dev/dri/renderD128).
{
  flake.modules.nixos.vm-host = { pkgs, ... }: {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;   # built with virglrenderer + OpenGL
        swtpm.enable = true;       # TPM for guests that want it
      };                           # OVMF/UEFI firmware ships by default
    };
    virtualisation.spiceUSBRedirection.enable = true; # pass USB devices into guests
    programs.virt-manager.enable = true;

    # libvirt's default NAT network: let guest DHCP/DNS through the host firewall.
    networking.firewall.trustedInterfaces = [ "virbr0" ];

    # Bring up the default NAT network on every boot.
    systemd.services.libvirt-default-network = {
      description = "Start libvirt default NAT network";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        virsh=${pkgs.libvirt}/bin/virsh
        $virsh net-autostart default
        $virsh net-info default | grep -q '^Active:.*yes' || $virsh net-start default
      '';
    };

    users.users.eelko.extraGroups = [ "libvirtd" "kvm" ];
  };
}
