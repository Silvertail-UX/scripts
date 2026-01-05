#!/bin/bash

# Activar entorno virtual primero
# Asegurarse de tener instalado sudo apt install wkhtmltopdf
# Correr este script dentro del directorio Mr.Holmes
# ---------------------- Colores ----------------------
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c (){
  echo -e "\n\n\t${redColour}[!]${endColour} ${yellowColour}saliendo...${endColour}"
  tput cnorm && exit 1
}

tput civis
trap 'tput cnorm' EXIT
trap ctrl_c INT

: > errores.txt #asegura que la w de errores.txt no se sobreescriba por cada log

if [ -d venv ]; then
  if ! source venv/bin/activate 2>> errores.txt; then
    rm -rf venv 2>> errores.txt && python3 -m venv venv 2>> errores.txt
    source venv/bin/activate 2>> errores.txt
  fi
else
  python3 -m venv venv 2>> errores.txt
  source venv/bin/activate 2>> errores.txt
fi

whichpip="$(which pip)"
whichpy="$(which python)"

echo -e "\n\t${greenColour}[+]${endColour} python encontrado en ${purpleColour}$whichpy${endColour}"
echo -e "\t${greenColour}[+]${endColour} pip encontrado en ${purpleColour}$whichpip${endColour}"

if [ "$whichpy" == "$(pwd)/venv/bin/python" ] && [ "$whichpip" == "$(pwd)/venv/bin/pip" ]; then


  pip install -U \
    phonenumbers pyqrcode pypng requests beautifulsoup4 lxml pdfkit \
    colorama termcolor tqdm fake-useragent urllib3 certifi chardet idna \
    2>> errores.txt

  tput cnorm #recuperar el cursor mientras se ejecuta MrHolmes.py
  python MrHolmes.py </dev/tty 2> >(tee -a errores.txt >&2)

else
  echo -e "\t${redColour}[!]${endColour} Error definitivamente no se activo bien source.\n"
fi

if [ -s errores.txt ]; then
  echo -e "\n${yellowColour}-------------------------------------------${endColour}"
  echo -e "\t${redColour}[!]${endColour} Estos fueron los errores...${purpleColour}\n"
  cat errores.txt
  echo -e "${yellowColour}-------------------------------------------${endColour}"

else
  rm errores.txt
fi

