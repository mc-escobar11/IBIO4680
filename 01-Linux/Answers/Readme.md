## Laboratorio 1 -Linux

# Punto 1

# Punto 2

# Punto 3

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

![punto 3](https://github.com/mc-escobar11/IBIO4680/blob/master/01-Linux/Answers/images/images/p_10.png?raw=true)

