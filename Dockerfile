FROM httpd:2.4

# Librerías
RUN apt-get update && apt-get install -y perl libjson-perl libfile-slurp-perl && rm -rf /var/lib/apt/lists/*

# Configuración CGI
RUN sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf
RUN echo "AddHandler cgi-script .pl" >> /usr/local/apache2/conf/httpd.conf
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /usr/local/apache2/conf/httpd.conf

# Copia
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

# PERMISOS TOTALES (Solución al error de guardado)
RUN echo "[]" > /usr/local/apache2/cgi-bin/datos.json
RUN chmod -R 777 /usr/local/apache2/cgi-bin/
RUN chown -R www-data:www-data /usr/local/apache2/cgi-bin/

EXPOSE 80