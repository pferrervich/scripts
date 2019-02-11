#!/bin/bash

# https://www.accv.es/fileadmin/Archivos/manuales_tj/ubu64fxgd_c.pdf - Guia instal.lacio Drivers

set -e
echo "EXECUTAR AMB SUPERUSER"


drivers () {
	echo "Instal.lant els drivers de la targeta electrònica"
	sleep 4s

	# Descarregar Drivers
	wget http://www.accv.es/fileadmin/Archivos/software/scmccid_linux_64bit_driver_V5.0.21.tar.gz
	wget http://www.accv.es/fileadmin/Archivos/software/safesign_3.0_64.tar.gz

	# Instal.lar Drivers targeta criptografica
	apt-get -y update
	apt-get -y install pcscd libpcsclite1 libccid libssl0.9.8 language-pack-ca
	tar -xzvf scmccid_linux_64bit_driver_V5.0.21.tar.gz
	cd scmccid_5.0.21_linux/
	sh ./install.sh
	/etc/init.d/pcscd restart
	cd ..

	# Instal.lar Drivers dels certificats de la targeta
	tar -xzvf safesign_3.0_64.tar.gz
	dpkg -i safesign_3.0.33.amd64.deb

	#(a) Acceda al menú Editar > Preferencias... de Mozilla Firefox.
	#(b) Seleccione el menú Avanzado. Dentro de este menú seleccione la pestaña Cifrado y
	#pulse sobre el botón Dispositivos de Seguridad.
	#(c) Haga clic sobre el botón Cargar e introduzca los siguientes datos en la ventana que se
	#le abrirá:
	# Nombre del módulo: “ACCV G&D PKCS#11”
	# Nombre del archivo del módulo: /usr/lib/libaetpkss.so
}

remmina (){
	echo "Instal.lació nova versio Remmina"
	sleep 4s

	apt-get purge remmina
	sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
	sudo apt-get -y update
	sudo apt-get -y install remmina remmina-plugin-rdp libfreerdp-plugins-standard

}

user (){
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

	if sed -i '1s/.*/LANGUAGE        DEFAULT=ca:es/' /home/$USERNAME/.pam_environment; then
	  echo "S'ha canviat l'idioma del sistema"
	else
	  echo "No s'ha pogut canviar l'idioma del sistema"
	fi

	ifconfig eth0 $USER_IP netmask 255.255.255.0
	echo "Quin gatweay ha de tenir?"
	read GW
	route add default gw $GW eth0
	echo "Configurant xarxa..."


	echo "##########################################################"
	echo "########  ATENCIÓ: COMPROVAR MANUALMENT LA XARXA. ########"
	echo "### ES POT DONAR EL CAS DE QUE NO CANVÏ AUTOMATICAMENT ###"
	echo "##########################################################"
	sleep 5s
}

#################################################################################

echo "Que vols fer?"
echo "1) Instal.lar Drivers targeta electronica"
echo "2) Instal.lar nova versio Remmina (necessari per compartir targeta)"
echo "3) Copiar carpeta d'usuari via SSH (ha d'estar instal.lat a la maquina remota)"
echo "4) Totes les passes anteriors"

read USER_SELECTION

if [ $USER_SELECTION -eq 1 ]
then
	drivers
fi

if [ $USER_SELECTION -eq 2 ]
then
 	remmina
fi

if [ $USER_SELECTION -eq 3 ]
then
	copyUser
fi

if [ $USER_SELECTION -eq 4 ]
then
	drivers
	remmina
	user
fi

#################################################################################
