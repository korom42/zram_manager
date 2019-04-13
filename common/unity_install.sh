
ui_print " "

    if [ -e "/data/adb/swap-config.txt" ]; then
	CONFIG=$(cat /data/adb/swap-config.txt)
    fi

if [ -z $CONFIG ] || [ ! -e "/data/adb/swap-config.txt" ]  ; then

 sleep "1"


  ui_print "** Please choose zRAM configuration **"
  ui_print " "
  ui_print "   Vol(+) = Enable (Recommended)"
  ui_print "   Vol(-) = Disable"
  ui_print " "

  if $VKSEL; then
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
  
  sed -i "s/<CONFIG>/${CONFIG}/g" ${TMPDIR}/common/service.sh
  echo ${CONFIG} > "/data/adb/swap-config.txt"
    ui_print "   Installation was successful !!.."
    ui_print " "
 

 sleep "0.5"
