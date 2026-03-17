# ================================================================
# Evaluación Técnica: Analista de Datos - AtentaMente
# Candidato: Isac Alejandro Balderas Sánchez
# Fecha limite: 17-Marzo-2026
# ================================================================
# Actividad: Consolidación de 4 bases mediante llave única (email) 
# para limpieza de duplicados y cálculo de asistencias.
#
# Resultado esperado: un archivo con el registro de asistencias
# por sesion con los datos limpios y agrupados, y un archivo 
# que muestre al personal con el menor desempeno de asistencias
# ================================================================

# --- REQUISITOS ---
# Si no se cuentan con las librerias instaladas, corre las siguientes instrucciones:
# install.packages("tidyverse")
# install.packages("readxl")
# install.packages("janitor")
# install.packages("stringi")
# install.packages("writexl")

# --- CARGAR LIBRERIAS -----------------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(readxl)   
library(janitor)  
library(stringi)   
library(skimr)
library(writexl)

# --- CARGAR LOS DATOS DEL ARCHIVO XLSX A UN DATAFRAME ---------------------------------------------------------------------------------------
ruta_carpeta <- "data/"
archivo_excel <- list.files(path = ruta_carpeta, pattern = "\\.xlsx$", full.names = TRUE)
archivo_a_cargar <- archivo_excel[1]
df_raw <- read_excel(archivo_a_cargar)

# --- NORMALIZADO EN NOMBRES DE COLUMNAS -----------------------------------------------------------------------------------------------------

df_col_normalizado <- df_raw %>% clean_names() #Se uso la funcion clean_names de la libreria janitor para normalizar los titulos de columnas 
colnames(df_col_normalizado) #Muestra los nombres de las columnas con los cambios aplicados

# --- LIMPIEZA Y NORMALIZACION EN NOMBRE Y CORREO --------------------------------------------------------------------------------------------
#El correo sera usado como identificador unico para fines de identificar que nombres se encuentran duplicados en dos o mas fuentes

df_normalizado <- df_col_normalizado %>% mutate(
  
    #limpiar el correo de espacios y transformar a lowercase en una nueva columna
    correo_limpio = email %>% str_to_lower() %>% stri_trans_general("Latin-ASCII") %>% str_replace_all(" ",""),
    
    #Limpiar los nombres y apellidos de acentos, espacios y transformar a lowercase en una nueva columna
    nombre_norm = stri_trans_general(nombre, "Latin-ASCII") %>% str_to_lower() %>%  str_squish(),
    primer_apellido_norm= stri_trans_general(primer_apellido,"Latin-ASCII") %>% str_to_lower()%>% str_squish(),
    segundo_apellido_norm=stri_trans_general(segundo_apellido,"Latin-ASCII") %>% str_to_lower() %>% str_squish()
    )




# --- ANALISIS DE INCONSISTENCIAS EN RELACION NOMBRE A CORREO ------------------------------------------------------------------------------
inconsistencias <- df_normalizado %>% group_by(correo_limpio) %>% summarise(
    cuantos_nombres = n_distinct(nombre_norm),
    nombres_detectados = paste(unique(nombre_norm), collapse = " | ")) %>% filter(cuantos_nombres > 1) %>% arrange(desc(cuantos_nombres))
#Se puede saber la cantidad de nombres asociados a un mismo correo con la siguiente vista, de manera que entendamos la situacion de los datos


# --- UNIFICACION DE NOMBRES Y DETERMINAR LA ASISTENCIA A LAS SESIONES A PARTIR DEL CORREO Y LOS DIAS MARCADOS CON ASISTENCIA MEDIANTE ACROSS----
df_entregable <- df_normalizado %>% group_by(correo_limpio) %>% summarise(
  
    #Se unen las columnas de nombre, primer apellido y segundo apellido previamente normalizadas y limpias, aplicando el formato title
    nombre_completo = paste(first(nombre_norm),first(primer_apellido_norm), first(segundo_apellido_norm)) %>% str_to_title() %>% str_squish(),
    
    #Se usa across para recorrer y modificar las 5 columnas de asistencia aplicando la siguiente regla usando un if
    #Si la suma de las columnas por cada registro que coincida con un correo es > 0, ponemos 1, de lo contrario 0.
    across(starts_with("asistencia_ses"), ~ if_else(sum(.x, na.rm = TRUE) > 0, 1, 0)),
    #Se aplana el contenido del dataframe
    .groups = "drop" 
  ) %>% 
  #Se calcula el totalde asistencias por persona para medir su desempeño
  mutate(total_asistencias = rowSums(select(., starts_with("asistencia_ses"))))
View(df_entregable)


# --- IDENTIFICACIÓN DE MENOR DESEMPEÑO ---
# Filtramos a los participantes que tengan un numero minimo de asistencias
personal_con_bajo_desempeno <- df_entregable %>% filter(total_asistencias == min(total_asistencias)) %>% select(nombre_completo, correo_limpio, total_asistencias)

# Imprimimos el resultado para saber que personas tuvieron el menor desempeno
View(personal_con_bajo_desempeno)

# --- EXPORTACION DE LOS RESULTADOS DESEADOS EN FORMATO XLSX ---------------------------------------------------------------------------------------

#Se creara la carpeta output si no existe previamente 
if(!dir.exists("output")) dir.create("output")
#Se exportan la lista de personal con la limpieza aplicada y la lista de menor desempeno
write_xlsx(df_entregable, "output/Participantes_Consolidados.xlsx")
write_xlsx(personal_con_bajo_desempeno, "output/Reporte_Bajo_Desempeno.xlsx")

# ------------------------------- SECCION DE PRUEBAS Y ANALISIS EXPLORATORIO -----------------------------------------------------------------------
#Esta seccion se uso para fines de comprobar y corroborar la integridad de los datos, el funcionamiento de las diferentes funciones y visualizar los
#cambios realizados al dataframe
#head(df_raw)
#glimpse(df_raw)
#colnames(df_col_normalizado) #Muestra los nombres de las columnas con los cambios aplicados
#View(inconsistencias)
#View(df_normalizado)
#View(duplicados <- df_entregable %>% get_dupes(nombre_completo))

