FROM debian:bullseye

# 1. Instalamos Apache, Perl y la librería JSON (VITAL para evitar el error 500)
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

# 2. Activamos el motor CGI para que Apache entienda archivos .pl
RUN a2enmod cgid

# 3. Limpiamos la página por defecto de Debian
RUN rm -f /var/www/html/index.html

# 4. Copiamos tus archivos a sus carpetas reales en Linux
COPY index.html /var/www/html/
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# 5. PERMISOS TOTALES (Para que no falle el guardado)
RUN chmod +x /usr/lib/cgi-bin/api.pl
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

CMD ["apachectl", "-D", "FOREGROUND"]