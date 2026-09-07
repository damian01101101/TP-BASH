#!/bin/bash

BASE="$HOME/EPNro1"
BORRAR_ENTORNO=false
PID_CONSOLIDAR=""

# Verificar parámetro -d
for arg in "$@"; do
    if [ "$arg" = "-d" ]; then
        BORRAR_ENTORNO=true
    fi
done

# Verificar que FILENAME esté definida
if [ -z "$FILENAME" ]; then
    echo "Error: la variable de ambiente FILENAME no está definida."
    echo "Ejemplo:"
    echo "export FILENAME=alumnos"
    exit 1
fi


mostrar_menu() {

    opcion=0

    while [ "$opcion" -ne 7 ]; do

        echo
        echo "=============================================="
        echo "              MENÚ PRINCIPAL"
        echo "=============================================="
        echo "Opción 1) Crear entorno"
        echo "Opción 2) Correr proceso"
        echo "Opción 3) Mostrar alumnos ordenados por padrón"
        echo "Opción 4) Mostrar las 10 notas más altas"
        echo "Opción 5) Buscar alumno por padrón"
        echo "Opción 6) Visualizar log"
        echo "Opción 7) Salir"
        echo "=============================================="
        echo -n "Ingrese una opción: "

        read -r opcion

        case "$opcion" in

            1)
                echo
                echo "Creando entorno..."

                if [ -d "$BASE" ]; then
                    echo "El entorno ya existe en $BASE"
                else
                    mkdir -p "$BASE/entrada"
                    mkdir -p "$BASE/salida"
                    mkdir -p "$BASE/procesado"

                    # Crear archivo de salida vacío
                    touch "$BASE/salida/$FILENAME.txt"

                    # Crear archivo de log
                    touch "$BASE/procesado.log"

                    # Crear consolidar.sh
                    cat > "$BASE/consolidar.sh" << 'EOF'
#!/bin/bash

BASE="$HOME/EPNro1"

while true; do

    for archivo in "$BASE"/entrada/*.txt; do

        # Si no hay archivos .txt, continuar
        [ -e "$archivo" ] || continue

        # Agregar el contenido al archivo de salida
        cat "$archivo" >> "$BASE/salida/$FILENAME.txt"

        # Obtener fecha y hora
        FECHA=$(date '+%d/%m/%Y %H:%M:%S')

        # Registrar el archivo procesado
        echo "$FECHA - Procesado archivo $(basename "$archivo")" >> "$BASE/procesado.log"

        # Mover archivo a procesado
        mv "$archivo" "$BASE/procesado/"

    done

    # Revisar la carpeta entrada periódicamente
    sleep 2

done
EOF

                    chmod +x "$BASE/consolidar.sh"

                    echo "Entorno creado correctamente."
                    echo "Directorio: $BASE"
                fi
                ;;

            2)
                echo

                if [ ! -d "$BASE" ]; then
                    echo "Error: primero debe crear el entorno."
                else
                    # Verificar si ya existe un proceso consolidar.sh
                    if pgrep -f "$BASE/consolidar.sh" > /dev/null; then
                        echo "El proceso consolidar.sh ya está ejecutándose."
                    else
                        echo "Iniciando proceso..."

                        FILENAME="$FILENAME" "$BASE/consolidar.sh" &
                        PID_CONSOLIDAR=$!

                        echo "Proceso iniciado en background."
                        echo "PID: $PID_CONSOLIDAR"
                    fi
                fi
                ;;

            3)
                echo

                ARCHIVO_SALIDA="$BASE/salida/$FILENAME.txt"

                if [ -f "$ARCHIVO_SALIDA" ]; then
                    echo "Listado de alumnos ordenados por número de padrón:"
                    echo

                    sort -n -k 1 "$ARCHIVO_SALIDA"
                else
                    echo "Error: no existe el archivo $ARCHIVO_SALIDA"
                fi
                ;;

            4)
                echo

                ARCHIVO_SALIDA="$BASE/salida/$FILENAME.txt"

                if [ -f "$ARCHIVO_SALIDA" ]; then
                    echo "Las 10 notas más altas:"
                    echo

                    sort -k 4 -nr "$ARCHIVO_SALIDA" | head -n 10
                else
                    echo "Error: no existe el archivo $ARCHIVO_SALIDA"
                fi
                ;;

            5)
                echo

                ARCHIVO_SALIDA="$BASE/salida/$FILENAME.txt"

                if [ -f "$ARCHIVO_SALIDA" ]; then

                    echo -n "Ingrese el número de padrón: "
                    read -r padron

                    resultado=$(awk -v padron="$padron" '$1 == padron' "$ARCHIVO_SALIDA")

                    if [ -n "$resultado" ]; then
                        echo
                        echo "Alumno encontrado:"
                        echo "$resultado"
                    else
                        echo "No se encontró ningún alumno con ese padrón."
                    fi

                else
                    echo "Error: no existe el archivo $ARCHIVO_SALIDA"
                fi
                ;;

            6)
                echo

                if [ -f "$BASE/procesado.log" ]; then
                    echo "Registro de archivos procesados:"
                    echo
                    cat "$BASE/procesado.log"
                else
                    echo "No existe el archivo de log."
                fi
                ;;

            7)
                echo
                echo "Saliendo..."

                # Si se utilizó -d, borrar el entorno
                if [ "$BORRAR_ENTORNO" = true ]; then

                    echo "Se indicó el parámetro -d."

                    # Matar proceso consolidar.sh
                    PIDS=$(pgrep -f "$BASE/consolidar.sh")

                    if [ -n "$PIDS" ]; then
                        echo "Deteniendo proceso consolidar.sh..."

                        for pid in $PIDS; do
                            kill "$pid" 2>/dev/null
                        done
                    fi

                    # Borrar entorno
                    if [ -d "$BASE" ]; then
                        rm -rf "$BASE"
                        echo "Entorno $BASE eliminado."
                    fi

                fi

                echo "Programa finalizado."
                ;;

            *)
                echo
                echo "Opción inválida."
                ;;

        esac

    done
}

mostrar_menu
