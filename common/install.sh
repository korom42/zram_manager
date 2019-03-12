
keytest() {
  ui_print "** Vol Key Test **"
  ui_print "** Press Vol UP **"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "**  Vol key not detected **"
    abort "** Use name change method in TWRP **"
  fi
}

# Tell user aml is needed if applicable
#if $MAGISK && ! $SYSOVERRIDE; then
#  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
#  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
#  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
#    ui_print " "
#    ui_print "   ! Conflicting audio mod found!"
#    ui_print "   ! You will need to install !"
#    ui_print "   ! Audio Modification Library !"
#    sleep 3
#  fi
#fi

# GET OLD/NEW FROM ZIP NAME
case $(echo $(basename $ZIP) | tr '[:upper:]' '[:lower:]') in
  *off* | *disab*) CONFIG=0;;
  *on* | *enab*) CONFIG=1;;
esac


# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK

ui_print " "

    if [ -e "/data/adb/swap-config.txt" ]; then
	CONFIG=$(cat /data/adb/swap-config.txt)
    fi

if [ -z $CONFIG ] || [ ! -e "/data/adb/swap-config.txt" ]  ; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "** Volume button programming **"
    ui_print " "
    ui_print "** Press Vol UP again **"
    $FUNCTION "UP"
    ui_print "**  Press Vol DOWN **"
    $FUNCTION "DOWN"
  fi

 sleep "1"


  ui_print "** Please choose zRAM configuration **"
  ui_print " "
  ui_print "   Vol(+) = Enable (Recommended)"
  ui_print "   Vol(-) = Disable"
  ui_print " "

  if $FUNCTION; then
  CONFIG=1
  ui_print "   User configuration = Enable zRAM"

  else
  CONFIG=0
  ui_print "   User configuration = Disable zRAM"

  fi
  else
   ui_print "   Using saved settings"

  if [ $CONFIG -eq 1 ]; then
   ui_print "   User configuration = Enable zRAM"
  elif [ $CONFIG -eq 0 ]; then
  ui_print "   User configuration = Disable zRAM"

  fi
fi
  if [ -e "/data/adb/swap-config.txt" ]; then
  rm "/data/adb/swap-config.txt"
  fi
  
  sed -i "s/<CONFIG>/${CONFIG}/g" ${INSTALLER}/common/service.sh
  echo ${CONFIG} > "/data/adb/swap-config.txt"
    ui_print "   Installation was successful !!.."
    ui_print " "
 

 sleep "0.5"
