Práctica final RA1: Salón recreativo

1. Stack y Tecnologías

Servidor Web: Apache.

SGBD: MariaDB.

Intérprete: PHP.

Servidor: En el backend se ejecutan los contenedores Docker que alojan Apache, PHP y MariaDB. El código PHP procesa funciones como la hora del servidor.

Cliente: En el navegador web del usuario se procesa el frontend, incluyendo la ejecución de JavaScript para mostrar la hora del navegador.



2. Diagrama de Arquitectura

graph LR
 N[Navegador] -->|8080| W[Apache + PHP]
 W -->|red Docker| B[(MariaDB)]



3. Comandos de Despliegue

Construir y levantar servicios: docker compose up -d --build

Detener servicios manteniendo la persistencia: docker compose down

Detener servicios y eliminar los datos: docker compose down -v



4. Respuestas a Niveles 1 y 2

1.2 Contraseña de root en el servicio web: El servicio web recibe únicamente las variables que necesita la aplicación por el principio de mínimo privilegio. Si la web sufriera una vulnerabilidad, el atacante no obtendría control administrativo total sobre el SGBD.

1.3 Permisos de la base de datos y usuario root:

MariaDB [arcade]> SHOW GRANTS;
+--------------------------------------------------------------------------------------------------------+
| Grants for jugador@%                                                                                   |
+--------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `jugador`@`%` IDENTIFIED BY PASSWORD '*25191BA4E6DA0D23829FB51E56726069C4BED650' |
| GRANT ALL PRIVILEGES ON `arcade`.* TO `jugador`@`%`                                                    |
+--------------------------------------------------------------------------------------------------------+
2 rows in set (0.001 sec)


El usuario jugador tiene todos los privilegios circunscritos exclusivamente a la base de datos arcade. No usamos root desde la aplicación para que, en caso de fallo de seguridad, el alcance del ataque quede contenido únicamente en los datos de este juego.

1.4 Persistencia: Al usar docker compose down, el volumen nombrado se mantiene intacto, por lo que los datos persisten al volver a levantar el contenedor. Al añadir la bandera -v, se elimina el volumen asociado, dejando la base de datos completamente vacía.

2.3 Desfase horario: PHP se ejecuta en el backend y JS en el cliente. Las horas pueden no coincidir si el contenedor Docker (servidor) tiene una zona horaria distinta a la máquina física local (navegador).



5. Comprobaciones de Seguridad (Nivel 3)

Sin credenciales en el repositorio: Ejecutado git ls-files verificando que no se lista el archivo .env. Confirmado con git log -p | grep -F "<contraseña>" que no se han filtrado claves en el historial.

Puerto 3306 aislado: Comprobado mediante docker compose ps que el puerto de la base de datos no está publicado en el host.

Usuario sin privilegios: La aplicación conecta correctamente utilizando jugador, descartando el uso de root.

Ocultación de cabeceras: Se comprobó con curl -I http://localhost:8080 que no se revela el número de versión de Apache ni de PHP (gracias a directivas como ServerTokens, ServerSignature y expose_php) inyectadas vía Dockerfile.



6. Monedas Conseguidas

1º MONEDA: |  9 | MONEDA-1: ARC-7X3K | secreto        |      0 |

2º MONEDA: 🪙 MONEDA 2: ARC-Q9M2

3º MONEDA: En persona



7. Problemas que me encontré y cómo los resolví

Problema: Al intentar aplicar los cambios hechos en el Dockerfile (como la instalación de la extensión mysqli o las configuraciones de seguridad), ejecutaba docker compose up -d pero veía que los cambios no surtían efecto en los contenedores.

Solución: Me di cuenta de que Docker estaba reutilizando la imagen anterior construida en caché. Para obligar a Docker a leer nuevamente el Dockerfile y reconstruir la imagen con los nuevos cambios, era necesario añadir la bandera --build. Lo resolví ejecutando el comando completo: docker compose up -d --build.