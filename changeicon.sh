#!/bin/bash/
#Creates a new file in /tmp/ where the line number 210 will be changed with the new icon URI, and then replaces
#the original file in /usr/share/applications/.
#The row number can be changed with the one of your system language to take effect.
sed '210 c\Icon[es]=/home/poh/Imagenes/Pictures/Icons/mpm.png' /usr/share/applications/eog.desktop > /tmp/eog.desktop
mv /tmp/eog.desktop /usr/share/applications/

