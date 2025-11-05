@echo off
echo ===============================
echo Menonaktifkan Touchpad...
echo ===============================
pnputil /disable-device "Synaptics PS/2 Port TouchPad"
if %errorlevel%==0 (
    echo Touchpad berhasil dinonaktifkan.
) else (
    echo Gagal menonaktifkan. Jalankan sebagai Administrator.
)
pause
