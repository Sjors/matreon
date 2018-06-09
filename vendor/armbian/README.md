Use [Armbian](https://www.armbian.com) to (automagically) compile Linux for your device,
compile Bitcoin Core, Lightning and install all the other things you need, copy
the blockchain and create an image for your SD card.

## Ingredients

* a board supported by Armbian. I suggest >= 16 GB eMMC storage and >= 2 GB of RAM
* 1 microSD card >= 8 GB (only used for installation)
* a computer (ideally >= 300 GB free space, >= 16 GB RAM)
* a microSD card reader

## Download and prune blockchain

Download and install Bitcoin Core on your computer and wait for the full blockchain
to sync. A few hints, if you open the Preferences (`Command` + `,` on macOS):

* set "Size of database cache" to 1 GB less than your RAM (though no more than 10 GB). This makes things a lot faster.
* click Open Configuration File and enter `prune=1`
* if you have less than 200 GB of free disk space, use`prune=...` instead, with the amount in megabytes.  Make it as large as possible, no less than 30000, but leave at least 50 GB free space. Unfortunately this does slow things down a bit. When you're done, you can reduce it all the way to 2 GB.
* if you have an existing installation, make a copy of your bitcoin data directory (see below). Delete your wallet from the copy. If you don't have space for a fully copy, you can also put this copy on a USB drive.

When it's done, quit bitcoind and change `prune=1` to `prune=550`. Start Bitcoin
Core again, wait a minute and quit. This deleted all but the most recent blocks.

## Put the blockchain in a shared folder

Create a `shared` folder somewhere on your computer. Create a directory `bitcoin`
inside of it, copy the `blocks` and `chainstate` folders to it. For testnet, create
`bitcoin/testnet3` and copy `testnet3/blocks` and `testnet3/chainstate`.

## Virtual Box

Download [Virtual Box](https://www.virtualbox.org/wiki/Downloads), install it and
when it asks, also install the guest extensions. The latter lets you share a folder
between your computer and the VM.

Armbian is picky about which Ubuntu version you use, so we'll use Ubuntu 18.04 Bionic
both for the virtual machine as well as the device. If that doesn't work for some reason,
the instructions below and all scripts most likely also work for Ubuntu 16.04 Xenial.

If you already use Ubuntu 18.04 then of course you won't need the virtual machine,
though if you run into strange errors, it might be worth trying.

Download the [Ubuntu Server installer](https://www.ubuntu.com/download/server).

Here's a good [step by step guide](https://github.com/bitcoin-core/docs/blob/master/gitian-building/gitian-building-create-vm-debian.md)
for installing the VM, which some changes:

* where it says "Debian", select "Ubuntu"
* whenever you need a machine / user / disk name, enter "armbian"
* give it as many CPU's as you have, but limit them to 90% so your machine doesn't freeze
* give it at least 4 GB RAM, or 2 GB for every CPU you have, whichever is more
* disk size: 50 GB should do
* you can skip the Network Tab section, but
  * you should become familiar with SSH anyhow
  * Ubuntu doesn't enable SSH by default, so type `sudo apt-get install shh` after installation
* the Ubuntu installer is pretty similar to the Debian one shown on that page (when in doubt, press enter) 
  * it skips the root user stuff, so you just need to create a single password

Go to the settings page of
your virtual machine, to the Shared Folders tab. Click the + button, find the
folder you just created, enter `shared` as the name and check the auto mount box.



Once the installation is complete, it should reboot the VM and you should see a
login prompt. Use the password you entered earlier.

Click on the VM window and then select Insert Guest Editions CD from the Devices menu.

TODO: put most of the below in a script, split between prep and (re)build.

Get Ubuntu up to date:

```
sudo apt-get update
sudo apt-get upgrade
```

To install the Guest Editions:

```
sudo apt-get install build-essential linux-headers-`uname -r`
sudo /media/cdrom/./VBoxLinuxAdditions.run
```

If for some reason after inserting guest editions `/media/cdrom` doesn't exist, try:

```
sudo mkdir --p /media/cdrom
sudo mount -t auto /dev/cdrom /media/cdrom/
cd /media/cdrom/
sudo sh VBoxLinuxAdditions.run
```

Then reboot: `sudo reboot`


Mount the shared drive with the correct permissions:

```sh
export USER_ID=`id -u`
export GROUP_ID=`id -g`
mkdir ~/shared
sudo mount -t vboxsf -o umask=0022,gid=$GROUP_ID,uid=$USER_ID shared ~/shared
```

Make sure everything is there:

```sh
ls ~/shared
# bitcoin
ls ~/shared/bitcoin
# blocks chainstate
```

## Cross compile Bitcoin Core

We need to cross-compile Bitcoin Core and C-Lightning, because it's too slow to
do this during customize-image.

```sh
sudo apt-get install automake autotools-dev libtool g++-aarch64-linux-gnu \
                     g++-arm-linux-gnueabihf pkg-config ccache

mkdir src
git clone https://github.com/bitcoin/bitcoin.git src/bitcoin

# TODO: reuse install code between AWS and Armbian (with compile or fetch binary flag)

pushd src/bitcoin
  git checkout v0.16.1rc2
  pushd depends
    # TODO: check if 32 or 64 bit is required
    # make HOST=arm-linux-gnueabihf NO_WALLET=1 NO_UPNP=1 NO_QT=1 -j5
    make HOST=aarch64-linux-gnu NO_WALLET=1 NO_UPNP=1 NO_QT=1 -j5
  popd
  ./autogen.sh
  # TODO: check if 32 or 64 bit is required
  # ./configure --disable-bench --disable-tests --prefix=$PWD/depends/arm-linux-gnueabihf --enable-glibc-back-compat --enable-reduce-exports LDFLAGS=-static-libstdc++
  ./configure --disable-bench --disable-tests --prefix=$PWD/depends/aarch64-linux-gnu --enable-glibc-back-compat --enable-reduce-exports LDFLAGS=-static-libstdc++
  # TODO: get CPU count and memory
  make -j5 
popd
```

## Cross compile C-Lightning

TODO: figure out how to cross compile, see https://github.com/ElementsProject/lightning/pull/1558

## Armbian

Clone the Armbian repo and the Matreon customization script:

```
git clone --depth 1 https://github.com/armbian/build
git clone https://github.com/Sjors/matreon.git
```

Copy the Matreon custom build scripts to the right place:

```sh
mkdir -p build/userpatches/overlay/bin
cp matreon/vendor/armbian/customize-image.sh build/userpatches
cp matreon/vendor/armbian/lib.config build/userpatches
```

Copy bitcoind to the right place:

```sh
cp src/bitcoin/src/bitcoind src/bitcoin/src/bitcoin-cli build/userpatches/overlay/bin
```

Copy block index and chainstate:

```sh
mkdir ~/build/userpatches/overlay/bitcoin
# mkdir ~/build/userpatches/overlay/bitcoin/testnet3
cp -r ~/shared/bitcoin/blocks ~/build/userpatches/overlay/bitcoin
# cp -r ~/shared/bitcoin/testnet3/blocks ~/build/userpatches/overlay/bitcoin/testnet3
cp -r ~/shared/chainstate ~/build/userpatches/overlay/bitcoin
# cp -r ~/shared/chainstate ~/build/userpatches/overlay/bitcoin/testnet3
```

Create an SSH key if you don't have one already and then copy `~/.ssh/id_rsa.pub`
to the shared folder. If present, your pi will only be accessible via SSH using that
key, whereas password login will only work if you have physical access to the device.
              
### Start Armbian build

```sh
cd build
./compile.sh RELEASE=bionic BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no PRIVATE_CCACHE=yes
```

After some initial work, it will ask you to select your board. Do so, and then sit
back and wait... If all goes well, it should output something like:

```
[ o.k. ] Writing U-boot bootloader [ /dev/loop1 ]
[ o.k. ] Done building [ /home/armbian/build/output/images/Armbian_5.46_Nanopineoplus2_Ubuntu_bionic_next_4.14.48.img ]
[ o.k. ] Runtime [ 30 min ]
```

Move the resulting image to the shared folder so you can access it:

```sh
mv /home/armbian/build/output/images/Armbian*.img ~/shared
```

You can shut the VM down now.

## Prepare bootable microSD card

Use [Etcher](https://etcher.io) to put the resulting `.img` file on the SD card.

The first time you login your user is `pi` and your password is `pi` (you'll be ask to pick a new one).

If everything works, you can delete the VM if you like, but if you keep it around,
the second time will be faster.I haven't worked out an upgrade mechanism yet. For
the most part the device could just update itself. But for more complex changes,
it might make more sense to build a new machine image from scratch and use it
on a backup of your data.

This is a good time to enable wifi if your device supports it:

```sh
nmcli d wifi list
sudo nmcli d wifi connect SSID password PASSWORD
sudo service network-manager start
```

To connect to it via SSH, first, find the IP address (most likely under wlan, `inet 192.168.x.x`):

```sh
ifconfig
```

On your computer, edit `.ssh/config` and add:

```
Host pi-wifi
    HostName 192.168.x.x
    User pi
```

## Copy microSD card to device eMMC

The device has eMMC storage which is faster than the microSD card, and you may
want to be able to use the card.

To copy it over: 

```sh
sudo nand-sata-install
```

This powers off the device when its done. Eject the microSD card and start
the device.

The [emmc-boot service](/vendor/armbian/emmc-boot.sh) should now kick in and
start spinning up Bitcoin, Lightning and the web server. It may take a few minutes.

## Check

In your browser, go to http://192.168.0.100/ (enter the device IP address).
You'll initially get a 500 error page (rather than nothing), but after a few minutes
you Matreon page should appear!

Try signing up as your own fan and make a 1 satoshi payment.

## Your domain & HTTPS

Only do this if you're comfortable with the whole world knowing your IP address.
I'm working on Tor support as a more privacy friendly alternative.

Your device needs to be visisble from the  internet, so you have to forward port
80 and 443 from your router to the device. In addition you need to forward port 9735
so your fans can connect to your Lightning node and pay you. Ideally you should
also forward port 8883 so other Bitcoin nodes can connect to you. 

You then need to create an A Record in your domains DNS settings that points to
your IP.

Matreon will automatically obtain an HTTPS certificate for you if, during the
steps above [TODO...] you entered a domain name, enabled https and provided an
email address. As soon as it detects the A-Record, it will request the certificate
and your domain should now work at https://...

## Congrats

If you pulled this off successfully, you now have the right skills to help the
world verify that Bitcoin Core binaries are actually derived from the source code.
Consider [contributing a Gitian build](https://github.com/bitcoin-core/docs/blob/master/gitian-building.md).
