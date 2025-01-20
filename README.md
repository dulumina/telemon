# telemon
Telegram Monitoring server

## Deskripsi
Telemon adalah aplikasi monitoring server yang mengirimkan laporan status server ke Telegram. Aplikasi ini memantau penggunaan CPU, RAM, Disk, serta status layanan yang ditentukan oleh pengguna.

## Cara Menginstall
1. Unduh dan jalankan script instalasi dengan perintah berikut:
    ```sh
    sudo curl -o install.sh https://raw.githubusercontent.com/dulumina/telemon/refs/heads/main/install.sh && sudo bash install.sh
    ```

2. Ikuti petunjuk yang muncul di terminal untuk memasukkan `BOT_TOKEN`, `CHAT_ID`, dan layanan yang ingin dimonitor.

3. Jika diminta, masukkan waktu eksekusi script untuk membuat cronjob (contoh: `*/5 * * * *` untuk setiap 5 menit).

## Fitur
- Monitoring penggunaan CPU, RAM, dan Disk, Uptime server
- Memeriksa status layanan yang ditentukan.
- Mengirim laporan status server ke Telegram.
