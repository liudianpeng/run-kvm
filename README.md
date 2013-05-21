RUN-KVM
=======

This is a helper utility that automates the creation of disk images and the
launch of kvm virtual machines. It isn't perfect, but I can't seem to remember
all the complicated command-line parameters and definately don't want the
complexity of libvirt.

It is as simple as I could make it and assumes you have a relatively modern
load like Debian 7.0 (Wheezy) or equivilent. You will also need to have your
box configured to use a bridge even if you only have one active network
interface. See this page for how to do it:

http://wiki.debian.org/BridgeNetworkConnections

Make sure you install bridge-utils before you make network changes. That
package is necessary to configure the network bridge for you via the interfaces
file. Speaking of which, here is what my /etc/network/interfaces file looks
like:

    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # The primary network interface
    #allow-hotplug eth0
    iface eth0 inet manual

    auto br0
    iface br0 inet dhcp
      post-up ip link set br0 address xx:xx:xx:xx:xx:xx
      bridge_ports eth0
      bridge_stp off
      bridge_fd 0
      bridge_maxwait 0

Note that setting the bridge's mac address to your ethernet card's address
will prevent the network pausing when you add and remove virtual machines.
Also note that the eth0 is set to manual since the bridge will be the
active interface.

when you run the run-kvm command with no parameters, you get this:

    Usage: run-kvm -b (n|c|d) -c cdrom.iso /path/to/disk.img
      -b Boot from network (n), disk (c) or cdrom (d)
      -c cdrom.iso is the cdrom iso image to use
      /path/to/disk.img is the disk image to use
        NOTE: If the disk image doesn't exist, you will be prompted
        to specify the size to create one.

You tell it where to boot from, supply an optional cdrom iso image if you are
installing from one, and give it a disk image. If the image isn't there, it
will prompt you to create one.

I designed this to run from the screen command, so consider using it as a
simple way to launch and manage multiple VMs. The kvm command will stay in the
foreground and allow you to interact with the QEMU monitor interface. This is
good, because there are some cool tricks you can do with it.

    $ run-kvm -b d -c debian-7.0.0-amd64-CD-1.iso encrypted.qcow2
    Running KVM in bridged mode with MAC address 52:54:89:f9:37:2c
    The Spice port will be 5900
    [sudo] password for username:
    QEMU 0.12.5 monitor - type 'help' for more information
    (qemu) set_password spice the-password-you-want
    Password: *********

To be able to connect via the spicy/spicec client, you must also set a
passphrase to the network connection. Using spicy you can pass through
your local USB devices to the VM just like they are connected.


Encrypted Disk Images
---------------------

I like using encrypted disk images for my personal system. This isn't the same
as installing Debian and picking encryption, this is using AES encryption in
KVM to basically hide the entire contents of the drive. You have to build a
blank encrypted disk first or convert an existing image to be encrypted.

To build a blank disk image, do this:

    $ qemu-img create -f qcow2 -o encryption blank.qcow2 5G
    Formatting 'blank.qcow2', fmt=qcow2 size=5368709120 encryption=on ...

To convert the blank or an existing image, do this:

    $ qemu-img convert -o encryption -O qcow2 blank.qcow2 protected.qcow2
    Disk image 'blank.qcow2' is encrypted.
    password: [hit enter]
    Disk image 'protected.qcow2' is encrypted.
    password: [type the passphrase you want to use and hit enter]

When you boot the virtual machine with an encrypted disk, the execution stops
and you have to run the 'cont' command to be prompted for the passphrase for
the disk.

    $ run-kvm -b d -c debian-7.0.0-amd64-CD-1.iso encrypted.qcow2
    Running KVM in bridged mode with MAC address 52:54:89:f9:37:2c
    The Spice port will be 5900
    [sudo] password for username:
    QEMU 0.12.5 monitor - type 'help' for more information
    (qemu) cont
    ide0-hd0 (encrypted.qcow2) is encrypted.
    Password: *********

# End
