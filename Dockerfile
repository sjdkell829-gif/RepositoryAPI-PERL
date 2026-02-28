FROM debian:bullseye

# Instalamos Apache y Perl
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl && \
    apt-get clean

# Activamos el módulo para que lea tu archivo api.pl
RUN a2enmod cgid

# Le decimos a Apache que no se apague
CMD ["apachectl", "-D", "FOREGROUND"]