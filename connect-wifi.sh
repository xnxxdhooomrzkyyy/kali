#!/bin/bash

Interactive Wi-Fi connect script for Kali Linux

Features:

- Scan available Wi-Fi networks

- Let user choose by number or enter SSID manually (hidden network)

- Prompt for password (hidden input)

- Try NetworkManager (nmcli) first, fallback to wpa_supplicant

set -e

Helpers

pause() { read -rp "Press Enter to continue..."; }

Detect wifi interface

WIFI_IFACE="$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')" if [ -z "$WIFI_IFACE" ]; then

try ip link style names

WIFI_IFACE="$(ip link show | awk -F: '/state UP/ && $2 ~ /wl/ {gsub(/ /, "", $2); print $2; exit}')" fi

if [ -z "$WIFI_IFACE" ]; then echo "[!] Tidak dapat menemukan interface Wi‑Fi otomatis. Masukkan nama interface (misal: wlan0):" read -r WIFI_IFACE fi

if [ -z "$WIFI_IFACE" ]; then echo "[!] Interface Wi‑Fi tidak diberikan. Keluar." exit 1 fi

echo "[+] Menggunakan interface: $WIFI_IFACE" sudo ip link set "$WIFI_IFACE" up 2>/dev/null || true

Function: scan with nmcli

scan_with_nmcli() { nmcli -t -f SSID,SECURITY,SIGNAL device wifi list ifname "$WIFI_IFACE" 2>/dev/null | sed '/^\s*$/d' }

Function: scan with iwlist

scan_with_iwlist() { sudo iwlist "$WIFI_IFACE" scan 2>/dev/null | awk -F ':' '/ESSID:/ {ssid=$2; gsub(/"/, "", ssid); getline; quality=$0; print ssid"|"quality}' | sed '/^$/d' }

Do scan

echo "Scanning Wi‑Fi networks... (this may take a few seconds)" NETS_RAW="" if command -v nmcli >/dev/null 2>&1; then NETS_RAW=$(scan_with_nmcli) fi

if [ -z "$NETS_RAW" ]; then if command -v iwlist >/dev/null 2>&1; then NETS_RAW=$(scan_with_iwlist) fi fi

if [ -z "$NETS_RAW" ]; then echo "[!] Gagal memindai jaringan (nmcli/iwlist tidak tersedia atau gagal)." echo "Anda bisa memasukkan SSID secara manual nanti." fi

Build array of SSIDs

declare -a SSIDS if [ -n "$NETS_RAW" ]; then I=0 while IFS= read -r line; do # Parse either nmcli format (SSID:SEC:SIG) or iwlist format (SSID|Quality...) if [[ "$line" == "|" ]]; then ssid="$(echo "$line" | cut -d'|' -f1)" else ssid="$(echo "$line" | cut -d: -f1)" fi # skip empty or duplicate [[ -z "$ssid" ]] && continue skip=0 for s in "${SSIDS[@]}"; do [[ "$s" == "$ssid" ]] && skip=1; done if [ $skip -eq 0 ]; then SSIDS+=("$ssid") fi done <<< "$NETS_RAW" fi

Show options

echo echo "Pilih Wi‑Fi yang ingin disambungkan:" if [ ${#SSIDS[@]} -gt 0 ]; then for idx in "${!SSIDS[@]}"; do printf "  %2d) %s\n" $((idx+1)) "${SSIDS[$idx]}" done else echo "  (Tidak ada SSID terdeteksi)" fi echo "  0) Masukkan SSID secara manual (untuk hidden network)"

read -rp $'Nomor pilihan: ' choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then echo "Pilihan tidak valid. Keluar."; exit 1 fi

if [ "$choice" -eq 0 ]; then read -rp "Masukkan SSID: " SSID else idx=$((choice-1)) if [ $idx -lt 0 ] || [ $idx -ge ${#SSIDS[@]} ]; then echo "Pilihan di luar rentang. Keluar."; exit 1 fi SSID="${SSIDS[$idx]}" fi

if [ -z "$SSID" ]; then echo "SSID kosong. Keluar."; exit 1 fi

Prompt for password (allow empty for open networks)

read -rsp "Password untuk '$SSID' (kosong jika open): " PASSWORD echo

Try nmcli first

if command -v nmcli >/dev/null 2>&1; then echo "[+] Mencoba sambungkan menggunakan nmcli..." if [ -z "$PASSWORD" ]; then sudo nmcli device wifi connect "$SSID" ifname "$WIFI_IFACE" >/dev/null 2>&1 && success=1 || success=0 else sudo nmcli device wifi connect "$SSID" password "$PASSWORD" ifname "$WIFI_IFACE" >/dev/null 2>&1 && success=1 || success=0 fi

if [ "$success" -eq 1 ]; then echo "[✅] Berhasil terhubung ke $SSID (nmcli)" nmcli connection show --active exit 0 else echo "[!] nmcli gagal menyambung. Mencoba metode fallback..." fi fi

Fallback: wpa_supplicant

if command -v wpa_passphrase >/dev/null 2>&1 && command -v wpa_supplicant >/dev/null 2>&1; then echo "[+] Menggunakan wpa_supplicant fallback" TMP_CONF="/tmp/wpa_supplicant_$(date +%s).conf" if [ -z "$PASSWORD" ]; then # open network -> create minimal conf cat > "$TMP_CONF" <<EOF network={ ssid="$SSID" key_mgmt=NONE } EOF else wpa_passphrase "$SSID" "$PASSWORD" > "$TMP_CONF" fi

sudo pkill wpa_supplicant 2>/dev/null || true sudo wpa_supplicant -B -i "$WIFI_IFACE" -c "$TMP_CONF" sleep 2 sudo dhclient -v "$WIFI_IFACE" || true

echo "Cek alamat IP untuk $WIFI_IFACE:" ip -4 addr show "$WIFI_IFACE" | grep -oP '(?<=inet\s)\d+(?:.\d+){3}/\d+' || echo "(tidak ada IP)" ping -c 3 8.8.8.8 && echo "[✅] Internet bekerja" || echo "[!] Tidak dapat ping internet" exit 0 else echo "[!] Tidak ada metode koneksi tersedia (nmcli atau wpa_supplicant)." exit 1 fi

