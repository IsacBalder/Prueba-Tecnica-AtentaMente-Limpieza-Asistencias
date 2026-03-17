# ================================================================
# Pipeline de limpieza y preprocesamiento: Amazon Delivery Dataset
#
# ================================================================
# Actividad: Estandarizar columnas, limpiar categoricas, convertir tipos,
# manejar valores faltantes y exportar el dataset limpio.
#
# NOTAS IMPORTANTES sobre decisiones de limpieza:
#   - Las horas (order_time, pickup_time) se leen como texto y se
#     convierten con hms() para no perder su valor real
#   - Traffic contiene "NaN " como string literal, no como NA, se
#     trata explicitamente antes de convertir a factor
#   - Las longitudes/latitudes se redondean a minimo 6 decimales sin
#     alterar el valor, usando formatC solo en la exportacion
# ================================================================

# --- REQUISITOS -------------------------------------------------------------
# Si no se cuentan con las librerias instaladas, corre las siguientes instrucciones:
# install.packages("tidyverse")
# install.packages("lubridate")
# install.packages("janitor")
# install.packages("hms")
# install.packages("writexl")

# --- CARGAR LIBRERIAS -------------------------------------------------------
library(tidyverse)
library(lubridate)
library(janitor)
library(hms)
library(writexl)

# --- CONFIGURACION ----------------------------------------------------------
DATASET_PATH  <- "data/amazon_delivery_original.csv"
OUTPUT_CSV    <- "output/dataset_limpio_para_analisis.csv"
OUTPUT_XLSX   <- "output/dataset_limpio_para_analisis.xlsx"

# --- CARGAR DATOS -----------------------------------------------------------
print("cargando dataset...")
df_raw <- read_csv(DATASET_PATH, col_types = cols(
    Order_Time  = col_character(), # se leen como texto para preservar HH:MM:SS
    Pickup_Time = col_character(), # misma razon que Order_Time
    Order_Date  = col_character(),
    .default    = col_guess()
  )
)
print("dataset cargado exitosamente")

# --- ESTANDARIZAR NOMBRES DE COLUMNAS ---------------------------------------
df <- df_raw %>% clean_names()

# --- LIMPIEZA DE CATEGORICAS ------------------------------------------------
# Se limpian espacios y se transforma a lowercase para evitar categorias duplicadas
# por diferencias de casing o espacios residuales (ej: "High " vs "high")
cols_categoricas <- c("weather", "traffic", "vehicle", "area", "category")

df <- df %>% mutate(across(all_of(cols_categoricas), ~ str_to_lower(str_trim(.x))))

# El valor "nan" en traffic es un string literal, se reemplaza por NA real
df <- df %>% mutate(traffic = na_if(traffic, "nan"))

# --- CONVERSION DE TIPOS ----------------------------------------------------

# Order_date se convierte a Date desde su formato YYYY-MM-DD
# Order_time y pickup_time se convierten con as_hms() del paquete hms, que acepta
# strings en formato "HH:MM:SS" directamente. Order_time contiene 91 filas con
# "NaN " como string literal (igual que traffic), se reemplazan por NA antes
# de la conversion para que as_hms() no falle
df <- df %>% mutate(
    order_date  = as.Date(order_date, format = "%Y-%m-%d"),
    order_time  = as_hms(na_if(str_trim(order_time), "NaN")),
    pickup_time = as_hms(pickup_time)
  )

# --- CONVERSION A FACTORES --------------------------------------------------
df <- df %>% mutate(across(all_of(cols_categoricas), as.factor))

# --- MANEJO DE VALORES FALTANTES --------------------------------------------
# Weather: se agrega "unknown" como nivel del factor para los NA
# Agent_age y agent_rating: imputacion con mediana y media respectivamente
# Se eliminan filas con NA en delivery_time, order_time, pickup_time y coordenadas
df <- df %>% mutate(
    weather = fct_explicit_na(weather, na_level = "unknown"),
    agent_age = if_else(is.na(agent_age), as.integer(median(agent_age, na.rm = TRUE)), agent_age),
    agent_rating = if_else(is.na(agent_rating), mean(agent_rating, na.rm = TRUE), agent_rating)
  ) %>%
  drop_na(delivery_time, order_time, pickup_time) %>%
  drop_na(store_latitude, store_longitude, drop_latitude, drop_longitude)

# --- AJUSTE DE PRECISION EN COORDENADAS -------------------------------------
# Se asegura que todas las coordenadas tengan exactamente 6 cifras decimales.
# round() garantiza el valor correcto; los ceros a la derecha se agregan en
# la exportacion con format() para que queden en el CSV sin alterar el numero.
cols_coords <- c("store_latitude", "store_longitude", "drop_latitude", "drop_longitude")

df <- df %>% mutate(across(all_of(cols_coords), ~ round(.x, 6)))

# --- EXPORTACION ------------------------------------------------------------
# Se formatea el dataframe antes de exportar para que las coordenadas
# aparezcan siempre con 6 decimales visibles (ej: 77.678400).
# Para el xlsx las columnas hms se convierten a string porque Excel
# no tiene un tipo nativo equivalente y las mostraria como numero entero.
print("guardando dataset limpio...")

df_export <- df %>% mutate(
    across(all_of(cols_coords), ~ formatC(.x, format = "f", digits = 6)),
    order_time  = as.character(order_time),
    pickup_time = as.character(pickup_time)
  )

write_csv(df_export, OUTPUT_CSV)
write_xlsx(df_export, OUTPUT_XLSX)
print(paste("csv guardado en:", OUTPUT_CSV))
print(paste("xlsx guardado en:", OUTPUT_XLSX))

# --- SECCION DE VERIFICACION ------------------------------------------------
# Descomentar para inspeccionar el resultado antes de exportar
# glimpse(df)
# summary(df)
# levels(df$weather)
# levels(df$traffic)
# head(df %>% select(all_of(cols_coords)))
# sum(is.na(df))