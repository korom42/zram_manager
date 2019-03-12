#!/system/bin/sh
function write() {
    echo -n $2 > $1
}
function round() {
  printf "%.${2}f" "${1}"
}
    CONFIG=<CONFIG>

    TOTAL_RAM=$(awk '/^MemTotal:/{print $2}' /proc/meminfo) 2>/dev/null

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
	
zram_dev()
{
	local idx="$1"
	echo "/dev/zram${idx:-0}"
}
zram_reset()
{
	write "/sys/block/$1/reset" 1
	write "/sys/block/$1/disksize" 0
}
function enable_swap() {
	zram="";
	if [ ${TOTAL_RAM} -gt 4000000 ]; then
	disksz_mb=2048
	elif [ ${TOTAL_RAM} -gt 2000000 ]; then
	disksz_mb=1792
	else
	disksz_mb=896
	fi
	disksz=$((${disksz_mb}*1024*1024))
	
    for zram in `blkid | grep swap | awk -F[/:] '{print $4}'`; do {
		zram_dev="/dev/block/${zram}"
		dev_index="$( echo $zram | grep -o "[0-9]*$" )"
		write "/sys/class/zram-control/hot_remove" ${dev_index}
		${swff} ${zram_dev} && zram_reset ${zram}
	} done
	
	zram="${zram//[[:space:]]/}"
	ZRAM_SYS_DIR='/sys/class/zram-control'
	if [ ! -d "${ZRAM_SYS_DIR}" ]; then
	    RAM_DEV='1'
	else
		RAM_DEV=$(cat /sys/class/zram-control/hot_add)
	fi
	if [ -z ${zram} ]; then
		zram="zram${RAM_DEV}"
		zram_dev="/dev/block/${zram}"
	fi
		av_alg=$(cat /sys/block/$zram/comp_algorithm);
		case ${av_alg} in
		"zstd")
		alg="zstd"
		;;
		*)
		alg="lz4"
		;;
		esac

	swapoff ${zram_dev}
	write /sys/block/${zram}/reset 1
	write /sys/block/${zram}/comp_algorithm ${alg}
	write /sys/block/${zram}/max_comp_streams 8
	write /sys/block/${zram}/disksize ${disksz_mb}M
	dd if=/dev/zero of=${zram_dev} bs=1m count=${disksz_mb}
	mkswap ${zram_dev}
	${swon} ${zram_dev} -p 32758
		
	setprop vnswap.enabled true
	setprop ro.config.zram true
	setprop ro.config.zram.support true
	setprop zram.disksize ${disksz}
	write /proc/sys/vm/swappiness 60
}
function disable_swap() {

    for zram in `blkid | grep swap | awk -F[/:] '{print $4}'`; do {
		zram_dev="/dev/block/${zram}"
		dev_index="$( echo $zram | grep -o "[0-9]*$" )"
		write /sys/class/zram-control/hot_remove ${dev_index}
		${swff} ${zram_dev} && zram_reset ${zram}
	} done
	
	
    local 

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
	exit 0
