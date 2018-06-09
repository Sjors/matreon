#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# TODO: exit with non-zero status if anything goes wrong

sudo -s <<'EOF'  
  # Disable root login
  passwd -l root

  # User with sudo rights and initial password:
  useradd pi -m -s /bin/bash --groups sudo
  echo "pi:pi" | chpasswd
  passwd -e pi
  echo "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pi

  # Create users (without password) and groups
  useradd bitcoin -m -s /bin/bash && passwd -l bitcoin
  useradd charge -m -s /bin/bash && passwd -l charge
  useradd matreon -m -s /bin/bash && passwd -l matreon
  useradd certbot -m -s /bin/bash && passwd -l certbot

  groupadd lightningrpc 
  usermod -a -G lightningrpc bitcoin
  usermod -a -G lightningrpc charge
EOF

# TODO copy ssh pubkey if found, disable password SSH login

# Install NodeJS and Yarn
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

# Various installation scripts and systemd services: 
mkdir src
pushd src
  git clone https://github.com/Sjors/matreon.git /usr/local/src
  
  # Use branch: (TODO: switch to master)
  cd /usr/local/src/matreon && git checkout 2018/06/armbian
  
  cp /usr/local/src/matreon/vendor/**/*.service /lib/systemd/system
  cp /usr/local/src/matreon/vendor/**/*.path    /lib/systemd/system
popd

# Install Bitcoin Core
sudo cp /tmp/overlay/bin/bitcoin* /usr/local/bin

# Configure Bitcoin Core:
sudo -s <<'EOF'
  mkdir /home/bitcoin/.bitcoin
  cp /usr/local/src/matreon/vendor/bitcoin/bitcoin.conf /home/bitcoin/.bitcoin
  # TODO: get GB RAM from $BOARD or user input (menu?)
  cat /usr/local/src/matreon/vendor/bitcoin/bitcoin-1GB-RAM.conf >> /home/bitcoin/.bitcoin/bitcoin.conf

  # TODO: this assumes >= 64 MB, handle 8 / 16/ 32 MB cards: 
  echo "prune=50000" >> /home/bitcoin/.bitcoin/bitcoin.conf
  
  # TODO: offer choice between mainnet and testnet
  echo "testnet=1" >> /home/bitcoin/.bitcoin/bitcoin.conf

  # Copy block index and chain state from host:
  mkdir /home/bitcoin/.bitcoin/testnet3
  # cp -r /tmp/overlay/chainstate /home/bitcoin/.bitcoin
  cp -r /tmp/overlay/testnet3/chainstate /home/bitcoin/.bitcoin/testnet3
  # cp -r /tmp/overlay/blocks /home/bitcoin/.bitcoin
  cp -r /tmp/overlay/testnet3/blocks /home/bitcoin/.bitcoin/testnet3

  chown -R bitcoin:bitcoin /home/bitcoin/.bitcoin
EOF

# Install c-lightning
pushd src
  git clone https://github.com/ElementsProject/lightning
popd

pushd src/lightning
  # TODO: too slow, cross-compile on host VM
   make -j5 # TODO: get CPU count and memory
   sudo make install
popd

# Configure c-lightning
sudo -s <<'EOF'
  mkdir /home/bitcoin/.lightning
  cp src/matreon/vendor/lightning/config /home/bitcoin/.lightning
  # TODO: offer choice
  # echo "network=bitcoin" >> /home/bitcoin/.lightning/config
  echo "network=testnet" >> /home/bitcoin/.lightning/config
  chown -R bitcoin:bitcoin /home/bitcoin/.lightning
EOF

# Start postgres server, create database
sudo service postgresql start
sudo su - postgres <<'EOF'
   createuser matreon
   createdb -O matreon matreon
EOF

# Install Lightning Charge
sudo su - charge <<'EOF'
  touch ~/.env
  mkdir ~/.npm-global && npm config set prefix '~/.npm-global'
  echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc
  git clone https://github.com/Sjors/lightning-charge
  cd lightning-charge
  git checkout 2018/05/node-uri
  npm link
EOF

# Install Bundler for Ruby
sudo gem install bundler --no-document

# Install Matreon Rails

# Intentionally cloning this repo again, to allow seperate updating of the Rails
# app and the rest of the system:
sudo mkdir -p /var/www/matreon
sudo chown -R matreon:matreon /var/www/matreon
sudo su - matreon <<'EOF'
  git clone https://github.com/Sjors/matreon.git /var/www/matreon

  # Use branch: (TODO: switch to master)
  cd /var/www/matreon && git checkout 2018/06/armbian
EOF

sudo -H -u matreon bash -c 'echo "RAILS_ENV=production
NODE_ENV=production
DATABASE_URL=postgres:///matreon
" > ~/.env'

# Intall certbot
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx

# Finish system configuration after first boot from eMMC:
systemctl enable emmc-boot.service
