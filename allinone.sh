#!/bin/bash
# based on DrSmyrke
#
# Any original DrSmyrke code is licensed under the BSD license
#
# All code written since the fork of DrSmyrke is licensed under the GPL
#
#
# Copyright (c) 2016 Prokofiev Y. <Smyrke2005@yandex.ru>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#
#set -o nounset -o errexit
#if ! [ $1 ];then echo "Usage $0 -h";fi



function buildPkt_all(){
	if [ ! -f "$1/DEBIAN/control" ]; then return 0; fi;
	version=$(cat $1/DEBIAN/control | grep Version | awk '{print $2}');
	fakeroot dpkg-deb --build $1 && mv $1.deb $PACKETS_DIR/$2_$version\_all.deb
}
function buildPkt(){
	if [ ! -f "$1/DEBIAN/control" ]; then return 0; fi;
	version=$(cat $1/DEBIAN/control | grep Version | awk '{print $2}');
	fakeroot dpkg-deb --build $1 && mv $1.deb $PACKETS_DIR/$2_$version\_$3.deb
}



case $1 in
	"-h"|"--help")
	echo "Usage:	$0 <SCRIPT> ARGUMENTS"
	echo "Scripts:"
	echo "s1 - Current video driver"
	echo "s2 - View progress at dd"
	echo "s3 - Clear swap"
	echo "s4 - Your IP"
	echo "s5 - Ping wour LAN"
	echo "s6 - Streaming WebCam to Lan (http://localhost:port/1.ogv) <port>"
	echo "s7 - Add current user to group vboxusers"
	echo "s8 - Face control"
	echo "s9 - makeCasperRW <size> (default 280Mb)"
	echo "s10 - convert man page to pdf <command>"
	echo "s11 - view 1-100 percents"
	echo "s12 - check port open <host> <port>"
	echo "s13 - Password recovery root"
	echo "s14 - GRUB recovery"
	echo "s15 - decode HEX to UTF-8 <string>"
	echo "s16 - unlock USB GSM modem <unlock code> <device> #/dev/ttyUSB{0,1,2} #unlock code get http://a-zgsm.com/freecode/"
	echo "s17 - pstree"
	echo "s18 - screenCast"
	echo "s19 - screenCast NOSOUND"
	echo "s20 - write ISO image to USB flash"
	echo "s21 - CPU usage"
	echo "s22 - DISTRIBUTIVE info"
	echo "s23 - LED ScrollLock on/off"
	echo "s24 - Echo IP to name <IP>"
	echo "s25 - Enter password"
	echo "s26 - Current day"
	echo "s27 - Install DEV Packets"
	echo "s28 - Generate SSH RSA key in current folder"
	echo "s29 - Create 10Gb in ZIP File"
	echo "s30 - Endless launch of the team <COMMAND>"
	echo "s31 - "
	echo "s32 - List all HDD & UUID"
	echo "s33 - Change bitVal for ~/.vine <32|64>"
    echo "s34 - Network activity"
	echo "s35 - Play videofile to ASCII symbols"
	echo "s36 - SNIFF Traffic remote server <SERVER ADDR>"
	echo "s37 - rsync directory <SSH PORT|22> <SYNC DIR> <remore user> <remote server> <remote dir> <[y] from show notify-send message>"
	echo "s38 - Create ext4 file <FILENAME> <SIZE Megabytes>"
	echo "s39 - Make DEB package <DIR> <packet-name> <all|i386|amd64>"
	echo "s40 - Mount WebDAV <URL> (https only) <MOUNT DIR>"
	echo "s41 - Mount SSHFS <USERNAME> <SSH SERVER> <REMOTE PATH> <LOCAL PATH>"
	echo "s42 - Get random file <DIR>"
	echo "s43 - Modify Script Bin for Cubieboard2"
	echo "s44 - Generator NMEA"
	echo "s45 - SSH PROXY4 <LOCAL_PORT> <SSH SERVER CONNECT LINE>"
	echo "s46 - "
	echo "s47 - "
	echo "s48 - "
	echo "s49 - "
	echo "s50 - "
	;;
	"s1")	grep -Eiwo -m1 'nvidia|amd|ati|intel' /var/log/Xorg.0.log	;;
	"s2")	watch -n 5 sudo killall -USR1 dd	;;
	"s3")	sudo swapoff -a && sudo swapon -a	;;
	"s4")
		MYIP=$(wget -O - -q http://drsmyrke.ru/other/info/ip.php);
		echo $MYIP;
	;;
	"s5")
		echo -n "Enter IP range (192.168.1):"
		read range
		if ! [ $range ];then range="192.168.1";fi
		echo -n "Enter $range."
		read lsubrange
		if ! [ $lsubrange ];then lsubrange="0";fi
		echo -n "Enter IP subrange high $range.$lsubrange-"
		read hsubrange
		if ! [ $hsubrange ];then hsubrange="255";fi
		for ((i=$lsubrange; i<=$hsubrange; i++)); do
			status=$(ping "$range.$i" -c 1 2>/dev/null | grep "packet loss" | awk '{print $6}' | awk -F'%' '{print $1}');
			if [ "$status" = "0" ]; then echo -e "\e[1;32m$range.$i	OnLine\e[0m";fi
			if [ "$status" = "+1" ]; then echo -e "\e[1;31m$range.$i	OffLine\e[0m";fi
		done
	;;
	"s6")
		vlc -I dummy screen:// --sout "#transcode{vcodec=theo,vb=1200,scale=0,acodec=vorb,ab=128,fps=24}:standard{access=http,mux=ogg,dst=:$2/1.ogv}"
	;;
	"s7")	sudo usermod -a -G vboxusers $USER	;;
	"s8")
		cmd=$(date +\%Y-\%m-\%d-\%H-\%M-\%S)
		if [ ! -d "~/.FaceControl" ]; then mkdir ~/.FaceControl; fi;
		ffmpeg -f video4linux2 -s 640x480 -i /dev/video0 -f image2 "~/.FaceControl/$cmd.jpg"
	;;
	"s9")
		size=280
		if [ $2 ];then size=$2;fi
		sudo dd if=/dev/zero of=casper-rw bs=1M count=$size
		sudo mkfs.ext4 casper-rw
		#sudo mount casper-rw /tmp/temp -o loop
	;;
	"s10")	man -t $2 | ps2pdf - $2.pdf	;;
	"s11")	echo -n "percents -    "; for i in {1..100}; do sleep 0.1; echo -ne '\e[4D'; printf "% 3d%%" $i; done; echo	;;
	"s12")
		if [[ "$(echo "quit" | telnet $2 $3 2>/dev/null | grep 'Escape\ character' | wc -l)" -eq "1" ]]; then echo "OPEN"; else echo "CLOSED"; fi
	;;
	"s13")
		sudo fdisk -l
		echo "Enter the name of the partition (example: sda1):"
		read razd
		sudo mount /dev/$razd /mnt
		sudo chroot /mnt
		sudo passwd root
		exit
		sudo umount /mnt
	;;
	"s14")
		sudo fdisk -l
		echo "Enter the name of the partition (example: sda1):"
		read razd
		sudo mount /dev/$razd /mnt
		sudo grub-install --root-directory=/mnt /dev/$razd
		sudo update-grub --output=/mnt/boot/grub/grub.cfg
		sudo umount /mnt
	;;
	"s15")
		len=$(echo $2 | awk '{print length}' || echo -n $2 | wc -c || expr length $2);
		echo "===================="
		for ((i=0; i<$len; i+=2)); do
			echo -e -n "\x"${2:$i:2}
		done
		echo ""
	;;
	"s16")
		sudo su -c "echo -e 'AT^CARDLOCK=$2\r\n' >$3"
		#PS-1: Еще насколько полезных команд:
		#AT^U2DIAG=0 (режим "только модем")
		#AT^U2DIAG=1 (режим "модем + CD-ROM")
		#AT^U2DIAG=255 (режим "модем + CD-ROM + Card Reader")
		#AT^U2DIAG=256 (режим "модем + Card Reader")
	;;
	"s17")	ps fax	;;
	"s18")
		#vlc -I dummy screen:// --sout "#transcode{vcodec=theo,vb=1200,scale=0,acodec=vorb,ab=128,fps=24}:standard{access=http,mux=ogg,dst=:$port/1.ogv}"
		#pacmd list-sources | grep "name:"
		cvlc screen:// --screen-fps=25.000000 --input-slave=pulse://alsa_input.pci-0000_00_1b.0.analog-stereo --live-caching=300 --sout "#transcode{vcodec=h264,vb=7000,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:file{dst=$HOME/MyScreenCast.mp4}"
	;;
	"s19")
		cvlc screen:// --screen-fps=25.000000 --live-caching=300 --sout "#transcode{vcodec=h264,vb=5000,scale=1}:file{dst=$HOME/MyScreenCast.mp4}"
	;;
	"s20")	sudo mintstick -m iso	;;
	"s21")
	PREV_TOTAL=0
	PREV_IDLE=0
	while true; do
	CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
	unset CPU[0]                          # Discard the "cpu" prefix.
	IDLE=${CPU[4]}                        # Get the idle CPU time.

	TOTAL=0
	for VALUE in "${CPU[@]}"; do
		let "TOTAL=$TOTAL+$VALUE"
	done

	let "DIFF_IDLE=$IDLE-$PREV_IDLE"
	let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
	let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
	echo -en "\rCPU: $DIFF_USAGE%  \b\b"

	PREV_TOTAL="$TOTAL"
	PREV_IDLE="$IDLE"

	sleep 1
	done
	;;
	"s22")
		cat /proc/version
		lsb_release -a
		cat /etc/*-release
	;;
	"s23")	for i in {1..100}; do xset led named "Scroll Lock" ;sleep 0.05 ;xset -led named "Scroll Lock"; sleep 0.05; done;	;;
	"s24")	net lookup $2	;;
	"s25")
		echo -n "Enter password: "
		stty -echo
		read password
		stty echo
		echo ""
		echo "Your password: [$password]"
	;;
	"s26")	calendar	;;
	"s27")
		sudo apt-get install qtcreator qt5-doc qttranslations5-l10n qttools5-dev-tools g++ gcc cmake mc qtbase5-dev git meld ghex dpkg debconf debhelper unetbootin extlinux vim qconf qt5-default libqt5x11extras5 libqt5x11extras5-dev libqt5serialport5-dev libudev1 libudev-dev
		sudo apt-get install gcc-avr avrdude avr-libc
		sudo apt-get install gpxviewer openstreetmap-client
		sudo apt-get install fakeroot dpkg-dev
	;;
	"s28")	ssh-keygen -t rsa -b 4096 -f ./ssh-new_key-rsa	;;
	"s29")	dd if=/dev/zero bs=1M count=10240 | gzip > 10G.gzip	;;
	"s30")	while [ 1 ]; do $2; sleep 3; done;	;;
	"s31")
		
	;;
	"s32")
		ls -l /dev/disk/by-uuid
		sudo blkid
	;;
	"s33")
		if [ $2 = "32" ];then
			rm -r ~/.wine
			WINEARCH=win32 WINEPREFIX=~/.wine winecfg
		fi
		if [ $2 = "64" ];then
			rm -r ~/.wine
			WINEARCH=win64 WINEPREFIX=~/.wine winecfg
		fi
	;;
	"s34")
		lsof -i
		sudo netstat -uplnt
	;;
	"s35")	mplayer -vo $2	;;
	"s36")
		ssh $2 tcpdump -U -s0 -w - 'not port 22' | wireshark -k -i -
	;;
	"s37")
		if [ $2 -a $3 -a $4 -a $5 -a $6 ];then
			rsync -azpgtlF --delete-excluded --prune-empty-dirs -e "ssh -p $2" $3 $4@$5:$6
			if [ $7 = "y" ];then
				notify-send --icon terminal "Sync complete" "$3\nto\n$6"
			fi
		else
			$0 -h
		fi
	;;
	"s38")
		if [ $2 -a $3 ];then
			dd if=/dev/zero of=$2 bs=1048576 count=$3
			mkfs.ext4 $2
		else
			$0 -h
		fi
	;;
	"s39")
		if [ -d $2 ]; then
			if [ $3 ];then
				if [ $4 ];then
					case $4 in
						"all")		buildPkt_all $2 $3		;;
						"i386")		buildPkt $2 $3 "i386"	;;
						"amd64")	buildPkt $2 $3 "amd64"	;;
					esac
				fi
			fi
		fi
	;;
	"s40")
		mount -t davfs $2 $3 -o uid=$UID,gid=$GID,rw
	;;
	"s41")
		sshfs $2@$3:$4 $5 -o uid=$UID,gid=$GID,reconnect
	;;
	"s42")
		FILE=$(find $2 -type f | shuf -n 1);
		echo $FILE
	;;
	"s43")
		mount /dev/nanda /mnt
		cd  /mnt
		bin2fex script.bin script.fex
		vim script.fex
		fex2bin script.fex script.bin
		cd /
		umount /mnt
		reboot
	;;
	"s44")
		while true; do
			SUM=0
			str=\$GPGGA,$(printf "%02d" $[$(date +%H)-3])$(date +%M%S.%N),,N,,E,1,08,0.9,0.0,M,0.0,M,0.0,,
			for (( ix=1; ix<$(expr length $str); ix++)) ;do SUM=$[SUM ^ $(printf '%d' "'${str:$ix:1}'")]; done
			echo -e "${str}$(printf "%02x" $SUM|sed 's/./\U&/')\n"
			sleep 0.5
			str=\$GPGSV,1,1,12,02,86,172,,09,62,237,,22,39,109,,27,37,301,,
			for (( ix=1; ix<$(expr length $str); ix++)) ;do SUM=$[SUM ^ $(printf '%d' "'${str:$ix:1}'")]; done
			echo -e "${str}$(printf "%02x" $SUM|sed 's/./\U&/')\n"
			sleep 0.5
			str=\$GPRMC,$(printf "%02d" $[$(date +%H)-3])$(date +%M%S.%N),A,,N,,E,0.0,0.0,$(date +%d%m%y),0.0,E,
			for (( ix=1; ix<$(expr length $str); ix++)) ;do SUM=$[SUM ^ $(printf '%d' "'${str:$ix:1}'")]; done
			echo -e "${str}$(printf "%02x" $SUM|sed 's/./\U&/')\n"
			sleep 0.5
		done
	;;
	"s45") ssh -D $2 $3 ;;
	"s46")
	;;
	"s47")
	;;
	"s48")
	;;
	"s49")
	;;
	"s50")
	;;
esac



#############################################################
#if [ $1 = "s39" ];then
#	ssh $rUser@$rHomeServer -p $rPort "if [ -d $DIR ];then mkdir '$DIR/$date'; if [ -d $DIR/lastest ];then rm '$DIR/lastest'; fi; ln -s '$DIR/$date' '$DIR/lastest'; fi;"
#	rsyncCmd ~/bin $rUser@$rHomeServer:$DIR/lastest/
#	rsyncCmd ~/Docs $rUser@$rHomeServer:$DIR/lastest/
#	rsyncCmd ~/Desktop $rUser@$rHomeServer:$DIR/lastest/
#	notify-send "Sync" "complete"
#fi
#if [ $1 = "s40" ];then
#	rsyncCmd ~/ $rUser@$rHomeServer:$DIR/home/
#	notify-send "Sync" "complete"
#fi
#############################################################

exit 0
