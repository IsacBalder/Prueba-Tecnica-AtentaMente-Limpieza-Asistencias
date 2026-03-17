# Evaluación Técnica: Analista de Datos - AtentaMente

Este proyecto contiene la resolución de la evaluación técnica propuesta para la posición de Analista de Datos. El objetivo del codigo es realizar la limpieza, normalización y consolidación de una base de datos de asistencia proveniente de cuatro fuentes distintas.

# --- Resumen de la Solución ----

El proceso se centró en asegurar la integridad de los datos mediante la utilizacion de una llave única la cual para se escogio el correo electrónico, permitiendo unificar registros de participantes que aparecían con variaciones en sus nombres o errores de captura (acentos, espacios internos y formatos de texto).

# Tareas Realizadas:
1. Normalización de Columnas: Estandarización de encabezados mediante la librería "anitor".
2. Limpieza de Texto: Eliminación de acentos, caracteres especiales y espacios innecesarios en nombres y correos electrónicos.
3. Consolidación de Identidad: Unificación de registros duplicados utilizando el correo electrónico como identificador único.
4. Lógica de Asistencia: Aplicación de una lógica de consolidación horizontal (si el participante asistió en cualquiera de las 4 bases, se marca como asistencia confirmada).
5. Análisis de Desempeño: Identificación automatizada de los participantes con el menor número de asistencias registradas.

# --- Estructura del Proyecto ---

* `scripts/data_cleaning.R`: Script principal con comentarios detallados de cada paso.
* `data/`: Contiene la base de datos original.
* `output/`: Archivos finales generados (Consolidado y Reporte de Bajo Desempeño).
* `Adicional/`: Carpeta con proyectos complementarios de análisis estadístico/visualización.

# --- Requisitos e Instalación ---

Para ejecutar este script, se requiere tener instalado **R** y las siguientes librerías:

```r
# Ejecutar en la consola de R si no se tienen los paquetes:
install.packages(c("tidyverse", "readxl", "janitor", "stringi", "writexl"))