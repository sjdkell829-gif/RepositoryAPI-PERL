FROM debian:bullseye

RUN apt-get update && apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && apt-get clean
RUN a2enmod cgid headers

# Limpiar y copiar
RUN rm -rf /var/www/html/*
COPY index.html /var/www/html/index.html
COPY swagger.html /var/www/html/swagger.html
COPY swagger.json /var/www/html/swagger.json
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# Permisos
RUN chmod +x /usr/lib/cgi-bin/api.pl
RUN chmod -R 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# Configuración Apache
RUN echo "DirectoryIndex index.html" >> /etc/apache2/apache2.conf

CMD ["apachectl", "-D", "FOREGROUND"]