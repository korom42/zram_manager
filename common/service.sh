#!/system/bin/sh
function write() {
    echo -n $2 > $1
}
function round() {
  printf "%.${2}f" "${1}"
}
    sleep 30
    CONFIG=<CONFIG>
    TOTAL_RAM=$(awk '/^MemTotal:/{print $2}' /proc/meminfo) 2>/dev/null
    alias SWAPT='grep -i SwapTotal /proc/meminfo | tr -d "[a-zA-Z :]"'
	if [ -f /system/bin/swapon ] ; then
	swon="/system/bin/swapon"
	elif [ -f /system/xbin/swapon ] ; then
	swon="/system/xbin/swapon"
	else
	swon="swapon"
	fi
	if [ -f /system/bin/swapoff ] ; then
	swff="/system/bin/swapoff"
	elif [ -f /system/xbin/swapoff ] ; then
	swff="/system/xbin/swapoff"
	else
	swff="swapoff"
	fi

zram_reset()
{
	write "/sys/block/$1/reset" 1
	write "/sys/block/$1/disksize" 0
}
function enable_swap() {
	zram="";
	if [ ${TOTAL_RAM} -gt 3000000 ]; then
	disksz_mb=2048
	elif [ ${TOTAL_RAM} -gt 2000000 ]; then
	disksz_mb=1792
	elif [ ${TOTAL_RAM} -gt 1000000 ]; then
	disksz_mb=1024
	else
	disksz_mb=768
	fi
	disksz=$((${disksz_mb}*1024*1024))
	
    for zram in `blkid | grep swap | awk -F[/:] '{print $4}'`; do {
		zram_dev="/dev/block/${zram}"
		dev_index="$( echo $zram | grep -o "[0-9]*$" )"
		write "/sys/class/zram-control/hot_remove" ${dev_index}
		${swff} ${zram_dev} && zram_reset ${zram}
	} done
	
	if [ ! -e "/sys/class/zram-control/hot_add" ]; then
	    RAM_DEV='1'
	else
		RAM_DEV=$(cat /sys/class/zram-control/hot_add)
	fi
	if [ -z ${zram} ]; then
		zram="zram${RAM_DEV}"
		zram_dev="/dev/block/${zram}"
	fi
	# Select the fastest alghorithm available
		av_alg=$(cat /sys/block/$zram/comp_algorithm);
		case ${av_alg} in
		"zstd")
		alg="zstd"
		;;
		*)
		alg="lz4"
		;;
		esac

	${swff} ${zram_dev} > /dev/null 2>&1
	write /sys/block/${zram}/comp_algorithm ${alg}
	write /sys/block/${zram}/max_comp_streams 8
	write /sys/block/${zram}/reset 1
	write /sys/block/${zram}/disksize ${disksz_mb}M
	dd if=/dev/zero of=${zram_dev} bs=1m count=${disksz_mb}
	mkswap ${zram_dev} > /dev/null 2>&1
	${swon} ${zram_dev} > /dev/null 2>&1
	sleep 3
	
	if [ `SWAPT` -eq 0  ]; then
	# Use a different path if disk creation fails
	zram_dev="/dev/block/loop7"
	${swff} ${zram_dev}
	rm -rf /data/system/swap
	rm -rf /data/property/swapfile-run
	rm -rf /data/system/swap/swapfile
	mkdir -p /data/system/swap
	if [ ! -f /data/system/swap/swapfile ]; then
	dd if=/dev/zero of=/data/system/swap/swapfile bs=1m count=${disksz_mb}
	fi
	losetup ${zram_dev} /data/system/swap/swapfile
	mkswap ${zram_dev} > /dev/null 2>&1
	${swon} ${zram_dev} > /dev/null 2>&1
	fi

	setprop vnswap.enabled true
	setprop ro.config.zram true
	setprop ro.config.zram.support true
	setprop zram.disksize ${disksz}
	write /proc/sys/vm/swappiness 100
	write /proc/sys/vm/swap_ratio_enable 1
	write /proc/sys/vm/swap_ratio 70
}
function disable_swap() {

    for zram in `blkid | grep swap | awk -F[/:] '{print $4}'`; do {
		zram_dev="/dev/block/${zram}"
		dev_index="$( echo $zram | grep -o "[0-9]*$" )"
		write /sys/class/zram-control/hot_remove ${dev_index}
		${swff} ${zram_dev} && zram_reset ${zram}
	} done
	
	setprop vnswap.enabled false
	setprop ro.config.zram false
	setprop ro.config.zram.support false
	setprop zram.disksize 0
	write /proc/sys/vm/swappiness 0
}

    if [ ${CONFIG} -eq 0 ];then
	disable_swap
    else
	enable_swap
    fi
	
