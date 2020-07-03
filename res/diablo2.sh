#!/bin/bash
cd "$(dirname "$0")"
vga=`xrandr | grep -P " connected (primary )?\d+" | sed -e "s/\(\w\+\) .*/\1/"`
res=800x600 && off=107
python - << EOF&
import gtk
def create_window():
    window = gtk.Window()
    window.set_title('sc_bg')
    window.set_default_size(200, 200)
    window.connect('destroy', gtk.main_quit)
    color = gtk.gdk.color_parse(str('#000000'))
    window.modify_bg(gtk.STATE_NORMAL, color)
    window.set_decorated(False)
    window.show()
    window.move(-30, -30)
    window.resize(2590, 1470)
create_window()
gtk.main()
EOF
echo $! > /tmp/sc_bg.pid
sleep 0.3
xrandr --output $vga --mode $res --panning $res --transform 1.33333333,0,-$off,0,1,0,0,0,1
LD_LIBRARY_PATH=/home/pi/mesa/lib/arm-linux-gnueabihf LIBGL_DRIVERS_PATH=/home/pi/mesa/lib/arm-linux-gnueabihf/dri/ GBM_DRIVERS_PATH=/home/pi/mesa/lib setarch linux32 -L wine libd2game_sa_arm.exe.so
xrandr --output $vga --auto --panning 0x0 --scale 1x1
if [[ -e /tmp/sc_bg.pid ]]; then   
    kill `cat /tmp/sc_bg.pid`    
    rm /tmp/sc_bg.pid 
fi
