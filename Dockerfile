FROM httpd:2.4

# Dependencias para Perl y JSON
RUN apt-get update && apt-get install -y perl libjson-perl libfile-slurp-perl && rm -rf /var/lib/apt/lists/*

# Configuración de Apache para scripts CGI
RUN sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf
RUN echo "AddHandler cgi-script .pl" >> /usr/local/apache2/conf/httpd.conf
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /usr/local/apache2/conf/httpd.conf

# Copiar archivos del proyecto Erick
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

# PERMISOS DE ESCRITURA (Vital para que el POST guarde datos)
RUN touch /usr/local/apache2/cgi-bin/datos.json
RUN chmod 777 /usr/local/apache2/cgi-bin/datos.json
RUN chmod 777 /usr/local/apache2/cgi-bin/
RUN chmod +x /usr/local/apache2/cgi-bin/api.pl

EXPOSE 80