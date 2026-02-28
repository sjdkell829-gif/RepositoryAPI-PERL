FROM debian:bullseye

# Instalación de Apache, Perl y soporte para JSON
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

# Activación del motor para ejecutar la API
RUN a2enmod cgid
RUN rm -f /var/www/html/index.html

# Transferencia de archivos al servidor
COPY index.html /var/www/html/
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# Configuración de permisos de ejecución y escritura
RUN chmod +x /usr/lib/cgi-bin/api.pl
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

CMD ["apachectl", "-D", "FOREGROUND"]