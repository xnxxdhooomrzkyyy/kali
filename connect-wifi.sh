#!/bin/bash
# Script interaktif konek WiFi di Kali Linux
# Pastikan nmcli sudah terinstal

echo "===================================="
echo "     🔗 KONEKSI WIFI OTOMATIS"
echo "===================================="
echo ""

# Cek interface WiFi
INTERFACE=$(nmcli dev | grep wifi | awk '{print $1}')

if [ -z "$INTERFACE" ]; then
    echo "❌ Tidak ada interface WiFi terdeteksi!"
    echo "Coba nyalakan dulu dengan: nmcli radio wifi on"
    exit 1
fi

echo "✅ Interface WiFi terdeteksi: $INTERFACE"
echo ""

# Nyalakan WiFi
nmcli radio wifi on

# Tampilkan daftar WiFi
echo "📡 Daftar jaringan WiFi terdekat:"
nmcli dev wifi list

echo ""
read -p "Masukkan nama WiFi (SSID): " SSID
read -s -p "Masukkan password WiFi: " PASSWORD
echo ""
echo "🔗 Menghubungkan ke jaringan $SSID ..."

nmcli dev wifi connect "$SSID" password "$PASSWORD" iface "$INTERFACE"

if [ $? -eq 0 ]; then
    echo "🎉 Berhasil terhubung ke $SSID!"
    echo ""
    nmcli connection show --active
    echo ""
    ping -c 4 google.com
else
    echo "⚠️ Gagal menghubungkan ke $SSID!"
    echo "Periksa kembali nama WiFi atau password-nya."
fi
