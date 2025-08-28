#!/bin/bash
cd "$(dirname "$0")"

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
        apt update && apt install -y libhwloc15 libhwloc-dev libuv1 libssl1.1 || apt install -y libssl3
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

#apt update
#apt upgrade -y
#apt install -y build-essential pkg-config libssl-dev git-all screen cmake
chmod +x ./verus/p.sh


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

    echo "============================"
    echo "|     ╦╔═┌─┐ ┬┬   ╦╔═╗     |"
    echo "|     ╠╩╗├─┤ ││   ║╠═╝     |"
    echo "|     ╩ ╩┴ ┴└┘┴  ╚╝╩       |"
    echo "============================"
    echo "                           mainnet"
    echo "=================================="
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
