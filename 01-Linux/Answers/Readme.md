# Laboratorio 1 -Linux

## Punto 1

El comando ```grep``` es empleado para realizar búsquedas de texto. Este busca en un archivo o directiorio específico las líneas que contienen un match para una palabra o frase determinada. [Referencia](https://www.cyberciti.biz/faq/howto-use-grep-command-in-linux-unix/)

## Punto 2

La linea ```#!/bin/bash``` al comienzo de los scripts le permite saber al shell con qué programa debería interpretar el script al ejecutarlo. 

[Referencia](https://stackoverflow.com/questions/13872048/bash-script-what-does-bin-bash-mean)

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

El siguiente comando permite obtener una tabla con usuarios y shells organizados por shell. El archivo /etc/passwd contiene los usuarios y los shells en las columnas 1 y 7. Luego se cambia el separador ":" por espacios entre usuarios y shells para obtener una lista con dos columnas. Finalmente se organiza la lista con respecto a la columna 2 que corresponde a los shells.    

```bash
cut -f 1,7 -d: /etc/passwd | tr ":" " " |sort -k 2 
```
El resultado es el siguiente:

![punto 4](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_4.png?raw=true)

[Referencia](https://unix.stackexchange.com/questions/144705/use-cut-to-extract-a-list-from-etc-passwd

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

## Punto 6

Luego de descargar la base de datos bsds500, se copió el directorio a la terminal y después a la máquina usando las lineas:

```bash
   scp "/drives/C/Users/Camila/Downloads/BSR_bsds500.tgz" .
   scp ./BSR_bsds500.tgz camilalaura@157.253.63.53:~
```
Posteriormente se descomprimió con ```tar```:

```bash
   tar -xf BSR_bsds500.tgz 
``` 

## Punto 7

Para encontrar el disk size del dataset se emplea el comando ```du -sh``` el cual informa el espacio que determinado file ocupa. ```-s``` se usa para obtener solo un resultado resumido y ```-h```da el resultado de forma legible (human readable).El disk size fue de 71M.  [Referencia](https://unix.stackexchange.com/questions/185764/how-do-i-get-the-size-of-a-directory-on-the-command-line)

![punto7](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_7.png?raw=true)

Para encontrar el número de imagenes hay en el directorio primero se listan todos los archivos con ```ls -Rl```, después se seleccionan únicamente los archivos terminados en .jpg con ```grep```. Por último, se cuentan la cantidad de archivos con ```wc -l```

```bash
   ls -Rl ~/BSR/BSDS500/data/images/ | grep  jpg | wc -l  
   ```
![punto7](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_7_1.png?raw=true)

## Punto 8

Estando en el directorio con las  imágenes, se ejecutó lo siguiente para guardar las rutas de las mismas en una variable. 

```bash
   rutas=`ls -d -1 $PWD/*.*`
```

Luego se emplea un ciclo para obtener la resolución y el formato de las imágenes por medio de  ```identify```  

```bash
for im in $rutas; do identify $im; done    
```
El resultado obtenido muestra que el formato de las imágenes es jpeg y que su resolución es de 481x321 o 321x481 dependiendo del archivo.

![punto8](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_8.png?raw=true)

[Referencia](https://stackoverflow.com/questions/246215/how-can-i-list-files-with-their-absolute-path-in-linux)

## Punto 9

Para encontrar la cantidad de imágenes que se encuentran en cada orientación primero se encuentra una lista de todas las imágenes disponibles. Después, en un ciclo se identifica cada imagen por medio de ```identify``` y con ```%[fx:(h>w)]```se evalúa si la altura de la imagen es mayor al ancho. De ser cierto, la imagen se encuentra en orientación portrait, de lo contrario se encuentra en landscape. 

```bash
   #! /bin/bash
por=0 
lan=0 

for f in ./BSR/BSDS500/data/images/*/*.jpg 

do 

  r=$(identify -format '%[fx:(h>w)]' "$f") 

  if [[ r -eq 1 ]] 

  then 

        por=$((por+1)) 

  else 

        lan=$((lan+1)) 

fi 

done 

  

echo hay  "$por" imagenes en orientacion portrait 

echo hay "$lan" imagenes en orientacion landscape 
 ```
El resultado fue

![punto9](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_9_1.png?raw=true)

[Referencia](https://unix.stackexchange.com/questions/294341/shell-script-to-separate-and-move-landscape-and-portrait-images)

## Punto 10

Para cortar las imágenes de manera que su nuevo tamaño fuera de 256x256, se empleó el script:

```bash
#! /bin/bash

rm -r cropped 2>/dev/null

mkdir cropped

cp ./BSR/BSDS500/data/images/*/*.jpg cropped

cd ./cropped

rutas=`ls -Rl | awk '{ print $9}'`

for im in $rutas

        do

        convert  -crop 256x256+0+0 $im $im

done

 ```
Primero se elimina el directorio cropped en caso de que ya exista y luego se crea con ```mkdir```. Se copian todos los archivos .jpg en la nueva carpeta y se obtienen sus rutas. Finalmente se cortan todas las imágenes para que queden de la dimensión deseada desde el centro de la imágen. 
  
