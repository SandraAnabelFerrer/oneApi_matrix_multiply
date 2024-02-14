
#!/bin/bash
#==========================================
# Script para enviar trabajos a través de qsub
#==========================================

# Dar permisos de ejecución al script
chmod +x $0

# Definir el nombre del script que quieres ejecutar
SCRIPT_NAME="oneapi_matrix_multiply.cpp"

# Verificar si el archivo del script existe
if [ ! -f "$SCRIPT_NAME" ]; then
    echo "El archivo $SCRIPT_NAME no existe."
    exit 1
fi

# Generar un nombre único para el archivo de salida
OUTPUT_FILE="output_matrix_$(date +"%Y%m%d_%H%M%S").txt"

# Ajustar el comando qsub para pasar argumentos al script
qsub -l nodes=1:gpu:ppn=2 -d ./$SCRIPT_NAME -o $OUTPUT_FILE
