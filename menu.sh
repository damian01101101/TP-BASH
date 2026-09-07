#!/bin/bash

BASE="$HOME/EPNro1"
BORRAR_ENTORNO=false

# Procesar parámetros
for arg in "$@"; do
    if [ "$arg" == "-d" ]; then
        BORRAR_ENTORNO=true
    else
        FILENAME="$arg"
    fi
done

# Verificar que se haya pasado un archivo
if [ -z "$FILENAME" ]; then
    echo "Error: debe pasar el nombre del archivo como parámetro"
    echo "Uso: ./menu.sh <nombre_archivo> [-d]"
    exit 1
fi


mostrar_menu() {

    opcion=0

    while [ "$opcion" -ne 7 ]; do

        echo
        echo "Elige una opción"
        echo "opción 1) crear entorno"
        echo "opción 2) correr proceso"
        echo "opción 3) mostrar por pantalla el listado de alumnos ordenados por número de padrón"
        echo "opción 4) mostrar por pantalla las 10 notas más altas"
        echo "opción 5) buscar alumno por padrón"
        echo "opción 6) visualizar log"
        echo "opción 7) salir"

        read -r opcion

        case "$opcion" in

            1)
                echo "Creando entorno..."

                if [ -d "$BASE" ]; then
                    echo "El entorno ya existe en $BASE"
                else
                    mkdir -p "$BASE/entrada" "$BASE/salida" "$BASE/procesado"

                    # Crear consolidar.sh
                    cat > "$BASE/consolidar.sh" << 'EOF'
#!/bin/bash

BASE="$HOME/EPNro1"

for archivo in "$BASE"/entrada/*.txt; do

    [ -e "$archivo" ] || continue

    cat "$archivo" >> "$BASE/salida/filename.txt"

    FECHA=$(date '+%d/%m/%Y %H:%M:%S')

    echo "$FECHA - Procesado archivo $archivo" >> "$BASE/procesado.log"

    mv "$archivo" "$BASE/procesado/"

done
EOF

                    chmod +x "$BASE/consolidar.sh"

                    if [ $? -eq 0 ]; then
                        echo "Entorno creado correctamente"
                    else
                        echo "Error al crear entorno"
                    fi
                fi
                ;;

            2)
                if [ ! -d "$BASE" ]; then
                    echo "Error: primero debe crear el entorno"
                else
                    echo "Corriendo proceso..."

                    # Copiar el archivo indicado al directorio de entrada
                    if [ -f "$FILENAME" ]; then
                        cp "$FILENAME" "$BASE/entrada/"
                    elif [ -f "$BASE/entrada/$FILENAME" ]; then
                        echo "El archivo ya se encuentra en la entrada"
                    else
                        echo "Error: no se encuentra el archivo $FILENAME"
                        break
                    fi

                    # Ejecutar consolidar.sh
                    "$BASE/consolidar.sh" &

                    echo "Proceso iniciado"
                fi
                ;;

            3)
                if [ -f "$BASE/salida/filename.txt" ]; then
                    sort -n -k 1 "$BASE/salida/filename.txt"
                else
                    echo "Archivo no encontrado"
                fi
                ;;

            4)
                if [ -f "$BASE/salida/filename.txt" ]; then
                    echo "Top 10 notas más altas"

                    sort -rn -k 2 "$BASE/salida/filename.txt" | head -n 10
                else
                    echo "Archivo no encontrado"
                fi
                ;;

            5)
                echo "Ingrese número de padrón del alumno a consultar:"
                read -r padron

                if [ -f "$BASE/salida/filename.txt" ]; then
                    awk -F ',' -v padron="$padron" '$4 == padron' \
                        "$BASE/salida/filename.txt"
                else
                    echo "Archivo no encontrado"
                fi
                ;;

            6)
                echo "Cargando registro..."

                if [ -f "$BASE/procesado.log" ]; then
                    cat "$BASE/procesado.log"
                else
                    echo "No existe el archivo de log"
                fi
                ;;

            7)
                echo "Saliendo..."

                if [ "$BORRAR_ENTORNO" = true ]; then
                    if [ -d "$BASE" ]; then
                        rm -rf "$BASE"
                        echo "Entorno borrado"
                    fi
                fi

                echo "Programa finalizado"
                ;;

            *)
                echo "Opción inválida"
                ;;

        esac

    done
}

mostrar_menu
