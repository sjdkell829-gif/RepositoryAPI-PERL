# 1. Usamos una imagen base de Linux liviana
FROM debian:bullseye

# 2. Instalamos Apache, Perl y la librería JSON necesaria para la API
# Es vital instalar libjson-perl para que el script no de error 500
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

# 3. Activamos el módulo CGI de Apache para que ejecute archivos .pl
RUN a2enmod cgid

# 4. Eliminamos el archivo por defecto de Apache
RUN rm -f /var/www/html/index.html

# 5. Copiamos los archivos del Frontend (Interfaz y Swagger)
# Estos archivos van a la ruta pública del servidor
COPY index.html /var/www/html/
COPY swagger.html /var/www/html/
COPY swagger.json /var/www/html/

# 6. Copiamos la carpeta del Backend (API y base de datos JSON)
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# 7. CONFIGURACIÓN DE PERMISOS (Crucial para el funcionamiento)
# Damos permiso de ejecución al script de Perl
RUN chmod +x /usr/lib/cgi-bin/api.pl

# Damos permisos de escritura a la carpeta y al archivo JSON 
# Esto permite que las funciones de Editar, Eliminar y Registrar guarden cambios
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# 8. Iniciamos el servidor Apache en primer plano
CMD ["apachectl", "-D", "FOREGROUND"]