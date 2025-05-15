#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "ERROR: Please use bash not sh or other shells to run this installer. You can also run this script directly like ./install.sh"
    exit 1
fi

INTERACTIVE="yes"
REBOOTCOMPTUER="yes"
ANSWERSTART="yes"
OVERWRITESIMAGES="no"
USEEXAMPLECONFIG="no"

# Get the options
while getopts "hnr:s:o:u:" option; do
   case $option in
      n) # Noninteractive Install
         INTERACTIVE="no"
         ;;
      r) # Reboot
        REBOOTCOMPTUER=$OPTARG
        ;;
      s) # Restart opensurv
        ANSWERSTART=$OPTARG
        ;;
      o) # Overwrite Images
        OVERWRITESIMAGES=$OPTARG
        ;;
      u) # Use Example Config
        USEEXAMPLECONFIG=$OPTARG
        ;;
      h)
        # Display Help
        echo "OpenSurv Installation Script Help"
        echo
        echo "Syntax: ./install.sh [-n] [-h] [-r arg] [-s arg] [-o arg] [-u arg]"
        echo "options:"
        echo "n     Non-Interactive Install"
        echo "r     Whether to reboot compuer"
        echo "s     Whether to start OpenSurv service"
        echo "o     Whether to Overwrite Images"
        echo "u     Whether to user example config"
        echo
        exit 1
        ;;
      \?) # Invalid option
        echo "Error: Invalid option"
        exit
        ;;
   esac
done

show_version() {
    grep fullversion_for_installer "$BASEPATH/surveillance/surveillance.py" | head -n 1 | cut -d"=" -f2
}

configure_lightdm() {
  echo '[Seat:*]
autologin-user=opensurv
#autologin-session=xfce
autologin-session=opensurv
autologin-user-timeout=0' > /etc/lightdm/lightdm.conf
}

set_default_options_mpv() {
  #mpv logging may really fill your disk fast, as a precaution only log fatal errors by default
  echo 'msg-level=all=fatal' > /home/opensurv/.config/mpv/mpv.conf
}

if [ "$(id -u)" -ne 0 ];then echo "ABORT, run this installer as the root user (sudo ./install.sh)"; exit 2; fi


BASEPATH="$(cd $(dirname "${BASH_SOURCE[0]}");pwd)"

echo "Use this installer on your own risk. Make sure this host does not contain important data and is replacable"
echo "This installer will configure to boot directly into Opensurv"
echo
echo -n "The following version will be installed:"
show_version
echo
if [ x"$INTERACTIVE" == x"yes" ]; then
echo "Do you want to continue press <Enter>, <Ctrl-C> to cancel"
read
fi

#Install needed packages
apt update
apt install xdotool mpv xfce4 python3-pygame python3-xlib ffmpeg wmctrl unclutter -y

#Configure user and autologin
useradd -m opensurv -s /bin/bash
configure_lightdm

DESTPATH="/home/opensurv"
mkdir -pv "$DESTPATH"/{etc,lib,logs,bin}

SOURCEDIR="$BASEPATH/surveillance"
CONFDIR="etc"
BACKUPCONFDIR=/tmp/backup_opensurv_config_$(date +%Y%m%d_%s)

if [ x"$INTERACTIVE" == x"yes" ]; then
if [ -d "$DESTPATH/${CONFDIR}" ];then
   echo
   echo "Existing config dir will be backed up to "${BACKUPCONFDIR}""
   cp -arv "$DESTPATH/${CONFDIR}" "${BACKUPCONFDIR}"

   echo
   echo "Do you want to overwrite your current config files with the example config files?"
   echo "Type yes/no"
   read USEEXAMPLECONFIG
else
   USEEXAMPLECONFIG="yes"
fi

if [ -d /home/opensurv/lib/images ];then
   echo
   echo "Do you want to overwrite you current images directory (/home/opensurv/lib/images) with the images from the installer?"
   echo "Type yes/no"
   read OVERWRITESIMAGES
else
   OVERWRITESIMAGES="yes"
fi

echo
echo "Do you want me to (re-)start opensurv after install?"
echo "Type yes/no"
read ANSWERSTART
fi

if [ x"$OVERWRITESIMAGES" == x"yes" ]; then
  rsync -av "$SOURCEDIR/images/" "$DESTPATH/lib/images/"
fi
if [ x"$USEEXAMPLECONFIG" == x"yes" ]; then
    rsync -av "$SOURCEDIR/etc/" "$DESTPATH/etc/"
    set_default_options_mpv
fi
rsync -av "$SOURCEDIR/demo" "$DESTPATH/lib/"
rsync -av "$SOURCEDIR/core" "$DESTPATH/lib/"
rsync -av "$SOURCEDIR/surveillance.py" "$DESTPATH/lib/"
rsync -av opensurv "$DESTPATH/bin/"
rsync -av opensurv.desktop "/usr/share/xsessions/"

chown -Rc opensurv:opensurv /home/opensurv

#Link config file dir into /etc as convenient way to edit
if [ ! -L /etc/opensurv ]; then
  ln -fsv "$DESTPATH/$CONFDIR" /etc/opensurv
fi

if [ ! -f /home/opensurv/firstinstall_DONE ];then
  #We use lightdm, do not let gdm3 be in our way
  apt remove gdm3
  touch /home/opensurv/firstinstall_DONE
  if [ x"$INTERACTIVE" == x"yes" ]; then
    echo "This is first install we need to reboot"
    echo "For reboot press <Enter>"
    read
    reboot
  fi
  elif [ x"$REBOOTCOMPUTER" == x"yes" ]; then
    reboot
  fi
fi

if [ x"$ANSWERSTART" == x"yes" ]; then
    systemctl daemon-reload
    systemctl restart lightdm
fi
