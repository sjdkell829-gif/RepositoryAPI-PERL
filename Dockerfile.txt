FROM debian:bullseye

# Instalamos Apache y Perl
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl && \
    apt-get clean

# Activamos el módulo CGI
RUN a2enmod cgid

# Borramos la página de bienvenida por defecto de Apache
RUN rm -f /var/www/html/index.html

# Copiamos TU página web y TU API adentro del servidor de internet
COPY ./htdocs/ /var/www/html/
COPY ./cgi-bin/ /usr/lib/cgi-bin/

# Le damos permisos para que la API se pueda ejecutar
RUN chmod +x /usr/lib/cgi-bin/api.pl

# Le decimos a Apache que no se apague
CMD ["apachectl", "-D", "FOREGROUND"]