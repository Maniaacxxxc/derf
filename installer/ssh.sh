#!/bin/bash

[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || { 
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf >> /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}


    # Konfigurasi URL izin
    PERMISSION_URL="https://permision.rerechanstore.eu.org/izin.txt"
    LOCAL_IP=$(curl -s ifconfig.me) # Mendapatkan IP lokal

    # Fungsi menghitung sisa waktu
    calculate_remaining_days() {
        local today=$(date +%s)
        local expired_date=$(date -d "$1" +%s 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Tanggal kadaluwarsa tidak valid."
            exit 1
        fi
        echo $(( (expired_date - today) / 86400 ))
    }

    # Unduh izin dan validasi
    clear
    PERMISSION_DATA=$(curl -s "$PERMISSION_URL" || { echo "Gagal mengunduh izin."; exit 1; })

    # Mencocokkan data berdasarkan IP lokal
    MATCH=$(echo "$PERMISSION_DATA" | grep "###" | grep "$LOCAL_IP")
    if [ -z "$MATCH" ]; then
        echo "Your IP doesn’t have on database"
        exit 1
    fi

    # Ekstraksi data dari baris yang cocok
    USERNAME=$(echo "$MATCH" | awk '{print $2}')
    PERMISSION_IP=$(echo "$MATCH" | awk '{print $3}')
    EXPIRED_DATE=$(echo "$MATCH" | awk '{print $4}')

    # Validasi masa aktif
    REMAINING_DAYS=$(calculate_remaining_days "$EXPIRED_DATE")
    if [ "$REMAINING_DAYS" -lt 0 ]; then
        echo "Izin telah kadaluwarsa."
        exit 1
    fi

    # Output informasi izin
    output() {
        echo "Username: $USERNAME"
        echo "IPv4: $PERMISSION_IP"
        echo "Expired: $EXPIRED_DATE ( $REMAINING_DAYS Days )"
    }

    output

hosting="https://scvps.rerechanstore.eu.org"

# Menanbah Port SSH
echo -e "Port 3303" >> /etc/ssh/sshd_config
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd

# Installasi Dropbear
apt install dropbear -y
rm /etc/default/dropbear
rm /etc/issue.net
cat> /etc/issue.net << END
</strong> <p style="text-align:center"><b> <br><font color="#00FFE2"<br>┏━━━━━━━━━━━━━━━┓<br> RERECHAN STORE<br>┗━━━━━━━━━━━━━━━┛<br></font><br><font color="#00FF00"></strong> <p style="text-align:center"><b> <br><font color="#00FFE2">क═══════क⊹⊱✫⊰⊹क═══════क</font><br><font color='#FFFF00'><b> ★ [ ༆Hʸᵖᵉʳ᭄W̺͆E̺͆L̺͆C̺͆O̺͆M̺͆E̺͆
T̺͆O̺͆ M̺͆Y̺͆ S̺͆E̺͆R̺͆V̺͆E̺͆R̺͆ V͇̿I͇̿P͇̿ ] ★ </b></font><br><font color="#FFF00">ℝ𝕖𝕣𝕖𝕔𝕙𝕒𝕟 𝕊𝕥𝕠𝕣𝕖</font><br> <font color="#FF00FF">❖Ƭʜᴇ No DDOS</font><br> <font color="#FF0000">❖Ƭʜᴇ No Torrent</font><br> <font color="#FFB1C2">❖Ƭʜᴇ No Bokep </font><br> <font color="#FFFFFF">❖Ƭʜᴇ No Hacking</font><br>
<font color="#00FF00">❖Ƭʜᴇ No Mining</font><br> <font color="#00FF00">➳ᴹᴿ᭄ Oder / Trial :
https://wa.me/62858630085249 </font><br>
<font color="#00FFE2">क═══════क⊹⊱✫⊰⊹क═══════क</font><br></font><br><font color="FFFF00">❖Ƭʜᴇ WHATSAPP GRUP => https://chat.whatsapp.com/LlJmbvSQ2DsHTA1EccNGoO</font><br>
END
clear
cat>  /etc/default/dropbear << END
# disabled because OpenSSH is installed
# change to NO_START=0 to enable Dropbear
NO_START=0
# the TCP port that Dropbear listens on
DROPBEAR_PORT=111

# any additional arguments for Dropbear
DROPBEAR_EXTRA_ARGS="-p 109 -p 69 "

# specify an optional banner file containing a message to be
# sent to clients before they connect, such as "/etc/issue.net"
DROPBEAR_BANNER="/etc/issue.net"

# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)
#DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"

# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)
#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"

# ECDSA hostkey file (default: /etc/dropbear/dropbear_ecdsa_host_key)
#DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"

# Receive window size - this is a tradeoff between memory and
# network performance
DROPBEAR_RECEIVE_WINDOW=65536
END
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
#dd=$(ps aux | grep dropbear | awk '{print $2}')
#kill $dd
clear
systemctl daemon-reload
/etc/init.d/dropbear restart
clear

# Installasi WebSocket
cd /usr/bin
wget --no-check-certificate ${hosting}/other/ws  >> /dev/null 2>&1
wget --no-check-certificate ${hosting}/config/config.yaml >> /dev/null 2>&1

# Mengaktifkan Permision
chmod +x ws
chmod +x config.yaml

# Membuat Service
cat> /etc/systemd/system/ws.service << END
[Unit]
Description=WebSocket
Documentation=https://github.com/DindaPutriFN
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/ws -f /usr/bin/config.yaml
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

# Mengaktifkan Service WebSocket
systemctl daemon-reload
systemctl enable ws
systemctl start ws

# Menginstall Websocket OpenVPN
cd /usr/local/bin
wget --no-check-certificate ${hosting}/other/dinda >> /dev/null 2>&1

# Menginstall Package
apt install python3 -y

# Membuat Service
cat> /etc/systemd/system/opn.service << END
[Unit]
Description=Python Proxy Mod By geovpn
Documentation=https://t.me/geovpn
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 -O /usr/local/bin/dinda
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

# Mengaktifkan Service
systemctl daemon-reload
systemctl enable opn
systemctl start opn

# Menghapus File Tidak Penting
rm -f /root/ssh.sh
