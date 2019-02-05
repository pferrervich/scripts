#!/bin/bash
set -e
echo "EXECUTAR AMB SUPERUSER"
echo "Introdueix el nom d'usuari que es crearà"
read USERNAME

echo "Introdueix el hostname"
read HOSTNAME

hostnamectl set-hostname $HOSTNAME

if echo "127.0.1.1		$HOSTNAME" >> /etc/hosts; then
	echo "S'ha modificat el fitxer hosts"
else
	echo "No s'ha pogut modificar el fitxer hosts"
fi

adduser $USERNAME

echo "Introdueix la IP del usuari"
read USER_IP
echo "Introdueix el nom del administrador remot"
read ADMIN_R

cp -rT /etc/skel /home/$USERNAME

echo "Introdueix la contrasenya d'administrador de l'equip remot"
if ssh -t $ADMIN_R@$USER_IP "sudo chmod 777 -R /home/$USERNAME"; then
  echo "S'han canviat els permisos de la carpeta remota"
else
  echo "No s'ha pogut canviar el chmod de la carpeta d'usuari remota"
fi
sleep 2s

echo "Es copiara la carpeta HOME de l'usuari"
sleep 4s
if rsync -r -a -v -e ssh $ADMIN_R@$USER_IP:/home/$USERNAME/  /home/$USERNAME/; then
  echo "S'ha copiat la carpeta de l'usuari"
else
  echo "No s'ha pogut copiar la carpeta remota de l'usuari"
fi

if chown -R $USERNAME:$USERNAME /home/$USERNAME; then
  echo "S'han canviat els permisos chown de la carpeta"
else
  echo "No s'han pogut canviar els permisos chown de la carpeta"
fi

if chmod -R 755 /home/$USERNAME; then
  echo "S'han canviat els permisos chmod de la carpeta"
else
  echo "No s'han pogut canviar els permisos chmod de la carpeta"
fi

ifconfig eth2 $USER_IP netmask 255.255.255.0
echo "Quin gatweay ha de tenir?"
read GW
route add default gw $GW eth2
echo "Configurant xarxa..."

if sed -i '1s/.*/LANGUAGE        DEFAULT=ca:es/' /home/$USERNAME/.pam_environment; then
  echo "S'ha canviat l'idioma del sistema"
else
  echo "No s'ha pogut canviar l'idioma del sistema"
fi

echo "##########################################################"
echo "########  ATENCIÓ: COMPROVAR MANUALMENT LA XARXA. ########"
echo "### ES POT DONAR EL CAS DE QUE NO CANVÏ AUTOMATICAMENT ###"
echo "##########################################################"
sleep 5s
