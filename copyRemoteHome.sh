#!/bin/bash

# https://www.accv.es/fileadmin/Archivos/manuales_tj/ubu64fxgd_c.pdf - Guia instal.lacio Drivers
# https://www.sede.fnmt.gob.es/descargas/descarga-software - Instal.lacio de drivers Crypto Key USB

set -e

if ! [ $(id -u) = 0 ]; then
   echo "Aquest script s'ha d'executar amb permisos ROOT!"
   exit 1
fi


drivers () {
	sleep 4s

	# Descarregar Drivers
  echo "Descarregant els drivers"
  sleep 2s
	wget http://www.accv.es/fileadmin/Archivos/software/scmccid_linux_64bit_driver_V5.0.21.tar.gz
	wget http://www.accv.es/fileadmin/Archivos/software/safesign_3.0_64.tar.gz

	# Instal.lar Drivers targeta criptografica
  echo "Instal.lant els drivers de la targeta criptografica"
	apt-get -y update
	apt-get -y install pcscd libpcsclite1 libccid libssl0.9.8 language-pack-ca
	tar -xzvf scmccid_linux_64bit_driver_V5.0.21.tar.gz
	cd scmccid_5.0.21_linux/
	sh ./install.sh
	/etc/init.d/pcscd restart
	cd ..

	# Instal.lar Drivers dels certificats de la targeta
  echo "Instal.lant els certificats de la targeta"
	tar -xzvf safesign_3.0_64.tar.gz
	dpkg -i safesign_3.0.33.amd64.deb

  echo  "  En cas de que fos necessari:
  ##############################################################################################
	# (a) Acceda al menú Editar > Preferencias... de Mozilla Firefox.                            #
	# (b) Seleccione el menú Avanzado. Dentro de este menú seleccione la pestaña Cifrado y       #
	# pulse sobre el botón Dispositivos de Seguridad.                                            #
	# (c) Haga clic sobre el botón Cargar e introduzca los siguientes datos en la ventana que se #
	# le abrirá:                                                                                 #
	# Nombre del módulo: “ACCV G&D PKCS#11”                                                      #
	# Nombre del archivo del módulo: /usr/lib/libaetpkss.so                                      #
  ##############################################################################################"
}

remmina (){
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

  if ssh -t $ADMIN_R@$USER_IP "sudo chmod 755 -R /home/$USERNAME"; then
	  echo "S'han restaurat els permisos de la carpeta remota"
	else
	  echo "No s'ha pogut restaurar el chmod de la carpeta d'usuari remota"
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
clear
echo ""
echo "Aquest script es un asistent per ajudar a instal.lar i configurar les eines"
echo "necessaries per emprar les targetes ACCV."
echo "Es un requeriment que la versio d'Ubuntu sigui la 14.04"
echo ""
echo "###################################################################################"
echo "# Que vols fer?                                                                   #"
echo "# 1) Instal.lar Drivers targeta electronica                                       #"
echo "# 2) Instal.lar nova versio Remmina (necessari per compartir targeta)             #"
echo "# 3) Copiar carpeta d'usuari via SSH (ha d'estar instal.lat a la maquina remota)  #"
echo "# 4) Totes les passes anteriors                                                   #"
echo "###################################################################################"
echo ""

read USER_SELECTION

if [ $USER_SELECTION -eq 1 ]
then
  echo "Es descarregaran i instal.laran els drivers..."
  sleep 5s
  clear
	drivers
fi

if [ $USER_SELECTION -eq 2 ]
then
  echo "Es descarregara i instal.lara la darrera versio de Remmina..."
  sleep 5s
  clear
  remmina
fi

if [ $USER_SELECTION -eq 3 ]
then
  echo "Es copiara la carpeta d'usuari..."
  sleep 5s
  clear
	user
fi

if [ $USER_SELECTION -eq 4 ]
then
  echo "Es realitzaran totes les passes"
  sleep 5s
  clear
	drivers
	remmina
	user
fi

#################################################################################
