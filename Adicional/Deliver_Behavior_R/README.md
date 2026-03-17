# Pipeline de Limpieza y Preprocesamiento: Amazon Delivery Dataset

Este proyecto contiene la conversión a R de un pipeline modular de Python para la limpieza y preprocesamiento de un dataset de entregas de Amazon con 43,738 registros y 16 columnas.

# --- Resumen de la Solución ---

El proceso se centró en estandarizar y limpiar el dataset para dejarlo listo para análisis, atendiendo problemas específicos encontrados en los datos crudos: valores categóricos con espacios residuales, strings literales `"NaN "` que no eran NA reales, columnas de tiempo que debían preservar su formato `HH:MM:SS`, y coordenadas geográficas que requerían precisión mínima de 6 decimales.

# Tareas Realizadas:
1. Estandarización de Columnas: Normalización de encabezados a snake_case mediante la librería `janitor`.
2. Limpieza de Categóricas: Eliminación de espacios residuales y conversión a lowercase para evitar categorías duplicadas por diferencias de formato (ej: `"High "` vs `"high"`).
3. Manejo de "NaN" como string literal: `traffic` y `order_time` contenían el string `"NaN "` en lugar de NA real, se trató explícitamente antes de cualquier conversión de tipo.
4. Conversión de Tipos: Fechas convertidas a `Date`, horas a `hms` preservando su valor `HH:MM:SS` sin inventar una fecha base, y columnas categóricas convertidas a `factor`.
5. Manejo de Valores Faltantes: `weather` conserva sus NA como nivel `"unknown"` dentro del factor; `agent_age` se imputa con mediana y `agent_rating` con media; filas sin tiempo o coordenadas geográficas se eliminan al no poder inferirse.
6. Precisión Geográfica: Coordenadas redondeadas a 6 decimales con `round()`, y formateadas con `formatC()` en la exportación para que los ceros a la derecha sean visibles en el archivo sin alterar el valor numérico.
7. Exportación Doble: El dataset limpio se exporta tanto en `.csv` como en `.xlsx`, con las columnas de tiempo convertidas a string para compatibilidad con Excel.

# --- Estructura del Proyecto ---

* `amazon_delivery_pipeline.R`: Script principal con el pipeline completo.
* `amazon_delivery_original.csv`: Dataset original sin modificaciones.
* `dataset_limpio_para_analisis.csv`: Dataset limpio exportado en formato CSV.
* `dataset_limpio_para_analisis.xlsx`: Dataset limpio exportado en formato Excel.

# --- Requisitos e Instalación ---

Para ejecutar este script se requiere tener instalado **R** y las siguientes librerías:

```r
install.packages(c("tidyverse", "lubridate", "janitor", "hms", "writexl"))
```
