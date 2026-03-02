FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

RUN a2enmod cgid
RUN rm -f /var/www/html/index.html

# Forzamos la copia de archivos al directorio raíz de Apache
COPY index.html /var/www/html/index.html
COPY swagger.html /var/www/html/swagger.html
COPY swagger.json /var/www/html/swagger.json

# Asegúrate de que tu carpeta en GitHub se llame cgi-bin
COPY cgi-bin/ /usr/lib/cgi-bin/

RUN chmod +x /usr/lib/cgi-bin/api.pl
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# Configuramos Apache para que reconozca index.html como página principal
RUN echo "DirectoryIndex index.html" >> /etc/apache2/apache2.conf

CMD ["apachectl", "-D", "FOREGROUND"]