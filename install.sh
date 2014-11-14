#!/usr/bin/env bash

DEST_DIR=bin
DEST_BIN=${DEST_DIR}/As3ToHaxe.n

SETUP(){
	if [[ ! -e ${DEST_DIR} ]]; then
    mkdir ${DEST_DIR}
	fi
}

CLEAN(){
	if [ -f ${DEST_BIN} ]; then
    	rm ${DEST_BIN}
	fi
}

BUILD(){
	haxe build.hxml
	chmod +x ${DEST_BIN}
}

PROMPT(){
	while true; do
    read -p "Do you wish to install this program? " yn
    case $yn in
        [Yy]* ) INSTALL; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

INSTALL(){
	#check for /usr/local
	URL_LOCAL="/usr/local"
	if [[ ! -e ${URL_LOCAL} ]]; then
		echo "Expecting $URL_LOCAL to exist, install failed."
    	exit 1;
	fi

	URL_LOCAL_BIN="${URL_LOCAL}/bin"
	if [[ ! -e ${URL_LOCAL_BIN} ]]; then
		echo "Expecting $URL_LOCAL_BIN to exist, install failed."
    	exit 1;
	fi

	#install libary
	LIB_NAME="As3ToHaxe"
	LIB_PATH=${URL_LOCAL}/${LIB_NAME}
	if [[ -e ${LIB_PATH} ]]; then
		rm -rf ${LIB_PATH}	
	fi
	mkdir ${LIB_PATH}
	cp ${DEST_BIN} ${LIB_PATH}
	
	#install script to bin
	SCRIPT_PATH="Script/as3tohx"
	LIB_PATH=${URL_LOCAL}/${LIB_NAME}
	if [[ -e ${URL_LOCAL_BIN} ]]; then
		rm -f ${URL_LOCAL_BIN}}	
	fi
	chmod +x ${SCRIPT_PATH}
	cp ${SCRIPT_PATH} ${URL_LOCAL_BIN}
}

HELP(){
	echo "Add the following text to your .bash_profile file:"
	echo
	echo 'export PATH=/usr/local/bin:$PATH'
	echo
}

SETUP
CLEAN
BUILD
PROMPT
#HELP