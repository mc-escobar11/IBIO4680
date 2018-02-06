# Laboratorio 1 -Linux

## Punto 1

## Punto 2

## Punto 3

El archivo ```etc/passwd``` contiene la información de todos los usuarios del sistema. En este caso queremos saber cuantos login users existen.
Primero, se debe identificar el user ID a partir del cual los usuarios son considerados login users:

 ```bash
   l=$(grep "^UID_MIN" /etc/login.defs) 
   ```

Ahora, se extrae del file solamente los login users, es decir los users cuyo UID sea mayor a l,  y se ejecuta wc -l para contar las líneas que corresponden cada una a un usuario

```bash
   awk -F':' -v "limit=${l##UID_MIN}" '{ if ( $3 >= limit ) print $1}' /etc/passwd | wc -l
   ```
El resultado es 11 login users en el server

![punto 3](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_3.png?raw=true)

[Referencia](https://unix.stackexchange.com/questions/144705/use-cut-to-extract-a-list-from-etc-passwd ) 

## Punto 4

## Punto 5

Para encontrar el duplicado de una imagen se debe obtener su ```hash```, este es una serie de números y letras que se le asigna a información electrónica y generalmente se usa como la "huella digital" de un archivo.[Referencia](https://percipient.co/computer-files-hash-value/)

En el script mostrado a continuación se buscan todos los archivos por medio de ```find```, luego se encuentra el has value de cada uno por medio de ```md5sum```, se organizan en orden alfabético por medio de ```sort```y por último se identifica si las primeras 32 letras (las cuales corresponden al hash) de dos líneas son iguales por medio de ```uniq```. De ser iguales, el nombre de los archivos y su hash se mostrarán en pantalla. 

```bash
   #! /bin/bash
   find ./BSR/BSDS500/data/images/* -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate
   ```
Para probar el script, se creó una copia de una imagen en la carpeta ```BSR/BSDS500/data/images/test```y el resultado se observa a continuación

![punto5](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_5_1.png?raw=true)

[Referencia](https://superuser.com/questions/487810/find-all-duplicate-files-by-md5-hash)
