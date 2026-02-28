FROM debian:bullseye

# 1. Instalamos Apache y Perl
RUN apt-get update && \
    apt-get install -y apache2 perl libcgi-pm-perl && \
    apt-get clean

# 2. Activamos el motor para la API
RUN a2enmod cgid

# 3. Borramos la página de bienvenida de Debian (la que te salió hace rato)
RUN rm -f /var/www/html/index.html

# 4. Copiamos tus archivos (Docker los buscará en la raíz de tu GitHub)
# No importa si están en carpetas, Docker intentará encontrarlos así:
COPY index.html /var/www/html/
COPY api.pl /usr/lib/cgi-bin/
COPY datos.json /usr/lib/cgi-bin/

# 5. Permisos de ejecución para tu API de anime
RUN chmod +x /usr/lib/cgi-bin/api.pl

CMD ["apachectl", "-D", "FOREGROUND"]