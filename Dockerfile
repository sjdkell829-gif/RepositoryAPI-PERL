# 1. Usamos una imagen estable de Debian
FROM debian:bullseye

# 2. Instalamos Apache, Perl y las librerías para manejar JSON y CGI
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

# 3. ACTIVAR MÓDULOS CRÍTICOS
# cgid: Para ejecutar Perl
# headers: Para permitir PATCH y evitar errores de CORS si pruebas desde fuera
RUN a2enmod cgid
RUN a2enmod headers

# 4. CONFIGURAR APACHE PARA PERMITIR TODO
# Esto evita el error "Not Found" y permite que el PATCH funcione
RUN echo "<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    DirectoryIndex index.html\n\
</Directory>" > /etc/apache2/conf-available/custom-access.conf && \
    a2enconf custom-access

# 5. LIMPIAR Y COPIAR ARCHIVOS
RUN rm -rf /var/www/html/*

# Copiamos la interfaz y la documentación a la raíz
COPY index.html /var/www/html/index.html
COPY swagger.html /var/www/html/swagger.html
COPY swagger.json /var/www/html/swagger.json

# Copiamos los scripts de Perl y la base de datos a cgi-bin
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# 6. PERMISOS DE SEGURIDAD Y ESCRITURA
# Permiso de ejecución para el script
RUN chmod +x /usr/lib/cgi-bin/api.pl
# Permiso total a la carpeta cgi-bin para que Perl pueda escribir archivos
RUN chmod 777 /usr/lib/cgi-bin
# Permiso de lectura/escritura para la base de datos JSON
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# 7. EXPONER PUERTO Y LANZAR
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]