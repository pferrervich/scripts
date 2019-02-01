#!/bin/bash
echo "EXECUTAR AMB SUPERUSER"
echo "Introdueix el nom d'usuari que es crearà"
read NEW_USERNAME

echo "Introdueix el hostname"
read HOSTNAME

hostnamectl set-hostname $HOSTNAME

echo "127.0.1.1		$HOSTNAME" >> /etc/hosts

adduser $NEW_USERNAME

echo "Usuari" $NEW_USERNAME "creat"
echo "Introdueix la IP del usuari"
read USER_IP
echo "Introdueix el nom del administrador remot"
read ADMIN_R

cp -rT /etc/skel /home/$NEW_USERNAME

echo "Introdueix la contrasenya d'administrador de l'equip remot"
rsync -r -a -v -e ssh $ADMIN_R@$USER_IP:/home/$NEW_USERNAME/  /home/$NEW_USERNAME/

chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME


ifconfig eth2 $USER_IP netmask 255.255.255.0
echo "Quin gatweay ha de tenir?"
read GW
route add default gw $GW eth2
echo "Configurant xarxa..."

sleep 5s 

ifconfig

service networking restart
