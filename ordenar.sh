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
  echo -e "\n\n${redColour}[!] saliendo...${endColour}${greenColour} \[>_<]/${endColour}\n"
  tput cnorm && exit 1 #recuperar el cursor y salir (por si las moscas)
}

arg_value=0
# --------------------- functions ---------------------

function desordenar(){
  echo -en "\n${yellowColour}[?]${endColour} En qué directorio están los ficheros que se van a desordenar? ${purpleColour}(escribir directorio completo):${endColour}" && read dir
  tput civis

  if [ -d "$dir" ]; then
    cd $dir 2>/dev/null
    command_status=$?
    echo -e "\n\t${turquoiseColour}[+]${endColour} Accediendo al directorio ${purpleColour}$dir${endColour}"
    if [ ! $command_status -eq 0 ]; then
      echo -e "\t${redColour}[!] Error: No se tienen los permisos necesarios para acceder al directorio ${purpleColour}$dir${endColour}" && tput cnorm && exit 1
    fi
  else
    echo -e "\n\t${redColour}[!] Error: Ingrese un directorio x_x)${endColour}" && tput cnorm && exit 1
  fi

  find . -maxdepth 1 -type f -printf '%P\n' | grep -v "^temp.txt" | sponge temp.txt
  limit_file=$(wc -l < temp.txt)

  tput cnorm && echo -en "\n${yellowColour}[?]${endColour} Tipo de archivo ${turquoiseColour}(ej: pdf, png, jpg)${endColour}:" && read file_type && tput civis && echo -e "\n"

  echo -e "\t${turquoiseColour}[+]${endColour} Límite detectado: ${purpleColour}$limit_file${endColour}\n"

  for ((i=1; i<=limit_file; i++)); do
    file="$(cat temp.txt | head -n$i | tail -n1)"
    name="$((RANDOM)).$file_type"
    echo -e "\t${purpleColour}[!]${endColour} cambiando nombre del archivo ${blueColour}$file${endColour} por ${greenColour}$name ${endColour}"
  done

  tput cnorm && echo -en "\n${redColour}[?]${endColour} Desea continuar? ${turquoiseColour}[s]/n${endColour}:" && read var && tput civis && echo -e "\n"

  if [ "$var" == "s" ]; then
    for ((i=1; i<=limit_file; i++)); do
      file="$(cat temp.txt | head -n$i | tail -n1)"
      name="$((RANDOM)).$file_type"
      mv -- "$file" "$name"
    done
    rm temp.txt
    echo -e "${turquoiseColour}\t[+]${endColour} Nombres cambiados ${blueColour}o.O)/${endColour}" && tput cnorm
  elif [ "$var" == "n" ]; then
    echo -e "${redColour}\t[+]${endColour} Usted no continua... ${blueColour}(u.u)/${endColour}" && tput cnorm
  else
    echo -e "${redColour}\t[!] Error: presione las teclas indicadas x_x)${endColour}" && tput cnorm && exit 2
  fi
}


function ordenar_nombre(){
  name="$1"
  echo -en "\n${yellowColour}[?]${endColour} En qué directorio están los ficheros que se van a ordenar? ${purpleColour}(escribir directorio completo)${endColour}" && read dir
  tput civis

  if [ -d "$dir" ]; then
    cd $dir 2>/dev/null
    command_status=$?
    echo -e "\n\t${turquoiseColour}[+]${endColour} Accediendo al directorio ${purpleColour}$dir${endColour}"
    if [ ! $command_status -eq 0 ]; then
      echo -e "\t${redColour}[!] Error: No se tienen los permisos necesarios para acceder al directorio ${purpleColour}$dir${endColour}" && tput cnorm && exit 1
    fi
  else
    echo -e "\n\t${redColour}[!] Error: Ingrese un directorio x_x)${endColour}" && tput cnorm && exit 1
  fi

  find . -maxdepth 1 -type f -printf '%P\n' | grep -v "^temp.txt" | sponge temp.txt
  limit_file=$(wc -l < temp.txt)

  echo -e "\t${turquoiseColour}[+]${endColour} Límite detectado: ${purpleColour}$limit_file${endColour}\n"
  tput cnorm && echo -en "${yellowColour}[?]${endColour} Tipo de archivo ${turquoiseColour}(ej: pdf, png, jpg)${endColour}:" && read file_type && tput civis && echo -e "\n"

  for ((i=1; i<=limit_file; i++)); do
    file="$(cat temp.txt | head -n $i | tail -n 1)"
    echo -e "\t${purpleColour}[!]${endColour} cambiando nombre del archivo ${blueColour}$file${endColour} por ${greenColour}$name$i.$file_type ${endColour}"
  done

  tput cnorm && echo -en "\n${redColour}[?]${endColour} Desea continuar? ${turquoiseColour}[s]/n${endColour}:" && read var && tput civis && echo -e "\n"

  if [ "$var" == "s" ]; then
    for ((i=1; i<=limit_file; i++)); do
      file="$(cat temp.txt | head -n $i | tail -n 1)"
      mv -- "$file" "$name$i.$file_type"
    done
    rm temp.txt
    echo -e "${turquoiseColour}\t[+]${endColour} Nombres cambiados ${blueColour}o.O)/${endColour}" && tput cnorm
  elif [ "$var" == "n" ]; then
    echo -e "${redColour}\t[+]${endColour} Usted no continua... ${blueColour}(u.u)/${endColour}" && tput cnorm
  else
    echo -e "${redColour}\t[!] Error presione las teclas indicadas x_x)${endColour}" && tput cnorm && exit 2
  fi
}

function help_panel(){
  echo -e "\n${blueColour}------------------------------ Panel de Ayuda -------------------------------${endColour}"
  echo -e "${greenColour}[+]${endColour} Uso: Es una herramienta que sirve para ordenar por nombre un conjunto de archivos."
  echo -e "\n\t${purpleColour}[h]${endColour} Mostar este mensaje."
  echo -e "\t${purpleColour}[o] <NOMBRE> ${endColour}Ordena el nombre de los archivos al función de su fecha de creación."
  echo -e "\t${purpleColour}[d] ${endColour}Ordena los nombres en función de números random."
  echo -e "\n\t${redColour}[!] Advertencias y consideraciones...${endColour}"
  echo -e "\t${purpleColour}[-] ${endColour}Esta es una herramienta que usa el comando ${redColour}mv${endColour} y puede sobreescribir archivos mal si no se usa bien."
  echo -e "\t${purpleColour}[-] ${endColour}Esta es una herramienta que usa el comando ${redColour}cd${endColour} puede haber errores si no se tienen los permisos para acceder a un direcotrio."
  echo -e "\t${purpleColour}[-] ${endColour}Puede haber errores si no se tienen los permisos de escritura en el directorio."
  echo -e "\t${purpleColour}[-] ${endColour}Tener los permisos necesarios para poner mover los ficheros con ${redColour}mv${endColour}."
  echo -e "${blueColour}----------------------------------------------------------------------${endColour}"
}

while getopts "o:dh" arg; do
  case $arg in
    o) name="$OPTARG"; let arg_value+=1;;
    d) let arg_value+=2;;
    h) ;;
  esac
done

if [ $arg_value -eq 1 ]; then
  ordenar_nombre $name
elif [ $arg_value -eq 2 ]; then
  desordenar
else
  help_panel
fi
