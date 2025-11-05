@echo off
echo ===============================
echo Mengaktifkan kembali Touchpad...
echo ===============================
pnputil /enable-device "Synaptics PS/2 Port TouchPad"
if %errorlevel%==0 (
    echo Touchpad berhasil diaktifkan kembali.
) else (
    echo Gagal mengaktifkan. Jalankan sebagai Administrator.
)
pause
