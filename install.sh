#!/bin/bash

# Periksa apakah dijalankan sebagai root
if [[ "$EUID" -ne 0 ]]; then
  echo "⚠️  Script ini harus dijalankan sebagai root. Silakan jalankan ulang dengan 'sudo'."
  exit 1
fi

echo "🚀 Mulai instalasi script monitoring..."

# Prompt untuk mengisi variabel
read -p "Masukkan Telegram BOT_TOKEN: " BOT_TOKEN
read -p "Masukkan Telegram CHAT_ID: " CHAT_ID
read -p "Masukkan layanan yang akan dimonitor (pisahkan dengan spasi, contoh: nginx apache2 php5.6): " -a SERVICES

# Buat file script monitoring
SCRIPT_PATH="/usr/local/bin/monitoring.sh"

cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

# Token dan Chat ID Telegram
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"

# Informasi Server
HOSTNAME=\$(hostname)
IP_ADDRESS=\$(hostname -I | awk '{print \$1}') # Mengambil IP pertama dari daftar

# Monitoring CPU, RAM, dan Disk
CPU_USAGE=\$(top -b -n1 | grep "Cpu(s)" | awk '{print \$2 + \$4}')
RAM_USAGE=\$(free -h | grep Mem | awk '{print \$3 "/" \$2}')
DISK_USAGE=\$(df -h | grep '/\$' | awk '{print \$3 "/" \$2 " (" \$5 ")"}')

# Menambahkan uptime server
UPTIME=\$(uptime -p) # Waktu server sudah berjalan

# Layanan yang akan diperiksa
SERVICES=(${SERVICES[@]})

# Fungsi untuk memeriksa status layanan
check_service() {
    systemctl is-active --quiet "\$1" && echo "✅ \$1: Active" || echo "❌ \$1: Inactive"
}

# Loop untuk memeriksa semua layanan dalam array
SERVICE_STATUS=""
for SERVICE in "\${SERVICES[@]}"; do
    SERVICE_STATUS+=\$(check_service "\$SERVICE")
    SERVICE_STATUS+=\$'\\n' # Tambahkan newline literal
done

# Buat pesan laporan
MESSAGE="🔔 *Server Monitoring Report*
📅 Tanggal: \$(date '+%d %B %Y')
🏷️ Hostname: *\${HOSTNAME}*
🌐 IP Address: *\${IP_ADDRESS}*

📊 CPU Usage: \${CPU_USAGE}%
📈 RAM Usage: \${RAM_USAGE}
💾 Disk Usage: \${DISK_USAGE}
⏳ Uptime: \${UPTIME}

🛠️ *Service Status*:
\${SERVICE_STATUS}"

# Kirim laporan ke Telegram
curl -s -X POST "https://api.telegram.org/bot\${BOT_TOKEN}/sendMessage" \\
  -d chat_id="\${CHAT_ID}" \\
  -d parse_mode="Markdown" \\
  -d text="\${MESSAGE}"
EOF

# Set permission agar script dapat dieksekusi
chmod +x "$SCRIPT_PATH"

echo "✅ Script monitoring telah dibuat di $SCRIPT_PATH"

# Prompt untuk membuat cronjob
read -p "Masukkan waktu eksekusi script (contoh: '*/5 * * * *' untuk setiap 5 menit, tekan Enter untuk melewati): " CRON_TIME

if [[ -n "$CRON_TIME" ]]; then
  # Tambahkan cronjob jika waktu diberikan
  (crontab -l 2>/dev/null; echo "$CRON_TIME bash $SCRIPT_PATH") | crontab -
  echo "✅ Cronjob telah ditambahkan: $CRON_TIME bash $SCRIPT_PATH"
else
  echo "ℹ️ Tidak ada cronjob yang dibuat."
fi

echo "🚀 Instalasi selesai! Monitoring script telah diatur."
