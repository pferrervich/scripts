#!/bin/bash
# Una vegada recuperada la imatge original GESTIONA, s'ha de redimensionar amb gparted
# ABANS DE FER SSH, S'HA DE FER CHMOD 777 A LA CARPETA Usuari, I UNA VEGADA COPIADA
# SHA DE FER chmod 755 directory_name A NES LOCAL
# TODO: To change desktop language, in ~/.pam_environment     LANGUAGE  DEFAULT=ca:es
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
ssh $ADMIN_R@$USER_IP@ "chmod 777 -R /home/$NEW_USERNAME"
echo "Ara es copiara la carpeta HOME de l'usuari"
sleep 5s
rsync -r -a -v -e ssh $ADMIN_R@$USER_IP:/home/$NEW_USERNAME/  /home/$NEW_USERNAME/

chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME
chmod -R 755 /home/$NEW_USERNAME

ifconfig eth2 $USER_IP netmask 255.255.255.0
echo "Quin gatweay ha de tenir?"
read GW
route add default gw $GW eth2
echo "Configurant xarxa..."

sleep 5s
