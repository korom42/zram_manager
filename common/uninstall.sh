if [ -f "/data/LKT.prop" ]; then
    rm -f "/data/LKT.prop"
fi
if [ -f "/data/soc.txt" ]; then
    rm -f "/data/soc.txt"
fi
if [ -e "/data/adb/lktprofile.txt" ]; then
    rm "/data/adb/lktprofile.txt"
fi
if [ -e "/data/adb/background.txt" ]; then
    rm "/data/adb/background.txt"
fi
if [ -e "/data/adb/foreground.txt" ]; then
    rm "/data/adb/foreground.txt"
fi
if [ -e "/data/adb/top-app.txt" ]; then  
    rm "/data/adb/top-app.txt"
fi
if [ -e "/data/adb/boost1.txt" ]; then
    rm "/data/adb/boost1.txt"
fi
if [ -e "/data/adb/boost2.txt" ]; then
    rm "/data/adb/boost2.txt"
fi
if [ -e "/data/adb/boost3.txt" ]; then
    rm "/data/adb/boost3.txt"
fi
if [ -e "/data/adb/go_hispeed.txt" ]; then
    rm "/data/adb/go_hispeed.txt"
fi;
if [ -e "/data/adb/go_hispeed_l.txt" ]; then
    rm "/data/adb/go_hispeed_l.txt"
fi;
if [ -e "/data/adb/go_hispeed_b.txt" ]; then
    rm "/data/adb/go_hispeed_b.txt"
fi;