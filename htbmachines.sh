#!/bin/bash

# ---------------------- Colores ----------------------
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# ---------------------- ctrl + c ----------------------
trap ctrl_c INT
function ctrl_c(){
  echo -e "\n\n${redColour}[!] saliendo...${endColour}${greenColour}\[>_<]/${endColour}\n"
  tput cnorm && exit 1 #recuperar el cursor y salir (por si las moscas)
}

# -------------------- Variables -----------------------
# Indicadores
declare -i parameter_counter=0
main_url="https://htbmachines.github.io/bundle.js"
# chivatos
declare -i chivato_diff=0
declare -i chivato_so=0

# ---------------------- Functiones ----------------------------

function helpPanel(){
  echo -e "\n${redColour}[>]${endColour}${yellowColour} ------------------------ Panel de ayuda ------------------------ ${endColour}"
  echo -e "\n${grayColour}Aquí tienes manual de como se usa este script${endColour} ${greenColour}\(>w<)/?!${endColour}"
  echo -e "\t${purpleColour}-h)${endColour} Mostrar este panel de ayuda."
  echo -e "\t${purpleColour}-m)${endColour} Mostrar información de una maquina (buscándola por nombre)."
  echo -e "\t${purpleColour}-u)${endColour} Buscar actualizaciones o actualizar."
  echo -e "\t${purpleColour}-i)${endColour} Buscar un nombre de máquina por medio de su ip."
  echo -e "\t${purpleColour}-y)${endColour} Mostrar el link de resolución de una maquina (buscala por nombre)"
  echo -e "\t${purpleColour}-d)${endColour} Mostrar todas las maquinas de una dificultad específica."
  echo -e "\t${purpleColour}-o)${endColour} Filtrar máquinas por sistema operativo (Windows o Linux)."
  echo -e "\t${purpleColour}-s)${endColour} Filtrar las máquinas por skills."
  echo -e "\n${redColour}[<]${endColour} ${yellowColour}-----------------------------------------------------------------${endColour}"
  echo -e ""
}

function searchMachine(){
  machineName="$1"
  comprobante="$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d ',' | tr -d '"' | sed 's/^ *//')"
  if [ ! "$comprobante" ];then
    echo -e "\n${redColour}[!] Error${endColour} maquina ${purpleColour}${machineName}${endColour} no existe ${greenColour}\(x_x)/${endColour}\n"
  else
    echo -e "\n${redColour}[+]${endColour} ${grayColour}Informacion de la maquina${endColour} ${purpleColour}$machineName${endColour}${grayColour}:${endColour}\n"
    echo -e "${comprobante}"
    echo -e ""
  fi
}

function upgrade(){
  tput civis #ocultar el cursor
  if [ ! -f bundle.js ]; then
    echo -e "\n${redColour}[+]${endColour} Creando el archivo principal ${greenColour}\_(u.u)_/${endColour}\n"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${redColour}[$]${endColour} Archivo principal creado con exito ${greenColour}:D${endColour}\n"
  else
    echo -e "\n${redColour}[+]${endColour} Comprobando si hay actualizaciones...\n"
    curl -s $main_url > temp.js
    js-beautify temp.js | sponge temp.js
    validacionmd5_1=$(md5sum temp.js | cut -d ' ' -f1)
    validacionmd5_2=$(md5sum bundle.js | cut -d ' ' -f1)
    echo -e "${purpleColour}Validacion 1 =${endColour}${redColour} $validacionmd5_1 ${endColour}\n${purpleColour}Validacion 2 =${endColour}${redColour} $validacionmd5_2 ${endColour}"
    if [ "$validacionmd5_1" == "$validacionmd5_2" ];then
      echo -e "\n${redColour}[=]${endColour} Hemos demostrado que no hay actualizaciones pendientes ${greenColour}\(u_u)/${endColour}\n"
      rm temp.js
      echo -e "${redColour}[!]${endColour} Archivo temporal borrado ${greenColour}(u.u)/${endColour}\n"
    else
      echo -e "\n${redColour}[!]${endColour} Actualizacion detectada."
      echo -e "\n${redColour}[+]${endColour} actualizando... ${greenColour}(>.<)/${endColour}"
      sleep 2
      rm bundle.js && mv temp.js bundle.js
      echo -e "\n${redColour}[=]${endColour} actualización exitosa ${greenColour}c:${endColour}\n"
    fi
  fi
  tput cnorm #recuperar el cursor
}

function searchIP(){
  ipName="$1"
  nombre="$(cat bundle.js | grep "ip: \"${ipName}\"" -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [ "$nombre" ];then
    echo -e "\n${redColour}[!]${endColour} La ip: ${purpleColour}${ipName}${endColour} pertenece a la maquina ${yellowColour}${nombre}${endColour}.\n"
  else
    echo -e "\n${redColour}[!] Error${endColour} la IP ${purpleColour}${ipName}${endColour} no existe en ninguna maquina registrada ${greenColour}(x_x)/${endColour}\n"
  fi
}

function searchLink(){
  machineName="$1"
  link="$(cat bundle.js | grep "name: \"${machineName}\"" -A10 | grep youtube | awk 'NF{print $NF}' | tr -d '"' | tr -d ",")"
  if [ "$link" ]; then
    echo -e "\n${redColour}[!]${endColour} La resolucion de la maquina ${purpleColour}${machineName}${endColour} esta en: ${yellowColour}${link}${endColour}\n"
  else
    echo -e "\n${redColour}[!] Error${endColour} la maquina ${purpleColour}${machineName}${endColour} no existe o no tiene resolucion todavia ${greenColour}\(x_x)/${endColour}\n"
  fi
}

function searchDiff(){
  diffName="$1"
  machine_names="$(cat bundle.js | grep "dificultad: \"${diffName}\"" -B5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$machine_names" ]; then
    echo -e "\n${redColour}[+]${endColour} ${grayColour}Las maquinas con la dificultad${endColour} ${purpleColour}${diffName}${endColour} ${grayColour}son las siguentes:${endColour}\n"
    echo -e "${machine_names}"
    echo -e ""
  else
    echo -e "\n${redColour}[!] Error${endColour} la dificultad ${purpleColour}${diffName}${endColour} no existe ${greenColour}(ù.ú)${endColour}"
    echo -e "${yellowColour}[=]${endColour} Prueba con las siguentes dificultades ${greenColour}(o.O)/${endColour}\n"
    echo -e "${grayColour}Fácil\nMedia\nDifícil\nInsane${endColour}"
  fi
}

function searchSO(){
  soName="$1"
  SO="$(cat bundle.js | grep "so: \"${soName}\"" -B7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ ! "$SO" ]; then
    echo -e "\n${redColour}[!] Error${endColour} no existe el SO ${purpleColour}${soName}${endColour} ${greenColour}(ò_ó)/${endColour}\n"
  else
    echo -e "\n${redColour}[+]${endColour} ${grayColour}Las maquinas con el SO${endColour} ${purpleColour}${soName}${endColour} ${grayColour}son las siguientes${endColour} ${greenColour}(o.O)/${endColour}\n\n"
    echo -e "${SO}"
    echo -e ""
  fi
}

function search_SO_Diff(){
  diffName="$1"
  soName="$2"
  comprobante="$(cat bundle.js | grep "so: \"${soName}\"" -C4 | grep "dificultad: \"${diffName}\"" -B5 | grep 'name:' | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  if [ "$comprobante" ]; then
    echo -e "\n${redColour}[+]${endColour} ${grayColour}Maquinas${endColour} ${purpleColour}${soName}${endColour} ${grayColour}con dificultad${endColour} ${purpleColour}${diffName}${endColour} ${greenColour}(o.O)/${endColour}\n"
    echo -e "${comprobante}"
    echo -e " "
  else
    echo -e "\n${redColour}[!] Error${endColour} el sistema operativo ${purpleColour}${soName}${endColour} o la dificultad ${purpleColour}${diffName}${endColour} no existen ${greenColour}(ú_ù)/${endColour}"
    echo -e "${yellowColour}[=]${endColour} Prueba con ${greenColour}(o.O)/${endColour}:\n"
    echo -e "${yellowColour}Dificultades:${endColour}"
    echo -e "${grayColour}Fácil\nMedia\nDifícil\nInsane\n${endColour}"
    echo -e "${yellowColour}Sistemas disponibles:${endColour}"
    echo -e "${grayColour}Windows\nLinux${endColour}"
    echo -e ""
  fi
}

function searchSkill(){
  skill="$1"
  comprobante="$(cat bundle.js | grep "skills:" -B7 | grep ${skill} -i -B7 2> /dev/null| grep 'name:' | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
  if [ "$comprobante" ]; then
    echo -e "\n${redColour}[+]${endColour} ${grayColour}Las máquinas con la skill${endColour} ${purpleColour}${skill}${endColour} ${grayColour}son las siguentes${endColour} ${greenColour}(o.O)/${endColour}\n"
    echo -e "${comprobante}"
    echo -e ""
  else
    echo -e "\n${redColour}[!] Error${endColour} no existe la skill ${purpleColour}${skill}${endColour}, prueba con otra ${greenColour}\(ú.ù)/${endColour}\n"
  fi
}

# --------------------------- Corazón_del_Script -----------------------------------
while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    h) ;;
    u) let parameter_counter+=2;;
    i) ipName="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) diffName="$OPTARG"; chivato_diff=1; let parameter_counter+=5;;
    o) soName="$OPTARG"; chivato_so=1; let parameter_counter=+6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $chivato_diff -eq 1 ] && [ $chivato_so -eq 1 ]; then
  search_SO_Diff $diffName $soName
elif [ $parameter_counter -eq 2 ]; then
  upgrade
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipName
elif [ $parameter_counter -eq 4 ]; then
  searchLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDiff $diffName
elif [ $parameter_counter -eq 6 ]; then
  searchSO $soName
elif [ $parameter_counter -eq 7 ]; then
  searchSkill "$skill"
else
  helpPanel
fi



