#!/bin/bash

# --------------- colores -----------------
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# --------------- ctrl_c ------------------
trap ctrl_c INT
function ctrl_c(){
  echo -e "\n\n${redColour}[!] saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# ----------------- function ----------------
function helpPanel(){
  echo -e "\n${redColour}[>]${endColour} ${yellowColour}------------ Panel de ayuda -------------${endColour}\n"
  echo -e "\t${purpleColour}-m)${endColour} Ingresa la m seguido de la cantidad de dinero con la que se va a jugar."
  echo -e "\t${purpleColour}-t)${endColour} Ingresa la técnica que se usará durante el juego."
  echo -e "\t${redColour}[!]${endColour} ${grayColour}Se requiere de ambos parámetros, no funciona con una tecnica default.${endColour}"
  echo -e "\t${redColour}[!]${endColour} ${grayColour}Lista de tecnicas validas${endColour} ${greenColour}o.O)_/${endColour}${blueColour}[martingala/inverseLabrouchere]${endColour}"
  echo -e "\n${redColour}[<]${endColour} ${yellowColour}-----------------------------------------${endColour}\n"
}

function martingala(){
  echo -e "\n${redColour}[+]${endColour} Dinero inicial: ${yellowColour}${money}${endColour}."
  echo -en "${redColour}[+]${endColour} ¿Cuánto dinero deseas apostar? ${purpleColour}-> ${endColour}" && read apuesta_inicial
  if [ ${apuesta_inicial} -gt ${money} ];then
    echo -e "\n\t${redColour}[!] Error:${endColour} No puedes apostar mas de lo que tienes ${greenColour}(ó-ò)${endColour}\n"
    exit 0
  fi

  echo -en "${redColour}[+]${endColour} ¿A cuál valor apuestas ${purpleColour}(par/impar)${endColour}? ${greenColour}o.O)/${endColour} " && read valor_apuesta
  if [ "${valor_apuesta}" != "par" ] && [ "${valor_apuesta}" != "impar" ];then
    echo -e "\n${redColour}[!] Error${endColour} ingresa un valor válido ${purpleColour}[par/impar]${endColour} ${greenColour}(x_x)/${endColour}\n"
    exit 0
  fi
  tput civis #ocultar cursor
  temp_belt=$apuesta_inicial
  jugadas_malas=""
  contador=0
  while [ $money -gt 0 ]; do
    random_number="$(($RANDOM % 37))"
    money=$((${money}-${apuesta_inicial}))
    if [ "${valor_apuesta}" == "par" ];then
      contador=$(($contador+1))
      if [ $random_number -eq 0 ];then
#        echo -e "\n[-] El numero es el 0, perdemos."
        apuesta_inicial=$(($apuesta_inicial*2))
        jugadas_malas="$jugadas_malas$random_number "
#        echo -e "Ahora mismo tienes ${money}."
      elif [ $((${random_number} % 2)) -eq 0 ];then
#        echo -e "\n[+] En hora buena, el numero ${random_number} es par."
        recompensa=$(($apuesta_inicial*2))
        money=$(($money+$recompensa))
#        echo -e "Ganaste ${recompensa}$ tienes ${money}$"
        apuesta_inicial=$temp_belt
        jugadas_malas=""
      else
#        echo -e "\n[-] El numero ${random_number} es impar, perdemos."
        apuesta_inicial=$(($apuesta_inicial*2))
        jugadas_malas="${jugadas_malas}${random_number} "
#        echo -e "Ahora mismo tienes ${money}."
      fi

    elif [ "${valor_apuesta}" == "impar" ]; then
      contador=$(($contador+1))
      if [ $random_number -eq 0 ];then
        apuesta_inicial=$(($apuesta_inicial*2))
#        echo -e "\n${redColour}[-]${endColour} El numero es el ${purpleColour}0${endColour}, perdemos."
#        echo -e "Ahora tienes ${redColour}$money${endColour}."
        jugadas_malas="${jugadas_malas}${random_number} "
      elif [ $((${random_number} % 2)) -eq 0 ];then
        apuesta_inicial=$(($apuesta_inicial*2))
#        echo -e "\n${redColour}[-]${endColour} El numero ${purpleColour}${random_number}${endColour} es par, perdemos."
#        echo -e "Ahora tienes ${redColour}$money${endColour}."
        jugadas_malas="${jugadas_malas}${random_number} "
      else
        recompensa=$(($apuesta_inicial*2))
        money=$(($money+$recompensa))
#        echo -e "\n${yellowColour}[+]${endColour} El numero es ${purpleColour}impar${endColour}"
#        echo -e "Ahora tienes ${yellowColour}${money}${endColour}"
        apuesta_inicial=$temp_belt
        jugadas_malas=""
      fi
    fi
#    sleep 1
  done
  echo -e "\n\t${redColour}[!] GAME OVER TE QUEDASTE SIN DINERO${endColour} ${greenColour}(X_X)${endColour}\n"
  echo -e "${redColour}[+]${endColour} Jugadas totales ${greenColour}(o.O)/! ${endColour}${purpleColour}-->${endColour} ${endColour}${yellowColour}${contador}${endColour}"
  echo -e "${redColour}[+]${endColour} A continuación tu peor racha ${greenColour}(ú.ù)/${endColour}"
  echo -e "${yellowColour}[ ${endColour}${purpleColour}${jugadas_malas}${endColour}${yellowColour}]${endColour}\n"
  tput cnorm #recuperar cursor
}

function inverseLabrouchere(){
  echo -e "\n${redColour}[+]${endColour} Empiezas con la técnica inverseLabrouchere y ${yellowColor}$money\$${endColour}."
  echo -en "${redColour}[+]${endColour} ¿A cuál deseas apostar(par/impar)? ${purpleColour}-->${endColour} " && read par_impar
  if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ];then
    echo -e "\n${redColour}[!]${endColour} Error apuesta a valores válidos ${greenColour}\(ò.ó)/${endColour}\n"
    exit 0
  fi

  declare -a myArray=(1 2 3 4)
  apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
  echo -e "\n${redColour}[+]${endColour} apuesta_inicial ${greenColour}(o.O)/${endColour} ${purpleColour}-->${endColour} ${yellowColour}${apuesta_inicial}${endColour}\n"
  contador=0
  limite_meta=$(($money+50))
  chivato_meta=$limite_meta #declaramos las variables al inicio para evitar problemas en el if
  boolean=" " #No es una booleana es un string pero le di valores de string para controlar las metas de Labrouchere


  while [ $money -gt 0 ]; do
    tput civis #ocultar el cursor
    let contador+=1
    random_number=$(($RANDOM % 37))

    if [ $money -gt $limite_meta ]; then #Efectual
      myArray=(1 2 3 4)
      echo -e "${greenColour}[+]${endColour} Limite meta superado, el array se ha reiniciado a ${purpleColour}[ ${myArray[@]} ]${endColour}"
      chivato_meta=$limite_meta # meta antes de ser reestablecida
      let limite_meta+=50
      boolean="True" # Huella de que en algún momento superamos la meta
      echo -e "${greenColour}[+]${endColour} Ahora el límite es ${purpleColour}$limite_meta${endColour}\n"
    fi

    if [ ${money} -lt ${chivato_meta} ] && [ "${boolean}" == "True" ]; then
      limite_meta=$chivato_meta # La meta vuelve a ser la anterior
      boolean="False" # La huella cambiará cuando volvamos a superar la meta
      echo -e "${redColour}[!]${endColour} Parece que haz tenido una mala racha ahora la meta para reiniciar el array es ${purpleColour}$limite_meta\$${endColour}\n"
    fi

    let money-=$apuesta_inicial

    if [ "$par_impar" == "par" ]; then
      if [ $random_number -eq 0 ]; then
        echo -e "${redColour}[-]${endColour} El numero salió $random_number. ${redColour}Perdemos${endColour}"
        unset myArray[0]
        unset myArray[-1] 2> /dev/null
        myArray=(${myArray[@]})
        echo -e "${redColour}[!]${endColour} Ahora te sobran: ${redColour}$money\$${endColour}"
        echo -e "${redColour}[!]${endColour} El array actual es: ${purpleColour}[ ${myArray[@]} ]${endColour}"
        if [ ${#myArray[@]} -ne 1 ] && [ ${#myArray[@]} -ne 0 ]; then
          apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        elif [ ${#myArray[@]} -eq 1 ]; then
          apuesta_inicial=${myArray[0]}
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        else
          myArray=(1 2 3 4)
          apuesta_inicial=5
          echo -e "${redColour}[!]${endColour} Array reiniciado: ${purpleColour}[ ${myArray[@]} ]${endColour}"
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        fi
        myArray=(${myArray[@]})
      elif [ $(($random_number % 2)) -eq 0 ]; then
        echo -e "${yellowColour}[+]${endColour} El número $random_number es par. Ganamos"
        reward=$(($apuesta_inicial*2))
        let money+=$reward
        echo -e "${yellowColour}[+]${endColour} Ahora tienes ${yellowColour}$money\$${endColour}"
        myArray+=(${apuesta_inicial})
        apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
        echo -e "${yellowColour}[!]${endColour} Array actual ${greenColour}o.O)/${endColour} ${purpleColour}[ ${myArray[@]} ]${endColour}"
        echo -e "${yellowColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        if [ ${#myArray[@]} -eq 1 ]; then
          apuesta_inicial=${myArray[0]}
        fi
      else
        echo -e "${redColour}[-]${endColour} El número $random_number es impar. ${redColour}Perdemos${endColour}"
        echo -e "${redColour}[-]${endColour} Ahora tenemos ${redColour}$money\$${redColour}"
        unset myArray[0]
        unset myArray[-1] 2>/dev/null
        myArray=(${myArray[@]})
        echo -e "${redColour}[!]${endColour} El array actual es: ${purpleColour}[ ${myArray[@]} ]${endColour}"
        if [ ${#myArray[@]} -ne 1 ] && [ ${#myArray[@]} -ne 0 ]; then
          apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        elif [ ${#myArray[@]} -eq 1 ]; then
          apuesta_inicial=${myArray[0]}
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        else
          myArray=(1 2 3 4)
          apuesta_inicial=5
          echo -e "${redColour}[!]${endColour} Array reiniciado: ${purpleColour}[ ${myArray[@]} ]${endColour}"
          echo -e "${redColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n"
        fi
      fi

    elif [ "$par_impar" == "impar" ]; then
      if [ $random_number -eq 0 ]; then
        echo -e "${redColour}[+]${endColour} El numero salió ${purpleColour}$random_number${endColour}. ${redColour}Perdemos${endColour}"
        echo -e "${redColour}[-]${endColour} Ahora tenemos ${redColour}$money\$${endColour}"
        unset myArray[0] 2>/dev/null
        unset myArray[-1] 2>/dev/null
        myArray=(${myArray[@]})
        echo -e "${redColour}[+]${endColour} Array actual: ${purpleColour}[ ${myArray[@]} ]${endColour}"
        if [ ${#myArray[@]} -eq 0 ]; then
          myArray=(1 2 3 4)
          apuesta_inicial=5
          echo -e "${purpleColour}[+]${endColour} Array reiniciado a ${purpleColour}[ ${myArray[@]} ]${endColour}"
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}5\$${endColour}\n"
        elif [ ${#myArray[@]} -eq 1 ]; then
          apuesta_inicial=${myArray[0]}
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}$apuesta_inicial\$${endColour}\n"
        else
          apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}$apuesta_inicial${endColour}\n"
        fi
      elif [ $(($random_number % 2)) -ne 0 ]; then
        echo -e "${yellowColour}[+]${endColour} El número ${purpleColour}$random_number${endColour} es impar. ${yellowColour}Ganamos${endColour}"
        myArray+=($apuesta_inicial)
        reward=$(($apuesta_inicial*2))
        let money+=$reward
        apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
        echo -e "${yellowColour}[+]${endColour} Ahora tenemos ${yellowColour}$money\$${endColour}"
        echo -e "${yellowColour}[+]${endColour} Array incrementado: ${purpleColour}[ ${myArray[@]} ]${endColour}"
        echo -e "${yellowColour}[+]${endColour} apostamos ${purpleColour}$apuesta_inicial\$${endColour}\n" 
      else
        echo -e "${redColour}[+]${endColour} El número ${purpleColour}$random_number${endColour} es par. ${redColour}Perdemos${endColour}"
        echo -e "${redColour}[-]${endColour} Ahora tenemos ${redColour}$money\$${endColour}"
        unset myArray[-1] 2>/dev/null
        unset myArray[0]
        myArray=(${myArray[@]})
        echo -e "${redColour}[+]${endColour} Array actual: ${purpleColour}[ ${myArray[@]} ]${endColour}"
        if [ ${#myArray[@]} -eq 0 ]; then
          myArray=(1 2 3 4)
          apuesta_inicial=5
          echo -e "${purpleColour}[+]${endColour} Array reiniciado a ${purpleColour}[ ${myArray[@]} ]${endColour}"
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}5\$${endColour}\n"
        elif [ ${#myArray[@]} -eq 1 ]; then
          apuesta_inicial=${myArray[0]}
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}$apuesta_inicial\$${endColour}\n"
        else
          apuesta_inicial=$((${myArray[0]}+${myArray[-1]}))
          echo -e "${redColour}[-]${endColour} Apostamos ${redColour}$apuesta_inicial\$${endColour}\n"
        fi
      fi
    fi
#    sleep 1
    tput cnorm #volver a mostrar el cursor
  done
  echo -e "\n\t${redColour}[x] GAME OVER se te ha acabado el dinero${endColour} ${greenColour}(x_X)/${endColour}"
  echo -e "\tjugadas totales ${greenColour}(o.O)/${endColour} ${purpleColour}-->${endColour} ${yellowColour}$contador${endColour}\n"
}

# -------------- principal ---------------
while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) technique="$OPTARG";;
    h);;
  esac
done

if [ $money ] && [ "$technique" ]; then
  if [ "$technique" == "martingala" ]; then
    martingala money
  elif [ "$technique" == "inverseLabrouchere" ];then
    inverseLabrouchere money
  else
    echo -e "\n${redColour}[!] Error${endColour} agrega un metodo que sea válido ${greenColour}ú.ù)/${endColour}${purpleColour}(martingala)${endColour}\n"
  fi
else 
  helpPanel
fi


