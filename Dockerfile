FROM debian:bullseye

# Instalamos Apache y Perl
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl && \
    apt-get clean

# Activamos el motor CGI
RUN a2enmod cgid

# Borramos la basura de Apache
RUN rm -f /var/www/html/index.html

# Copiamos los archivos a sus puestos
COPY index.html /var/www/html/
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# PERMISOS CRÍTICOS:
# Ejecución para la API
RUN chmod +x /usr/lib/cgi-bin/api.pl
# Escritura total a la CARPETA y al archivo para permitir el guardado
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

CMD ["apachectl", "-D", "FOREGROUND"]