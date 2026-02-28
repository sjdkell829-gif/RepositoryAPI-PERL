FROM debian:bullseye

# 1. Instalamos Apache y Perl
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl && \
    apt-get clean

# 2. Activamos el motor para la API
RUN a2enmod cgid

# 3. Borramos la página de bienvenida de Debian
RUN rm -f /var/www/html/index.html

# 4. Copiamos tus archivos
COPY index.html /var/www/html/
COPY ./cgi-bin/api.pl /usr/lib/cgi-bin/
COPY ./cgi-bin/datos.json /usr/lib/cgi-bin/

# 5. PERMISOS (Aquí está el truco)
# Damos permiso de ejecución a la API
RUN chmod +x /usr/lib/cgi-bin/api.pl
# Damos permiso de ESCRITURA al archivo de datos para que Apache pueda guardar
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# Le decimos a Apache que no se apague
CMD ["apachectl", "-D", "FOREGROUND"]