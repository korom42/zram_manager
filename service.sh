#!/system/bin/sh
sleep 60
stop perfd

    TOTAL_RAM=$(free | grep Mem | awk '{print $2}') 2>/dev/null
    if [ $TOTAL_RAM -ge 1000000 ] && [ $TOTAL_RAM -lt 1500000 ]; then
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/1000000}')
    memg=$(round ${memg} 1)
	else
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0)
    fi
    if [ ${memg} -gt 32 ];then
    memg=$(awk -v x=$memg 'BEGIN{printf("%.f\n", (x/1000)+0.5)}')
    fi

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
	if [ ${memg} -gt 4 ]; then
	disksz_mb=2048
	elif [ ${memg} -gt 2 ]; then
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
		zram_dev="/sys/block/${zram}"
	fi
		disksz_check=$(cat /sys/block/$zram/disksize);
		av_alg=$(cat /sys/block/$zram/comp_algorithm);
		case ${av_alg} in
		"zstd")
		alg="zstd"
		;;
		*)
		alg="lz4"
		;;
		esac
		write" /sys/block/${zram}/disksize" ${disksz}
		write "/sys/block/${zram}/comp_algorithm" ${alg}
		write "/sys/block/${zram}/max_comp_streams" 8
		mkswap ${zram_dev}
        ${swon} ${zram_dev} -p 32758
		
	setprop vnswap.enabled true
	setprop ro.config.zram true
	setprop ro.config.zram.support true
	setprop zram.disksize ${disksz}

	LOGDATA "#  [INFO] CONFIGURING ANDROID SWAP" 
}
function disable_swap() {
	#SR="\/dev\/"
	#PS="/proc/swap*"
	
	#DIE=`awk -v SBD="$SR" ' $0 ~ SBD {
    #  for ( i=1;i<=NF;i++ )
    #    {
    #      if ( $i ~ ( "^" SBD ) )
    #       {
    #          printf "%s;", $i
    #       }
    #    }
    #  }' $PS`

	#Copyright EarlyMon @ XDA for the code above

	#for zram_dev in $DIE; do {
    #case ${zram_dev} in
    #    *zram* | *swap* )
	#	zram=$( basename "$zram_dev" )
	#	disable_swap ${zram_dev}
	#	;;
    #esac
	#} done
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
}