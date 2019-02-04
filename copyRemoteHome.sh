#!/bin/bash
echo "EXECUTAR AMB SUPERUSER"
echo "Introdueix el nom d'usuari que es crearà"
read USERNAME

echo "Introdueix el hostname"
read HOSTNAME

hostnamectl set-hostname $HOSTNAME

echo "127.0.1.1		$HOSTNAME" >> /etc/hosts

adduser $USERNAME

echo "Usuari" $USERNAME "creat"
echo "Introdueix la IP del usuari"
read USER_IP
echo "Introdueix el nom del administrador remot"
read ADMIN_R

cp -rT /etc/skel /home/$USERNAME

echo "Introdueix la contrasenya d'administrador de l'equip remot"
ssh -t $ADMIN_R@$USER_IP "sudo chmod 777 -R /home/$USERNAME"
echo "Ara es copiara la carpeta HOME de l'usuari"
sleep 5s
rsync -r -a -v -e ssh $ADMIN_R@$USER_IP:/home/$USERNAME/  /home/$USERNAME/

chown -R $USERNAME:$USERNAME /home/$USERNAME
chmod -R 755 /home/$USERNAME

ifconfig eth2 $USER_IP netmask 255.255.255.0
echo "Quin gatweay ha de tenir?"
read GW
route add default gw $GW eth2
echo "Configurant xarxa..."


sed -i '1s/.*/LANGUAGE        DEFAULT=ca:es/' /home/$USERNAME/.pam_environment
echo "##########################################################"
echo "########  ATENCIÓ: COMPROVAR MANUALMENT LA XARXA. ########"
echo "### ES POT DONAR EL CAS DE QUE NO CANVÏ AUTOMATICAMENT ###"
echo "##########################################################"
sleep 5s
