FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl libjson-perl && \
    apt-get clean

RUN a2enmod cgid
RUN rm -f /var/www/html/index.html

# Copia explícita de archivos para evitar el 404
COPY index.html /var/www/html/index.html
COPY swagger.html /var/www/html/swagger.html
COPY swagger.json /var/www/html/swagger.json
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# Permisos críticos
RUN chmod +x /usr/lib/cgi-bin/api.pl
RUN chmod 777 /usr/lib/cgi-bin
RUN chmod 666 /usr/lib/cgi-bin/datos.json

# Asegura que index.html sea lo primero que cargue
RUN echo "DirectoryIndex index.html" >> /etc/apache2/apache2.conf

CMD ["apachectl", "-D", "FOREGROUND"]