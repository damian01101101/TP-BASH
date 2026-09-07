#!/bin/bash

BASE="$HOME/EPNro1"
BORRAR_ENTORNO=false

for arg in "$@"; do
	if [ "$arg" == "-d" ]; then
		BORRAR_ENTORNO=true
	else
		FILENAME="$arg"
	fi
done

if [ -z "$FILENAME" ]; then
    echo "Error: debe pasar el nombre del archivo como parámetro"
    echo "Uso: ./menu.sh <nombre_archivo> [-d]"
    exit 1
fi


mostrar_menu(){	
   	 opcion=0
   	 while [ $opcion -ne 7 ]; do
    		echo -e "Elige una opcion\nopcion 1) crear entorno\nopcion 2) correr proceso\nopcion 3) mostrar por pantalla el listado de alumnos ordenados por número de padrón.\nopcion 4) mostrar por pantalla las 10 notas mas altas\nopcion 5) buscar alumno por padron\nopcion 6) visualizar log\nopcion 7) salir"
    		read opcion
       		case $opcion in
			1)      
				echo "creando entorno..."

			  	if [ -d "$BASE" ]; then
                                    echo "El entorno ya existe en $BASE"
                                else
                                    mkdir -p "$BASE/entrada" "$BASE/salida" "$BASE/procesado"
		  		    echo -e "#!/bin/bash\n txt='entrada/*.txt'\n archivo=$1\n for $archivo in txt;\n do\n   cat $archivo >> 'salida\filename.txt'\n FECHA=$(date + "%d/%m/%Y %H:%M:%S")\n echo "$FECHA - Procesado archivo $archivo" >> EPNro1/procesado.log\n mv $archivo '~/EPNro1/procesado/'\n done" >> "~/EPNro1/consolidar.sh"
					if [ $? -eq 0 ]; then
						echo "Entorno creado"
					else
						echo "Error al crear entorno"
					fi
				fi
				;;

			2)
		  		if [ ! -d "~/EPNro1" ]; then
           		 		echo "error: entorno necesario"
		 	 	else
			   		echo "corriendo proceso.."
					chmod -x "~/EPNro1/consolidar.sh"
					"~/EPNro1/consolidar.sh" &
					FILENAME="$FILENAME" "$BASE/consolidar.sh" &
		 		fi
				;;
			3) 
				if [ -f  "EPNro1/salida/filename.txt" ]; then
					sort -n -k 1 "EPNro1/salida/filename.txt"
				else 
					echo "archivo no encontrado"
				fi
				;;
			4)
				if [ -f "EPNro1/salida/filename.txt" ]; then
					echo "Top 10 notas más altas"
					sort -rn -k 2 "EPNro1/salida/filename.txt" | head -n 10
				else
					echo "no file found"
				fi
				;;
			5)
				echo "ingrese numero de padron del alumno a consultar"
				padron=0
				read padron
				awk -F ',' "$4 == $padron" "EPNro1/salida/filename.txt" 
				;;
			6)
				echo "cargando registro..."
				cat "EPNro1/procesado.log"
				;;
			7)
				echo "saliendo..."
				if [ -d "$BASE" ]; then

					rm -rf "$BASE"
					echo "Entorno borrado
				;;

			esac
	 done
}

mostrar_menu
