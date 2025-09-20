#!/bin/bash
# Installer hcxdumptool + hcxtools manual build dari GitHub

set -e

echo "[*] Update repository..."
sudo apt update

echo "[*] Install dependencies..."
sudo apt install -y git build-essential pkg-config \
  libpcap-dev libcurl4-openssl-dev libssl-dev \
  zlib1g-dev libbz2-dev liblzma-dev libsqlite3-dev

echo "[*] Clone & build hcxdumptool..."
if [ -d "hcxdumptool" ]; then
  rm -rf hcxdumptool
fi
git clone https://github.com/ZerBea/hcxdumptool.git
cd hcxdumptool
make
sudo make install
cd ..

echo "[*] Clone & build hcxtools..."
if [ -d "hcxtools" ]; then
  rm -rf hcxtools
fi
git clone https://github.com/ZerBea/hcxtools.git
cd hcxtools
make
sudo make install
cd ..

echo "[*] Instalasi selesai!"
echo "Coba jalankan: hcxpcapngtool --help atau hcxdumptool --help"
